import Foundation

final class SpotService {

    private static let countryFiles: [String: String] = [
        "France": "Spots_france",
        "Espagne": "Spots_espagne",
    ]

    // Cache global des spots (chargé une seule fois)
    private static var cachedSpots: [Spot] = loadAllSpotsInternal()

    // Index rapide pour retrouver un spot par son id
    private static var spotById: [String: Spot] = {
        Dictionary(uniqueKeysWithValues: cachedSpots.map { ($0.id, $0) })
    }()

    // Return tous les spots
    static func allSpots() -> [Spot] {
        cachedSpots
    }

    // Return un spot par son Id
    static func spot(for id: String) -> Spot? {
        spotById[id]
    }

    // Charge tous les Json et fusionne les spots
    private static func loadAllSpotsInternal() -> [Spot] {
        var allSpots: [Spot] = []

        for (_, fileName) in countryFiles {
            if let spots = loadSpots(from: fileName) {
                allSpots.append(contentsOf: spots)
            }
        }

        return allSpots
    }

    // Charge un Json spécifique
    private static func loadSpots(from fileName: String) -> [Spot]? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("Fichier \(fileName).json introuvable")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Spot].self, from: data)
        } catch {
            print("Erreur chargement spots depuis \(fileName):", error)
            return nil
        }
    }
    
    // Accés public au cache
    static func loadAllSpots() -> [Spot] {
        cachedSpots
    }
}
