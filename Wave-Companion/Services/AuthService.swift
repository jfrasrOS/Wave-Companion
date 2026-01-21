import FirebaseAuth
import GoogleSignIn
import FirebaseCore

// Gère l'authentification de Firebase
final class AuthService {

    static let shared = AuthService()
    private init() {}
    
    // Récupérer l'utilisateur actuel
    var currentUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }

    // Permet de connecter un utlisateur via AuthCredential ( credential obtenu via Google, Apple, ..)
    func signInWithCredential(_ credential: AuthCredential) async throws -> String {
        let result = try await Auth.auth().signIn(with: credential)
        return result.user.uid
    }
    
    // Connexion avec Google
    func signInWithGoogle() async throws -> FirebaseAuth.User {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw URLError(.badServerResponse)
        }

        GIDSignIn.sharedInstance.configuration =
            GIDConfiguration(clientID: clientID)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            throw URLError(.cannotFindHost)
        }

        let result = try await GIDSignIn.sharedInstance
            .signIn(withPresenting: rootVC)

        let credential = GoogleAuthProvider.credential(
            withIDToken: result.user.idToken!.tokenString,
            accessToken: result.user.accessToken.tokenString
        )

        let authResult = try await Auth.auth().signIn(with: credential)
        return authResult.user
    }


    // Connexion email + password
    func loginWithEmailPassword(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user.uid
    }

    // Inscription email + password
    func signUpWithEmailPassword(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user.uid
    }

    // Déconnexion
    func signOut() throws {
        try Auth.auth().signOut()
    }

    
    
    
}

