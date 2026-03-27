//
//  SessionUser.swift
//  Wave-Companion
//
//  Created by John on 27/03/2026.
//

import Foundation

struct SessionUser: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let nationality: String
    let boardType: String
    let boardSize: String
    let boardColor: String
    let profileImage: String?
}
