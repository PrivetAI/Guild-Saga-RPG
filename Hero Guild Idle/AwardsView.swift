import SwiftUI

struct AwardsView: View {
    @EnvironmentObject var store: HeroGuildStore

    var body: some View {
        ZStack {
            HGBackground()
            VStack(spacing: 0) {
                HGResourceHeader()
                ScrollView {
                    VStack(spacing: 16) {
                        statsCard
                        achievementsSection
                        Color.clear.frame(height: 8)
                    }
                    .padding(.horizontal, 16).padding(.top, 14)
                    .frame(maxWidth: 600)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationBarTitle("Awards", displayMode: .inline)
    }

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("GUILD RECORDS")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(1.2)
                .foregroundColor(HGPalette.textMuted)
            VStack(spacing: 0) {
                statRow("Quests Completed", "\(store.stats.questsCompleted)")
                divider
                statRow("Gold Earned", "\(store.stats.goldEarned)")
                divider
                statRow("Heroes Recruited", "\(store.stats.heroesRecruited)")
                divider
                statRow("Loot Collected", "\(store.stats.lootCollected)")
                divider
                statRow("Highest Total Power", "\(max(store.stats.highestPower, store.totalPower))")
                divider
                statRow("Sagas Begun", "\(store.stats.sagas)")
                divider
                statRow("Renown", "\(store.renown)")
            }
            .padding(.horizontal, 14)
            .hgPanel()
        }
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("ACHIEVEMENTS")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(1.2)
                    .foregroundColor(HGPalette.textMuted)
                Spacer()
                Text("\(store.unlockedCount) / \(HGAchievements.all.count)")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundColor(HGPalette.accentDeep)
            }
            ForEach(HGAchievements.all) { ach in
                AchievementRow(ach: ach, unlocked: store.unlocked.contains(ach.id), progress: ach.progress(store))
            }
        }
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(HGPalette.textPrimary)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundColor(HGPalette.crimson)
        }
        .padding(.vertical, 11)
    }

    private var divider: some View {
        Rectangle().fill(HGPalette.panelRaised.opacity(0.5)).frame(height: 1)
    }
}

struct AchievementRow: View {
    let ach: HGAchievement
    let unlocked: Bool
    let progress: Int
    var body: some View {
        let clamped = min(progress, ach.goal)
        return HStack(spacing: 12) {
            if unlocked {
                HGMedalShape(color: HGPalette.accent, size: 38)
            } else {
                ZStack {
                    Circle().fill(HGPalette.panelInset).frame(width: 38, height: 38)
                    HGLockGlyph(color: HGPalette.lock, size: 20)
                }
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(ach.title)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(unlocked ? HGPalette.textPrimary : HGPalette.textSecondary)
                Text(ach.detail)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(HGPalette.textMuted)
                if !unlocked && ach.goal > 1 {
                    HGProgressBar(value: Double(clamped) / Double(ach.goal), tint: HGPalette.primary, height: 5)
                        .frame(maxWidth: 160)
                }
            }
            Spacer()
            if unlocked {
                HGCheckGlyph(color: HGPalette.success, size: 22)
            } else if ach.goal > 1 {
                Text("\(clamped)/\(ach.goal)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(HGPalette.textMuted)
            }
        }
        .padding(12)
        .hgPanel(corner: HGMetrics.cornerSmall)
    }
}
