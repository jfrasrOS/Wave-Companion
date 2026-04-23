//
//  FriendRequest.swift
//  Wave-Companion
//
//  Created by John on 22/04/2026.
//

import Foundation
import FirebaseFirestore

struct FriendRequest: Identifiable, Codable {
    
    @DocumentID var id: String?
    
    let from: String
    let to: String
    let status: String
    let createdAt: Timestamp
    
    var fromName: String?
    var fromAvatar: String?
}
