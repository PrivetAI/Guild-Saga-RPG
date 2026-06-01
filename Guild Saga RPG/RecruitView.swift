import SwiftUI

struct RecruitView: View {
    @EnvironmentObject var store: GuildSagaStore
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        ZStack {
            HGBackground()
            VStack(spacing: 0) {
                header
                HGResourceHeader()
                ScrollView {
                    VStack(spacing: 12) {
                        Text("Recruit heroes to grow your guild. The pool refreshes the available adventurers.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(HGPalette.textMuted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if store.recruitPool.isEmpty {
                            Text("No heroes available — refresh the pool.")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(HGPalette.textSecondary)
                                .padding(.top, 30)
                        } else {
                            ForEach(Array(store.recruitPool.enumerated()), id: \.offset) { idx, defId in
                                RecruitCard(poolIndex: idx, defId: defId)
                            }
                        }
                        refreshButton
                        Color.clear.frame(height: 8)
                    }
                    .padding(.horizontal, 16).padding(.top, 14)
                    .frame(maxWidth: 600)
                    .frame(maxWidth: .infinity)
                }
            }
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
            Text("Tavern")
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundColor(HGPalette.textPrimary)
            Spacer()
            Text("Close").font(.system(size: 15)).opacity(0)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(HGPalette.panel)
    }

    private var refreshButton: some View {
        Button {
            store.refreshRecruitPool()
        } label: {
            HStack(spacing: 6) {
                Text("Refresh Pool")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                HGCoinIcon().frame(width: 14, height: 14)
                Text("\(store.refreshCost)")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(store.gold >= store.refreshCost ? HGPalette.accentDeep : HGPalette.lock)
            )
        }
        .buttonStyle(.plain)
        .disabled(store.gold < store.refreshCost)
        .padding(.top, 4)
    }
}

struct RecruitCard: View {
    @EnvironmentObject var store: GuildSagaStore
    let poolIndex: Int
    let defId: String

    var body: some View {
        let def = HGContent.heroDef(defId)
        let usesTokens = def.tokenCost > 0
        let goldCost = store.recruitGoldCost(defId)
        let canAfford = store.canRecruit(defId)
        return HStack(spacing: 12) {
            HGHeroCrest(heroClass: def.heroClass, rarity: def.rarity)
                .frame(width: 50, height: 50)
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(def.name)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(HGPalette.textPrimary)
                    Text(def.rarity.name)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(HGPalette.rarity(def.rarity))
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Capsule().fill(HGPalette.rarity(def.rarity).opacity(0.14)))
                }
                Text("\(def.heroClass.name) • Base Power \(Int((Double(def.basePower) * def.rarity.powerMultiplier).rounded()))")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(HGPalette.textMuted)
            }
            Spacer()
            Button {
                store.recruit(poolIndex: poolIndex)
            } label: {
                HStack(spacing: 4) {
                    if usesTokens {
                        HGTokenIcon().frame(width: 13, height: 13)
                        Text("\(def.tokenCost)")
                    } else {
                        HGCoinIcon().frame(width: 13, height: 13)
                        Text("\(goldCost)")
                    }
                }
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 12).padding(.vertical, 9)
                .background(Capsule().fill(canAfford ? HGPalette.primary : HGPalette.lock))
            }
            .buttonStyle(.plain)
            .disabled(!canAfford)
        }
        .padding(12)
        .hgPanel()
    }
}
