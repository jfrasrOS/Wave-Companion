import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var vm: RegistrationViewModel

    var body: some View {
       
            VStack(spacing: 20) {
                Text("Bienvenue sur Wave Companion !")
                    .font(.title.bold())

                // Bouton déconnexion
                Button(action: logout) {
                    Text("Déconnexion")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(12)
                }
            }
            .padding()
        
    }

    private func logout() {
        do {
            // Déconnexion Firebase
            try Auth.auth().signOut()
            print("Firebase: utilisateur déconnecté")
        } catch {
            print("Erreur déconnexion Firebase:", error.localizedDescription)
        }

        // Met à jour la session
        session.logout()
        // Réinitialise toutes les données temporaires d'inscription
        vm.reset()
        
                
        
    }
}

