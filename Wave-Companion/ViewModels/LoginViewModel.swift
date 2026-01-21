import Foundation
import FirebaseAuth
import Combine

@MainActor
final class LoginViewModel: ObservableObject {

    @Published var errorMessage: String?
    @Published var isLoading = false

    func loginWithGoogle(
        session: SessionManager,
        registrationVM: RegistrationViewModel
    ) async {

        isLoading = true
        defer { isLoading = false }

        do {
            let firebaseUser = try await AuthService.shared
                .signInWithGoogle()

            try await handlePostLogin(
                firebaseUser: firebaseUser,
                session: session,
                registrationVM: registrationVM
            )

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loginWithEmailPassword(
        email: String,
        password: String,
        session: SessionManager,
        registrationVM: RegistrationViewModel
    ) async {

        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await AuthService.shared
                .loginWithEmailPassword(email: email, password: password)

            guard let user = Auth.auth().currentUser else { return }

            try await handlePostLogin(
                firebaseUser: user,
                session: session,
                registrationVM: registrationVM
            )

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Vérifie si User existe dans Firestore et redirige
    private func handlePostLogin(
        firebaseUser: FirebaseAuth.User,
        session: SessionManager,
        registrationVM: RegistrationViewModel
    ) async throws {

        let result = try await LoginService.shared
            .handlePostLogin(firebaseUser: firebaseUser)

        switch result {

        case .completed(let user):
            session.login(user: user)
            registrationVM.reset()

        case .incomplete(let user):
            registrationVM.reset()
            registrationVM.data.email = user.email
            registrationVM.path = [.profile]
        }
    }
}

