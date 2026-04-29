import Foundation

struct SurfSession: Identifiable, Codable, Hashable{
    
    var id: String
    
    var spotName: String
    var spotId: String
    
    var latitude: Double
    var longitude: Double
    var geohash: String
    
    var date: Date
    var createdAt: Date
    
    var creatorId: String
    
    var minimumLevel: String
    var maxPeople: Int
    
    var participantIDs: [String]
    
    var chatId: String
    
    var status: SessionStatus
    
    var wavesCount: Int?
    var skills: [String]?
    var afterSessionCompleted: Bool?
}

enum SessionStatus: String, Codable, Hashable {
    case open
    case full
    case cancelled
    case finished
}

extension SurfSession {
    
    var city: String {
        SpotService.spot(for: spotId)?.city ?? ""
    }
    
    var region: String {
        SpotService.spot(for: spotId)?.region ?? ""
    }
}

