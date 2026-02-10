
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
            Group {
                if session.isAuthenticated {
                    MainTabContainer()
                } else {
                    AuthChoiceView()
                }
            }
            .environmentObject(session)
            .environmentObject(registrationVM)
            .onAppear {
                checkAuthentication()
            }
        }
    }
    
   
    // Vérifie si l'utilisateur est déjà connecté sur Firebase
    private func checkAuthentication() {

        // Vérification Firebase
        if let firebaseUser = Auth.auth().currentUser {
            registrationVM.data.email = firebaseUser.email ?? ""
            registrationVM.path = [.profile]
        }

    }

}

