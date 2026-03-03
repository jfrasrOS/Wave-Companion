
import Foundation

struct SurfSession: Identifiable, Codable {
    var id: String
    var spotName: String
    var date: Date
    var maxPeople: Int
    var minimumLevel: String
    var participantIDs: [String]
}
