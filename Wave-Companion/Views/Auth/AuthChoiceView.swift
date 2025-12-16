//
//  AuthChoiceView.swift
//  Wave-Companion
//
//  Created by John on 03/12/2025.
//

import SwiftUI

struct AuthChoiceView: View {
    @EnvironmentObject var vm: RegistrationViewModel

    var body: some View {
        //ViewModel gère  le chemin de navigation
        NavigationStack(path: $vm.path) {
            VStack(spacing: 20) {

                NavigationLink("Connexion") {
                    LoginView()
                        .environmentObject(vm)
                }

                NavigationLink("Inscription") {
                    RegistrationProfileView()
                        .environmentObject(vm)
                }
            }
            // Gestion ders destinations pour chaque étape de l'inscription
            .navigationDestination(for: RegistrationStep.self) { step in
                switch step {
                case .surfLevel:
                    RegistrationSurfLevelView().environmentObject(vm)
                case .board:
                    RegistrationBoardView().environmentObject(vm)
                case .spots:
                    RegistrationFavoritesSpotsView().environmentObject(vm)
                default:
                    EmptyView()
                }
            }
        }
    }
}


#Preview {
    AuthChoiceView()
}
