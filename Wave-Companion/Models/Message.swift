//
//  Message.swift
//  Wave-Companion
//
//  Created by John on 31/03/2026.
//

import Foundation

struct Message: Identifiable, Codable, Hashable {
    var id: String
    var chatId: String
    var senderId: String
    var senderName: String
    var text: String
    var createdAt: Date
}
