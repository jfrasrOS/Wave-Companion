//
//  MockData.swift
//  Wave-Companion
//

import Foundation

enum MockData {
    
    static let nearbySessions: [SurfSession] = [
        SurfSession(
            id: "1",
            spotName: "La Côte des Basques",
            spotId: "Biarritz_cote_des_basques",
            latitude: 43.4860,
            longitude: -1.5586,
            geohash: "ex26888",
            date: Calendar.current.date(byAdding: .hour, value: 2, to: Date())!,
            createdAt: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            creatorId: "u1",
            minimumLevel: "Intermédiaire",
            maxPeople: 8,
            participantIDs: ["u1", "u2", "u3"],
            chatId: "chat_1",
            status: .open
        ),
        SurfSession(
            id: "2",
            spotName: "Parlementia",
            spotId: "Bidart_parlementia",
            latitude: 43.3860,
            longitude: -1.5478,
            geohash: "ex26888",
            date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            createdAt: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            creatorId: "u2",
            minimumLevel: "Débutant",
            maxPeople: 5,
            participantIDs: ["u1"],
            chatId: "chat_2",
            status: .open
        ),
        SurfSession(
            id: "3",
            spotName: "Hossegor La Nord",
            spotId: "Hossegor_la_nord",
            latitude: 43.6660,
            longitude: -1.4500,
            geohash: "ex26888",
            date: Calendar.current.date(byAdding: .hour, value: 5, to: Date())!,
            createdAt: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            creatorId: "u3",
            minimumLevel: "Intermédiaire",
            maxPeople: 4,
            participantIDs: [],
            chatId: "chat_3",
            status: .open
        )
    ]
    
}
