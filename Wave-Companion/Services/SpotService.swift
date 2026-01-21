import Foundation

final class SpotService {

    // Liste des fichiers JSON par pays
    private static let countryFiles: [String: String] = [
        "France": "Spots_france",
        "Espagne": "Spots_espagne",
       
    ]

    // Charge tous les spots de tous les pays
    static func loadAllSpots() -> [Spot] {
        var allSpots: [Spot] = []

        for (_, fileName) in countryFiles {
            if let spots = loadSpots(from: fileName) {
                allSpots.append(contentsOf: spots)
            }
        }

        return allSpots
    }

    // Charge tous les spots d’un pays spécifique
    static func loadSpots(for country: String) -> [Spot] {
        guard let fileName = countryFiles[country] else {
            print("Aucun fichier JSON trouvé pour le pays : \(country)")
            return []
        }

        return loadSpots(from: fileName) ?? []
    }

    // Fonction pour charger un fichier JSON
    private static func loadSpots(from fileName: String) -> [Spot]? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("Fichier \(fileName).json introuvable")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let spots = try JSONDecoder().decode([Spot].self, from: data)
            return spots
        } catch {
            print("Erreur chargement spots depuis \(fileName) :", error)
            return nil
        }
    }
}

