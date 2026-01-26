//
//  SurfQuestionaireService.swift
//  Wave-Companion
//
//  Created by John on 26/01/2026.
//

import Foundation

struct SurfQuestionnaireService {
    static func load() -> SurfQuestionnaireModel {
        guard let url = Bundle.main.url(forResource: "SurfQuestionnaire", withExtension: "json") else {
            fatalError("SurfQuestionnaire.json introuvable")
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(SurfQuestionnaireModel.self, from: data)
        } catch {
            fatalError("Erreur de chargement du questionnaire : \(error)")
        }
    }
}
