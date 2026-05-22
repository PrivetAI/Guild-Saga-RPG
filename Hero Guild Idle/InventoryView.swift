import SwiftUI

struct InventoryView: View {
    @EnvironmentObject var store: HeroGuildStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var filter: HGSlot? = nil
    @State private var showSellAlert = false

    private var items: [HGItem] {
        let base = filter == nil ? store.inventory : store.inventory.filter { $0.slot == filter }
        return base.sorted { lhs, rhs in
            if lhs.rarity != rhs.rarity { return lhs.rarity > rhs.rarity }
            return lhs.powerBonus > rhs.powerBonus
        }
    }

    var body: some View {
        ZStack {
            HGBackground()
            VStack(spacing: 0) {
                header
                HGResourceHeader()
                filterBar
                ScrollView {
                    VStack(spacing: 10) {
                        if items.isEmpty {
                            Text("Your vault is empty. Complete quests to collect loot.")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(HGPalette.textMuted)
                                .multilineTextAlignment(.center)
                                .padding(.top, 50)
                                .padding(.horizontal, 24)
                        } else {
                            ForEach(items) { item in
                                InventoryRow(item: item)
                            }
                        }
                        Color.clear.frame(height: 8)
                    }
                    .padding(.horizontal, 16).padding(.top, 12)
                    .frame(maxWidth: 600)
                    .frame(maxWidth: .infinity)
                }
                if !store.inventory.isEmpty { sellBar }
            }
        }
        .alert(isPresented: $showSellAlert) {
            Alert(
                title: Text("Sell Common & Uncommon?"),
                message: Text("This sells every Common and Uncommon item in your vault for gold."),
                primaryButton: .destructive(Text("Sell")) {
                    store.sellAllOfRarityOrLower(.uncommon)
                },
                secondaryButton: .cancel()
            )
        }
    }

    private var header: some View {
        HStack {
            Button { presentationMode.wrappedValue.dismiss() } label: {
                Text("Close")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(HGPalette.textSecondary)
            }
            .buttonStyle(.plain)
            Spacer()
            Text("Vault")
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundColor(HGPalette.textPrimary)
            Spacer()
            Text("Close").font(.system(size: 15)).opacity(0)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(HGPalette.panel)
    }

    private var filterBar: some View {
        HStack(spacing: 8) {
            filterChip("All", nil)
            ForEach(HGSlot.allCases, id: \.rawValue) { slot in
                filterChip(slot.name, slot)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
    }

    private func filterChip(_ label: String, _ slot: HGSlot?) -> some View {
        let sel = filter == slot
        return Button {
            filter = slot
        } label: {
            Text(label)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(sel ? .white : HGPalette.textSecondary)
                .padding(.horizontal, 14).padding(.vertical, 7)
                .background(Capsule().fill(sel ? HGPalette.primary : HGPalette.panel))
                .overlay(Capsule().stroke(HGPalette.panelRaised, lineWidth: sel ? 0 : 1.5))
        }
        .buttonStyle(.plain)
    }

    private var sellBar: some View {
        Button { showSellAlert = true } label: {
            Text("Sell all Common & Uncommon")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(HGPalette.crimson)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
        }
        .buttonStyle(.plain)
        .background(
            HGPalette.panel
                .overlay(Rectangle().fill(HGPalette.panelRaised.opacity(0.6)).frame(height: 1), alignment: .top)
                .edgesIgnoringSafeArea(.bottom)
        )
    }
}

struct InventoryRow: View {
    @EnvironmentObject var store: HeroGuildStore
    let item: HGItem
    var body: some View {
        HStack(spacing: 12) {
            HGItemSigil(slot: item.slot, rarity: item.rarity).frame(width: 42, height: 42)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(HGPalette.rarity(item.rarity))
                Text("\(item.slot.name) • \(item.rarity.name)")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(HGPalette.textMuted)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("+\(item.powerBonus)")
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .foregroundColor(HGPalette.crimson)
                Button {
                    store.sell(item: item)
                } label: {
                    HStack(spacing: 3) {
                        Text("Sell")
                        HGCoinIcon().frame(width: 11, height: 11)
                        Text("\(item.sellValue)")
                    }
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(HGPalette.accentDeep)
                    .padding(.horizontal, 9).padding(.vertical, 5)
                    .background(Capsule().fill(HGPalette.accent.opacity(0.14)))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .hgPanel(corner: HGMetrics.cornerSmall)
    }
}
