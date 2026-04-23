//
//  SessionDetailViewModel.swift
//  Wave-Companion
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
final class SessionDetailViewModel: ObservableObject {

    @Published var session: SurfSession
    @Published var participants: [SessionUser] = []
    
    @Published var currentUserId: String = ""
    @Published var currentUserFriends: [String] = []
    @Published var sentRequests: Set<String> = []

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init(session: SurfSession) {
        self.session = session
        observeParticipants()
        loadCurrentUser()
        listenSentRequests()
    }

    deinit {
        listener?.remove()
        listener = nil
    }
    
    // Récupérer le User
    func loadCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        currentUserId = uid
        
        db.collection("users").document(uid)
            .addSnapshotListener { [weak self] snapshot, _ in
                let data = snapshot?.data()
                self?.currentUserFriends = data?["friends"] as? [String] ?? []
            }
    }

    // Listener sur les participants
    func observeParticipants() {
        let ids = session.participantIDs
        guard !ids.isEmpty else { return }

        listener = db.collection("users")
            .whereField(FieldPath.documentID(), in: ids)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                guard let documents = snapshot?.documents else { return }

                // Mapping direct vers SessionUser
                let users: [SessionUser] = documents.map { doc in
                    let data = doc.data()
                    return SessionUser(
                        id: doc.documentID,
                        name: data["name"] as? String ?? "",
                        nationality: data["nationality"] as? String ?? "FR",
                        boardType: data["boardType"] as? String ?? "",
                        boardSize: data["boardSize"] as? String ?? "",
                        boardColor: data["boardColor"] as? String ?? "#FFFFFF",
                        profileImage: data["profileImage"] as? String
                    )
                }

                self.participants = users
            }
    }

    // Supprime le listener pour éviter les fuites mémoire
    func removeListener() {
        listener?.remove()
        listener = nil
    }
    
    // Envoie la requete
    func sendFriendRequest(to userId: String) {
        Task {
            try? await FriendService.shared.sendFriendRequest(
                to: userId,
                sessionId: session.id
            )
        }
    }
    
    
    func listenSentRequests() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("friendRequests")
            .whereField("from", isEqualTo: uid)
            .whereField("status", isEqualTo: "pending")
            .addSnapshotListener { [weak self] snapshot, _ in
                
                let ids = snapshot?.documents.compactMap {
                    $0.data()["to"] as? String
                } ?? []
                
                self?.sentRequests = Set(ids)
            }
    }
    
}
