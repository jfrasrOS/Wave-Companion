import SwiftUI
import MapKit
import FirebaseAuth

struct SurfMapView: View {

    @StateObject private var vm = SessionViewModel()

    @State private var selectedSession: SurfSession?
    @State private var showingCreate = false

    @State private var searchText = ""

    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 46.6, longitude: 2.4),
        span: MKCoordinateSpan(latitudeDelta: 7, longitudeDelta: 7)
    )

    @Binding var selectedTab: TabItem
    @Binding var selectedChatId: String?

    init(
        selectedTab: Binding<TabItem>,
        selectedChatId: Binding<String?>
    ) {
        _selectedTab = selectedTab
        _selectedChatId = selectedChatId
    }

    var body: some View {

        NavigationStack {

            ZStack(alignment: .top) {

                // MAP
                SpotClusterMapViewSingle(
                    spots: vm.spots,
                    hasOpenSession: { vm.hasOpenSession(for: $0) },
                    hasOnlyFullSession: { vm.hasOnlyFullSession(for: $0) },
                    selectedSpotID: $vm.selectedSpotID,
                    focusedSpotID: $vm.selectedSpotID,
                    region: $mapRegion,
                    focusOffsetRatio: 0.012,
                    onRegionChanged: { region in
                        vm.updateVisibleSessions(for: region)
                    }
                )
                .ignoresSafeArea()

                // OVERLAY
                VStack(spacing: 12) {

                    searchBar

                    if !searchResults.isEmpty && !searchText.isEmpty {
                        searchResultsView
                    }

                    Spacer()

                    if vm.selectedSpotID != nil {
                        bottomSheet
                    }
                }
                .animation(.spring(response: 0.35), value: vm.selectedSpotID)
            }

            .navigationDestination(item: $selectedSession) { session in

                SessionDetailView(
                    vm: SessionDetailViewModel(session: session),
                    selectedTab: $selectedTab,
                    selectedChatId: $selectedChatId
                )
            }

            .sheet(isPresented: $showingCreate) {
                CreateSessionView(vm: vm)
            }

            .onAppear {
                vm.loadSpots()
                vm.loadCurrentUserLevel()
                vm.startGlobalSessionsListener()

                    vm.updateVisibleSessions(
                        for: mapRegion
                    )
            }
        }
    }
}

// Recherche
extension SurfMapView {

    var searchResults: [Spot] {

        guard !searchText.isEmpty else {
            return []
        }

        return vm.spots.filter {

            $0.name.localizedCaseInsensitiveContains(searchText)
            || $0.city.localizedCaseInsensitiveContains(searchText)
        }
        .prefix(6)
        .map { $0 }
    }

    var searchBar: some View {

        HStack(spacing: 10) {

            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.secondary)

            TextField(
                "Rechercher un spot",
                text: $searchText
            )
            .font(.subheadline)

            if !searchText.isEmpty {

                Button {

                    searchText = ""

                } label: {

                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    Color.white.opacity(0.35),
                    lineWidth: 1
                )
        )
        .shadow(
            color: .black.opacity(0.08),
            radius: 12,
            y: 6
        )
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    var searchResultsView: some View {

        VStack(spacing: 0) {

            ForEach(searchResults) { spot in

                Button {

                    focus(on: spot)

                } label: {

                    HStack(spacing: 12) {

                        Image(systemName: "water.waves")
                            .foregroundColor(AppColors.primary)

                        VStack(alignment: .leading, spacing: 2) {

                            Text(spot.name)
                                .foregroundColor(.primary)

                            Text(spot.city)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 54)
                }

                if spot.id != searchResults.last?.id {
                    Divider()
                }
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
        .shadow(
            color: .black.opacity(0.08),
            radius: 12,
            y: 6
        )
    }

    func focus(on spot: Spot) {

        let adjustedCenter = CLLocationCoordinate2D(
            latitude: spot.latitude - 0.012,
            longitude: spot.longitude
        )

        withAnimation(.easeInOut(duration: 0.35)) {

            mapRegion = MKCoordinateRegion(
                center: adjustedCenter,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.035,
                    longitudeDelta: 0.035
                )
            )

            vm.selectSpot(id: spot.id)

            searchText = ""
        }
    }
}


extension SurfMapView {

    var bottomSheet: some View {

        VStack(spacing: 16) {

            Capsule()
                .fill(Color.secondary.opacity(0.25))
                .frame(width: 42, height: 5)

            header

            if vm.sessionsForSelectedSpot.isEmpty {

                emptyState

            } else {

                sessionsList
            }

            createButton
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(
                    Color.white.opacity(0.25),
                    lineWidth: 1
                )
        )
        .shadow(
            color: .black.opacity(0.12),
            radius: 20,
            y: 8
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 10)
    }

    var header: some View {

        HStack(alignment: .top, spacing: 14) {

            if let spot = vm.spots.first(where: {
                $0.id == vm.selectedSpotID
            }) {

                MapSnapshotImageView(
                    latitude: spot.latitude,
                    longitude: spot.longitude,
                    width: 82,
                    height: 82
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 18)
                )

                VStack(alignment: .leading, spacing: 6) {

                    Text(spot.name)
                        .font(.title3.bold())

                    Text("\(spot.city)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if vm.sessionsForSelectedSpot.count > 0 {

                        Text(
                            "\(vm.sessionsForSelectedSpot.count) session\(vm.sessionsForSelectedSpot.count > 1 ? "s" : "")"
                        )
                        .font(.caption.weight(.medium))
                            .foregroundColor(AppColors.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                AppColors.primary.opacity(0.12)
                            )
                            .clipShape(Capsule())
                    }
                    
                }

                Spacer()

                Button {

                    vm.selectSpot(id: nil)

                } label: {

                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.black.opacity(0.8))
                        .frame(width: 38, height: 38)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
        }
    }

    var emptyState: some View {

        VStack(spacing: 14) {

            Text("Aucune session pour le moment")
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text("Soit le premier à en organiser une.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }

    var sessionsList: some View {

        ScrollView(.horizontal, showsIndicators: false) {

            HStack(spacing: 16) {

                ForEach(vm.sessionsForSelectedSpot) { session in

                    let participants = Array(Set(session.participantIDs))

                    let remaining = max(
                        0,
                        session.maxPeople - participants.count
                    )

                    let isJoined = Auth.auth().currentUser.map {
                        participants.contains($0.uid)
                    } ?? false

                    let canJoin = !isJoined && remaining > 0

                    MapSessionCard(

                        session: session,

                        statusText:
                            isJoined
                            ? "Ta session"
                            : (
                                remaining == 0
                                ? "Complète"
                                : "Ouverte"
                            ),

                        statusColor:
                            isJoined
                            ? AppColors.primary
                            : (
                                remaining == 0
                                ? .red
                                : .green
                            ),

                        buttonTitle:
                            isJoined
                            ? "Voir"
                            : (
                                remaining == 0
                                ? "Complet"
                                : "Rejoindre"
                            ),

                        buttonEnabled:
                            canJoin || isJoined,

                        levelText:
                            "Min. \(vm.category(for: session.minimumLevel))",

                        onTap: {

                            if isJoined {

                                selectedSession = session
                            }
                            else if canJoin {

                                Task {
                                    await vm.joinSession(session)
                                }
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
        }
        .frame(height: 175)
        .scrollIndicators(.hidden)
    }

    var createButton: some View {

        Button {

            showingCreate = true

        } label: {

            HStack(spacing: 10) {

                Image(systemName: "plus")

                Text("Créer une session")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AppColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(
                color: AppColors.primary.opacity(0.22),
                radius: 10,
                y: 4
            )
        }
    }
}
