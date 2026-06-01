import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: GuildSagaStore
    @State private var showOnboarding = false

    var body: some View {
        ZStack {
            RootTabView()

            if showOnboarding {
                OnboardingView(isPresented: $showOnboarding)
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .onAppear {
            if !store.onboardingDone {
                showOnboarding = true
            }
        }
    }
}
