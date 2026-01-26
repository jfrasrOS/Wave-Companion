//
//  SurfQuestions.swift
//  Wave-Companion
//
//  Created by John on 26/01/2026.
//

import Foundation

struct SurfQuestion: Codable, Identifiable {
    let id: String
    let text: String
    let answers: [SurfAnswer]
}
