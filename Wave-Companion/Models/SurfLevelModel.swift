
import Foundation


struct SurfLevelModel: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let skills: [String]
    let order: Int
    let category: String
}
