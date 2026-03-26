import SwiftUI

struct RegistrationProgressView: View {

    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index <= currentStep ? AppColors.primary : Color.gray.opacity(0.3))
                    .frame(
                        width: index == currentStep ? 24 : 8,
                        height: 6
                    )
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(alignment: .center)
    }
}

#Preview {
    RegistrationProgressView(currentStep: 1, totalSteps: 4)
}
