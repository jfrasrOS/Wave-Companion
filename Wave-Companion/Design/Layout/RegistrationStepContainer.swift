import SwiftUI

// Container pour tout le parcours d'inscription
struct RegistrationStepContainer<Content: View>: View {

    let title: String
    let subtitle: String
    let currentStep: Int
    let totalSteps: Int
    let isActionEnabled: Bool
    let actionTitle: String
    let onAction: () -> Void
    let onBack: (() -> Void)?
    let content: Content

    init(
        title: String,
        subtitle: String,
        currentStep: Int,
        totalSteps: Int,
        isActionEnabled: Bool,
        actionTitle: String = "Continuer",
        onBack: (() -> Void)? = nil,
        onAction: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.currentStep = currentStep
        self.totalSteps = totalSteps
        self.isActionEnabled = isActionEnabled
        self.actionTitle = actionTitle
        self.onBack = onBack
        self.onAction = onAction
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            
            // HEADER -> Btn back custom + progress bar
            ZStack{
                HStack {
                    if let onBack = onBack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(AppColors.primary)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                    }
                    Spacer()
                }
                .padding()
               
                
                RegistrationProgressView(currentStep: currentStep, totalSteps: totalSteps)
                    .frame(height: 6)
                    .padding(.leading, onBack != nil ? 12 : 0)
                
            }
               
            

           // TITRE + SOUS-TITRE
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title.bold())
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            Spacer(minLength: 20)

          
            // CONTENU PRINCIPAL
            ScrollView {
                VStack(spacing: 32) {
                    content
                }
                .padding()
                .padding(.top, 12)
                // Animation entre les changements 
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    )
                )
            }

            // Bouton fixe
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
        .navigationBarBackButtonHidden(true)
    }
}



