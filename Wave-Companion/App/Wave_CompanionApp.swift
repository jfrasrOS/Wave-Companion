
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
            
            // Affiche le chargement
            if isLoading {
                LoadingView()
                    .onAppear {
                        // Vérifie si User est dèjà connecté sur Firebase
                        checkAuthentication()
                    }
                // Chargement terminé, affichage des views
            } else {
                // User connecté + inscription complète → HomeView
                if session.isAuthenticated {
                    HomeView()
                        .environmentObject(session)
                        .environmentObject(registrationVM)
                } else {
                    // Sinon -> AuthChoice pour connexion/inscription
                    AuthChoiceView()
                        .environmentObject(session)
                        .environmentObject(registrationVM)
                }
            }
        }
    }
    
   
    // Vérifie si l'utilisateur est déjà connecté sur Firebase
        private func checkAuthentication() {
            DispatchQueue.main.async {
                if let firebaseUser = Auth.auth().currentUser {
                    // Utilisateur déjà authentifié → direct ProfileView
                    registrationVM.data.email = firebaseUser.email ?? ""
                    registrationVM.path = [.profile]
                }
                isLoading = false
            }
        }
}

