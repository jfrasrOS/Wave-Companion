import SwiftUI

struct RegistrationStepContainer<Content: View>: View {

    let title: String
    let subtitle: String
    let currentStep: Int
    let totalSteps: Int
    let isActionEnabled: Bool
    let actionTitle: String
    let onAction: () -> Void
    let content: Content

    init(
        title: String,
        subtitle: String,
        currentStep: Int,
        totalSteps: Int,
        isActionEnabled: Bool,
        actionTitle: String = "Continuer",
        onAction: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.currentStep = currentStep
        self.totalSteps = totalSteps
        self.isActionEnabled = isActionEnabled
        self.actionTitle = actionTitle
        self.onAction = onAction
        self.content = content()
    }

    var body: some View {
        ZStack {
           

            VStack(spacing: 0) {

                header

                ScrollView {
                    VStack(spacing: 24) {
                        content
                    }
                    .padding()
                    .padding(.bottom, 120)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        )
                    )
                }

                actionButton
            }
        }
        .animation(.easeInOut(duration: 0.35), value: currentStep)
    }


    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title.bold())

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)

            RegistrationProgressView(
                currentStep: currentStep,
                totalSteps: totalSteps
            )
        }
        .padding()
    }

    private var actionButton: some View {
        Button(action: onAction) {
            Text(actionTitle)
                .font(.headline)
                .foregroundColor(isActionEnabled ? .white : AppColors.primary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isActionEnabled ? AppColors.action : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(isActionEnabled ? Color.clear : AppColors.primary, lineWidth: 2)
                )
                .cornerRadius(24)
                .padding()
        }
        .disabled(!isActionEnabled)
    }

    private var progress: Double {
        Double(currentStep + 1) / Double(totalSteps)
    }
}

