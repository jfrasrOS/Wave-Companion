//
//  MockData.swift
//  Wave-Companion
//
//  Created by John on 02/03/2026.
//

import Foundation

enum MockData {

    static let nearbySessions: [SurfSession] = [
        SurfSession(
            id: "1",
            spotName: "La Côte des Basques",
            date: Calendar.current.date(byAdding: .hour, value: 2, to: Date())!,
            maxPeople: 8,
            minimumLevel: "Intermédiaire",
            participantIDs: ["u1", "u2", "u3"]
        ),
        SurfSession(
            id: "2",
            spotName: "Parlementia",
            date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            maxPeople: 5,
            minimumLevel: "mousse_1",
            participantIDs: ["u1"]
        ),
        SurfSession(
            id: "3",
            spotName: "Hossegor La Nord",
            date: Calendar.current.date(byAdding: .hour, value: 5, to: Date())!,
            maxPeople: 4,
            minimumLevel: "argent_1",
            participantIDs: []
        )
    ]
}
