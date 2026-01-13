//
//  AuthService.swift
//  Wave-Companion
//
//  Created by John on 12/01/2026.
//

import Foundation
import FirebaseAuth

class AuthService {
    
    // Objet unique qu'on peut utiliser partout
    static let shared = AuthService()

    func createUser(email: String, password: String) async throws -> String {
        // Appelle Firebase pour créer le compte (Auth)
        let result = try await Auth.auth().createUser(
            withEmail: email,
            password: password
        )
        return result.user.uid
    }
}
