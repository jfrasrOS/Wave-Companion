//
//  User.swift
//  Wave-Companion
//
//  Created by John on 01/12/2025.
//

import Foundation


struct User:Identifiable, Codable{
    var id: String
    var name: String
    var email: String
    var profileImage: String
    var nationality: String
    var surfLevel: String
    var boardType: String
    var boardColor: String
}
