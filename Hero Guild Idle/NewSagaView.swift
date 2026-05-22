import SwiftUI

struct NewSagaView: View {
    @EnvironmentObject var store: HeroGuildStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var confirming = false

    var body: some View {
        ZStack {
            HGBackground()
            VStack(spacing: 20) {
                Spacer()
                HGRenownIcon().frame(width: 90, height: 90)
                Text("Begin a New Saga")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(HGPalette.textPrimary)
                VStack(spacing: 14) {
                    infoLine("You will gain", "+\(store.pendingRenown) Renown", HGPalette.crimson)
                    infoLine("New total Renown", "\(store.renown + store.pendingRenown)", HGPalette.crimson)
                    infoLine("Permanent bonus", "+\(Int(((1.0 + Double(store.renown + store.pendingRenown) * 0.02) - 1.0) * 100))% gold & loot", HGPalette.success)
                }
                .padding(18)
                .frame(maxWidth: .infinity)
                .hgPanel()
                .padding(.horizontal, 24)

                Text("This resets your heroes, gold, loot, and buildings. Renown and lifetime records are kept forever.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(HGPalette.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
                Button {
                    confirming = true
                } label: {
                    Text("Begin New Saga")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(store.canPrestige ? HGPalette.crimson : HGPalette.lock)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!store.canPrestige)
                .padding(.horizontal, 24)
                Button { presentationMode.wrappedValue.dismiss() } label: {
                    Text("Not yet")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(HGPalette.textMuted)
                }
                .buttonStyle(.plain)
                Color.clear.frame(height: 16)
            }
            .frame(maxWidth: 520)
        }
        .alert(isPresented: $confirming) {
            Alert(
                title: Text("Begin New Saga?"),
                message: Text("Your current guild will be reset. You will gain +\(store.pendingRenown) Renown permanently."),
                primaryButton: .destructive(Text("Begin")) {
                    store.startNewSaga()
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func infoLine(_ label: String, _ value: String, _ color: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(HGPalette.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundColor(color)
        }
    }
}
