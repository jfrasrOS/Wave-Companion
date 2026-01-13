//
//  UserService.swift
//  Wave-Companion
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class UserService {
    
    //Objet qu'on peut utiliser partout
    static let shared = UserService()
    //Firestore pour les données user
    private let db = Firestore.firestore()
    // Storage pour les images (profil)
    private let storage = Storage.storage()
    
    private init() {}
    
    // Image
    func uploadProfileImage(_ data: Data, uid: String) async throws -> String {
        
        // Créer le cheminn poour stocker l'image dans Storage
        let storageRef = storage.reference().child("profileImages/\(uid).jpg")
        
        // Définit le type de fichier
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        //Envoie dans Storage
        let _ = try await storageRef.putDataAsync(data, metadata: metadata)
        
        // Récupère l'URL pour firestore
        let url = try await storageRef.downloadURL()
        return url.absoluteString
    }
    
    // Enregistre User dans Firestore
    func saveUser(_ user: User, uid: String) async throws {
        try await db.collection("users")
            .document(uid)
            .setData([
                "id": user.id,
                "name": user.name,
                "email": user.email,
                "profileImage": user.profileImage,
                "nationality": user.nationality,
                "surfLevelId": user.surfLevelId,
                "boardType": user.boardType,
                "boardColor": user.boardColor,
                "favoriteSpotIDs": user.favoriteSpotIDs,
                "createdAt": Timestamp()
            ])
    }
}

// Envoie et récupère des fichiers depuis Storage
extension StorageReference {
    // Envoie les données sur storage de façcon async
    func putDataAsync(_ data: Data, metadata: StorageMetadata?) async throws -> StorageMetadata {
        try await withCheckedThrowingContinuation { continuation in
            self.putData(data, metadata: metadata) { metadata, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let metadata = metadata {
                    continuation.resume(returning: metadata)
                } else {
                    continuation.resume(throwing: NSError(domain: "StorageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error during upload"]))
                }
            }
        }
    }
    
    // Récupére l'url du fichier storage
    func downloadURL() async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            self.downloadURL { url, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let url = url {
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(throwing: NSError(domain: "StorageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error getting download URL"]))
                }
            }
        }
    }
}

