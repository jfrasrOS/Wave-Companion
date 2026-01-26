import SwiftUI
import FirebaseAuth

struct RegistrationFavoritesSpotsView: View {

    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var vm: RegistrationViewModel

    let spots: [Spot] = SpotService.loadAllSpots()

    @State private var selectedCountry: String = "France"
    @State private var selectedRegion: String = ""
    @State private var selectedSpotIDs: Set<String> = []

    private let maxSelection = 3

    var body: some View {
        RegistrationStepContainer(
            title: "Tes spots favoris",
            subtitle: "Choisis jusqu’à 3 spots pour personnaliser ton expérience.",
            currentStep: 4,
            totalSteps: 5,
            isActionEnabled: !selectedSpotIDs.isEmpty,
            actionTitle: "Terminer l’inscription",
            onAction: finishRegistration
        ) {
            countryPicker
            regionPicker
            selectionCounter
            spotsGrid
            selectedSpotsList
        }
        .onAppear {
            if selectedRegion.isEmpty {
                selectedRegion = regions.first ?? ""
            }
        }
    }

    

    private var countryPicker: some View {
        Picker("Pays", selection: $selectedCountry) {
            ForEach(countries, id: \.self) {
                Text($0)
            }
        }
        .pickerStyle(.menu)
    }

    private var regionPicker: some View {
        Picker("Région", selection: $selectedRegion) {
            ForEach(regions, id: \.self) {
                Text($0)
            }
        }
        .pickerStyle(.menu)
    }

    private var selectionCounter: some View {
        Text("\(selectedSpotIDs.count) / \(maxSelection) sélectionnés")
            .font(.subheadline)
            .foregroundColor(.secondary)
    }

    private var spotsGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 12) {
            ForEach(filteredSpots) { spot in
                spotButton(for: spot)
            }
        }
    }

    private var selectedSpotsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(selectedSpots) { spot in
                HStack {
                    Text(spot.name)
                        .font(.subheadline.bold())
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
    }

  

    private func finishRegistration() {
        vm.data.favoriteSpotIDs = Array(selectedSpotIDs)

        Task {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            await vm.completeRegistration(uid: uid, session: session)
        }
    }

    private func spotButton(for spot: Spot) -> some View {
        let isSelected = selectedSpotIDs.contains(spot.id)

        return Button {
            toggleSelection(for: spot)
        } label: {
            Text(spot.name)
                .font(.subheadline.bold())
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? AppColors.action : Color(.systemGray5))
                .cornerRadius(20)
        }
    }

    private func toggleSelection(for spot: Spot) {
        if selectedSpotIDs.contains(spot.id) {
            selectedSpotIDs.remove(spot.id)
        } else if selectedSpotIDs.count < maxSelection {
            selectedSpotIDs.insert(spot.id)
        }
    }

    

    private var countries: [String] {
        Array(Set(spots.map { $0.country })).sorted()
    }

    private var regions: [String] {
        Array(Set(
            spots
                .filter { $0.country == selectedCountry }
                .map { $0.region }
        )).sorted()
    }

    private var filteredSpots: [Spot] {
        spots.filter {
            $0.country == selectedCountry &&
            $0.region == selectedRegion
        }
    }

    private var selectedSpots: [Spot] {
        spots.filter { selectedSpotIDs.contains($0.id) }
    }
}

