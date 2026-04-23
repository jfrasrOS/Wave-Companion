import Foundation
import FirebaseFirestore
import FirebaseStorage

final class UserService {

    static let shared = UserService()

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private init() {}

  
    //Création de User
    func createUser(
        uid: String,
        user: User
    ) async throws {

        // Données envoyées à Firestore
        var data: [String: Any] = [
            "id": uid,
            "name": user.name,
            "email": user.email,
            "nationality": user.nationality,
            "surfLevelId": user.surfLevelId,
            "boardType": user.boardType,
            "boardSize": user.boardSize,
            "boardColor": user.boardColor,
            "favoriteSpotIDs": user.favoriteSpotIDs,
            "createdAt": Timestamp()
        ]

        // Ajout de la photo uniquement si elle existe
        if ((user.profileImage?.isEmpty) == nil) {
            data["profileImage"] = user.profileImage
        }

        try await db.collection("users")
            .document(uid)
            .setData(data)
    }

    
    // Image de profil
    func uploadProfileImage(
        _ data: Data,
        uid: String
    ) async throws -> String {

        let ref = storage
            .reference()
            .child("profileImages/\(uid).jpg")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(data, metadata: metadata)
        let url = try await ref.downloadURL()

        // Mise à jour Firestore
        try await db
            .collection("users")
            .document(uid)
            .updateData([
                "profileImage": url.absoluteString
            ])

        return url.absoluteString
    }
    
    // Récupérer un user par UID
    func fetchUser(uid: String) async throws -> User? {
        let snapshot = try await db.collection("users").document(uid).getDocument()
        guard let data = snapshot.data() else { return nil }
        
        return User(
            id: data["id"] as? String ?? uid,
            name: data["name"] as? String ?? "",
            email: data["email"] as? String ?? "",
            nationality: data["nationality"] as? String ?? "",
            surfLevelId: data["surfLevelId"] as? String ?? "",
            completedSkills: data["completedSkills"] as? [String] ?? [],
            boardType: data["boardType"] as? String ?? "",
            boardSize: data["boardSize"] as? String ?? "",
            boardColor: data["boardColor"] as? String ?? "",
            favoriteSpotIDs: data["favoriteSpotIDs"] as? [String] ?? [],
            profileImage: data["profileImage"] as? String,
            friends: data["friends"] as? [String] ?? []
        )
    }
    
    // Met à jour uniquement les champs fournis
    func updateUserProgress(
        uid: String,
        surfLevelId: String,
        completedSkills: [String]
    ) async throws {

        try await Firestore.firestore()
            .collection("users")
            .document(uid)
            .updateData([
                "surfLevelId": surfLevelId,
                "completedSkills": completedSkills
            ])
    }
}

