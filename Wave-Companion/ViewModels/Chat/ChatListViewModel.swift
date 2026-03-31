//
//  ChatListViewModel.swift
//  Wave-Companion
//
//  Created by John on 31/03/2026.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
final class ChatListViewModel: ObservableObject {
    
    @Published var chats: [Chat] = []
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    func listenChats() {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        listener?.remove()
        
        listener = db.collection("chats")
            .whereField("participantIDs", arrayContains: userId)
            .order(by: "lastMessageDate", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                
                guard let self else { return }
                
                if let error {
                    print("Chat listener error:", error)
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                print("RAW chats count:", documents.count)
                
                self.chats = documents.compactMap { doc in
                    
                    guard let chat = try? doc.data(as: Chat.self) else { return nil }
                    
                    guard !chat.participantIDs.isEmpty else { return nil }
                    
                    return chat
                }
                
                print("FILTERED chats:", self.chats.count)
            }
    }
}
