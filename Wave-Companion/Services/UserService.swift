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
}

