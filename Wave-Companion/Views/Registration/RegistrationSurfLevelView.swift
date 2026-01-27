import SwiftUI


struct RegistrationSurfLevelView: View {

    @EnvironmentObject var vm: RegistrationViewModel
    @StateObject private var questionnaireVM: SurfLevelQuestionnaireViewModel

    // Initialise la view
    init() {
        // Chargement questionnaire + niveaux de surf (service)
        let levels = SurfLevelService.loadLevels()
        let questionnaire = SurfQuestionnaireService.load()
        // crée le vm du questionnaire
        _questionnaireVM = StateObject(
            wrappedValue: SurfLevelQuestionnaireViewModel(
                questionnaire: questionnaire,
                levels: levels
            )
        )
    }

    var body: some View {
        // Container commun au parcours
        RegistrationStepContainer(
            title: "Ton niveau de surf",
            subtitle: "Quelques questions pour t’associer aux bonnes sessions.",
            currentStep: 1,
            totalSteps: 4,
            isActionEnabled: questionnaireVM.resultingLevel != nil,
            onBack: { vm.back() },
            onAction: { vm.next(.board) }
        ) {

            // BTN Question précédente
            Button {
                questionnaireVM.goBack()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.left")
                    Text("Question précédente")
                }
                .font(.subheadline.weight(.medium))
                .foregroundColor(AppColors.primary)
            }
            .frame(height: 44)
            .opacity(questionnaireVM.history.isEmpty || questionnaireVM.resultingLevel != nil ? 0 : 1)
            .disabled(questionnaireVM.history.isEmpty || questionnaireVM.resultingLevel != nil)
            .animation(.easeInOut(duration: 0.25), value: questionnaireVM.history.count)

 
            // Contenu principal
            Group {
                if let level = questionnaireVM.resultingLevel {
                    // Affiche le résultat si le questionnaire est terminé
                    SurfLevelResultView(questionnaireVM: questionnaireVM, level: level)
                        .frame(maxWidth: .infinity)
                        .transition(.scale.combined(with: .opacity))

                } else if let question = questionnaireVM.currentQuestion {
                    // Sinon affiche la question en cours
                    SurfQuestionView(
                        question: question,
                        onAnswerSelected: { answer in
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            questionnaireVM.selectAnswer(answer)
                            if let level = questionnaireVM.resultingLevel {
                                vm.data.surfLevel = level
                            }
                        }
                    )
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: questionnaireVM.currentQuestionId)
    }
}

// QUESTION/REPONSE
struct SurfQuestionView: View {

    let question: SurfQuestion
    let onAnswerSelected: (SurfAnswer) -> Void

    var body: some View {
        VStack(spacing: 36) {

            // Question
            Text(question.text)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)

            // Liste des réponses
            VStack(spacing: 14) {
                ForEach(question.answers) { answer in
                    Button {
                        onAnswerSelected(answer)
                    } label: {
                        Text(answer.text)
                            .font(.headline)
                            .foregroundColor(AppColors.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(AppColors.primary.opacity(0.08))
                            )
                    }
                }
            }
        }
    }
}

// RESULTAT ESTIMATION SURF LEVEL
struct SurfLevelResultView: View {

    @EnvironmentObject var vm: RegistrationViewModel
    @ObservedObject var questionnaireVM: SurfLevelQuestionnaireViewModel
    let level: SurfLevelModel

    var body: some View {
        VStack(spacing: 12) {

            Text("Ton niveau estimé")
                .font(.caption.weight(.medium))
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            // Niveau de surf
            // Sépare le nom et le niveau (avant et après “–”)
            let parts = level.name.split(separator: "–").map { $0.trimmingCharacters(in: .whitespaces) }
            VStack(spacing: 8) {
                if parts.count == 2 {
                    Text(parts[0])
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    Text(parts[1])
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                } else {
                    Text(level.name)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                }
            }

            // Description
            Text(level.description)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            // BTN pour recommencer le questionnaire
            Button {
                questionnaireVM.reset()      // Remet toutes les réponses à zéro
               vm.data.surfLevel = nil        // Supprime le niveau déjà choisi
            } label: {
                HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                        Text("Recommencer le questionnaire")
                    }
                    .font(.headline)
                    .foregroundColor(AppColors.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(AppColors.primary.opacity(0.1))
                    )
            }
            .padding(.top, 16)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(AppColors.primary.opacity(0.12))
        )
        .frame(maxWidth: .infinity)
    }
}


#Preview {
    RegistrationSurfLevelView()
        .environmentObject(RegistrationViewModel())
}

