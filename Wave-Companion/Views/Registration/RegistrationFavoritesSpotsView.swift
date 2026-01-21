import SwiftUI
import FirebaseAuth

struct RegistrationFavoritesSpotsView: View {

    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var vm: RegistrationViewModel
    
    // Tous les spots dispo
    let spots: [Spot] = SpotService.loadAllSpots()

    @State private var selectedCountry: String = "France"
    @State private var selectedRegion: String = ""
    @State private var selectedSpotIDs: Set<String> = []
    private let maxSelection = 3

    // Liste des pays disponibles
    private var countries: [String] {
        Array(Set(spots.map { $0.country })).sorted()
    }

    // Liste des régions du pays sélectionné
    private var regions: [String] {
        Array(Set(spots.filter { $0.country == selectedCountry }.map { $0.region })).sorted()
    }

    // Spots filtrés par pays + région
    private var filteredSpots: [Spot] {
        spots.filter { $0.country == selectedCountry && $0.region == selectedRegion }
    }

    // Spots actuellement sélectionnés
    private var selectedSpots: [Spot] {
        spots.filter { selectedSpotIDs.contains($0.id) }
    }

    var body: some View {
        ZStack {
         

            VStack(spacing: 16) {

                Text("Choisis tes spots")
                    .font(.title.bold())
                    .padding(.top)

                // Picker pour le pays
                Picker("Pays", selection: $selectedCountry) {
                    ForEach(countries, id: \.self) { country in
                        Text(country).tag(country)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.horizontal)
                .onChange(of: selectedCountry) {
                    selectedRegion = regions.first ?? ""
                }

                // Picker pour la région
                if !regions.isEmpty {
                    Picker("Région", selection: $selectedRegion) {
                        ForEach(regions, id: \.self) { region in
                            Text(region).tag(region)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)
                }

                // Compteur de sélection
                Text("\(selectedSpotIDs.count) / \(maxSelection) sélectionnés")
                    .foregroundColor(.secondary)

                // Grille des spots
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 12) {
                        ForEach(filteredSpots) { spot in
                            spotButton(for: spot)
                        }
                    }
                    .padding(.vertical)
                    .padding(.horizontal, 8)
                }

                // Liste des spots sélectionnés
                if !selectedSpots.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Spots sélectionnés :")
                            .font(.headline)
                        ForEach(selectedSpots) { spot in
                            HStack {
                                Text(spot.name)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 10)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(12)
                                Spacer()
                                Button {
                                    selectedSpotIDs.remove(spot.id)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Bouton terminer inscription
                Button {
                    // Save les spots sélectionnés dans vm
                    vm.data.favoriteSpotIDs = Array(selectedSpotIDs)
                    
                    Task {
                        guard let uid = Auth.auth().currentUser?.uid else { return }
                        await vm.completeRegistration(uid: uid, session: session)
                    }


                } label: {
                    Text("Terminer l’inscription")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedSpotIDs.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(selectedSpotIDs.isEmpty)

            }
            .padding()
        }
        .onAppear {
            if selectedRegion.isEmpty { selectedRegion = regions.first ?? "" }
        }
    }

    // Bouton pour chaque Spot
    private func spotButton(for spot: Spot) -> some View {
        let isSelected = selectedSpotIDs.contains(spot.id)

        return Button {
            toggleSelection(for: spot)
        } label: {
            Text(spot.name)
                .font(.subheadline.bold())
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .cornerRadius(20)
        }
    }
    
    // Ajoute/Retire le spot de la sélection
    private func toggleSelection(for spot: Spot) {
        if selectedSpotIDs.contains(spot.id) {
            selectedSpotIDs.remove(spot.id)
        } else if selectedSpotIDs.count < maxSelection {
            selectedSpotIDs.insert(spot.id)
        }
    }
}

#Preview {
    RegistrationFavoritesSpotsView()
        .environmentObject(RegistrationViewModel())
        .environmentObject(SessionManager())
}

