import Foundation

// MARK: - Hero definition (static catalog)

struct HGHeroDef: Identifiable {
    let id: String
    let name: String
    let title: String
    let heroClass: HGHeroClass
    let rarity: HGRarity
    let basePower: Int
    let growth: Int          // power gained per level
    let goldCost: Int        // recruit cost in gold
    let tokenCost: Int       // recruit cost in tokens (0 == gold only)
}

// MARK: - Quest definition (static catalog)

enum HGQuestTier: Int, CaseIterable {
    case easy = 0, hard, elite, legendary
    var name: String {
        switch self {
        case .easy: return "Easy"
        case .hard: return "Hard"
        case .elite: return "Elite"
        case .legendary: return "Legendary"
        }
    }
}

struct HGQuestDef: Identifiable {
    let id: String
    let name: String
    let tier: HGQuestTier
    let requiredPower: Int
    let durationSeconds: Int
    let goldReward: Int
    let xpReward: Int
    let tokenReward: Int      // 0 == none
    let lootRarityFloor: HGRarity
    let maxHeroes: Int
}

enum HGContent {

    // MARK: Heroes (24 across 6 classes & all rarities)

    static let heroDefs: [HGHeroDef] = [
        // Warriors
        HGHeroDef(id: "hero_aldric", name: "Aldric", title: "the Steadfast", heroClass: .warrior, rarity: .common, basePower: 12, growth: 5, goldCost: 60, tokenCost: 0),
        HGHeroDef(id: "hero_brunhild", name: "Brunhild", title: "Shieldmaiden", heroClass: .warrior, rarity: .rare, basePower: 22, growth: 8, goldCost: 320, tokenCost: 0),
        HGHeroDef(id: "hero_gorath", name: "Gorath", title: "the Unbroken", heroClass: .warrior, rarity: .epic, basePower: 34, growth: 12, goldCost: 0, tokenCost: 14),
        HGHeroDef(id: "hero_valdris", name: "Valdris", title: "Warlord of the East", heroClass: .warrior, rarity: .legendary, basePower: 52, growth: 18, goldCost: 0, tokenCost: 40),

        // Mages
        HGHeroDef(id: "hero_elenwe", name: "Elenwe", title: "the Curious", heroClass: .mage, rarity: .common, basePower: 11, growth: 6, goldCost: 70, tokenCost: 0),
        HGHeroDef(id: "hero_morrigan", name: "Morrigan", title: "Stormcaller", heroClass: .mage, rarity: .uncommon, basePower: 17, growth: 7, goldCost: 160, tokenCost: 0),
        HGHeroDef(id: "hero_zephyrine", name: "Zephyrine", title: "Arcane Adept", heroClass: .mage, rarity: .epic, basePower: 32, growth: 13, goldCost: 0, tokenCost: 16),
        HGHeroDef(id: "hero_thaumiel", name: "Thaumiel", title: "the Voidwise", heroClass: .mage, rarity: .legendary, basePower: 50, growth: 19, goldCost: 0, tokenCost: 42),

        // Rangers
        HGHeroDef(id: "hero_finn", name: "Finn", title: "the Swift", heroClass: .ranger, rarity: .common, basePower: 12, growth: 5, goldCost: 65, tokenCost: 0),
        HGHeroDef(id: "hero_sylvara", name: "Sylvara", title: "Greenwarden", heroClass: .ranger, rarity: .uncommon, basePower: 18, growth: 7, goldCost: 150, tokenCost: 0),
        HGHeroDef(id: "hero_kaelen", name: "Kaelen", title: "Hawk-eye", heroClass: .ranger, rarity: .rare, basePower: 24, growth: 9, goldCost: 340, tokenCost: 0),
        HGHeroDef(id: "hero_artemys", name: "Artemys", title: "the Trueshot", heroClass: .ranger, rarity: .legendary, basePower: 48, growth: 18, goldCost: 0, tokenCost: 38),

        // Clerics
        HGHeroDef(id: "hero_mira", name: "Mira", title: "the Kind", heroClass: .cleric, rarity: .common, basePower: 10, growth: 5, goldCost: 60, tokenCost: 0),
        HGHeroDef(id: "hero_benedict", name: "Benedict", title: "Lightbearer", heroClass: .cleric, rarity: .uncommon, basePower: 16, growth: 7, goldCost: 155, tokenCost: 0),
        HGHeroDef(id: "hero_seraphine", name: "Seraphine", title: "the Radiant", heroClass: .cleric, rarity: .epic, basePower: 31, growth: 12, goldCost: 0, tokenCost: 15),
        HGHeroDef(id: "hero_lucent", name: "Lucent", title: "Saint of Dawn", heroClass: .cleric, rarity: .legendary, basePower: 47, growth: 17, goldCost: 0, tokenCost: 36),

        // Rogues
        HGHeroDef(id: "hero_vex", name: "Vex", title: "the Shadow", heroClass: .rogue, rarity: .common, basePower: 13, growth: 5, goldCost: 70, tokenCost: 0),
        HGHeroDef(id: "hero_isolde", name: "Isolde", title: "Nightblade", heroClass: .rogue, rarity: .rare, basePower: 25, growth: 9, goldCost: 330, tokenCost: 0),
        HGHeroDef(id: "hero_corvus", name: "Corvus", title: "the Veiled", heroClass: .rogue, rarity: .epic, basePower: 33, growth: 13, goldCost: 0, tokenCost: 16),
        HGHeroDef(id: "hero_nyx", name: "Nyx", title: "Whisper of Coin", heroClass: .rogue, rarity: .legendary, basePower: 49, growth: 18, goldCost: 0, tokenCost: 40),

        // Paladins
        HGHeroDef(id: "hero_garrick", name: "Garrick", title: "Squire", heroClass: .paladin, rarity: .uncommon, basePower: 19, growth: 7, goldCost: 170, tokenCost: 0),
        HGHeroDef(id: "hero_rowena", name: "Rowena", title: "the Oathbound", heroClass: .paladin, rarity: .rare, basePower: 26, growth: 9, goldCost: 360, tokenCost: 0),
        HGHeroDef(id: "hero_alaric", name: "Alaric", title: "the Resolute", heroClass: .paladin, rarity: .epic, basePower: 35, growth: 13, goldCost: 0, tokenCost: 17),
        HGHeroDef(id: "hero_celestine", name: "Celestine", title: "Champion of the Light", heroClass: .paladin, rarity: .legendary, basePower: 54, growth: 19, goldCost: 0, tokenCost: 44),
    ]

    private static let heroDefMap: [String: HGHeroDef] = {
        var m: [String: HGHeroDef] = [:]
        for d in heroDefs { m[d.id] = d }
        return m
    }()

    static func heroDef(_ id: String) -> HGHeroDef {
        heroDefMap[id] ?? heroDefs[0]
    }

    // MARK: Quests (20 across four tiers)

    static let questDefs: [HGQuestDef] = [
        // Easy (minutes)
        HGQuestDef(id: "q_rats", name: "Cellar Rats", tier: .easy, requiredPower: 14, durationSeconds: 120, goldReward: 30, xpReward: 25, tokenReward: 0, lootRarityFloor: .common, maxHeroes: 1),
        HGQuestDef(id: "q_herbs", name: "Gather Healing Herbs", tier: .easy, requiredPower: 18, durationSeconds: 240, goldReward: 42, xpReward: 32, tokenReward: 0, lootRarityFloor: .common, maxHeroes: 1),
        HGQuestDef(id: "q_courier", name: "Courier Run", tier: .easy, requiredPower: 24, durationSeconds: 360, goldReward: 55, xpReward: 40, tokenReward: 0, lootRarityFloor: .common, maxHeroes: 2),
        HGQuestDef(id: "q_goblins", name: "Goblin Scouts", tier: .easy, requiredPower: 32, durationSeconds: 600, goldReward: 80, xpReward: 55, tokenReward: 0, lootRarityFloor: .uncommon, maxHeroes: 2),
        HGQuestDef(id: "q_bridge", name: "Guard the Bridge", tier: .easy, requiredPower: 40, durationSeconds: 900, goldReward: 110, xpReward: 70, tokenReward: 1, lootRarityFloor: .uncommon, maxHeroes: 2),

        // Hard (tens of minutes)
        HGQuestDef(id: "q_bandits", name: "Bandit Hideout", tier: .hard, requiredPower: 60, durationSeconds: 1800, goldReward: 190, xpReward: 110, tokenReward: 1, lootRarityFloor: .uncommon, maxHeroes: 2),
        HGQuestDef(id: "q_mine", name: "Cleanse the Mines", tier: .hard, requiredPower: 80, durationSeconds: 2700, goldReward: 270, xpReward: 150, tokenReward: 1, lootRarityFloor: .rare, maxHeroes: 3),
        HGQuestDef(id: "q_wraith", name: "Marsh Wraiths", tier: .hard, requiredPower: 110, durationSeconds: 3600, goldReward: 360, xpReward: 200, tokenReward: 2, lootRarityFloor: .rare, maxHeroes: 3),
        HGQuestDef(id: "q_caravan", name: "Escort the Caravan", tier: .hard, requiredPower: 140, durationSeconds: 5400, goldReward: 470, xpReward: 250, tokenReward: 2, lootRarityFloor: .rare, maxHeroes: 3),

        // Elite (hours)
        HGQuestDef(id: "q_orc", name: "Orc War-Camp", tier: .elite, requiredPower: 190, durationSeconds: 7200, goldReward: 680, xpReward: 360, tokenReward: 3, lootRarityFloor: .rare, maxHeroes: 3),
        HGQuestDef(id: "q_crypt", name: "The Forgotten Crypt", tier: .elite, requiredPower: 250, durationSeconds: 10800, goldReward: 940, xpReward: 480, tokenReward: 3, lootRarityFloor: .epic, maxHeroes: 4),
        HGQuestDef(id: "q_troll", name: "Mountain Troll", tier: .elite, requiredPower: 330, durationSeconds: 14400, goldReward: 1300, xpReward: 620, tokenReward: 4, lootRarityFloor: .epic, maxHeroes: 4),
        HGQuestDef(id: "q_warlock", name: "The Black Warlock", tier: .elite, requiredPower: 430, durationSeconds: 18000, goldReward: 1750, xpReward: 800, tokenReward: 5, lootRarityFloor: .epic, maxHeroes: 4),

        // Legendary (long hauls)
        HGQuestDef(id: "q_dragon", name: "Slay the Frost Dragon", tier: .legendary, requiredPower: 560, durationSeconds: 25200, goldReward: 2600, xpReward: 1100, tokenReward: 6, lootRarityFloor: .epic, maxHeroes: 5),
        HGQuestDef(id: "q_demon", name: "Seal the Demon Gate", tier: .legendary, requiredPower: 720, durationSeconds: 32400, goldReward: 3600, xpReward: 1450, tokenReward: 8, lootRarityFloor: .legendary, maxHeroes: 5),
        HGQuestDef(id: "q_lich", name: "The Lich King's Tomb", tier: .legendary, requiredPower: 920, durationSeconds: 43200, goldReward: 5000, xpReward: 1900, tokenReward: 10, lootRarityFloor: .legendary, maxHeroes: 5),
        HGQuestDef(id: "q_titan", name: "Awaken the Titan", tier: .legendary, requiredPower: 1180, durationSeconds: 57600, goldReward: 7000, xpReward: 2500, tokenReward: 12, lootRarityFloor: .legendary, maxHeroes: 5),
    ]

    private static let questDefMap: [String: HGQuestDef] = {
        var m: [String: HGQuestDef] = [:]
        for d in questDefs { m[d.id] = d }
        return m
    }()

    static func questDef(_ id: String) -> HGQuestDef? { questDefMap[id] }

    // MARK: Loot generation (deterministic via seed)

    private static let weaponNames = ["Shortsword", "Warhammer", "Longbow", "Battleaxe", "Dagger", "Greatsword", "War Staff", "Crossbow", "Mace", "Glaive"]
    private static let armorNames = ["Leather Vest", "Chainmail", "Plate Cuirass", "Robe", "Scale Armor", "Brigandine", "Tower Shield", "Cloak", "Bulwark", "Hauberk"]
    private static let trinketNames = ["Silver Ring", "Amulet", "Lucky Charm", "Sigil Stone", "Pendant", "Talisman", "Signet", "Phylactery", "Brooch", "Relic"]
    private static let prefixes = ["Worn", "Sturdy", "Fine", "Keen", "Blessed", "Runed", "Ancient", "Gleaming", "Dread", "Mythic"]

    /// Roll a single loot item from a seed and a rarity floor. `forgeLevel` raises rarity odds.
    static func rollLoot(seed: UInt64, floor: HGRarity, forgeLevel: Int) -> HGItem {
        var rng = HGSplitMix64(seed: HGSplitMix64.mix(seed))
        // Determine rarity: start at floor, roll upgrades.
        var rarity = floor
        let forgeBonus = Double(forgeLevel - 1) * 0.04
        for _ in 0..<4 {
            if rarity == .legendary { break }
            let upgradeChance = 0.20 + forgeBonus
            if rng.double() < upgradeChance {
                rarity = HGRarity(rawValue: rarity.rawValue + 1) ?? rarity
            } else {
                break
            }
        }
        let slot = HGSlot(rawValue: rng.int(HGSlot.allCases.count)) ?? .trinket
        let baseName: String
        switch slot {
        case .weapon: baseName = weaponNames[rng.int(weaponNames.count)]
        case .armor: baseName = armorNames[rng.int(armorNames.count)]
        case .trinket: baseName = trinketNames[rng.int(trinketNames.count)]
        }
        let prefixIndex = min(prefixes.count - 1, rarity.rawValue * 2 + rng.int(2))
        let name = "\(prefixes[prefixIndex]) \(baseName)"
        // Power bonus scales with rarity and a roll.
        let basePB = 4 + rarity.rawValue * 6
        let bonus = basePB + rng.range(0, basePB / 2 + 2)
        return HGItem(name: name, slot: slot, rarity: rarity, powerBonus: bonus)
    }

    // MARK: Recruit pool generation (deterministic)

    /// Build a recruit pool of `count` hero defIds from a seed. Weighted toward lower rarities,
    /// with rarer heroes appearing occasionally. Tavern level improves quality slightly.
    static func generateRecruitPool(seed: UInt64, count: Int, tavernLevel: Int) -> [String] {
        var rng = HGSplitMix64(seed: HGSplitMix64.mix(seed &+ 0xABCDEF))
        var pool: [String] = []
        let qualityBonus = Double(tavernLevel - 1) * 0.03
        var attempts = 0
        while pool.count < count && attempts < count * 12 {
            attempts += 1
            // Pick a target rarity by weighted roll.
            let roll = rng.double()
            let targetRarity: HGRarity
            if roll < 0.42 - qualityBonus { targetRarity = .common }
            else if roll < 0.70 - qualityBonus { targetRarity = .uncommon }
            else if roll < 0.88 { targetRarity = .rare }
            else if roll < 0.97 + qualityBonus { targetRarity = .epic }
            else { targetRarity = .legendary }
            let candidates = heroDefs.filter { $0.rarity == targetRarity }
            guard !candidates.isEmpty else { continue }
            let pick = candidates[rng.int(candidates.count)]
            pool.append(pick.id)
        }
        // Guarantee at least one entry.
        if pool.isEmpty { pool.append(heroDefs[0].id) }
        return pool
    }

    // MARK: Building costs / effects

    /// Gold cost to upgrade a building TO `targetLevel` (i.e. from targetLevel-1).
    static func buildingUpgradeCost(_ kind: HGBuildingKind, targetLevel: Int) -> Int {
        let base: Int
        switch kind {
        case .questBoard: base = 200
        case .trainingHall: base = 150
        case .forge: base = 180
        case .tavern: base = 160
        case .treasury: base = 140
        }
        let lv = max(2, targetLevel)
        // Geometric growth.
        var cost = Double(base)
        for _ in 2...lv { cost *= 1.85 }
        return Int(cost.rounded())
    }

    static let baseQuestSlots = 1

    /// Number of quest slots given the Quest Board level.
    static func questSlotCount(boardLevel: Int) -> Int {
        return baseQuestSlots + (boardLevel - 1)   // L1=1, L8=8
    }

    /// XP multiplier from Training Hall.
    static func xpMultiplier(trainingLevel: Int) -> Double {
        return 1.0 + Double(trainingLevel - 1) * 0.15
    }

    /// Gold multiplier from Treasury.
    static func goldMultiplier(treasuryLevel: Int) -> Double {
        return 1.0 + Double(treasuryLevel - 1) * 0.12
    }

    /// Recruit/refresh cost multiplier from Tavern (lower is better).
    static func tavernCostMultiplier(tavernLevel: Int) -> Double {
        return max(0.5, 1.0 - Double(tavernLevel - 1) * 0.07)
    }
}
