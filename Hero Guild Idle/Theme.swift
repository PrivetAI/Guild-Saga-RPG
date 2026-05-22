import SwiftUI

// Fantasy guild-hall palette — parchment/cream background, royal blue primary,
// gold accent, crimson highlights, dark ink text.
enum HGPalette {
    static let background = Color(red: 0.96, green: 0.93, blue: 0.85)      // parchment
    static let backgroundDeep = Color(red: 0.91, green: 0.86, blue: 0.74)  // aged parchment
    static let panel = Color(red: 0.99, green: 0.97, blue: 0.91)           // cream card
    static let panelRaised = Color(red: 0.86, green: 0.79, blue: 0.64)     // card border
    static let panelInset = Color(red: 0.93, green: 0.89, blue: 0.79)      // inset wells

    static let primary = Color(red: 0.16, green: 0.27, blue: 0.55)         // royal blue
    static let primaryDeep = Color(red: 0.10, green: 0.18, blue: 0.40)
    static let primaryLight = Color(red: 0.30, green: 0.44, blue: 0.74)

    static let accent = Color(red: 0.84, green: 0.65, blue: 0.18)          // gold
    static let accentDeep = Color(red: 0.68, green: 0.50, blue: 0.10)
    static let accentLight = Color(red: 0.95, green: 0.80, blue: 0.36)

    static let crimson = Color(red: 0.70, green: 0.15, blue: 0.18)         // crimson highlight
    static let crimsonDeep = Color(red: 0.54, green: 0.09, blue: 0.13)

    static let textPrimary = Color(red: 0.18, green: 0.14, blue: 0.10)     // dark ink
    static let textSecondary = Color(red: 0.40, green: 0.34, blue: 0.26)
    static let textMuted = Color(red: 0.55, green: 0.49, blue: 0.40)

    static let success = Color(red: 0.22, green: 0.52, blue: 0.30)         // emerald
    static let successLight = Color(red: 0.40, green: 0.68, blue: 0.45)
    static let lock = Color(red: 0.62, green: 0.57, blue: 0.48)

    // Rarity colors (Common -> Legendary)
    static func rarity(_ r: HGRarity) -> Color {
        switch r {
        case .common:    return Color(red: 0.52, green: 0.50, blue: 0.46)  // slate
        case .uncommon:  return Color(red: 0.30, green: 0.54, blue: 0.34)  // green
        case .rare:      return Color(red: 0.20, green: 0.40, blue: 0.70)  // blue
        case .epic:      return Color(red: 0.52, green: 0.30, blue: 0.66)  // purple
        case .legendary: return Color(red: 0.84, green: 0.55, blue: 0.13)  // gold-orange
        }
    }
}

enum HGMetrics {
    static let corner: CGFloat = 16
    static let cornerSmall: CGFloat = 10
}

// Reusable raised parchment panel.
struct HGPanelModifier: ViewModifier {
    var corner: CGFloat = HGMetrics.corner
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(HGPalette.panel)
                    .overlay(
                        RoundedRectangle(cornerRadius: corner, style: .continuous)
                            .stroke(HGPalette.panelRaised, lineWidth: 1.5)
                    )
            )
    }
}

extension View {
    func hgPanel(corner: CGFloat = HGMetrics.corner) -> some View {
        modifier(HGPanelModifier(corner: corner))
    }
}

// Background gradient used across screens.
struct HGBackground: View {
    var body: some View {
        LinearGradient(
            colors: [HGPalette.background, HGPalette.backgroundDeep],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// A small pill chip used for resource readouts and tags.
struct HGChip: View {
    let text: String
    var color: Color = HGPalette.primary
    var icon: AnyView? = nil
    var body: some View {
        HStack(spacing: 5) {
            if let icon = icon { icon }
            Text(text)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule().fill(color.opacity(0.12))
        )
    }
}
