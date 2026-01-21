import FirebaseAuth
import FirebaseFirestore

enum LoginResult {
    // User est déjà présent dans Firestore (inscription complète)
    // User est sur Firebase Auth mais pas sur Firestore (inscription incomplète)
    case completed(User)
    case incomplete(User)
}

final class LoginService {

    static let shared = LoginService()
    private init() {}

    // Vérification
    func handlePostLogin(
        firebaseUser: FirebaseAuth.User
    ) async throws -> LoginResult {

        let uid = firebaseUser.uid
        let email = firebaseUser.email ?? ""

        let doc = try await Firestore.firestore()
            .collection("users")
            .document(uid)
            .getDocument()

        if let data = doc.data() {
            // User Firestore existant
            let user = User(
                id: uid,
                name: data["name"] as? String ?? "",
                email: data["email"] as? String ?? email,
                nationality: data["nationality"] as? String ?? "",
                surfLevelId: data["surfLevelId"] as? String ?? "",
                boardType: data["boardType"] as? String ?? "",
                boardSize: data["boardSize"] as? String ?? "",
                boardColor: data["boardColor"] as? String ?? "",
                favoriteSpotIDs: data["favoriteSpotIDs"] as? [String] ?? [],
                profileImage: data["profileImage"] as? String
            )

            return .completed(user)
        }

        // Auth OK mais pas encore inscrit
        let minimalUser = User(
            id: uid,
            name: "",
            email: email,
            nationality: "",
            surfLevelId: "",
            boardType: "",
            boardSize: "",
            boardColor: "",
            favoriteSpotIDs: [],
            profileImage: nil
        )

        return .incomplete(minimalUser)
    }
}
