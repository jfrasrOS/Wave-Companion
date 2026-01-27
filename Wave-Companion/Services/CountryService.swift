import Foundation


struct CountryService {
    
    // Return la liste des pays
    static func allCountries() -> [Country] {
        
        // Récupére tous les pays connus dans le système
        Locale.Region.isoRegions
            .filter { $0.identifier.count == 2 } // filtre continents
            .compactMap { region in
                
                // Code pays
                let identifier = region.identifier

                // Nom du pays dans la langue du téléphone
                guard let name = Locale.current.localizedString(forRegionCode: identifier) else {
                    return nil
                }

                // Création de l'objet 
                return Country(
                    id: identifier,
                    name: name,
                    flag: flagEmoji(from: identifier)
                )
            }
            // Par ordre alphabétique
            .sorted { $0.name < $1.name }
    }

    // Transforme le code pays en emoji drapeau
    private static func flagEmoji(from countryCode: String) -> String {
        countryCode
            .uppercased()
            .unicodeScalars
            .compactMap { scalar in
                UnicodeScalar(127397 + scalar.value)
            }
            .map(String.init)
            .joined()
    }
}
