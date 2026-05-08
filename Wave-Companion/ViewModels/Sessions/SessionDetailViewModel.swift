import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine
import SwiftUI

@MainActor
final class SessionDetailViewModel: ObservableObject {
    
    @Published var session: SurfSession
    @Published var participants: [SessionUser] = []
    
    @Published var currentUserId: String = ""
    @Published var currentUserFriends: [String] = []
    @Published var sentRequests: Set<String> = []
    
    private let db = Firestore.firestore()
    
    private var participantsListener: ListenerRegistration?
    private var sessionListener: ListenerRegistration?
    private var currentUserListener: ListenerRegistration?
    private var requestsListener: ListenerRegistration?
    
    enum SessionState {
        case upcoming
        case ongoing
        case past
    }
    
    var state: SessionState {
        
        let now = Date()
        
        if now < session.date {
            return .upcoming
            
        } else if now < session.date.addingTimeInterval(7200) {
            return .ongoing
            
        } else {
            return .past
        }
    }
    
    var stateTitle: String {
        
        switch state {
            
        case .upcoming:
            return "À venir"
            
        case .ongoing:
            return "En cours"
            
        case .past:
            return "Terminée"
        }
    }
    
    var stateColor: Color {
        
        switch state {
            
        case .upcoming:
            return AppColors.primary
            
        case .ongoing:
            return .green
            
        case .past:
            return .gray
        }
    }
    
    var isChatAvailable: Bool {
        
        guard let endAt = session.chatEndAt else {
            return false
        }
        
        return endAt > Date()
    }
    
    enum FriendState {
        case currentUser
        case friend
        case pending
        case locked
        case addable
    }
    
    func friendState(for user: SessionUser) -> FriendState {
        
        if user.id == currentUserId {
            return .currentUser
        }
        
        if currentUserFriends.contains(user.id) {
            return .friend
        }
        
        if sentRequests.contains(user.id) {
            return .pending
        }
        
        if state != .past {
            return .locked
        }
        
        return .addable
    }
    
    private let surfLevels = SurfLevelService.loadLevels()
    
    func category(for levelId: String) -> String {
        surfLevels.first { $0.id == levelId }?.category ?? levelId
    }
    
    init(session: SurfSession) {
        
        self.session = session
        
        observeSession()
        observeParticipants()
        loadCurrentUser()
        listenSentRequests()
    }
    
    deinit {
        
        participantsListener?.remove()
        sessionListener?.remove()
        currentUserListener?.remove()
        requestsListener?.remove()
    }
    
    func observeSession() {
        
        sessionListener = db.collection("sessions")
            .document(session.id)
            .addSnapshotListener { [weak self] snapshot, _ in
                
                guard let document = snapshot else { return }
                
                guard let updatedSession = try? document.data(as: SurfSession.self) else {
                    return
                }
                
                self?.session = updatedSession
            }
    }
    
    func loadCurrentUser() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        currentUserId = uid
        
        currentUserListener = db.collection("users")
            .document(uid)
            .addSnapshotListener { [weak self] snapshot, _ in
                
                let data = snapshot?.data()
                
                self?.currentUserFriends =
                    data?["friends"] as? [String] ?? []
            }
    }
    

    func observeParticipants() {
        
        let ids = session.participantIDs
        
        guard !ids.isEmpty else {
            return
        }
        
        participantsListener = db.collection("users")
            .whereField(FieldPath.documentID(), in: ids)
            .addSnapshotListener { [weak self] snapshot, error in
                
                guard let self = self else { return }
                guard let documents = snapshot?.documents else { return }
                
                let users: [SessionUser] = documents.map { doc in
                    
                    let data = doc.data()
                    
                    return SessionUser(
                        id: doc.documentID,
                        name: data["name"] as? String ?? "",
                        nationality: data["nationality"] as? String ?? "FR",
                        boardType: data["boardType"] as? String ?? "",
                        boardSize: data["boardSize"] as? String ?? "",
                        boardColor: data["boardColor"] as? String ?? "#FFFFFF",
                        profileImage: data["profileImage"] as? String,
                        level: data["surfLevelId"] as? String ?? "mousse_1"
                    )
                }
                
                self.participants = users
            }
    }
    
    func sendFriendRequest(to userId: String) {
        
        Task {
            
            try? await FriendService.shared.sendFriendRequest(
                to: userId,
                sessionId: session.id
            )
        }
    }
    
    func listenSentRequests() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        requestsListener = db.collection("friendRequests")
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
