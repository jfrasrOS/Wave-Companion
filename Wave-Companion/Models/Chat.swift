//
//  Chat.swift
//  Wave-Companion
//
//  Created by John on 31/03/2026.
//

import Foundation

struct Chat: Identifiable, Codable, Hashable {
    var id: String
    var sessionId: String?
    var participantIDs: [String]
    var lastMessage: String?
    var lastMessageDate: Date?
    var createdAt: Date
    var type: ChatType
}

enum ChatType: String, Codable, Hashable {
    case session
    case privateChat
}
