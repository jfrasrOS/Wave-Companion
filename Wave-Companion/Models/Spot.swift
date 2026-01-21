

import Foundation


struct Spot: Codable, Identifiable {
    var id: String
    var country: String
    var region : String
    var city: String
    var name: String
    var latitude: Double
    var longitude: Double
}
