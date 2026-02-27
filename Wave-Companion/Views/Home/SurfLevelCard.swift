import SwiftUI
import Foundation

struct SurfLevelCard: View {

    @ObservedObject var vm: HomeViewModel

    var body: some View {

        VStack(alignment: .leading, spacing: 12) {

            HStack(spacing: 12) {

                Circle()
                    .fill(AppColors.primary.opacity(0.15))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "trophy.fill")
                            .foregroundColor(AppColors.primary)
                    )

                let parts = vm.surfLevelName
                                   .split(separator: "–")
                                   .map { String($0).trimmingCharacters(in: .whitespaces) }

                VStack(alignment: .leading, spacing: 2) {
                    if parts.count == 2 {
                        Text(parts[0])
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)

                        Text(parts[1])
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary.opacity(0.6))
            }

            VStack(alignment: .leading, spacing: 6) {

                if vm.nextLevelSkills.isEmpty {
                    Text("Niveau max atteint")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(AppColors.primary)
                        .padding(.top, 8)

                } else {

                    let completedNext = Double(vm.completedNextLevelSkills.count)
                    let totalNext = Double(vm.nextLevelSkills.count)

                    let safeTotal = max(totalNext, 1)
                    let safeValue = min(completedNext, safeTotal)

                    ProgressView(
                        value: safeValue,
                        total: safeTotal
                    )
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primary))
                    .frame(height: 8)
                    .padding(.top, 8)

                    Text("\(Int(totalNext - completedNext)) compétences restantes pour atteindre le prochain niveau")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .cornerRadius(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.primary, lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
}
