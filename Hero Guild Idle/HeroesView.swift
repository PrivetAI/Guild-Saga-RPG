import SwiftUI

struct HeroesView: View {
    @EnvironmentObject var store: HeroGuildStore

    var body: some View {
        ZStack {
            HGBackground()
            VStack(spacing: 0) {
                HGResourceHeader()
                ScrollView {
                    VStack(spacing: 12) {
                        if store.heroes.isEmpty {
                            emptyState
                        } else {
                            HStack {
                                Text("\(store.heroes.count) HEROES")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .tracking(1.2)
                                    .foregroundColor(HGPalette.textMuted)
                                Spacer()
                                Text("Total Power \(store.totalPower)")
                                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                                    .foregroundColor(HGPalette.crimson)
                            }
                            ForEach(store.heroes.sorted(by: { $0.power > $1.power })) { hero in
                                NavigationLink(destination: HeroDetailView(heroId: hero.id).environmentObject(store)) {
                                    HeroRosterCard(hero: hero, busy: store.busyHeroIds.contains(hero.id))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        Color.clear.frame(height: 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .frame(maxWidth: 600)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationBarTitle("Heroes", displayMode: .inline)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            HGTabHeroesIcon(color: HGPalette.panelRaised, size: 56)
            Text("No heroes yet")
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundColor(HGPalette.textSecondary)
            Text("Recruit heroes in the Guild tab.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(HGPalette.textMuted)
        }
        .padding(.top, 60)
    }
}

struct HeroRosterCard: View {
    let hero: HGHero
    let busy: Bool
    var body: some View {
        HStack(spacing: 12) {
            HGHeroCrest(heroClass: hero.def.heroClass, rarity: hero.def.rarity)
                .frame(width: 46, height: 46)
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(hero.def.name)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(HGPalette.textPrimary)
                    Text(hero.def.rarity.name)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(HGPalette.rarity(hero.def.rarity))
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Capsule().fill(HGPalette.rarity(hero.def.rarity).opacity(0.14)))
                }
                Text("Lv \(hero.level) • \(hero.def.heroClass.name)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(HGPalette.textMuted)
                HGProgressBar(value: Double(hero.xp) / Double(max(1, hero.xpForNext)), tint: HGPalette.accent, height: 5)
                    .frame(width: 120)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text("\(hero.power)")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(HGPalette.crimson)
                Text(busy ? "On Quest" : "Power")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(busy ? HGPalette.primary : HGPalette.textMuted)
            }
        }
        .padding(13)
        .hgPanel()
    }
}
