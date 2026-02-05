import SwiftUI
import FirebaseAuth
struct RegistrationFavoritesSpotsView: View {

    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var vm: RegistrationViewModel

    let spots: [Spot] = SpotService.loadAllSpots()

    @State private var selectedSpotIDs: Set<String> = []
    @State private var focusedSpotID: String?

    private let maxSelection = 3

    var body: some View {
        RegistrationStepContainer(
            title: "Tes spots favoris",
            subtitle: "Tape sur la carte pour en choisir jusqu’à 3.",
            currentStep: 3,
            totalSteps: 4,
            isActionEnabled: !selectedSpotIDs.isEmpty,
            actionTitle: "Terminer l’inscription",
            onBack: { vm.back() },
            onAction: finishRegistration
        ) {
            VStack(spacing: 16) {

                ZStack(alignment: .topTrailing) {
                    // Carte avec les spots
                    SpotClusterMapView(
                        spots: spots,
                        selectedSpotIDs: $selectedSpotIDs,
                        focusedSpotID: $focusedSpotID
                    )
                    .frame(height: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 24))

                    // compteur
                    Text("\(selectedSpotIDs.count) / \(maxSelection)")
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(12)
                }

                selectedSpotsCards
            }
        }
    }

    // Cards avec les spots selectionnés
    private var selectedSpotsCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(selectedSpots) { spot in
                    SpotSnapshotCard(
                        spot: spot,
                        isFocused: focusedSpotID == spot.id
                    ) {
                        selectedSpotIDs.remove(spot.id)
                        if focusedSpotID == spot.id {
                            focusedSpotID = nil
                        }
                    }
                    .onTapGesture {
                        withAnimation(.spring()) {
                            focusedSpotID = spot.id
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func finishRegistration() {
        vm.data.favoriteSpotIDs = Array(selectedSpotIDs)

        Task {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            await vm.completeRegistration(uid: uid, session: session)
        }
    }

    private var selectedSpots: [Spot] {
        spots.filter { selectedSpotIDs.contains($0.id) }
    }
}


#Preview {
    RegistrationFavoritesSpotsView()
        .environmentObject(RegistrationViewModel())
}
