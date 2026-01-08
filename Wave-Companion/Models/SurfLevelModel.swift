//
//  SurfLevel.swift
//  Wave-Companion
//
//  Created by John on 18/12/2025.
//

import Foundation


struct SurfLevelModel: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let skills: [String]
    let order: Int
    let category: String
}
