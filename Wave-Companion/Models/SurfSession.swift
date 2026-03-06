import Foundation

struct SurfSession: Identifiable, Codable {
    
    var id: String
    var spotName: String
    var latitude: Double
    var longitude: Double
    var date: Date
    var createdAt: Date
    var creatorId: String
    var minimumLevel: String
    var maxPeople: Int
    var participantIDs: [String]
    var chatId: String
    var status: SessionStatus
}

enum SessionStatus: String, Codable {
    case open
    case full
    case cancelled
    case finished
}

