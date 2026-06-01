import SwiftUI

struct HowToPlayView: View {
    @Environment(\.presentationMode) private var presentationMode

    private let sections: [(title: String, body: String)] = [
        ("The Guild Loop",
         "Recruit heroes, send them on timed quests, and collect Gold, Loot, and XP when they return. Spend your earnings to upgrade buildings, grow your roster, and become the realm's greatest guild."),
        ("Quests & Timers",
         "Each quest has a Power requirement and a real-time duration. Assign one or more heroes — their combined Power must meet the requirement. Quests keep running even while the app is closed; your heroes will be waiting with rewards when you return."),
        ("Overshoot Rewards",
         "Send more Power than a quest requires and it finishes faster. Big overshoots also improve the quality of the loot you find."),
        ("Heroes & Power",
         "Heroes gain XP from quests and level up, raising their stats. Equip Weapons, Armor, and Trinkets from your Vault to boost their Power even further. Rarer heroes are stronger and grow faster."),
        ("Guild Buildings",
         "Upgrade the Quest Board for more quest slots, the Training Hall for faster leveling, the Forge for better loot, the Tavern for cheaper recruiting, and the Treasury for more gold."),
        ("New Saga (Prestige)",
         "When your guild grows mighty, begin a New Saga. You reset your progress but gain permanent Renown — a forever bonus to all gold and loot. Renown carries across every saga.")
    ]

    var body: some View {
        ZStack {
            HGBackground()
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Text("How to Play")
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .foregroundColor(HGPalette.textPrimary)
                    Spacer()
                }
                .overlay(
                    HStack {
                        Spacer()
                        Button { presentationMode.wrappedValue.dismiss() } label: {
                            Text("Done")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(HGPalette.primary)
                        }
                        .buttonStyle(.plain)
                    }
                )
                .padding(.horizontal, 16).padding(.vertical, 14)
                .background(HGPalette.panel)

                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(0..<sections.count, id: \.self) { i in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(sections[i].title)
                                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                                    .foregroundColor(HGPalette.primary)
                                Text(sections[i].body)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(HGPalette.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .hgPanel()
                        }
                        Color.clear.frame(height: 8)
                    }
                    .padding(.horizontal, 16).padding(.top, 14)
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
