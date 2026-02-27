

import Foundation

struct UserMock {
    static let shared = UserMock()
    
    let user = User(
        id: "mock_id",
        name: "John",
        email: "test@gmail.com",
        nationality: "FR",
        surfLevelId: "or_1",
        completedSkills: ["Réaliser un tube", "Réaliser un cut back"],
        boardType: "Mid-Length",
        boardSize: "7'2\"",
        boardColor: "#FFFFFF",
        favoriteSpotIDs: ["hossegor_la_sud", "hossegor_la_nord", "hossegor_la_graviere"],
        profileImage: nil
    )
}
