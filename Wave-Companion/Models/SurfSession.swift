//
//  SurfSession.swift
//  Wave-Companion
//
//  Created by John on 01/12/2025.
//

import Foundation

struct SurfSession: Codable {
    var id: String
    var spotName: String
    var date: Date
    var maxPeople: Int
    var minimumLevel: String
}
