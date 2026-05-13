import SwiftUI
import MapKit
import FirebaseAuth

struct SurfMapView: View {

    @StateObject private var vm = SessionViewModel()

    @State private var selectedSession: SurfSession?
    @State private var showSessionDetail = false
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

            .navigationDestination(for: SurfSession.self) { session in

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

        withAnimation {

            mapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: spot.latitude,
                    longitude: spot.longitude
                ),
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

        HStack {

            if let spot = vm.spots.first(where: {
                $0.id == vm.selectedSpotID
            }) {

                VStack(alignment: .leading, spacing: 4) {

                    Text(spot.name)
                        .font(.title3.bold())

                    Text(spot.city)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Button {

                vm.selectSpot(id: nil)

            } label: {

                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black.opacity(0.7))
                    .frame(width: 30, height: 30)
                    .background(Color.black.opacity(0.06))
                    .clipShape(Circle())
            }
        }
    }

    var emptyState: some View {

        VStack(spacing: 8) {

            Image(systemName: "water.waves")
                .font(.title3)
                .foregroundColor(AppColors.primary)

            Text("Aucune session")
                .font(.headline)

            Text("Soyez le premier à surfer ici")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    var sessionsList: some View {

        ScrollView(.horizontal, showsIndicators: false) {

            HStack(spacing: 12) {

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

                    SessionHorizontalCard(
                        session: session,
                        title: isJoined
                        ? "Ta session"
                        : (remaining == 0 ? "Complète" : "Ouverte"),

                        titleColor: isJoined
                        ? AppColors.primary
                        : (remaining == 0 ? .gray : .green),

                        buttonTitle: isJoined
                        ? "Voir"
                        : (remaining == 0 ? "Complet" : "Rejoindre"),

                        buttonEnabled: canJoin || isJoined,

                        onTap: {

                            if isJoined {

                                selectedSession = session
                                showSessionDetail = true

                            } else if canJoin {

                                Task {
                                    await vm.joinSession(session)
                                }
                            }
                        }
                    )
                }
            }
        }
    }

    var createButton: some View {

        Button {

            showingCreate = true

        } label: {

            HStack(spacing: 10) {

                Image(systemName: "plus")

                Text("Créer une session")
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(AppColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}
