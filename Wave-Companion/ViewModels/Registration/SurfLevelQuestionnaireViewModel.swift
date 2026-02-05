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

    // Appelé quand l'utilisateur selectionne une réponse
    func selectAnswer(_ answer: SurfAnswer) {
        
        // Save la question actuelle pour pouvoir revenir en arrière
        history.append(currentQuestionId)

        // Si la réponse donne directement le niveau estimé
        if let resultId = answer.resultLevelId {
            resultingLevel = levels.first { $0.id == resultId }
        // Sinon question suivante
        } else if let nextId = answer.next {
            withAnimation {
                currentQuestionId = nextId
            }
        }
    }

    func goBack() {
        // Récupère la dernière question visitée
        guard let last = history.popLast() else { return }
        withAnimation {
            currentQuestionId = last
            resultingLevel = nil
        }
    }
    
    func reset() {
            // Reviens à la 1ere question
            currentQuestionId = questionnaire.start
            history.removeAll()
            resultingLevel = nil
        }
}

