import SwiftUI

struct AssignQuestView: View {
    @EnvironmentObject var store: GuildSagaStore
    @Environment(\.presentationMode) private var presentationMode
    let slotIndex: Int

    @State private var selectedQuestId: String? = nil
    @State private var selectedHeroIds: [String] = []

    private var selectedQuest: HGQuestDef? {
        selectedQuestId.flatMap { HGContent.questDef($0) }
    }

    private var availableHeroes: [HGHero] {
        let busy = store.busyHeroIds
        return store.heroes.filter { !busy.contains($0.id) }
    }

    private var combinedPower: Int { store.combinedPower(ofHeroIds: selectedHeroIds) }

    private var canStart: Bool {
        guard let q = selectedQuest else { return false }
        return !selectedHeroIds.isEmpty
            && selectedHeroIds.count <= q.maxHeroes
            && combinedPower >= q.requiredPower
    }

    var body: some View {
        ZStack {
            HGBackground()
            VStack(spacing: 0) {
                header
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        questPicker
                        if selectedQuest != nil { heroPicker }
                        Color.clear.frame(height: 90)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .frame(maxWidth: 600)
                    .frame(maxWidth: .infinity)
                }
            }
            VStack {
                Spacer()
                startBar
            }
        }
    }

    private var header: some View {
        HStack {
            Button { presentationMode.wrappedValue.dismiss() } label: {
                Text("Close")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(HGPalette.textSecondary)
            }
            .buttonStyle(.plain)
            Spacer()
            Text("Assign Quest")
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundColor(HGPalette.textPrimary)
            Spacer()
            Text("Close").font(.system(size: 15)).opacity(0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(HGPalette.panel)
        .overlay(Rectangle().fill(HGPalette.panelRaised.opacity(0.6)).frame(height: 1), alignment: .bottom)
    }

    private var questPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CHOOSE A QUEST")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(1.2)
                .foregroundColor(HGPalette.textMuted)
            ForEach(HGContent.questDefs, id: \.id) { quest in
                Button {
                    selectedQuestId = quest.id
                    // Trim hero selection to maxHeroes.
                    if selectedHeroIds.count > quest.maxHeroes {
                        selectedHeroIds = Array(selectedHeroIds.prefix(quest.maxHeroes))
                    }
                } label: {
                    questRow(quest)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func questRow(_ quest: HGQuestDef) -> some View {
        let isSel = selectedQuestId == quest.id
        return HStack(spacing: 12) {
            HGQuestMark(tier: quest.tier).frame(width: 36, height: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(quest.name)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(HGPalette.textPrimary)
                HStack(spacing: 8) {
                    Text("Power \(quest.requiredPower)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(HGPalette.crimson)
                    Text(HGFormat.duration(TimeInterval(quest.durationSeconds)))
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(HGPalette.textMuted)
                    Text("up to \(quest.maxHeroes)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(HGPalette.textMuted)
                }
            }
            Spacer()
            if isSel {
                HGCheckGlyph(color: HGPalette.primary, size: 22)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: HGMetrics.cornerSmall, style: .continuous)
                .fill(isSel ? HGPalette.primary.opacity(0.10) : HGPalette.panel)
                .overlay(
                    RoundedRectangle(cornerRadius: HGMetrics.cornerSmall, style: .continuous)
                        .stroke(isSel ? HGPalette.primary : HGPalette.panelRaised, lineWidth: isSel ? 2 : 1.5)
                )
        )
    }

    private var heroPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("ASSIGN HEROES")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(1.2)
                    .foregroundColor(HGPalette.textMuted)
                Spacer()
                if let q = selectedQuest {
                    Text("\(selectedHeroIds.count)/\(q.maxHeroes)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(HGPalette.textSecondary)
                }
            }
            if availableHeroes.isEmpty {
                Text("All your heroes are busy. Wait for a quest to finish or recruit more in the Guild.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(HGPalette.textMuted)
                    .padding(.vertical, 8)
            } else {
                ForEach(availableHeroes) { hero in
                    heroRow(hero)
                }
            }
        }
    }

    private func heroRow(_ hero: HGHero) -> some View {
        let isSel = selectedHeroIds.contains(hero.id)
        let q = selectedQuest
        let atMax = q != nil && selectedHeroIds.count >= q!.maxHeroes && !isSel
        return Button {
            if isSel {
                selectedHeroIds.removeAll { $0 == hero.id }
            } else if !atMax {
                selectedHeroIds.append(hero.id)
            }
        } label: {
            HStack(spacing: 12) {
                HGHeroCrest(heroClass: hero.def.heroClass, rarity: hero.def.rarity)
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text(hero.def.name)
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundColor(HGPalette.textPrimary)
                    Text("Lv \(hero.level) • \(hero.def.heroClass.name)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(HGPalette.textMuted)
                }
                Spacer()
                Text("\(hero.power)")
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundColor(HGPalette.crimson)
                if isSel {
                    HGCheckGlyph(color: HGPalette.success, size: 22)
                }
            }
            .padding(12)
            .opacity(atMax ? 0.45 : 1.0)
            .background(
                RoundedRectangle(cornerRadius: HGMetrics.cornerSmall, style: .continuous)
                    .fill(isSel ? HGPalette.success.opacity(0.10) : HGPalette.panel)
                    .overlay(
                        RoundedRectangle(cornerRadius: HGMetrics.cornerSmall, style: .continuous)
                            .stroke(isSel ? HGPalette.success : HGPalette.panelRaised, lineWidth: isSel ? 2 : 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var startBar: some View {
        VStack(spacing: 8) {
            if let q = selectedQuest {
                HStack {
                    Text("Combined Power")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(HGPalette.textSecondary)
                    Spacer()
                    Text("\(combinedPower) / \(q.requiredPower)")
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundColor(combinedPower >= q.requiredPower ? HGPalette.success : HGPalette.crimson)
                }
                if combinedPower >= q.requiredPower {
                    let dur = store.effectiveDuration(quest: q, power: combinedPower)
                    Text("Estimated time: \(HGFormat.duration(TimeInterval(dur)))")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(HGPalette.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            Button {
                if let q = selectedQuest, canStart {
                    let ok = store.startQuest(slotIndex: slotIndex, questId: q.id, heroIds: selectedHeroIds)
                    if ok { presentationMode.wrappedValue.dismiss() }
                }
            } label: {
                Text("Begin Quest")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(canStart ? HGPalette.primary : HGPalette.lock)
                    )
            }
            .buttonStyle(.plain)
            .disabled(!canStart)
        }
        .padding(14)
        .background(
            HGPalette.panel
                .overlay(Rectangle().fill(HGPalette.panelRaised.opacity(0.6)).frame(height: 1), alignment: .top)
                .edgesIgnoringSafeArea(.bottom)
        )
    }
}
