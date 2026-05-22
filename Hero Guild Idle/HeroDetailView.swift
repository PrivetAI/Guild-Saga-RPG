import SwiftUI

struct HeroDetailView: View {
    @EnvironmentObject var store: HeroGuildStore
    let heroId: String
    @State private var equipSlot: HGSlot? = nil

    private var hero: HGHero? { store.hero(byId: heroId) }

    var body: some View {
        ZStack {
            HGBackground()
            ScrollView {
                if let hero = hero {
                    VStack(spacing: 16) {
                        headerCard(hero)
                        statsCard(hero)
                        equipmentSection(hero)
                        Color.clear.frame(height: 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .frame(maxWidth: 600)
                    .frame(maxWidth: .infinity)
                } else {
                    Text("Hero not found.")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(HGPalette.textMuted)
                        .padding(.top, 60)
                }
            }
        }
        .navigationBarTitle(hero?.def.name ?? "Hero", displayMode: .inline)
        .sheet(item: Binding(
            get: { equipSlot.map { SlotWrapper(slot: $0) } },
            set: { equipSlot = $0?.slot }
        )) { wrapped in
            EquipPickerView(heroId: heroId, slot: wrapped.slot)
                .environmentObject(store)
        }
    }

    private func headerCard(_ hero: HGHero) -> some View {
        VStack(spacing: 10) {
            HGHeroCrest(heroClass: hero.def.heroClass, rarity: hero.def.rarity)
                .frame(width: 84, height: 84)
            Text(hero.def.name)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(HGPalette.textPrimary)
            Text(hero.def.title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .italic()
                .foregroundColor(HGPalette.textSecondary)
            HStack(spacing: 8) {
                tag(hero.def.heroClass.name, HGPalette.primary)
                tag(hero.def.rarity.name, HGPalette.rarity(hero.def.rarity))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .hgPanel()
    }

    private func statsCard(_ hero: HGHero) -> some View {
        VStack(spacing: 12) {
            HStack {
                statBlock("Power", "\(hero.power)", HGPalette.crimson)
                Divider().frame(height: 36)
                statBlock("Level", "\(hero.level)", HGPalette.primary)
                Divider().frame(height: 36)
                statBlock("Base", "\(hero.def.basePower)", HGPalette.textSecondary)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Experience")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(HGPalette.textMuted)
                    Spacer()
                    Text("\(hero.xp) / \(hero.xpForNext)")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(HGPalette.textSecondary)
                }
                HGProgressBar(value: Double(hero.xp) / Double(max(1, hero.xpForNext)), tint: HGPalette.accent)
            }
        }
        .padding(16)
        .hgPanel()
    }

    private func equipmentSection(_ hero: HGHero) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("EQUIPMENT")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(1.2)
                .foregroundColor(HGPalette.textMuted)
            ForEach(HGSlot.allCases, id: \.rawValue) { slot in
                equipRow(hero, slot)
            }
        }
    }

    private func equipRow(_ hero: HGHero, _ slot: HGSlot) -> some View {
        let item = hero.equipped[slot.rawValue]
        return HStack(spacing: 12) {
            if let item = item {
                HGItemSigil(slot: slot, rarity: item.rarity).frame(width: 40, height: 40)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(HGPalette.panelInset).frame(width: 40, height: 40)
                    HGItemSigil(slot: slot, rarity: .common).frame(width: 36, height: 36).opacity(0.35)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(slot.name)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(HGPalette.textMuted)
                if let item = item {
                    Text(item.name)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(HGPalette.rarity(item.rarity))
                    Text("+\(item.powerBonus) Power")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(HGPalette.textSecondary)
                } else {
                    Text("Empty")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(HGPalette.textMuted)
                }
            }
            Spacer()
            if item != nil {
                Button {
                    store.unequip(slot: slot, fromHeroId: heroId)
                } label: {
                    Text("Remove")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(HGPalette.crimson)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 6)
            }
            Button {
                equipSlot = slot
            } label: {
                Text(item == nil ? "Equip" : "Swap")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12).padding(.vertical, 7)
                    .background(Capsule().fill(HGPalette.primary))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .hgPanel(corner: HGMetrics.cornerSmall)
    }

    private func statBlock(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(HGPalette.textMuted)
        }
        .frame(maxWidth: .infinity)
    }

    private func tag(_ t: String, _ c: Color) -> some View {
        Text(t)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundColor(c)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(Capsule().fill(c.opacity(0.14)))
    }
}

struct SlotWrapper: Identifiable {
    let slot: HGSlot
    var id: Int { slot.rawValue }
}

// MARK: - Equip picker (inventory filtered to a slot)

struct EquipPickerView: View {
    @EnvironmentObject var store: HeroGuildStore
    @Environment(\.presentationMode) private var presentationMode
    let heroId: String
    let slot: HGSlot

    private var items: [HGItem] {
        store.inventory.filter { $0.slot == slot }.sorted { $0.powerBonus > $1.powerBonus }
    }

    var body: some View {
        ZStack {
            HGBackground()
            VStack(spacing: 0) {
                HStack {
                    Button { presentationMode.wrappedValue.dismiss() } label: {
                        Text("Close")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(HGPalette.textSecondary)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    Text("Choose \(slot.name)")
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .foregroundColor(HGPalette.textPrimary)
                    Spacer()
                    Text("Close").font(.system(size: 15)).opacity(0)
                }
                .padding(.horizontal, 16).padding(.vertical, 14)
                .background(HGPalette.panel)
                .overlay(Rectangle().fill(HGPalette.panelRaised.opacity(0.6)).frame(height: 1), alignment: .bottom)

                ScrollView {
                    VStack(spacing: 10) {
                        if items.isEmpty {
                            Text("No \(slot.name.lowercased()) in your inventory. Complete quests to find loot.")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(HGPalette.textMuted)
                                .multilineTextAlignment(.center)
                                .padding(.top, 60)
                                .padding(.horizontal, 24)
                        } else {
                            ForEach(items) { item in
                                Button {
                                    store.equip(item: item, toHeroId: heroId)
                                    presentationMode.wrappedValue.dismiss()
                                } label: {
                                    itemRow(item)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        Color.clear.frame(height: 8)
                    }
                    .padding(.horizontal, 16).padding(.top, 14)
                    .frame(maxWidth: 600)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func itemRow(_ item: HGItem) -> some View {
        HStack(spacing: 12) {
            HGItemSigil(slot: item.slot, rarity: item.rarity).frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(HGPalette.rarity(item.rarity))
                Text(item.rarity.name)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(HGPalette.textMuted)
            }
            Spacer()
            Text("+\(item.powerBonus)")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundColor(HGPalette.crimson)
        }
        .padding(12)
        .hgPanel(corner: HGMetrics.cornerSmall)
    }
}
