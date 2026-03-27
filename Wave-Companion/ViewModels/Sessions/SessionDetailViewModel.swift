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

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init(session: SurfSession) {
        self.session = session
        observeParticipants()
    }

    deinit {
        listener?.remove()
        listener = nil
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
}
