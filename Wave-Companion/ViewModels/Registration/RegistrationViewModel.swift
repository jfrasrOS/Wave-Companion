import SwiftUI
import GoogleSignIn
import FirebaseCore
import FirebaseAuth
import Combine

// Etape parcours d'inscription
enum RegistrationStep: Hashable {
    case signupMethod
    case profile
    case surfLevel
    case board
    case spots
}

@MainActor
final class RegistrationViewModel: ObservableObject {
    
    @Published var data = RegistrationData()
    @Published var path: [RegistrationStep] = []
    @Published var errorMessages: [String: String] = [:]
    @Published var errorMessage: String?
    
    @Published var selectedCountry: Country? = nil
    let countries = CountryService.allCountries()
    
    func next(_ step: RegistrationStep) {
        path.append(step)
    }
    
    func back() {
            guard !path.isEmpty else { return }
            path.removeLast()
        }
    
    func reset() {
        data = RegistrationData()
        path.removeAll()
        errorMessages.removeAll()
        errorMessage = nil
        selectedCountry = nil
    }
    
    func validateProfile() -> Bool {
        errorMessages = [:]
        if data.name.count < 2 { errorMessages["name"] = "Nom trop court" }
        if data.email.isEmpty { errorMessages["email"] = "Email requis" }
        if selectedCountry == nil { errorMessages["nationality"] = "Choisir un pays" }
        return errorMessages.isEmpty
    }
    
    // Finalisation de l'inscription → création Firestore
    func completeRegistration(uid: String, session: SessionManager) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let user = data.buildUser(uid: uid)
        do {
            try await UserService.shared.createUser(uid: uid, user: user)
            session.login(user: user)
            reset()
        } catch {
            print("Erreur inscription finale:", error)
        }
    }
    
    
    @MainActor
    func signUpWithEmailPassword(email: String, password: String) async {
        errorMessage = nil

        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email et mot de passe requis"
            return
        }

        do {
            // Création utilisateur Firebase
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = result.user.uid

            // Sauvegarde temporaire de l'email pour le flow d'inscription
            data.email = email

            // Passage à l'étape profil
            next(.profile)

            print("Utilisateur créé Firebase uid: \(uid)")
        } catch {
            errorMessage = "Erreur inscription: \(error.localizedDescription)"
        }
    }

}

