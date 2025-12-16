//
//  RegistrationData.swift
//  Wave-Companion
//
//  Created by John on 05/12/2025.
//

import Foundation

// Modele pour stocker les données temporaires au cours de l'inscription
struct RegistrationData {
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var profileImage: String = ""
    var nationality: String = ""

    var surfLevel: String = ""
    var boardType: String = ""
    var boardColor: String = ""
    
    var favoriteSpotIDs: [String] = []
    
    // Crée une instance User à partir des données saisies 
    func buildUser() -> User {
        User(
            id: UUID().uuidString,
            name: name,
            email: email,
            password: password,
            profileImage: profileImage,
            nationality: nationality,
            surfLevel: surfLevel,
            boardType: boardType,
            boardColor: boardColor,
            favoriteSpotIDs: favoriteSpotIDs
        )
    }
}

