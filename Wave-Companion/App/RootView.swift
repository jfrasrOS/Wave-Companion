import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var registrationVM: RegistrationViewModel
    
    var body: some View {
        Group {
            if session.isAuthenticated {
                // User a terminé son inscription → HomeView
                HomeView()
                    .environmentObject(session)
                    .environmentObject(registrationVM)
            } else if registrationVM.path.isEmpty {
                // Pas d'inscription en cours → choix connexion/inscription
                AuthChoiceView()
                    .environmentObject(session)
                    .environmentObject(registrationVM)
            } else {
                // Inscription commencé mais pas terminé → RegistrationFlow
                RegistrationFlowView()
                    .environmentObject(registrationVM)
            }
        }
    }
}

