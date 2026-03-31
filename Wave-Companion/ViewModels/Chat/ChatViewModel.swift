import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    
    // Message affiché dans le chat (temps réel)
    @Published var messages: [Message] = []
    @Published var text: String = ""
    // Cache local des users (évite de refaire trop de requêtes)
    @Published var users: [String: String] = [:] // userId → name
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    let chatId: String
    
    init(chatId: String) {
        self.chatId = chatId
        // démarre l'écoute en temps réel dès l'ouverture
        listenMessages()
    }
    
    deinit {
        // Evite fuite mémoire
        listener?.remove()
    }
    
    // LISTENER TEMPS RÉEL
    func listenMessages() {
        
        listener?.remove()
        
        listener = db.collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                
                guard let self else { return }
                
                if let error {
                    print("listenMessages error:", error)
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                // Mapping firestore -> model swift
                self.messages = documents.compactMap {
                    try? $0.data(as: Message.self)
                }

                // charges les noms des users si nécessaire
                self.fetchUsersIfNeeded(for: self.messages)
            }
    }
    
    // Envoie de message
    func sendMessage() async {
        
        guard let user = Auth.auth().currentUser else { return }
        
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let messageId = UUID().uuidString
        
        // récupére nom depuis le cache sinon fallback
        let name = users[user.uid] ?? "Surfeur"
        
        let data: [String: Any] = [
            "id": messageId,
            "chatId": chatId,
            "senderId": user.uid,
            "senderName": name,
            "text": trimmed,
            "createdAt": Timestamp(date: Date())
        ]
        
        do {
            // Ecrit message
            try await db.collection("chats")
                .document(chatId)
                .collection("messages")
                .document(messageId)
                .setData(data)
            
            // Update
            try await db.collection("chats")
                .document(chatId)
                .updateData([
                    "lastMessage": trimmed,
                    "lastMessageDate": Timestamp(date: Date())
                ])
            
            // Reset input
            text = ""
            
        } catch {
            print("send message error:", error)
        }
    }
    
    // Charge les users manquants
    func fetchUsersIfNeeded(for messages: [Message]) {
        
        let ids = Set(messages.map { $0.senderId })
        
        for id in ids {
            if users[id] != nil { continue } // Déjà chargé 
            
            db.collection("users").document(id).getDocument { [weak self] snapshot, _ in
                guard let data = snapshot?.data() else { return }
                
                let name = data["name"] as? String ?? "Surfeur"
                
                DispatchQueue.main.async {
                    self?.users[id] = name
                }
            }
        }
    }
}
