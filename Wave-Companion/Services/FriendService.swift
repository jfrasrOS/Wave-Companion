//
//  FriendService.swift
//  Wave-Companion
//
//  Created by John on 22/04/2026.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FriendService {
    
    static let shared = FriendService()
    private let db = Firestore.firestore()
    
    
    // Envoie de la demande d'ami
    func sendFriendRequest(to userId: String, sessionId: String) async throws {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        // empêcher soi-même
        if currentUserId == userId { return }
        
        // Vérification backend (session commune passée)
        let sessionDoc = try await db.collection("sessions").document(sessionId).getDocument()
        
        guard let data = sessionDoc.data(),
              let participants = data["participantIDs"] as? [String],
              let date = (data["date"] as? Timestamp)?.dateValue()
        else { return }
        
        guard participants.contains(currentUserId),
              participants.contains(userId),
              date < Date()
        else {
            throw NSError(domain: "NotAllowed", code: 403)
        }
        
            // récupérer user courant
            let currentUserDoc = try await db.collection("users").document(currentUserId).getDocument()
            let currentData = currentUserDoc.data()
            
            let currentFriends = currentData?["friends"] as? [String] ?? []
            
            // déjà ami
            if currentFriends.contains(userId) { return }
        
           // éviter doublon (dans les 2 sens)
           let existing = try await db.collection("friendRequests")
               .whereFilter(
                   Filter.orFilter([
                       Filter.andFilter([
                           Filter.whereField("from", isEqualTo: currentUserId),
                           Filter.whereField("to", isEqualTo: userId)
                       ]),
                       Filter.andFilter([
                           Filter.whereField("from", isEqualTo: userId),
                           Filter.whereField("to", isEqualTo: currentUserId)
                       ])
                   ])
               )
               .getDocuments()
        
        if !existing.documents.isEmpty { return }
        
        let userDoc = try await db.collection("users").document(currentUserId).getDocument()
        let userData = userDoc.data()

        let fromName = userData?["name"] as? String ?? "Surfeur"
        let fromAvatar = userData?["profileImage"] as? String

        // création demande
        try await db.collection("friendRequests").addDocument(data: [
            "from": currentUserId,
            "to": userId,
            "fromName": fromName,
            "fromAvatar": fromAvatar ?? "",
            "status": "pending",
            "createdAt": Timestamp(date: Date())
        ])
    }
    
    // Accepté la demande d'ami
    func acceptRequest(requestId: String, from userId: String) async throws {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let batch = db.batch()
        
        let requestRef = db.collection("friendRequests").document(requestId)
        
        // supprime directement la requete aprés avoir accepté la demande
        batch.deleteDocument(requestRef)
        
        // ajoute amis des 2 cotés
        let currentUserRef = db.collection("users").document(currentUserId)
        let otherUserRef = db.collection("users").document(userId)
        
        batch.updateData([
            "friends": FieldValue.arrayUnion([userId])
        ], forDocument: currentUserRef)
        
        batch.updateData([
            "friends": FieldValue.arrayUnion([currentUserId])
        ], forDocument: otherUserRef)
        
        try await batch.commit()
    }
    
    // refuser la demande
    func rejectRequest(requestId: String) async throws {
        try await db.collection("friendRequests")
            .document(requestId)
            .delete()
    }
    
    // Supprimer un ami
    func removeFriend(userId: String) async throws {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let batch = db.batch()
        
        let currentUserRef = db.collection("users").document(currentUserId)
        let otherUserRef = db.collection("users").document(userId)
        
        batch.updateData([
            "friends": FieldValue.arrayRemove([userId])
        ], forDocument: currentUserRef)
        
        batch.updateData([
            "friends": FieldValue.arrayRemove([currentUserId])
        ], forDocument: otherUserRef)
        
        try await batch.commit()
    }
}
