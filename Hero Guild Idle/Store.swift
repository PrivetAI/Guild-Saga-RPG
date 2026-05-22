import Foundation
import SwiftUI

// MARK: - Quest completion summary (for offline-progress popup)

struct HGQuestResult: Identifiable {
    let id = UUID()
    let questName: String
    let gold: Int
    let xp: Int
    let tokens: Int
    let loot: HGItem?
    let heroNames: [String]
}

// MARK: - Store (Codable + UserDefaults under hgi.*)

final class HeroGuildStore: ObservableObject {
    private let saveKey = "hgi.save.v1"
    private let settingsKey = "hgi.settings.v1"
    private let achievementsKey = "hgi.achievements.v1"
    private let onboardingKey = "hgi.onboarding.v1"

    @Published private(set) var save: HGSave
    @Published var settings: HGSettings
    @Published private(set) var unlocked: Set<String>
    @Published var lastUnlocked: [String] = []
    @Published var onboardingDone: Bool

    // Live clock tick — drives countdowns. Updated by a Timer.
    @Published var now: Date = Date()

    // Pending offline-completion results, surfaced as a popup on launch.
    @Published var pendingResults: [HGQuestResult] = []

    private var timer: Timer?
    private var lastSaveTime: Date = .distantPast

    // For deterministic loot/reward seeds across launches.
    private var rewardCounter: UInt64 = 0

    init() {
        let d = UserDefaults.standard

        if let data = d.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode(HGSave.self, from: data) {
            save = decoded
        } else {
            save = HGSave()
        }

        if let data = d.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(HGSettings.self, from: data) {
            settings = decoded
        } else {
            settings = HGSettings()
        }

        if let data = d.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            unlocked = decoded
        } else {
            unlocked = []
        }

        onboardingDone = d.bool(forKey: onboardingKey)

        // First-run bootstrapping.
        bootstrapIfNeeded()

        // Complete any quests finished while closed (offline progression).
        completeFinishedQuests(surface: true)

        evaluateAchievements()
        startTimer()
    }

    deinit { timer?.invalidate() }

    // MARK: - Bootstrap

    private func bootstrapIfNeeded() {
        // Ensure every building has a level (>=1).
        for kind in HGBuildingKind.allCases {
            if save.buildingLevels[kind.rawValue] == nil {
                save.buildingLevels[kind.rawValue] = 1
            }
        }
        // Ensure quest slots match the board level.
        syncQuestSlots()
        // Ensure a recruit pool exists.
        if save.recruitPool.isEmpty {
            regenerateRecruitPool()
        }
        // Give a starter hero on a truly fresh save.
        if save.heroes.isEmpty && save.stats.heroesRecruited == 0 {
            let starter = HGHero(defId: "hero_aldric", level: 1)
            save.heroes.append(starter)
            save.stats.heroesRecruited += 1
        }
        persistSave()
    }

    private func syncQuestSlots() {
        let boardLevel = buildingLevel(.questBoard)
        let target = HGContent.questSlotCount(boardLevel: boardLevel)
        if save.slots.count < target {
            for i in save.slots.count..<target {
                save.slots.append(HGQuestSlot(id: i))
            }
        }
        // Fix ids to be stable indices.
        for i in 0..<save.slots.count { save.slots[i].id = i }
    }

    // MARK: - Timer / clock

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.now = Date()
            self.completeFinishedQuests(surface: false)
        }
        if let t = timer { RunLoop.main.add(t, forMode: .common) }
    }

    /// Called when the app returns to the foreground.
    func refreshFromClock() {
        now = Date()
        completeFinishedQuests(surface: true)
    }

    // MARK: - Resource accessors

    var gold: Int { save.gold }
    var tokens: Int { save.tokens }
    var renown: Int { save.renown }
    var heroes: [HGHero] { save.heroes }
    var inventory: [HGItem] { save.inventory }
    var slots: [HGQuestSlot] { save.slots }
    var recruitPool: [String] { save.recruitPool }
    var stats: HGStats { save.stats }

    func buildingLevel(_ kind: HGBuildingKind) -> Int {
        save.buildingLevels[kind.rawValue] ?? 1
    }

    /// Permanent renown bonus to gold & loot (as a multiplier).
    var renownMultiplier: Double { 1.0 + Double(save.renown) * 0.02 }

    func hero(byId id: String) -> HGHero? { save.heroes.first(where: { $0.id == id }) }

    var totalPower: Int { save.heroes.reduce(0) { $0 + $1.power } }

    var highestSingleHeroPower: Int { save.heroes.map { $0.power }.max() ?? 0 }

    // MARK: - Quest mechanics

    /// Combined power of the heroes assigned to a slot (live, including equipment).
    func combinedPower(forSlot slot: HGQuestSlot) -> Int {
        slot.assignedHeroIds.compactMap { hero(byId: $0)?.power }.reduce(0, +)
    }

    func combinedPower(ofHeroIds ids: [String]) -> Int {
        ids.compactMap { hero(byId: $0)?.power }.reduce(0, +)
    }

    /// IDs of heroes that are currently busy on an active quest.
    var busyHeroIds: Set<String> {
        var s = Set<String>()
        for slot in save.slots where slot.isActive {
            for id in slot.assignedHeroIds { s.insert(id) }
        }
        return s
    }

    /// Effective duration for a quest given the assigned power. Overshoot reduces time (down to 60%).
    func effectiveDuration(quest: HGQuestDef, power: Int) -> Int {
        guard quest.requiredPower > 0 else { return quest.durationSeconds }
        let ratio = Double(power) / Double(quest.requiredPower)
        // ratio 1.0 -> full time; ratio 2.0+ -> 60% time.
        let speed = min(0.40, max(0.0, (ratio - 1.0) * 0.40))
        let factor = 1.0 - speed
        return max(30, Int(Double(quest.durationSeconds) * factor))
    }

    /// Loot quality boost factor for overshoot (returns extra forge-equivalent levels).
    private func overshootLootBoost(quest: HGQuestDef, power: Int) -> Int {
        guard quest.requiredPower > 0 else { return 0 }
        let ratio = Double(power) / Double(quest.requiredPower)
        if ratio >= 2.5 { return 3 }
        if ratio >= 1.8 { return 2 }
        if ratio >= 1.3 { return 1 }
        return 0
    }

    /// Start a quest in `slotIndex` with the given hero ids. Returns true on success.
    @discardableResult
    func startQuest(slotIndex: Int, questId: String, heroIds: [String]) -> Bool {
        guard slotIndex >= 0, slotIndex < save.slots.count else { return false }
        guard let quest = HGContent.questDef(questId) else { return false }
        guard !save.slots[slotIndex].isActive else { return false }
        guard !heroIds.isEmpty, heroIds.count <= quest.maxHeroes else { return false }
        // Heroes must be free and exist.
        let busy = busyHeroIds
        for id in heroIds {
            if busy.contains(id) || hero(byId: id) == nil { return false }
        }
        let power = combinedPower(ofHeroIds: heroIds)
        guard power >= quest.requiredPower else { return false }

        let dur = effectiveDuration(quest: quest, power: power)
        let start = Date()
        save.slots[slotIndex].questDefId = questId
        save.slots[slotIndex].assignedHeroIds = heroIds
        save.slots[slotIndex].startDate = start
        save.slots[slotIndex].endDate = start.addingTimeInterval(TimeInterval(dur))
        persistSave()
        return true
    }

    /// Cancel an active quest (no rewards). Frees the heroes.
    func cancelQuest(slotIndex: Int) {
        guard slotIndex >= 0, slotIndex < save.slots.count else { return }
        save.slots[slotIndex].questDefId = nil
        save.slots[slotIndex].assignedHeroIds = []
        save.slots[slotIndex].startDate = nil
        save.slots[slotIndex].endDate = nil
        persistSave()
    }

    func progress(forSlot slot: HGQuestSlot, at date: Date) -> Double {
        guard let start = slot.startDate, let end = slot.endDate else { return 0 }
        let total = end.timeIntervalSince(start)
        guard total > 0 else { return 1 }
        let elapsed = date.timeIntervalSince(start)
        return min(1.0, max(0.0, elapsed / total))
    }

    func remaining(forSlot slot: HGQuestSlot, at date: Date) -> TimeInterval {
        guard let end = slot.endDate else { return 0 }
        return max(0, end.timeIntervalSince(date))
    }

    /// Idempotent: completes any active quest whose end date has passed, granting rewards.
    /// Because we clear the slot atomically when granting, repeated launches never double-grant.
    private func completeFinishedQuests(surface: Bool) {
        let nowDate = Date()
        var changed = false
        var newResults: [HGQuestResult] = []

        for i in 0..<save.slots.count {
            let slot = save.slots[i]
            guard slot.isActive, let end = slot.endDate, end <= nowDate,
                  let questId = slot.questDefId, let quest = HGContent.questDef(questId) else { continue }

            let result = grantQuestRewards(quest: quest, heroIds: slot.assignedHeroIds, slotIndex: i)
            newResults.append(result)

            // Clear the slot atomically — this is what makes completion idempotent.
            save.slots[i].questDefId = nil
            save.slots[i].assignedHeroIds = []
            save.slots[i].startDate = nil
            save.slots[i].endDate = nil
            changed = true
        }

        if changed {
            evaluateAchievements()
            persistSave()
        }
        if surface && !newResults.isEmpty {
            pendingResults.append(contentsOf: newResults)
        }
    }

    private func nextRewardSeed() -> UInt64 {
        rewardCounter &+= 1
        let base = UInt64(bitPattern: Int64(Date().timeIntervalSince1970 * 1000))
        return HGSplitMix64.mix(base &+ rewardCounter &* 0x9E3779B97F4A7C15)
    }

    private func grantQuestRewards(quest: HGQuestDef, heroIds: [String], slotIndex: Int) -> HGQuestResult {
        let power = combinedPower(ofHeroIds: heroIds)
        let goldMult = HGContent.goldMultiplier(treasuryLevel: buildingLevel(.treasury)) * renownMultiplier
        let xpMult = HGContent.xpMultiplier(trainingLevel: buildingLevel(.trainingHall))

        let gold = Int((Double(quest.goldReward) * goldMult).rounded())
        let xpEach = Int((Double(quest.xpReward) * xpMult).rounded())
        let tokens = quest.tokenReward

        save.gold += gold
        save.tokens += tokens
        save.stats.goldEarned += gold
        save.stats.questsCompleted += 1

        // Grant XP to each assigned hero and level them.
        var heroNames: [String] = []
        for id in heroIds {
            if let idx = save.heroes.firstIndex(where: { $0.id == id }) {
                heroNames.append(save.heroes[idx].def.name)
                addXP(toHeroIndex: idx, amount: xpEach)
            }
        }

        // Loot roll.
        let forgeLevel = buildingLevel(.forge) + overshootLootBoost(quest: quest, power: power)
        let loot = HGContent.rollLoot(seed: nextRewardSeed(), floor: quest.lootRarityFloor, forgeLevel: forgeLevel)
        save.inventory.append(loot)
        save.stats.lootCollected += 1
        if loot.rarity == .legendary { save.stats.legendaryLoot += 1 }

        save.stats.highestPower = max(save.stats.highestPower, totalPower)

        return HGQuestResult(questName: quest.name, gold: gold, xp: xpEach, tokens: tokens, loot: loot, heroNames: heroNames)
    }

    private func addXP(toHeroIndex idx: Int, amount: Int) {
        guard idx >= 0, idx < save.heroes.count else { return }
        save.heroes[idx].xp += amount
        // Level up while enough XP.
        var safety = 0
        while save.heroes[idx].xp >= save.heroes[idx].xpForNext && safety < 500 {
            save.heroes[idx].xp -= save.heroes[idx].xpForNext
            save.heroes[idx].level += 1
            safety += 1
        }
    }

    // MARK: - Recruiting

    func regenerateRecruitPool() {
        save.recruitPoolSeed = HGSplitMix64.mix(save.recruitPoolSeed &+ UInt64(save.recruitsTaken) &+ 1)
        let pool = HGContent.generateRecruitPool(seed: save.recruitPoolSeed, count: 6, tavernLevel: buildingLevel(.tavern))
        save.recruitPool = pool
        persistSave()
    }

    /// Cost in gold to refresh the recruit pool.
    var refreshCost: Int {
        Int((45.0 * HGContent.tavernCostMultiplier(tavernLevel: buildingLevel(.tavern))).rounded())
    }

    @discardableResult
    func refreshRecruitPool() -> Bool {
        let cost = refreshCost
        guard save.gold >= cost else { return false }
        save.gold -= cost
        regenerateRecruitPool()
        return true
    }

    func recruitGoldCost(_ defId: String) -> Int {
        let def = HGContent.heroDef(defId)
        return Int((Double(def.goldCost) * HGContent.tavernCostMultiplier(tavernLevel: buildingLevel(.tavern))).rounded())
    }

    func recruitTokenCost(_ defId: String) -> Int {
        HGContent.heroDef(defId).tokenCost
    }

    func canRecruit(_ defId: String) -> Bool {
        let def = HGContent.heroDef(defId)
        if def.tokenCost > 0 {
            return save.tokens >= def.tokenCost
        }
        return save.gold >= recruitGoldCost(defId)
    }

    /// Recruit a hero from the pool at `poolIndex`. Returns true on success.
    @discardableResult
    func recruit(poolIndex: Int) -> Bool {
        guard poolIndex >= 0, poolIndex < save.recruitPool.count else { return false }
        let defId = save.recruitPool[poolIndex]
        let def = HGContent.heroDef(defId)
        if def.tokenCost > 0 {
            guard save.tokens >= def.tokenCost else { return false }
            save.tokens -= def.tokenCost
        } else {
            let cost = recruitGoldCost(defId)
            guard save.gold >= cost else { return false }
            save.gold -= cost
        }
        let newHero = HGHero(defId: defId, level: 1)
        save.heroes.append(newHero)
        save.stats.heroesRecruited += 1
        if def.rarity == .legendary { save.stats.legendaryHeroes += 1 }
        save.stats.highestPower = max(save.stats.highestPower, totalPower)
        // Remove from pool so it can't be recruited twice.
        save.recruitPool.remove(at: poolIndex)
        evaluateAchievements()
        persistSave()
        return true
    }

    // MARK: - Inventory / equipment

    func equip(item: HGItem, toHeroId heroId: String) {
        guard let idx = save.heroes.firstIndex(where: { $0.id == heroId }) else { return }
        guard let invIdx = save.inventory.firstIndex(where: { $0.id == item.id }) else { return }
        let slotKey = item.slot.rawValue
        // Unequip any existing item in that slot back to inventory.
        if let existing = save.heroes[idx].equipped[slotKey] {
            save.inventory.append(existing)
        }
        save.heroes[idx].equipped[slotKey] = item
        save.inventory.remove(at: invIdx)
        save.stats.highestPower = max(save.stats.highestPower, totalPower)
        evaluateAchievements()
        persistSave()
    }

    func unequip(slot: HGSlot, fromHeroId heroId: String) {
        guard let idx = save.heroes.firstIndex(where: { $0.id == heroId }) else { return }
        if let item = save.heroes[idx].equipped[slot.rawValue] {
            save.inventory.append(item)
            save.heroes[idx].equipped[slot.rawValue] = nil
            persistSave()
        }
    }

    func sell(item: HGItem) {
        guard let invIdx = save.inventory.firstIndex(where: { $0.id == item.id }) else { return }
        save.gold += item.sellValue
        save.stats.goldEarned += item.sellValue
        save.inventory.remove(at: invIdx)
        persistSave()
    }

    func sellAllOfRarityOrLower(_ rarity: HGRarity) {
        let toSell = save.inventory.filter { $0.rarity <= rarity }
        var total = 0
        for item in toSell { total += item.sellValue }
        save.inventory.removeAll { $0.rarity <= rarity }
        save.gold += total
        save.stats.goldEarned += total
        persistSave()
    }

    // MARK: - Buildings

    func canUpgrade(_ kind: HGBuildingKind) -> Bool {
        let lv = buildingLevel(kind)
        guard lv < kind.maxLevel else { return false }
        return save.gold >= HGContent.buildingUpgradeCost(kind, targetLevel: lv + 1)
    }

    func upgradeCost(_ kind: HGBuildingKind) -> Int {
        let lv = buildingLevel(kind)
        guard lv < kind.maxLevel else { return 0 }
        return HGContent.buildingUpgradeCost(kind, targetLevel: lv + 1)
    }

    @discardableResult
    func upgrade(_ kind: HGBuildingKind) -> Bool {
        let lv = buildingLevel(kind)
        guard lv < kind.maxLevel else { return false }
        let cost = HGContent.buildingUpgradeCost(kind, targetLevel: lv + 1)
        guard save.gold >= cost else { return false }
        save.gold -= cost
        save.buildingLevels[kind.rawValue] = lv + 1
        if kind == .questBoard { syncQuestSlots() }
        evaluateAchievements()
        persistSave()
        return true
    }

    var buildingsAtMax: Int {
        HGBuildingKind.allCases.filter { buildingLevel($0) >= $0.maxLevel }.count
    }

    // MARK: - Prestige (New Saga)

    /// Renown that would be granted right now if a New Saga were started.
    var pendingRenown: Int {
        // Based on total accumulated progress: gold earned + power + buildings.
        let fromGold = save.stats.goldEarned / 5000
        let fromPower = totalPower / 200
        let fromBuildings = HGBuildingKind.allCases.reduce(0) { $0 + (buildingLevel($1) - 1) }
        let fromQuests = save.stats.questsCompleted / 20
        return max(0, fromGold + fromPower + fromBuildings + fromQuests)
    }

    var canPrestige: Bool { pendingRenown >= 1 }

    func startNewSaga() {
        let gained = pendingRenown
        guard gained >= 1 else { return }
        let keptRenown = save.renown + gained
        let keptSagas = save.stats.sagas + 1

        // Preserve only renown + lifetime cumulative stats; reset everything else.
        var preservedStats = save.stats
        preservedStats.sagas = keptSagas

        save = HGSave()
        save.renown = keptRenown
        save.stats = preservedStats

        // Re-bootstrap fresh world.
        for kind in HGBuildingKind.allCases { save.buildingLevels[kind.rawValue] = 1 }
        syncQuestSlots()
        regenerateRecruitPool()
        // Starter hero again.
        save.heroes.append(HGHero(defId: "hero_aldric", level: 1))
        save.stats.heroesRecruited += 1

        evaluateAchievements()
        persistSave()
    }

    // MARK: - Reset

    func resetProgress() {
        save = HGSave()
        for kind in HGBuildingKind.allCases { save.buildingLevels[kind.rawValue] = 1 }
        syncQuestSlots()
        regenerateRecruitPool()
        save.heroes.append(HGHero(defId: "hero_aldric", level: 1))
        save.stats.heroesRecruited += 1
        unlocked = []
        lastUnlocked = []
        pendingResults = []
        persistSave()
        saveAchievements()
        evaluateAchievements()
    }

    // MARK: - Persistence

    /// Throttled save (used by frequent mutators).
    func persistSave() {
        let nowD = Date()
        if nowD.timeIntervalSince(lastSaveTime) < 0.4 {
            // schedule a flush soon
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.flushSave()
            }
            objectWillChange.send()
            return
        }
        flushSave()
    }

    func flushSave() {
        lastSaveTime = Date()
        if let data = try? JSONEncoder().encode(save) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
        objectWillChange.send()
    }

    func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: settingsKey)
        }
        objectWillChange.send()
    }

    func markOnboardingDone() {
        onboardingDone = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }

    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(unlocked) {
            UserDefaults.standard.set(data, forKey: achievementsKey)
        }
    }

    // MARK: - Achievements

    func evaluateAchievements() {
        var newly: [String] = []
        for ach in HGAchievements.all where !unlocked.contains(ach.id) {
            if ach.progress(self) >= ach.goal {
                unlocked.insert(ach.id)
                newly.append(ach.id)
            }
        }
        if !newly.isEmpty {
            saveAchievements()
            lastUnlocked.append(contentsOf: newly)
        }
    }

    var unlockedCount: Int { unlocked.count }
}
