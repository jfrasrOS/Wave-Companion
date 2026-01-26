import SwiftUI

struct RegistrationSurfLevelView: View {

    @EnvironmentObject var vm: RegistrationViewModel

    @StateObject private var questionnaireVM: SurfLevelQuestionnaireViewModel

    init() {
        let levels = SurfLevelService.loadLevels()
        let questionnaire = SurfQuestionnaireService.load()
        _questionnaireVM = StateObject(
            wrappedValue: SurfLevelQuestionnaireViewModel(
                questionnaire: questionnaire,
                levels: levels
            )
        )
    }

    var body: some View {
        RegistrationStepContainer(
            title: "Ton niveau de surf",
            subtitle: "Quelques questions pour t’associer aux bonnes sessions.",
            currentStep: 1,
            totalSteps: 4,
            isActionEnabled: questionnaireVM.resultingLevel != nil,
            onAction: {
                vm.next(.board)
            }
        ) {

            if let question = questionnaireVM.currentQuestion {
                SurfQuestionView(
                    question: question,
                    onAnswerSelected: { answer in
                        questionnaireVM.selectAnswer(answer)
                        if let level = questionnaireVM.resultingLevel {
                            vm.data.surfLevel = level
                        }
                    }
                )
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }

            if let level = questionnaireVM.resultingLevel {
                SurfLevelResultView(level: level)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: questionnaireVM.currentQuestionId)
    }
}

struct SurfQuestionView: View {

    let question: SurfQuestion
    let onAnswerSelected: (SurfAnswer) -> Void

    var body: some View {
        VStack(spacing: 28) {

            Text(question.text)
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            VStack(spacing: 14) {
                ForEach(question.answers) { answer in
                    Button {
                        onAnswerSelected(answer)
                    } label: {
                        Text(answer.text)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.primary.opacity(0.15))
                            .foregroundColor(AppColors.primary)
                            .cornerRadius(18)
                    }
                }
            }
        }
    }
}


struct SurfLevelResultView: View {

    let level: SurfLevelModel

    var body: some View {
        VStack(spacing: 8) {
            Text("Ton niveau estimé")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(level.name)
                .font(.title.bold())

            Text(level.description)
                .font(.subheadline)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(AppColors.primary.opacity(0.1))
        .cornerRadius(20)
    }
}
