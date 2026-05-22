import Foundation

/// One achievement: a stable id, display strings, a target `goal`, and a `progress` closure that
/// reads the current store snapshot. Progress is recomputed live; only the unlocked flag persists.
struct HGAchievement: Identifiable {
    let id: String
    let title: String
    let detail: String
    let goal: Int
    let progress: (HeroGuildStore) -> Int
}

enum HGAchievements {
    static let all: [HGAchievement] = [

        // MARK: Quests
        HGAchievement(id: "first_quest", title: "First Steps",
                      detail: "Complete your first quest.", goal: 1,
                      progress: { $0.stats.questsCompleted }),
        HGAchievement(id: "questing_10", title: "Adventurer",
                      detail: "Complete 10 quests.", goal: 10,
                      progress: { $0.stats.questsCompleted }),
        HGAchievement(id: "questing_50", title: "Seasoned Guild",
                      detail: "Complete 50 quests.", goal: 50,
                      progress: { $0.stats.questsCompleted }),
        HGAchievement(id: "questing_200", title: "Legend of the Realm",
                      detail: "Complete 200 quests.", goal: 200,
                      progress: { $0.stats.questsCompleted }),

        // MARK: Heroes
        HGAchievement(id: "recruit_1", title: "Open for Business",
                      detail: "Recruit a hero.", goal: 1,
                      progress: { $0.stats.heroesRecruited }),
        HGAchievement(id: "recruit_5", title: "A Fine Roster",
                      detail: "Recruit 5 heroes.", goal: 5,
                      progress: { $0.stats.heroesRecruited }),
        HGAchievement(id: "recruit_15", title: "Full House",
                      detail: "Recruit 15 heroes.", goal: 15,
                      progress: { $0.stats.heroesRecruited }),
        HGAchievement(id: "legendary_hero", title: "Hero of Renown",
                      detail: "Recruit a Legendary hero.", goal: 1,
                      progress: { $0.stats.legendaryHeroes }),
        HGAchievement(id: "hero_level_10", title: "Mentor",
                      detail: "Raise a hero to level 10.", goal: 10,
                      progress: { $0.heroes.map { $0.level }.max() ?? 0 }),
        HGAchievement(id: "hero_level_25", title: "Grandmaster",
                      detail: "Raise a hero to level 25.", goal: 25,
                      progress: { $0.heroes.map { $0.level }.max() ?? 0 }),

        // MARK: Power
        HGAchievement(id: "power_200", title: "Rising Force",
                      detail: "Reach 200 total guild Power.", goal: 200,
                      progress: { $0.totalPower }),
        HGAchievement(id: "power_1000", title: "Mighty Guild",
                      detail: "Reach 1,000 total guild Power.", goal: 1000,
                      progress: { $0.totalPower }),
        HGAchievement(id: "power_3000", title: "Unstoppable",
                      detail: "Reach 3,000 total guild Power.", goal: 3000,
                      progress: { $0.totalPower }),
        HGAchievement(id: "single_500", title: "Champion",
                      detail: "Have a single hero reach 500 Power.", goal: 500,
                      progress: { $0.highestSingleHeroPower }),

        // MARK: Gold
        HGAchievement(id: "gold_1000", title: "Coin Counter",
                      detail: "Earn 1,000 gold in total.", goal: 1000,
                      progress: { $0.stats.goldEarned }),
        HGAchievement(id: "gold_25000", title: "Treasurer",
                      detail: "Earn 25,000 gold in total.", goal: 25000,
                      progress: { $0.stats.goldEarned }),
        HGAchievement(id: "gold_100000", title: "Guild Magnate",
                      detail: "Earn 100,000 gold in total.", goal: 100000,
                      progress: { $0.stats.goldEarned }),

        // MARK: Loot
        HGAchievement(id: "loot_10", title: "Pack Rat",
                      detail: "Collect 10 pieces of loot.", goal: 10,
                      progress: { $0.stats.lootCollected }),
        HGAchievement(id: "loot_legendary", title: "Treasure Hunter",
                      detail: "Find a Legendary item.", goal: 1,
                      progress: { $0.stats.legendaryLoot }),

        // MARK: Buildings
        HGAchievement(id: "first_upgrade", title: "Master Builder",
                      detail: "Upgrade any building.", goal: 2,
                      progress: { s in HGBuildingKind.allCases.map { s.buildingLevel($0) }.max() ?? 1 }),
        HGAchievement(id: "building_max", title: "Pinnacle",
                      detail: "Bring a building to its maximum level.", goal: 1,
                      progress: { $0.buildingsAtMax }),
        HGAchievement(id: "all_buildings_max", title: "Grand Architect",
                      detail: "Max out all 5 guild buildings.", goal: HGBuildingKind.allCases.count,
                      progress: { $0.buildingsAtMax }),

        // MARK: Prestige
        HGAchievement(id: "first_saga", title: "A New Saga",
                      detail: "Begin a New Saga.", goal: 1,
                      progress: { $0.stats.sagas }),
        HGAchievement(id: "saga_5", title: "Eternal Guild",
                      detail: "Begin 5 New Sagas.", goal: 5,
                      progress: { $0.stats.sagas }),
        HGAchievement(id: "renown_10", title: "Renowned",
                      detail: "Accumulate 10 Renown.", goal: 10,
                      progress: { $0.renown }),
    ]

    static func byId(_ id: String) -> HGAchievement? {
        all.first(where: { $0.id == id })
    }
}
