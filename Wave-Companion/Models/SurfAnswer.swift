//
//  SurfAnswer.swift
//  Wave-Companion
//
//  Created by John on 26/01/2026.
//

import Foundation

struct SurfAnswer: Codable, Identifiable {
    var id = String()
    let text: String
    let next: String?    
    let resultLevelId: String?
}
