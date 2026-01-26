import SwiftUI
import Combine

final class SurfLevelQuestionnaireViewModel: ObservableObject {

    @Published var currentQuestionId: String
    @Published var history: [String] = []
    @Published var resultingLevel: SurfLevelModel?

    let questionnaire: SurfQuestionnaireModel
    let levels: [SurfLevelModel]

    init(questionnaire: SurfQuestionnaireModel, levels: [SurfLevelModel]) {
        self.questionnaire = questionnaire
        self.levels = levels
        self.currentQuestionId = questionnaire.start
    }

    var currentQuestion: SurfQuestion? {
        questionnaire.questions.first { $0.id == currentQuestionId }
    }

    func selectAnswer(_ answer: SurfAnswer) {
        history.append(currentQuestionId)

        if let resultId = answer.resultLevelId {
            resultingLevel = levels.first { $0.id == resultId }
        } else if let nextId = answer.next {
            withAnimation {
                currentQuestionId = nextId
            }
        }
    }

    func goBack() {
        guard let last = history.popLast() else { return }
        withAnimation {
            currentQuestionId = last
            resultingLevel = nil
        }
    }
}

