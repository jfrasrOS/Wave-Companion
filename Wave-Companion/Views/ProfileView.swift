import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    
    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var vm: RegistrationViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Profil")
                .font(.title.bold())
            
            Button(action: logout) {
                Text("Déconnexion")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func logout() {
        do { try Auth.auth().signOut() } catch {}
        session.logout()
        vm.reset()
    }
}
