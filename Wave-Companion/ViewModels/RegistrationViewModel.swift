//
//  RegistrationViewModel.swift
//  Wave-Companion
//
//  Created by John on 05/12/2025.
//

import Foundation
import SwiftUI
import Combine

// Liste des étapes d'inscription
enum RegistrationStep: Hashable {
    case profile
    case surfLevel
    case board
    case spots
}

class RegistrationViewModel: ObservableObject {
    
    @Published var data = RegistrationData()
    @Published var path: [RegistrationStep] = []
    
    // Avance vers l'étape suivante
    func next(_ step: RegistrationStep) {
        path.append(step)
    }

    // Revient à l'écran précédent
    func back() {
        path.removeLast()
    }

    // Construit et retourne l'objet User avec les données temporaires collectées
    func register() -> User {
        data.buildUser()
    }
}
