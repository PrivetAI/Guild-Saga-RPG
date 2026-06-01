import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var store: GuildSagaStore
    @State private var page = 0

    private let pages: [(title: String, body: String)] = [
        ("Welcome, Guildmaster",
         "Your guild hall awaits. Recruit heroes, send them on quests, and grow your renown across many sagas."),
        ("Send Heroes on Quests",
         "Assign heroes to quests on the Quest board. Their combined Power must meet the requirement. Quests run in real time — even while the app is closed."),
        ("Grow & Equip",
         "Collect Gold, Loot, and XP. Equip gear to raise a hero's Power, upgrade your guild buildings, and unlock more quest slots."),
        ("Begin a New Saga",
         "When your guild is mighty, start a New Saga to earn permanent Renown — a forever bonus to your gold and loot.")
    ]

    var body: some View {
        ZStack {
            HGBackground()
            VStack(spacing: 24) {
                Spacer()
                HGCrestShape()
                    .frame(width: 96, height: 96)
                Text(pages[page].title)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(HGPalette.textPrimary)
                    .multilineTextAlignment(.center)
                Text(pages[page].body)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(HGPalette.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Circle()
                            .fill(i == page ? HGPalette.primary : HGPalette.panelRaised)
                            .frame(width: 8, height: 8)
                    }
                }
                Button {
                    if page < pages.count - 1 {
                        withAnimation { page += 1 }
                    } else {
                        store.markOnboardingDone()
                        withAnimation { isPresented = false }
                    }
                } label: {
                    Text(page < pages.count - 1 ? "Next" : "Enter the Guild")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(HGPalette.primary)
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 28)

                if page < pages.count - 1 {
                    Button {
                        store.markOnboardingDone()
                        withAnimation { isPresented = false }
                    } label: {
                        Text("Skip")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(HGPalette.textMuted)
                    }
                    .buttonStyle(.plain)
                }
                Color.clear.frame(height: 12)
            }
            .frame(maxWidth: 520)
        }
    }
}
