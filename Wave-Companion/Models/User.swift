
import Foundation
import FirebaseFirestore


struct User:Identifiable, Codable{
    var id: String
    var name: String
    var email: String
    var nationality: String
    var surfLevelId: String
    var boardType: String
    var boardSize: String 
    var boardColor: String
    var favoriteSpotIDs: [String]
    var profileImage: String? // optionnel, plus tard
}

