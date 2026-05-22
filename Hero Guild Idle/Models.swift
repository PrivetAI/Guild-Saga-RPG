import Foundation

// MARK: - Rarity

enum HGRarity: Int, Codable, CaseIterable, Comparable {
    case common = 0, uncommon, rare, epic, legendary

    var name: String {
        switch self {
        case .common: return "Common"
        case .uncommon: return "Uncommon"
        case .rare: return "Rare"
        case .epic: return "Epic"
        case .legendary: return "Legendary"
        }
    }

    var powerMultiplier: Double {
        switch self {
        case .common: return 1.0
        case .uncommon: return 1.25
        case .rare: return 1.6
        case .epic: return 2.1
        case .legendary: return 3.0
        }
    }

    static func < (lhs: HGRarity, rhs: HGRarity) -> Bool { lhs.rawValue < rhs.rawValue }
}

// MARK: - Hero class

enum HGHeroClass: Int, Codable, CaseIterable {
    case warrior = 0, mage, ranger, cleric, rogue, paladin

    var name: String {
        switch self {
        case .warrior: return "Warrior"
        case .mage: return "Mage"
        case .ranger: return "Ranger"
        case .cleric: return "Cleric"
        case .rogue: return "Rogue"
        case .paladin: return "Paladin"
        }
    }
}

// MARK: - Equipment slot

enum HGSlot: Int, Codable, CaseIterable {
    case weapon = 0, armor, trinket
    var name: String {
        switch self {
        case .weapon: return "Weapon"
        case .armor: return "Armor"
        case .trinket: return "Trinket"
        }
    }
}

// MARK: - Item (equipment / loot)

struct HGItem: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var slot: HGSlot
    var rarity: HGRarity
    var powerBonus: Int

    init(id: String = UUID().uuidString, name: String, slot: HGSlot, rarity: HGRarity, powerBonus: Int) {
        self.id = id
        self.name = name
        self.slot = slot
        self.rarity = rarity
        self.powerBonus = powerBonus
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        name = try c.decodeIfPresent(String.self, forKey: .name) ?? "Trinket"
        slot = try c.decodeIfPresent(HGSlot.self, forKey: .slot) ?? .trinket
        rarity = try c.decodeIfPresent(HGRarity.self, forKey: .rarity) ?? .common
        powerBonus = try c.decodeIfPresent(Int.self, forKey: .powerBonus) ?? 1
    }

    enum CodingKeys: String, CodingKey { case id, name, slot, rarity, powerBonus }

    // Gold value when sold.
    var sellValue: Int { max(5, powerBonus * 3 + rarity.rawValue * 12) }
}

// MARK: - Hero (a recruited, levelable hero instance)

struct HGHero: Codable, Identifiable, Equatable {
    var id: String
    var defId: String           // points to a HGHeroDef for name/class/sigil/base
    var level: Int
    var xp: Int
    var equipped: [Int: HGItem]  // slot.rawValue -> item

    init(id: String = UUID().uuidString, defId: String, level: Int = 1, xp: Int = 0, equipped: [Int: HGItem] = [:]) {
        self.id = id
        self.defId = defId
        self.level = level
        self.xp = xp
        self.equipped = equipped
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        defId = try c.decodeIfPresent(String.self, forKey: .defId) ?? "hero_aldric"
        level = try c.decodeIfPresent(Int.self, forKey: .level) ?? 1
        xp = try c.decodeIfPresent(Int.self, forKey: .xp) ?? 0
        equipped = try c.decodeIfPresent([Int: HGItem].self, forKey: .equipped) ?? [:]
    }

    enum CodingKeys: String, CodingKey { case id, defId, level, xp, equipped }

    var def: HGHeroDef { HGContent.heroDef(defId) }

    // XP needed to advance from current level to the next.
    var xpForNext: Int { 50 + (level - 1) * 35 + (level - 1) * (level - 1) * 4 }

    // Power = base + per-level growth + equipment bonuses, scaled by rarity.
    var power: Int {
        let d = def
        let base = Double(d.basePower)
        let growth = Double(level - 1) * Double(d.growth)
        let raw = (base + growth) * d.rarity.powerMultiplier
        var total = Int(raw.rounded())
        for (_, item) in equipped { total += item.powerBonus }
        return total
    }
}

// MARK: - Quest slot (an active or empty assignment slot)

struct HGQuestSlot: Codable, Identifiable {
    var id: Int                 // stable slot index 0..<n
    var questDefId: String?     // nil == idle
    var assignedHeroIds: [String]
    var startDate: Date?
    var endDate: Date?

    init(id: Int, questDefId: String? = nil, assignedHeroIds: [String] = [], startDate: Date? = nil, endDate: Date? = nil) {
        self.id = id
        self.questDefId = questDefId
        self.assignedHeroIds = assignedHeroIds
        self.startDate = startDate
        self.endDate = endDate
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(Int.self, forKey: .id) ?? 0
        questDefId = try c.decodeIfPresent(String.self, forKey: .questDefId)
        assignedHeroIds = try c.decodeIfPresent([String].self, forKey: .assignedHeroIds) ?? []
        startDate = try c.decodeIfPresent(Date.self, forKey: .startDate)
        endDate = try c.decodeIfPresent(Date.self, forKey: .endDate)
    }

    enum CodingKeys: String, CodingKey { case id, questDefId, assignedHeroIds, startDate, endDate }

    var isActive: Bool { questDefId != nil && endDate != nil }
}

// MARK: - Building

enum HGBuildingKind: Int, Codable, CaseIterable {
    case questBoard = 0   // more quest slots
    case trainingHall     // XP gain
    case forge            // loot quality
    case tavern           // recruit cost / refresh
    case treasury         // gold gain

    var name: String {
        switch self {
        case .questBoard: return "Quest Board"
        case .trainingHall: return "Training Hall"
        case .forge: return "Forge"
        case .tavern: return "Tavern"
        case .treasury: return "Treasury"
        }
    }

    var detail: String {
        switch self {
        case .questBoard: return "Unlocks additional quest slots."
        case .trainingHall: return "Increases hero XP gained from quests."
        case .forge: return "Improves the quality of loot drops."
        case .tavern: return "Reduces recruit cost and refresh price."
        case .treasury: return "Increases gold earned from quests."
        }
    }

    var maxLevel: Int { 8 }
}

// MARK: - Persisted settings

struct HGSettings: Codable {
    var soundOn: Bool
    var hapticsOn: Bool

    init(soundOn: Bool = true, hapticsOn: Bool = true) {
        self.soundOn = soundOn
        self.hapticsOn = hapticsOn
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        soundOn = try c.decodeIfPresent(Bool.self, forKey: .soundOn) ?? true
        hapticsOn = try c.decodeIfPresent(Bool.self, forKey: .hapticsOn) ?? true
    }

    enum CodingKeys: String, CodingKey { case soundOn, hapticsOn }
}

// MARK: - Lifetime stats

struct HGStats: Codable {
    var questsCompleted: Int = 0
    var goldEarned: Int = 0
    var heroesRecruited: Int = 0
    var highestPower: Int = 0
    var sagas: Int = 0
    var legendaryHeroes: Int = 0
    var legendaryLoot: Int = 0
    var lootCollected: Int = 0

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        questsCompleted = try c.decodeIfPresent(Int.self, forKey: .questsCompleted) ?? 0
        goldEarned = try c.decodeIfPresent(Int.self, forKey: .goldEarned) ?? 0
        heroesRecruited = try c.decodeIfPresent(Int.self, forKey: .heroesRecruited) ?? 0
        highestPower = try c.decodeIfPresent(Int.self, forKey: .highestPower) ?? 0
        sagas = try c.decodeIfPresent(Int.self, forKey: .sagas) ?? 0
        legendaryHeroes = try c.decodeIfPresent(Int.self, forKey: .legendaryHeroes) ?? 0
        legendaryLoot = try c.decodeIfPresent(Int.self, forKey: .legendaryLoot) ?? 0
        lootCollected = try c.decodeIfPresent(Int.self, forKey: .lootCollected) ?? 0
    }

    enum CodingKeys: String, CodingKey {
        case questsCompleted, goldEarned, heroesRecruited, highestPower
        case sagas, legendaryHeroes, legendaryLoot, lootCollected
    }
}

// MARK: - The full save blob (hgi.save.v1)

struct HGSave: Codable {
    var gold: Int
    var tokens: Int
    var renown: Int
    var heroes: [HGHero]
    var inventory: [HGItem]
    var buildingLevels: [Int: Int]      // HGBuildingKind.rawValue -> level (>=1)
    var slots: [HGQuestSlot]
    var recruitPool: [String]           // defIds available to recruit
    var recruitPoolSeed: UInt64         // seed used to derive the current pool
    var recruitsTaken: Int              // recruits performed (drives pool/refresh seeds)
    var stats: HGStats

    init() {
        gold = 120
        tokens = 0
        renown = 0
        heroes = []
        inventory = []
        buildingLevels = [:]
        slots = []
        recruitPool = []
        recruitPoolSeed = 0x5EED_1234_ABCD_0001
        recruitsTaken = 0
        stats = HGStats()
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        gold = try c.decodeIfPresent(Int.self, forKey: .gold) ?? 120
        tokens = try c.decodeIfPresent(Int.self, forKey: .tokens) ?? 0
        renown = try c.decodeIfPresent(Int.self, forKey: .renown) ?? 0
        heroes = try c.decodeIfPresent([HGHero].self, forKey: .heroes) ?? []
        inventory = try c.decodeIfPresent([HGItem].self, forKey: .inventory) ?? []
        buildingLevels = try c.decodeIfPresent([Int: Int].self, forKey: .buildingLevels) ?? [:]
        slots = try c.decodeIfPresent([HGQuestSlot].self, forKey: .slots) ?? []
        recruitPool = try c.decodeIfPresent([String].self, forKey: .recruitPool) ?? []
        recruitPoolSeed = try c.decodeIfPresent(UInt64.self, forKey: .recruitPoolSeed) ?? 0x5EED_1234_ABCD_0001
        recruitsTaken = try c.decodeIfPresent(Int.self, forKey: .recruitsTaken) ?? 0
        stats = try c.decodeIfPresent(HGStats.self, forKey: .stats) ?? HGStats()
    }

    enum CodingKeys: String, CodingKey {
        case gold, tokens, renown, heroes, inventory, buildingLevels
        case slots, recruitPool, recruitPoolSeed, recruitsTaken, stats
    }
}
