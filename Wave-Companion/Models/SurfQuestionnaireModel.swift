//
//  SurfQuestionnaire.swift
//  Wave-Companion
//
//  Created by John on 26/01/2026.
//

import Foundation

struct SurfQuestionnaireModel: Codable {
    let start: String
    let questions: [SurfQuestion]
}
