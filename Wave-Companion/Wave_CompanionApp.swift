//
//  Wave_CompanionApp.swift
//  Wave-Companion
//
//  Created by John on 25/11/2025.
//
import SwiftUI
import SwiftData

@main
struct Wave_CompanionApp: App {
    
    @State private var isLoading = true
    @State private var isUserLoggedIn = false

    @StateObject private var registrationVM = RegistrationViewModel()

    var body: some Scene {
        WindowGroup {
            // Ecran de chargement affiché au démarrage
            if isLoading {
                LoadingView()
                    .onAppear {
                        // Simulation du temps de chargement
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isLoading = false
                        }
                    }
            } else {
                // Si User est connecté -> Home
                if isUserLoggedIn {
                    ContentView()
                        .environmentObject(registrationVM)
                } else {
                    //Sinon, page connexion/inscription
                    AuthChoiceView()
                        .environmentObject(registrationVM)  
                }
            }
        }
    }
}
