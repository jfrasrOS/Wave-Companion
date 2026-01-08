//
//  SurfLevelService.swift
//  Wave-Companion
//
//  Created by John on 18/12/2025.
//

import Foundation

final class SurfLevelService {

    // Charge les niveaux de surf depuis le JSON
    static func loadLevels() -> [SurfLevelModel] {
        guard let url = Bundle.main.url(forResource: "SurfLevels", withExtension: "json") else {
            fatalError("SurfLevels.json introuvable")
        }

        do {
            // Lecture du fichier
            let data = try Data(contentsOf: url)
            // Transforme le JSOn en objet
            let levels = try JSONDecoder().decode([SurfLevelModel].self, from: data)
            // Trie dans l'ordre des niveaux
            return levels.sorted { $0.order < $1.order }
        } catch {
            fatalError("Erreur de chargement du fichier SurfsLevels.json: \(error)")
        }
    }
}
