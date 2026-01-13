//
//  Wave_CompanionApp.swift
//  Wave-Companion
//

import SwiftUI
import FirebaseCore
import FirebaseAuth


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Configure Firebase une seule fois ici
        FirebaseApp.configure()
        
        // Vérification du fichier GoogleService-Info.plist
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            print("Fichier Firebase trouvé :", path)
        } else {
            print("Erreur : GoogleService-Info.plist manquant !")
        }
        
        return true
    }
}


@main
struct Wave_CompanionApp: App {
    
    // Relie SwiftUI à AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var session = SessionManager()
    @StateObject private var registrationVM = RegistrationViewModel()
    
    @State private var isLoading = true
    
    var body: some Scene {
        WindowGroup {
            
            if isLoading {
                LoadingView()
                    .onAppear {
                        checkAuthentication()
                    }
            } else {
                if session.isAuthenticated {
                    HomeView()
                        .environmentObject(session)
                        .environmentObject(registrationVM)
                } else {
                    AuthChoiceView()
                        .environmentObject(session)
                        .environmentObject(registrationVM)
                }
            }
        }
    }
    
    // Vérifie si un utilisateur Firebase est déjà connecté
    private func checkAuthentication() {
        DispatchQueue.main.async {
            if let firebaseUser = Auth.auth().currentUser {
                session.isAuthenticated = true
                print("Utilisateur Firebase connecté :", firebaseUser.uid)
            } else {
                session.isAuthenticated = false
                print("Aucun utilisateur connecté")
            }
            isLoading = false
        }
    }
}

