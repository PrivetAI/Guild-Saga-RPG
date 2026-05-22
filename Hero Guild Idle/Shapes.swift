import SwiftUI

// All icons / art are custom SwiftUI Shapes — no SF Symbols, no emoji, no system images.

// MARK: - Generic shield outline path (used as crest base)

struct HGShieldPath: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to: CGPoint(x: w * 0.5, y: 0))
        p.addLine(to: CGPoint(x: w, y: h * 0.16))
        p.addLine(to: CGPoint(x: w, y: h * 0.52))
        p.addCurve(to: CGPoint(x: w * 0.5, y: h),
                   control1: CGPoint(x: w, y: h * 0.80),
                   control2: CGPoint(x: w * 0.74, y: h * 0.94))
        p.addCurve(to: CGPoint(x: 0, y: h * 0.52),
                   control1: CGPoint(x: w * 0.26, y: h * 0.94),
                   control2: CGPoint(x: 0, y: h * 0.80))
        p.addLine(to: CGPoint(x: 0, y: h * 0.16))
        p.closeSubpath()
        return p
    }
}

// MARK: - Guild crest (loading + brand mark)

struct HGCrestShape: View {
    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            ZStack {
                HGShieldPath()
                    .fill(HGPalette.primary)
                    .frame(width: s * 0.86, height: s * 0.94)
                HGShieldPath()
                    .stroke(HGPalette.accent, lineWidth: s * 0.05)
                    .frame(width: s * 0.86, height: s * 0.94)
                HGStarBurst(points: 5)
                    .fill(HGPalette.accentLight)
                    .frame(width: s * 0.40, height: s * 0.40)
                    .offset(y: -s * 0.04)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Star burst (sharp star polygon)

struct HGStarBurst: Shape {
    var points: Int = 5
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * 0.45
        let n = max(3, points)
        for i in 0..<(n * 2) {
            let r = i.isMultiple(of: 2) ? outer : inner
            let angle = -Double.pi / 2 + Double(i) * Double.pi / Double(n)
            let pt = CGPoint(x: c.x + CGFloat(cos(angle)) * r, y: c.y + CGFloat(sin(angle)) * r)
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        p.closeSubpath()
        return p
    }
}

// MARK: - Laurel ring (loading spinner ornament)

struct HGLaurelShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        // Two arcs leaving a gap at the top.
        p.addArc(center: c, radius: r, startAngle: .degrees(20), endAngle: .degrees(160), clockwise: false)
        p.move(to: CGPoint(x: c.x + cos(.pi * 200/180) * r, y: c.y + sin(.pi * 200/180) * r))
        p.addArc(center: c, radius: r, startAngle: .degrees(200), endAngle: .degrees(340), clockwise: false)
        return p
    }
}

// MARK: - Class sigils (one distinct shape per hero class)

struct HGClassSigil: View {
    let heroClass: HGHeroClass
    var color: Color
    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            ZStack {
                switch heroClass {
                case .warrior: warrior(s)
                case .mage: mage(s)
                case .ranger: ranger(s)
                case .cleric: cleric(s)
                case .rogue: rogue(s)
                case .paladin: paladin(s)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    // Crossed swords
    private func warrior(_ s: CGFloat) -> some View {
        ZStack {
            sword(s).rotationEffect(.degrees(45))
            sword(s).rotationEffect(.degrees(-45))
        }
    }
    private func sword(_ s: CGFloat) -> some View {
        ZStack {
            Capsule().fill(color).frame(width: s * 0.10, height: s * 0.66)
            Capsule().fill(color).frame(width: s * 0.34, height: s * 0.08).offset(y: s * 0.16)
        }
    }

    // Mage: starburst over circle (orb)
    private func mage(_ s: CGFloat) -> some View {
        ZStack {
            Circle().stroke(color, lineWidth: s * 0.07).frame(width: s * 0.5, height: s * 0.5)
            HGStarBurst(points: 4).fill(color).frame(width: s * 0.6, height: s * 0.6)
        }
    }

    // Ranger: bow + arrow
    private func ranger(_ s: CGFloat) -> some View {
        ZStack {
            HGBowPath().stroke(color, lineWidth: s * 0.07).frame(width: s * 0.6, height: s * 0.7)
            // arrow
            Capsule().fill(color).frame(width: s * 0.6, height: s * 0.06)
            Path { p in
                p.move(to: CGPoint(x: s * 0.74, y: s * 0.5))
                p.addLine(to: CGPoint(x: s * 0.62, y: s * 0.40))
                p.move(to: CGPoint(x: s * 0.74, y: s * 0.5))
                p.addLine(to: CGPoint(x: s * 0.62, y: s * 0.60))
            }.stroke(color, lineWidth: s * 0.05)
        }
    }

    // Cleric: cross / chalice
    private func cleric(_ s: CGFloat) -> some View {
        ZStack {
            Capsule().fill(color).frame(width: s * 0.12, height: s * 0.62)
            Capsule().fill(color).frame(width: s * 0.40, height: s * 0.12).offset(y: -s * 0.10)
            Circle().fill(color).frame(width: s * 0.16, height: s * 0.16).offset(y: -s * 0.30)
        }
    }

    // Rogue: dagger + drop
    private func rogue(_ s: CGFloat) -> some View {
        ZStack {
            Path { p in
                p.move(to: CGPoint(x: s * 0.5, y: s * 0.12))
                p.addLine(to: CGPoint(x: s * 0.6, y: s * 0.6))
                p.addLine(to: CGPoint(x: s * 0.5, y: s * 0.72))
                p.addLine(to: CGPoint(x: s * 0.4, y: s * 0.6))
                p.closeSubpath()
            }.fill(color)
            Capsule().fill(color).frame(width: s * 0.34, height: s * 0.08).offset(y: s * 0.04)
        }
    }

    // Paladin: shield + cross
    private func paladin(_ s: CGFloat) -> some View {
        ZStack {
            HGShieldPath().stroke(color, lineWidth: s * 0.07).frame(width: s * 0.56, height: s * 0.62)
            Capsule().fill(color).frame(width: s * 0.08, height: s * 0.34)
            Capsule().fill(color).frame(width: s * 0.26, height: s * 0.08).offset(y: -s * 0.04)
        }
    }
}

struct HGBowPath: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to: CGPoint(x: w * 0.7, y: 0))
        p.addCurve(to: CGPoint(x: w * 0.7, y: h),
                   control1: CGPoint(x: w * -0.2, y: h * 0.3),
                   control2: CGPoint(x: w * -0.2, y: h * 0.7))
        return p
    }
}

// MARK: - Hero crest (shield framed sigil, colored by rarity)

struct HGHeroCrest: View {
    let heroClass: HGHeroClass
    let rarity: HGRarity
    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            let rc = HGPalette.rarity(rarity)
            ZStack {
                HGShieldPath()
                    .fill(rc.opacity(0.18))
                    .frame(width: s * 0.92, height: s * 0.98)
                HGShieldPath()
                    .stroke(rc, lineWidth: s * 0.06)
                    .frame(width: s * 0.92, height: s * 0.98)
                HGClassSigil(heroClass: heroClass, color: rc)
                    .frame(width: s * 0.56, height: s * 0.56)
                    .offset(y: -s * 0.02)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Item sigil (per slot)

struct HGItemSigil: View {
    let slot: HGSlot
    let rarity: HGRarity
    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            let rc = HGPalette.rarity(rarity)
            ZStack {
                RoundedRectangle(cornerRadius: s * 0.22, style: .continuous)
                    .fill(rc.opacity(0.16))
                    .frame(width: s * 0.9, height: s * 0.9)
                RoundedRectangle(cornerRadius: s * 0.22, style: .continuous)
                    .stroke(rc, lineWidth: s * 0.05)
                    .frame(width: s * 0.9, height: s * 0.9)
                glyph(s, rc)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
    @ViewBuilder private func glyph(_ s: CGFloat, _ rc: Color) -> some View {
        switch slot {
        case .weapon:
            ZStack {
                Capsule().fill(rc).frame(width: s * 0.10, height: s * 0.5)
                Capsule().fill(rc).frame(width: s * 0.32, height: s * 0.08).offset(y: s * 0.1)
            }.rotationEffect(.degrees(45))
        case .armor:
            HGShieldPath().fill(rc).frame(width: s * 0.42, height: s * 0.48)
        case .trinket:
            ZStack {
                Circle().stroke(rc, lineWidth: s * 0.06).frame(width: s * 0.4, height: s * 0.4)
                Circle().fill(rc).frame(width: s * 0.14, height: s * 0.14)
            }
        }
    }
}

// MARK: - Quest banner mark (per tier)

struct HGQuestMark: View {
    let tier: HGQuestTier
    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            let c = tierColor
            ZStack {
                // Banner / pennant
                HGPennantPath()
                    .fill(c.opacity(0.18))
                    .frame(width: s * 0.7, height: s * 0.9)
                HGPennantPath()
                    .stroke(c, lineWidth: s * 0.05)
                    .frame(width: s * 0.7, height: s * 0.9)
                HGStarBurst(points: 5)
                    .fill(c)
                    .frame(width: s * 0.3, height: s * 0.3)
                    .offset(y: -s * 0.06)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
    private var tierColor: Color {
        switch tier {
        case .easy: return HGPalette.success
        case .hard: return HGPalette.primary
        case .elite: return HGPalette.crimson
        case .legendary: return HGPalette.accent
        }
    }
}

struct HGPennantPath: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to: CGPoint(x: 0, y: 0))
        p.addLine(to: CGPoint(x: w, y: 0))
        p.addLine(to: CGPoint(x: w, y: h * 0.78))
        p.addLine(to: CGPoint(x: w * 0.5, y: h))
        p.addLine(to: CGPoint(x: 0, y: h * 0.78))
        p.closeSubpath()
        return p
    }
}

// MARK: - Resource icons (gold coin, token, renown laurel)

struct HGCoinIcon: View {
    var color: Color = HGPalette.accent
    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            ZStack {
                Circle().fill(color).frame(width: s * 0.9, height: s * 0.9)
                Circle().stroke(HGPalette.accentDeep, lineWidth: s * 0.07).frame(width: s * 0.9, height: s * 0.9)
                HGStarBurst(points: 5).fill(HGPalette.accentDeep.opacity(0.6)).frame(width: s * 0.42, height: s * 0.42)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

struct HGTokenIcon: View {
    var color: Color = HGPalette.primary
    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            ZStack {
                HGGemPath().fill(color).frame(width: s * 0.78, height: s * 0.84)
                HGGemPath().stroke(HGPalette.primaryDeep, lineWidth: s * 0.05).frame(width: s * 0.78, height: s * 0.84)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

struct HGGemPath: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to: CGPoint(x: w * 0.5, y: 0))
        p.addLine(to: CGPoint(x: w, y: h * 0.36))
        p.addLine(to: CGPoint(x: w * 0.5, y: h))
        p.addLine(to: CGPoint(x: 0, y: h * 0.36))
        p.closeSubpath()
        return p
    }
}

struct HGRenownIcon: View {
    var color: Color = HGPalette.crimson
    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            ZStack {
                HGLaurelShape().stroke(color, lineWidth: s * 0.09).frame(width: s * 0.86, height: s * 0.86)
                HGStarBurst(points: 6).fill(color).frame(width: s * 0.36, height: s * 0.36)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Building icons

struct HGBuildingIcon: View {
    let kind: HGBuildingKind
    var color: Color = HGPalette.primary
    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            ZStack {
                switch kind {
                case .questBoard: questBoard(s)
                case .trainingHall: trainingHall(s)
                case .forge: forge(s)
                case .tavern: tavern(s)
                case .treasury: treasury(s)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private func questBoard(_ s: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: s * 0.08).stroke(color, lineWidth: s * 0.06)
                .frame(width: s * 0.66, height: s * 0.56)
            ForEach(0..<3, id: \.self) { i in
                Capsule().fill(color).frame(width: s * 0.42, height: s * 0.05)
                    .offset(y: -s * 0.12 + CGFloat(i) * s * 0.14)
            }
        }
    }
    private func trainingHall(_ s: CGFloat) -> some View {
        ZStack {
            // dumbbell-ish training bar
            Capsule().fill(color).frame(width: s * 0.5, height: s * 0.07)
            ForEach(0..<2, id: \.self) { i in
                RoundedRectangle(cornerRadius: s * 0.04).fill(color)
                    .frame(width: s * 0.10, height: s * 0.3)
                    .offset(x: i == 0 ? -s * 0.26 : s * 0.26)
            }
        }
    }
    private func forge(_ s: CGFloat) -> some View {
        ZStack {
            // anvil
            HGAnvilPath().fill(color).frame(width: s * 0.66, height: s * 0.5)
        }
    }
    private func tavern(_ s: CGFloat) -> some View {
        ZStack {
            // mug
            RoundedRectangle(cornerRadius: s * 0.06).fill(color)
                .frame(width: s * 0.4, height: s * 0.5)
            Circle().stroke(color, lineWidth: s * 0.06)
                .frame(width: s * 0.22, height: s * 0.22).offset(x: s * 0.28)
            RoundedRectangle(cornerRadius: s * 0.04).fill(HGPalette.panel)
                .frame(width: s * 0.4, height: s * 0.1).offset(y: -s * 0.16)
        }
    }
    private func treasury(_ s: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: s * 0.08).stroke(color, lineWidth: s * 0.06)
                .frame(width: s * 0.6, height: s * 0.46).offset(y: s * 0.06)
            // lid
            HGChestLidPath().stroke(color, lineWidth: s * 0.06)
                .frame(width: s * 0.6, height: s * 0.22).offset(y: -s * 0.16)
            Circle().fill(color).frame(width: s * 0.1, height: s * 0.1).offset(y: s * 0.06)
        }
    }
}

struct HGAnvilPath: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to: CGPoint(x: w * 0.1, y: h * 0.2))
        p.addLine(to: CGPoint(x: w * 0.95, y: h * 0.2))
        p.addLine(to: CGPoint(x: w * 0.78, y: h * 0.45))
        p.addLine(to: CGPoint(x: w * 0.6, y: h * 0.45))
        p.addLine(to: CGPoint(x: w * 0.6, y: h * 0.75))
        p.addLine(to: CGPoint(x: w * 0.78, y: h))
        p.addLine(to: CGPoint(x: w * 0.22, y: h))
        p.addLine(to: CGPoint(x: w * 0.4, y: h * 0.75))
        p.addLine(to: CGPoint(x: w * 0.4, y: h * 0.45))
        p.addLine(to: CGPoint(x: w * 0.1, y: h * 0.45))
        p.closeSubpath()
        return p
    }
}

struct HGChestLidPath: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to: CGPoint(x: 0, y: h))
        p.addArc(center: CGPoint(x: w * 0.5, y: h),
                 radius: w * 0.5, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
        return p
    }
}

// MARK: - Small UI glyphs

struct HGChevron: View {
    var color: Color = HGPalette.textMuted
    var size: CGFloat = 18
    var body: some View {
        Path { p in
            p.move(to: CGPoint(x: size * 0.35, y: size * 0.25))
            p.addLine(to: CGPoint(x: size * 0.62, y: size * 0.5))
            p.addLine(to: CGPoint(x: size * 0.35, y: size * 0.75))
        }
        .stroke(color, style: StrokeStyle(lineWidth: size * 0.11, lineCap: .round, lineJoin: .round))
        .frame(width: size, height: size)
    }
}

struct HGPlusGlyph: View {
    var color: Color = .white
    var size: CGFloat = 18
    var body: some View {
        ZStack {
            Capsule().fill(color).frame(width: size * 0.7, height: size * 0.14)
            Capsule().fill(color).frame(width: size * 0.14, height: size * 0.7)
        }
        .frame(width: size, height: size)
    }
}

struct HGCheckGlyph: View {
    var color: Color = HGPalette.success
    var size: CGFloat = 18
    var body: some View {
        Path { p in
            p.move(to: CGPoint(x: size * 0.22, y: size * 0.52))
            p.addLine(to: CGPoint(x: size * 0.42, y: size * 0.72))
            p.addLine(to: CGPoint(x: size * 0.78, y: size * 0.28))
        }
        .stroke(color, style: StrokeStyle(lineWidth: size * 0.12, lineCap: .round, lineJoin: .round))
        .frame(width: size, height: size)
    }
}

struct HGLockGlyph: View {
    var color: Color = HGPalette.lock
    var size: CGFloat = 18
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.12).fill(color)
                .frame(width: size * 0.62, height: size * 0.46).offset(y: size * 0.12)
            Path { p in
                p.addArc(center: CGPoint(x: size * 0.5, y: size * 0.38), radius: size * 0.18,
                         startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
            }.stroke(color, lineWidth: size * 0.08)
        }
        .frame(width: size, height: size)
    }
}

struct HGMedalShape: View {
    var color: Color = HGPalette.accent
    var size: CGFloat = 32
    var body: some View {
        ZStack {
            Circle().fill(color.opacity(0.2)).frame(width: size, height: size)
            Circle().stroke(color, lineWidth: size * 0.07).frame(width: size, height: size)
            HGStarBurst(points: 5).fill(color).frame(width: size * 0.5, height: size * 0.5)
        }
        .frame(width: size, height: size)
    }
}

struct HGStar: View {
    var filled: Bool
    var size: CGFloat = 14
    var color: Color = HGPalette.accent
    var body: some View {
        HGStarBurst(points: 5)
            .fill(filled ? color : HGPalette.panelRaised)
            .frame(width: size, height: size)
    }
}

// MARK: - Tab bar icons

struct HGTabQuestsIcon: View {
    var color: Color
    var size: CGFloat = 24
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.12).stroke(color, lineWidth: size * 0.10)
                .frame(width: size * 0.74, height: size * 0.86)
            ForEach(0..<3, id: \.self) { i in
                Capsule().fill(color).frame(width: size * 0.44, height: size * 0.07)
                    .offset(y: -size * 0.18 + CGFloat(i) * size * 0.18)
            }
        }
        .frame(width: size, height: size)
    }
}

struct HGTabHeroesIcon: View {
    var color: Color
    var size: CGFloat = 24
    var body: some View {
        HGShieldPath().stroke(color, lineWidth: size * 0.10)
            .frame(width: size * 0.74, height: size * 0.86)
            .overlay(
                Circle().fill(color).frame(width: size * 0.18, height: size * 0.18).offset(y: -size * 0.04)
            )
    }
}

struct HGTabGuildIcon: View {
    var color: Color
    var size: CGFloat = 24
    var body: some View {
        ZStack {
            // tower / hall
            Path { p in
                p.move(to: CGPoint(x: size * 0.5, y: size * 0.1))
                p.addLine(to: CGPoint(x: size * 0.88, y: size * 0.4))
                p.addLine(to: CGPoint(x: size * 0.12, y: size * 0.4))
                p.closeSubpath()
            }.fill(color)
            RoundedRectangle(cornerRadius: size * 0.05).stroke(color, lineWidth: size * 0.09)
                .frame(width: size * 0.6, height: size * 0.42).offset(y: size * 0.18)
        }
        .frame(width: size, height: size)
    }
}

struct HGTabAwardsIcon: View {
    var color: Color
    var size: CGFloat = 24
    var body: some View {
        HGMedalShape(color: color, size: size)
    }
}

struct HGTabMoreIcon: View {
    var color: Color
    var size: CGFloat = 24
    var body: some View {
        HStack(spacing: size * 0.14) {
            ForEach(0..<3, id: \.self) { _ in
                Circle().fill(color).frame(width: size * 0.18, height: size * 0.18)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Progress bar (parchment styled)

struct HGProgressBar: View {
    var value: Double          // 0..1
    var tint: Color = HGPalette.primary
    var height: CGFloat = 8
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(HGPalette.panelInset)
                Capsule().fill(tint)
                    .frame(width: max(0, min(1, value)) * geo.size.width)
            }
        }
        .frame(height: height)
    }
}
