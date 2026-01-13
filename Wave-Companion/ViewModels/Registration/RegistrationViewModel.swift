import Foundation
import SwiftUI
import Combine
import PhotosUI

enum RegistrationStep: Hashable {
    case profile
    case surfLevel
    case board
    case spots
}

class RegistrationViewModel: ObservableObject {
    
    @Published var data = RegistrationData()
    @Published var path: [RegistrationStep] = []
    
    @Published var confirmPassword: String = ""
    @Published var errorMessages: [String: String] = [:]
    
    @Published var profileUIImage: UIImage? = nil
    @Published var isPhotoReady: Bool = false
    
    @Published var selectedCountry: Country? = nil

    let countries = CountryService.allCountries()

    
    func next(_ step: RegistrationStep) {
        path.append(step)
    }

    func back() {
        path.removeLast()
    }

    func register() -> User {
        data.buildUser()
    }
    
    // Validation des champs
    func validateProfile() -> Bool {
        errorMessages = [:]

        let namePattern = "^[A-Za-z0-9\\-\\'\\s]{3,20}$"
        if !NSPredicate(format: "SELF MATCHES %@", namePattern).evaluate(with: data.name) {
            errorMessages["name"] = "Nom invalide (3-20 caractères, lettres, chiffres, -, ', espace)"
        }
        if data.email.isEmpty || !data.email.contains("@") {
            errorMessages["email"] = "Email invalide"
        }
        if data.password.count < 6 {
            errorMessages["password"] = "Mot de passe trop court (min 6 caractères)"
        }
        if data.password != confirmPassword {
            errorMessages["confirmPassword"] = "Les mots de passe ne correspondent pas"
        }
       
        return errorMessages.isEmpty
    }

    
    // Mise à jour de la photo de profil
    @MainActor
    func updateProfileImage(from item: PhotosPickerItem?) async {
        
        // Si pas de photo, return nil
        guard let item else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               // Transforme en UIImage
               let uiImage = UIImage(data: data) {
                self.profileUIImage = uiImage
                // version base64
                self.data.profileImage = data.base64EncodedString()
                self.isPhotoReady = true
            }
        } catch {
            print("Erreur conversion image:", error)
        }
    }
    
    // @MainActor s’assure que cette fonction tourne sur le thread principal
    @MainActor
    func completeRegistration(session: SessionManager) async {
        do {
            // Crée objet User
            let user = data.buildUser()

            // Crée user dans Firebase Auth et récupére uid
            let uid = try await AuthService.shared.createUser(
                email: user.email,
                password: user.password
            )
            
            // Upload de l'image
            var profileURL = ""
            if let imageData = Data(base64Encoded: data.profileImage) {
                profileURL = try await UserService.shared.uploadProfileImage(imageData, uid: uid)
            }

            // Remplace la base64 par l'URL
            var userToSave = user
            userToSave.profileImage = profileURL
            
            // Save user dans Firestore avec le même uid
            try await UserService.shared.saveUser(userToSave, uid: uid)

            // met à jour SessionManager ( connecte user dans l'app )
            session.login(user: user)

        } catch {
            print("Erreur inscription Firebase:", error)
        }
    }

    //Réinitialise registationData (données temporaires)
    func reset() {
            data = RegistrationData()
            confirmPassword = ""
            errorMessages = [:]
            profileUIImage = nil
            isPhotoReady = false
            selectedCountry = nil
            path = []
        }
}

