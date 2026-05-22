import SwiftUI

// Splash shown while the launch check runs.
struct HeroGuildLoadingScreen: View {
    @State private var spin = false
    @State private var pulse = false

    var body: some View {
        ZStack {
            HGBackground()
            VStack(spacing: 28) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(HGPalette.panel)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(HGPalette.panelRaised, lineWidth: 2)
                        )
                        .frame(width: 132, height: 132)
                    HGLaurelShape()
                        .stroke(HGPalette.accent.opacity(0.4), lineWidth: 3)
                        .frame(width: 112, height: 112)
                        .rotationEffect(.degrees(spin ? 360 : 0))
                    HGCrestShape()
                        .frame(width: 68, height: 68)
                        .scaleEffect(pulse ? 1.06 : 0.94)
                }
                Text("HERO GUILD IDLE")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .tracking(2)
                    .foregroundColor(HGPalette.textPrimary)
                Text("Opening the guild hall…")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(HGPalette.textSecondary)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2.6).repeatForever(autoreverses: false)) { spin = true }
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) { pulse = true }
        }
    }
}
