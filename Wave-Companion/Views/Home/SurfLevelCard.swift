import SwiftUI
import Foundation

struct SurfLevelCard: View {

    @ObservedObject var vm: HomeViewModel

    var body: some View {

        VStack(alignment: .leading, spacing: 16) {

            HStack(spacing: 12) {

                // Badge (logo à contruire)
                Circle()
                    .fill(Color.white)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.05), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)

                VStack(alignment: .leading, spacing: 2) {


                    Text(vm.categoryName)
                        .font(.headline)

                    Text(vm.surfLevelName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {

                if vm.nextLevelSkills.isEmpty {

                    Text("Niveau max atteint")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(AppColors.primary)

                } else {

                    let completedNext = Double(vm.completedNextLevelSkills.count)
                    let totalNext = Double(vm.nextLevelSkills.count)

                    let safeTotal = max(totalNext, 1)
                    let safeValue = min(completedNext, safeTotal)

                    ProgressView(
                        value: safeValue,
                        total: safeTotal
                    )
                    .progressViewStyle(
                        LinearProgressViewStyle(tint: AppColors.primary)
                    )
                    .scaleEffect(y: 1.6)
                }
            }

            HStack {

                Text("Voir ma progression")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(AppColors.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(AppColors.primary.opacity(0.6))
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.primary.opacity(0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.primary.opacity(0.08), lineWidth: 1)
        )
    }
}
