import SwiftUI

struct QuestsView: View {
    @EnvironmentObject var store: HeroGuildStore
    @State private var assignSlotIndex: Int? = nil

    var body: some View {
        ZStack {
            HGBackground()
            VStack(spacing: 0) {
                HGResourceHeader()
                ScrollView {
                    VStack(spacing: 16) {
                        slotsSection
                        availableSection
                        Color.clear.frame(height: 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .frame(maxWidth: 600)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationBarTitle("Quest Board", displayMode: .inline)
        .sheet(item: Binding(
            get: { assignSlotIndex.map { IdentifiableInt(value: $0) } },
            set: { assignSlotIndex = $0?.value }
        )) { wrapped in
            AssignQuestView(slotIndex: wrapped.value)
                .environmentObject(store)
        }
    }

    private var slotsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Quest Slots")
            ForEach(store.slots) { slot in
                QuestSlotCard(slot: slot) {
                    assignSlotIndex = slot.id
                }
            }
        }
    }

    private var availableSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Quest Log")
            Text("Tap an empty slot above to choose a quest and assign heroes.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(HGPalette.textMuted)
                .padding(.bottom, 2)
            ForEach(HGContent.questDefs, id: \.id) { quest in
                QuestInfoRow(quest: quest)
            }
        }
    }

    private func sectionHeader(_ t: String) -> some View {
        Text(t.uppercased())
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .tracking(1.2)
            .foregroundColor(HGPalette.textMuted)
    }
}

struct IdentifiableInt: Identifiable {
    let value: Int
    var id: Int { value }
}

// MARK: - Quest slot card (active = countdown, idle = tap to assign)

struct QuestSlotCard: View {
    @EnvironmentObject var store: HeroGuildStore
    let slot: HGQuestSlot
    let onAssign: () -> Void

    var body: some View {
        if slot.isActive, let questId = slot.questDefId, let quest = HGContent.questDef(questId) {
            activeCard(quest)
        } else {
            idleCard
        }
    }

    private func activeCard(_ quest: HGQuestDef) -> some View {
        let remaining = store.remaining(forSlot: slot, at: store.now)
        let prog = store.progress(forSlot: slot, at: store.now)
        let done = remaining <= 0
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                HGQuestMark(tier: quest.tier).frame(width: 38, height: 38)
                VStack(alignment: .leading, spacing: 2) {
                    Text(quest.name)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(HGPalette.textPrimary)
                    Text("\(quest.tier.name) • \(slot.assignedHeroIds.count) hero\(slot.assignedHeroIds.count == 1 ? "" : "es")")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(HGPalette.textMuted)
                }
                Spacer()
                if done {
                    Text("Complete!")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundColor(HGPalette.success)
                } else {
                    Text(HGFormat.duration(remaining))
                        .font(.system(size: 17, weight: .heavy, design: .rounded).monospacedDigit())
                        .foregroundColor(HGPalette.primary)
                }
            }
            HGProgressBar(value: done ? 1.0 : prog, tint: done ? HGPalette.success : HGPalette.primary)
            HStack(spacing: 6) {
                ForEach(slot.assignedHeroIds, id: \.self) { hid in
                    if let h = store.hero(byId: hid) {
                        HGHeroCrest(heroClass: h.def.heroClass, rarity: h.def.rarity)
                            .frame(width: 22, height: 22)
                    }
                }
                Spacer()
                Button {
                    store.cancelQuest(slotIndex: slot.id)
                } label: {
                    Text("Cancel")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(HGPalette.crimson)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .hgPanel()
    }

    private var idleCard: some View {
        Button(action: onAssign) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(HGPalette.panelInset)
                        .frame(width: 44, height: 44)
                    HGPlusGlyph(color: HGPalette.primary, size: 22)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Empty Slot")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(HGPalette.textPrimary)
                    Text("Tap to send heroes on a quest")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(HGPalette.textMuted)
                }
                Spacer()
                HGChevron(color: HGPalette.textMuted, size: 18)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: HGMetrics.corner, style: .continuous)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    .foregroundColor(HGPalette.panelRaised)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quest info row (read-only catalog entry)

struct QuestInfoRow: View {
    let quest: HGQuestDef
    var body: some View {
        HStack(spacing: 12) {
            HGQuestMark(tier: quest.tier).frame(width: 34, height: 34)
            VStack(alignment: .leading, spacing: 2) {
                Text(quest.name)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(HGPalette.textPrimary)
                HStack(spacing: 8) {
                    Text("Power \(quest.requiredPower)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(HGPalette.crimson)
                    Text(HGFormat.duration(TimeInterval(quest.durationSeconds)))
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(HGPalette.textMuted)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 3) {
                    HGCoinIcon().frame(width: 12, height: 12)
                    Text("\(quest.goldReward)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(HGPalette.accentDeep)
                }
                Text("+\(quest.xpReward) XP")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(HGPalette.textMuted)
            }
        }
        .padding(12)
        .hgPanel(corner: HGMetrics.cornerSmall)
    }
}

// MARK: - Quest completion summary

struct QuestResultsView: View {
    let results: [HGQuestResult]
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            HGBackground()
            VStack(spacing: 0) {
                Text("Quests Complete!")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(HGPalette.textPrimary)
                    .padding(.top, 24)
                Text("Your heroes have returned.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(HGPalette.textSecondary)
                    .padding(.bottom, 12)
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(results) { r in
                            resultCard(r)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity)
                }
                Button(action: onDismiss) {
                    Text("Collect")
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
                .padding(.horizontal, 18)
                .padding(.bottom, 18)
                .frame(maxWidth: 560)
            }
        }
    }

    private func resultCard(_ r: HGQuestResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(r.questName)
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundColor(HGPalette.textPrimary)
            HStack(spacing: 10) {
                rewardChip(AnyView(HGCoinIcon()), "+\(r.gold)", HGPalette.accentDeep)
                rewardChip(nil, "+\(r.xp) XP", HGPalette.primary)
                if r.tokens > 0 {
                    rewardChip(AnyView(HGTokenIcon()), "+\(r.tokens)", HGPalette.primary)
                }
            }
            if let loot = r.loot {
                HStack(spacing: 8) {
                    HGItemSigil(slot: loot.slot, rarity: loot.rarity).frame(width: 26, height: 26)
                    Text(loot.name)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(HGPalette.rarity(loot.rarity))
                    Text("+\(loot.powerBonus) Pwr")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(HGPalette.textMuted)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .hgPanel()
    }

    private func rewardChip(_ icon: AnyView?, _ text: String, _ color: Color) -> some View {
        HStack(spacing: 4) {
            if let icon = icon { icon.frame(width: 13, height: 13) }
            Text(text)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(Capsule().fill(color.opacity(0.12)))
    }
}

// MARK: - Duration formatting

enum HGFormat {
    static func duration(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds.rounded()))
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%d:%02d", m, s)
    }
    static func shortDuration(_ seconds: Int) -> String {
        if seconds >= 3600 {
            let h = Double(seconds) / 3600.0
            return String(format: "%.1fh", h)
        }
        let m = seconds / 60
        return "\(m)m"
    }
}
