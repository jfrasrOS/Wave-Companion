import SwiftUI
import MapKit
import FirebaseAuth

struct SurfMapView: View {

    @StateObject private var vm = SessionViewModel()
    @State private var showingCreate = false
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 46.6, longitude: 2.4),
        span: MKCoordinateSpan(latitudeDelta: 7, longitudeDelta: 7)
    )

    var body: some View {
        ZStack(alignment: .bottom) {

            // Carte avec clusters
            SpotClusterMapViewSingle(
                spots: vm.spots,
                hasSession: { vm.hasSession(for: $0) },
                selectedSpotID: $vm.selectedSpotID,
                focusedSpotID: $vm.selectedSpotID,
                region: $mapRegion,
                onRegionChanged: { region in
                    vm.startSessionListener(for: region)
                }
            )
            .edgesIgnoringSafeArea(.all)

            // Bottom sheet affichée si un spot est sélectionné
            if vm.selectedSpotID != nil {
                bottomSheet
            }
        }
        .sheet(isPresented: $showingCreate) {
            CreateSessionView(vm: vm)
        }
        .onAppear {
            vm.loadSpots()
            vm.loadCurrentUserLevel()
        }
    }
}

extension SurfMapView {

    // MARK: - Bottom Sheet
    var bottomSheet: some View {
        VStack(spacing: 16) {

            // Drag indicator
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.4))

            header
            Divider()

            if vm.sessionsForSelectedSpot.isEmpty {
                emptyState
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(vm.sessionsForSelectedSpot) { session in

                            // Participants uniques
                            let participants = Array(Set(session.participantIDs))
                            let remaining = max(0, session.maxPeople - participants.count)
                            let isJoined = Auth.auth().currentUser.map { participants.contains($0.uid) } ?? false
                            let canJoin = !isJoined && remaining > 0

                            // Utilisation de SessionCardView
                            SessionCardView(
                                session: session,
                                levelText: "Min. \(vm.category(for: session.minimumLevel))",
                                sessionTitle: isJoined ? "Ta prochaine session" : (remaining == 0 ? "Session complète" : "Session ouverte"),
                                titleColor: isJoined ? .green : (remaining == 0 ? .red : .green),
                                buttonTitle: isJoined ? "Détails" : (remaining == 0 ? "Complet" : "Rejoindre"),
                                buttonEnabled: canJoin || isJoined,
                                onButtonTap: {
                                    if isJoined {
                                        // TODO: navigation vers les détails de la session
                                    } else {
                                        Task { await vm.joinSession(session) }
                                    }
                                }
                            )
                        }
                    }
                }
            }

            createButton
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 20)
        )
        .transition(.move(edge: .bottom))
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: vm.selectedSpotID)
    }

    // MARK: - Header
    var header: some View {
        HStack {
            if let spot = vm.spots.first(where: { $0.id == vm.selectedSpotID }) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(spot.name).font(.title3.bold())
                    Text(spot.city).font(.caption).foregroundColor(.secondary)
                }
            }
            Spacer()
            Button { vm.selectSpot(id: nil) } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Empty State
    var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: "water.waves")
                .font(.title2)
                .foregroundColor(.secondary)
            Text("Aucune session pour ce spot").font(.subheadline)
            Text("Soyez le premier à en créer une").font(.caption).foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Create Button
    var createButton: some View {
        Button {
            showingCreate = true
        } label: {
            Label("Créer une session", systemImage: "plus.circle.fill")
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.primary)
                .foregroundColor(.white)
                .cornerRadius(14)
        }
    }
}
