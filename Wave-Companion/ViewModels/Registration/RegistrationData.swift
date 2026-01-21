
import Foundation
import FirebaseCore

// Modele pour stocker les données temporaires au cours de l'inscription
struct RegistrationData {
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var profileImage: String = ""
    var nationality: String = ""
    var surfLevel: SurfLevelModel? = nil
    var boardType: String = ""
    var boardSize: String = ""
    var boardColor: String = ""
    
    var favoriteSpotIDs: [String] = []
    
    // Crée une instance User à partir des données saisies 
    func buildUser(uid: String) -> User {
        guard let surfLevel = surfLevel else {
            fatalError("Le niveau de surf doit être selectionné")
        }

        return User(
            id: uid,
            name: name,
            email: email,
            nationality: nationality,
            surfLevelId: surfLevel.id,
            boardType: boardType,
            boardSize: boardSize,
            boardColor: boardColor,
            favoriteSpotIDs: favoriteSpotIDs,
            profileImage: nil,
            
        )
    }

}

