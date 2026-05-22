import SwiftUI

struct GuildView: View {
    @EnvironmentObject var store: HeroGuildStore
    @State private var showRecruit = false
    @State private var showInventory = false
    @State private var showPrestige = false

    var body: some View {
        ZStack {
            HGBackground()
            VStack(spacing: 0) {
                HGResourceHeader()
                ScrollView {
                    VStack(spacing: 16) {
                        actionsRow
                        buildingsSection
                        prestigeCard
                        Color.clear.frame(height: 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .frame(maxWidth: 600)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationBarTitle("Guild Hall", displayMode: .inline)
        .sheet(isPresented: $showRecruit) { RecruitView().environmentObject(store) }
        .sheet(isPresented: $showInventory) { InventoryView().environmentObject(store) }
        .sheet(isPresented: $showPrestige) { NewSagaView().environmentObject(store) }
    }

    private var actionsRow: some View {
        HStack(spacing: 12) {
            actionButton("Recruit", AnyView(HGTabHeroesIcon(color: .white, size: 22)), HGPalette.primary) {
                showRecruit = true
            }
            actionButton("Inventory", AnyView(HGItemSigil(slot: .weapon, rarity: .rare)), HGPalette.accentDeep) {
                showInventory = true
            }
        }
    }

    private func actionButton(_ label: String, _ icon: AnyView, _ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                icon.frame(width: 30, height: 30)
                Text(label)
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(HGPalette.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: HGMetrics.corner, style: .continuous)
                    .fill(color.opacity(0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: HGMetrics.corner, style: .continuous)
                            .stroke(color.opacity(0.4), lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var buildingsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("GUILD BUILDINGS")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(1.2)
                .foregroundColor(HGPalette.textMuted)
            ForEach(HGBuildingKind.allCases, id: \.rawValue) { kind in
                BuildingCard(kind: kind)
            }
        }
    }

    private var prestigeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                HGRenownIcon().frame(width: 34, height: 34)
                VStack(alignment: .leading, spacing: 2) {
                    Text("New Saga")
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .foregroundColor(HGPalette.textPrimary)
                    Text("Reset your guild for permanent Renown.")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(HGPalette.textMuted)
                }
            }
            HStack {
                Text("Renown available: ")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(HGPalette.textSecondary)
                + Text("+\(store.pendingRenown)")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(HGPalette.crimson)
                Spacer()
            }
            Button {
                showPrestige = true
            } label: {
                Text(store.canPrestige ? "Begin New Saga" : "Build more renown first")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .fill(store.canPrestige ? HGPalette.crimson : HGPalette.lock)
                    )
            }
            .buttonStyle(.plain)
            .disabled(!store.canPrestige)
        }
        .padding(16)
        .hgPanel()
    }
}

struct BuildingCard: View {
    @EnvironmentObject var store: HeroGuildStore
    let kind: HGBuildingKind

    var body: some View {
        let level = store.buildingLevel(kind)
        let maxed = level >= kind.maxLevel
        let cost = store.upgradeCost(kind)
        let affordable = store.canUpgrade(kind)
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                HGBuildingIcon(kind: kind).frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(kind.name)
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .foregroundColor(HGPalette.textPrimary)
                        Text("Lv \(level)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(HGPalette.primary)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Capsule().fill(HGPalette.primary.opacity(0.12)))
                    }
                    Text(kind.detail)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(HGPalette.textMuted)
                }
                Spacer()
            }
            Text(effectLine(level))
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(HGPalette.success)
            // Level pips.
            HStack(spacing: 4) {
                ForEach(0..<kind.maxLevel, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i < level ? HGPalette.accent : HGPalette.panelInset)
                        .frame(height: 6)
                }
            }
            if maxed {
                Text("Maximum level")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(HGPalette.accentDeep)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12).fill(HGPalette.accent.opacity(0.12)))
            } else {
                Button {
                    store.upgrade(kind)
                } label: {
                    HStack(spacing: 6) {
                        Text("Upgrade")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                        HGCoinIcon().frame(width: 14, height: 14)
                        Text("\(cost)")
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(affordable ? HGPalette.primary : HGPalette.lock)
                    )
                }
                .buttonStyle(.plain)
                .disabled(!affordable)
            }
        }
        .padding(14)
        .hgPanel()
    }

    private func effectLine(_ level: Int) -> String {
        switch kind {
        case .questBoard:
            return "Quest slots: \(HGContent.questSlotCount(boardLevel: level))"
        case .trainingHall:
            let pct = Int((HGContent.xpMultiplier(trainingLevel: level) - 1.0) * 100)
            return "Hero XP gain: +\(pct)%"
        case .forge:
            let pct = Int(Double(level - 1) * 4)
            return "Loot upgrade chance: +\(pct)%"
        case .tavern:
            let pct = Int((1.0 - HGContent.tavernCostMultiplier(tavernLevel: level)) * 100)
            return "Recruit & refresh cost: -\(pct)%"
        case .treasury:
            let pct = Int((HGContent.goldMultiplier(treasuryLevel: level) - 1.0) * 100)
            return "Gold from quests: +\(pct)%"
        }
    }
}
