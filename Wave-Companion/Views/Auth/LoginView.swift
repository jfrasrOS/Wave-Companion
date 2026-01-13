import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var registrationVM: RegistrationViewModel

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Connexion")
                .font(.largeTitle.bold())
                .padding(.top)

            TextField("Email", text: $email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            SecureField("Mot de passe", text: $password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button(action: login) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Se connecter")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .disabled(isLoading || email.isEmpty || password.isEmpty)
            .padding(.horizontal)
        }
        .padding()
    }

    private func login() {
        errorMessage = ""
        isLoading = true

        Task {
            do {
                // Login Firebase Auth
                let result = try await Auth.auth().signIn(withEmail: email, password: password)
                let uid = result.user.uid
                print("Firebase: Utilisateur connecté avec uid \(uid)")

                // Récupére l'utilisateur depuis Firestore
                let userDoc = try await Firestore.firestore()
                    .collection("users")
                    .document(uid)
                    .getDocument()

                guard let data = userDoc.data() else {
                    errorMessage = "Impossible de récupérer les données utilisateur"
                    isLoading = false
                    return
                }

                // Construit l'objet User
                let user = User(
                    id: data["id"] as? String ?? uid,
                    name: data["name"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    password: data["password"] as? String ?? "",
                    profileImage: data["profileImage"] as? String ?? "",
                    nationality: data["nationality"] as? String ?? "",
                    surfLevelId: data["surfLevelId"] as? String ?? "",
                    boardType: data["boardType"] as? String ?? "",
                    boardColor: data["boardColor"] as? String ?? "",
                    favoriteSpotIDs: data["favoriteSpotIDs"] as? [String] ?? []
                )

                //Met à jour la session
                session.login(user: user)

            } catch {
                errorMessage = error.localizedDescription
                print("Erreur login:", error)
            }
            isLoading = false
        }
    }
}
