import SwiftUI

/// App shell: a custom HStack tab bar (NOT a TabView) over a `switch` on the selected tab.
struct RootTabView: View {
    @EnvironmentObject var store: GuildSagaStore
    @State private var selectedTab = 0
    @State private var toastTitle: String?

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case 0:
                        NavigationView { QuestsView() }
                            .navigationViewStyle(StackNavigationViewStyle())
                    case 1:
                        NavigationView { HeroesView() }
                            .navigationViewStyle(StackNavigationViewStyle())
                    case 2:
                        NavigationView { GuildView() }
                            .navigationViewStyle(StackNavigationViewStyle())
                    case 3:
                        NavigationView { AwardsView() }
                            .navigationViewStyle(StackNavigationViewStyle())
                    default:
                        NavigationView { MoreView() }
                            .navigationViewStyle(StackNavigationViewStyle())
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                tabBar
            }

            if let title = toastTitle {
                unlockToast(title)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(30)
            }
        }
        // Offline-progress / quest-completion summary popup.
        .sheet(isPresented: Binding(
            get: { !store.pendingResults.isEmpty },
            set: { if !$0 { store.pendingResults = [] } }
        )) {
            QuestResultsView(results: store.pendingResults) {
                store.pendingResults = []
            }
        }
        .onChange(of: store.lastUnlocked) { ids in
            guard let first = ids.first,
                  let ach = HGAchievements.byId(first) else { return }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                toastTitle = ach.title
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    toastTitle = nil
                }
                store.lastUnlocked = []
            }
        }
    }

    private func unlockToast(_ title: String) -> some View {
        VStack {
            HStack(spacing: 10) {
                HGMedalShape(color: HGPalette.accent, size: 32)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Achievement Unlocked")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(0.8)
                        .foregroundColor(HGPalette.textMuted)
                    Text(title)
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundColor(HGPalette.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(HGPalette.panel)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(HGPalette.accent.opacity(0.5), lineWidth: 1.5)
                    )
            )
            .padding(.horizontal, 16)
            .padding(.top, 8)
            Spacer()
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(0, "Quests", AnyView(HGTabQuestsIcon(color: tint(0), size: 24)))
            tabButton(1, "Heroes", AnyView(HGTabHeroesIcon(color: tint(1), size: 24)))
            tabButton(2, "Guild", AnyView(HGTabGuildIcon(color: tint(2), size: 24)))
            tabButton(3, "Awards", AnyView(HGTabAwardsIcon(color: tint(3), size: 24)))
            tabButton(4, "More", AnyView(HGTabMoreIcon(color: tint(4), size: 24)))
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(HGPalette.panel.edgesIgnoringSafeArea(.bottom))
        .overlay(
            Rectangle()
                .fill(HGPalette.panelRaised.opacity(0.8))
                .frame(height: 1),
            alignment: .top
        )
    }

    private func tint(_ i: Int) -> Color { selectedTab == i ? HGPalette.primary : HGPalette.textMuted }

    private func tabButton(_ i: Int, _ label: String, _ icon: AnyView) -> some View {
        Button {
            selectedTab = i
        } label: {
            VStack(spacing: 3) {
                icon
                    .frame(height: 26)
                Text(label)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(tint(i))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// Shared resource header used at the top of game tabs.
struct HGResourceHeader: View {
    @EnvironmentObject var store: GuildSagaStore
    var body: some View {
        HStack(spacing: 10) {
            resource(AnyView(HGCoinIcon()), "\(store.gold)", HGPalette.accentDeep)
            resource(AnyView(HGTokenIcon()), "\(store.tokens)", HGPalette.primary)
            resource(AnyView(HGRenownIcon()), "\(store.renown)", HGPalette.crimson)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(HGPalette.panel.opacity(0.9))
        .overlay(
            Rectangle().fill(HGPalette.panelRaised.opacity(0.6)).frame(height: 1),
            alignment: .bottom
        )
    }
    private func resource(_ icon: AnyView, _ value: String, _ color: Color) -> some View {
        HStack(spacing: 5) {
            icon.frame(width: 18, height: 18)
            Text(value)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundColor(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(color.opacity(0.10)))
    }
}
