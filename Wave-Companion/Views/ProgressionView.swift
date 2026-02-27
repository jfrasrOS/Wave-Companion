import SwiftUI

struct ProgressionView: View {

    @ObservedObject var vm: ProgressionViewModel

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 32) {
                headerSection
                if let nextName = vm.nextLevelName {
                    objectiveSection(nextName: nextName)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 16)

            ScrollView {
                skillsSection
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 40)

                downgradeButton
                    .padding(.bottom, 20)
            }
        }
        .navigationTitle("Progression")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            vm.pendingLevelAction != nil ?
            (vm.pendingLevelAction == .levelUp ? "Passer au niveau supérieur ?" : "Descendre d'un niveau ?") : "",
            isPresented: Binding(
                get: { vm.pendingLevelAction != nil },
                set: { if !$0 { vm.pendingLevelAction = nil } }
            )
        ) {
            Button("Confirmer") { vm.confirmPendingLevelAction() }
            Button("Annuler", role: .cancel) { }
        }
    }

    //Header
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Niveau actuel")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(vm.surfLevelName)
                .font(.title3.bold())
        }
    }

    // Objectif
    private func objectiveSection(nextName: String) -> some View {
        VStack(spacing: 16) {
            Text("Objectif")
                .font(.caption.bold())
                .foregroundColor(AppColors.action)

            Text(nextName)
                .font(.title3.weight(.semibold))

            if !vm.nextLevelSkills.isEmpty {
                ProgressView(
                    value: Double(vm.nextLevelCompletedCount),
                    total: Double(max(vm.nextLevelSkills.count, 1))
                )
                .progressViewStyle(
                    LinearProgressViewStyle(tint: .blue)
                )

                Text("\(vm.nextLevelCompletedCount)/\(vm.nextLevelSkills.count) compétences validées")
                    .font(.caption2)
                    .foregroundColor(.blue)
            } else {
                Text("Niveau max atteint")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.action, lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 3)
    }

    // SKILLS
    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(vm.nextLevelSkills, id: \.self) { skill in
                SkillRow(
                    skill: skill,
                    isCompleted: vm.completedNextLevelSkills.contains(skill),
                    onToggle: { vm.toggleNextLevelSkill(skill) },
                    onCoach: { print("Coach IA pour \(skill)") }
                )
            }
        }
    }

    // Ajuster le niveau
    private var downgradeButton: some View {
        Group {
            if !vm.isAtLowestLevel {
                Button {
                    vm.requestLevelDown()
                } label: {
                    Text("Ajuster mon niveau")
                        .font(.footnote)
                        .foregroundColor(AppColors.action)
                }
                .padding(.top, 12)
            }
        }
    }

    struct SkillRow: View {
        let skill: String
        let isCompleted: Bool
        let onToggle: () -> Void
        let onCoach: () -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    Button(action: onToggle) {
                        ZStack {
                            Circle()
                                .stroke(
                                    isCompleted ? .blue : Color.gray.opacity(0.3),
                                    lineWidth: 2
                                )
                                .frame(width: 28, height: 28)
                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.caption.bold())
                                    .foregroundColor(.blue)
                            }
                        }
                    }

                    Text(skill)
                        .font(.subheadline)
                        .strikethrough(isCompleted)

                    Spacer()
                }

                if !isCompleted {
                    Button(action: onCoach) {
                        Text("S'entraîner avec Coach IA")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.blue)
                    }
                    .padding(.leading, 44)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
            )
            .animation(.easeInOut(duration: 0.2), value: isCompleted)
        }
    }
}
