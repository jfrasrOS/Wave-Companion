//
//  FriendViewModel.swift
//  Wave-Companion
//
//  Created by John on 22/04/2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

final class FriendsViewModel: ObservableObject {
    
    @Published var requests: [FriendRequest] = []
    @Published var friends: [User] = []
    
    private let db = Firestore.firestore()
    
    func listenRequests() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("friendRequests")
            .whereField("to", isEqualTo: uid)
            .whereField("status", isEqualTo: "pending")
            .addSnapshotListener { snapshot, _ in
                
                self.requests = snapshot?.documents.compactMap {
                    try? $0.data(as: FriendRequest.self)
                } ?? []
            }
    }
    
    func listenFriends() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid)
            .addSnapshotListener { [weak self] snapshot, _ in
                
                guard let self = self,
                      let data = snapshot?.data(),
                      let friendIds = data["friends"] as? [String],
                      !friendIds.isEmpty
                else {
                    self?.friends = []
                    return
                }
                
                // un seul call Firestore
                Task {
                    do {
                        let snapshot = try await self.db.collection("users")
                            .whereField(FieldPath.documentID(), in: friendIds)
                            .getDocuments()
                        
                        let users: [User] = snapshot.documents.compactMap { doc in
                            let data = doc.data()
                            
                            return User(
                                id: doc.documentID,
                                name: data["name"] as? String ?? "",
                                email: data["email"] as? String ?? "",
                                nationality: data["nationality"] as? String ?? "FR",
                                surfLevelId: data["surfLevelId"] as? String ?? "",
                                completedSkills: data["completedSkills"] as? [String] ?? [],
                                boardType: data["boardType"] as? String ?? "",
                                boardSize: data["boardSize"] as? String ?? "",
                                boardColor: data["boardColor"] as? String ?? "#FFFFFF",
                                favoriteSpotIDs: data["favoriteSpotIDs"] as? [String] ?? [],
                                friends: data["friends"] as? [String] ?? []
                            )
                        }
                        
                        self.friends = users
                        
                    } catch {
                        print("Error fetching friends:", error)
                    }
                }
            }
    }
}
