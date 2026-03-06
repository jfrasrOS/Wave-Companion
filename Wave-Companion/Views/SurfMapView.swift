import SwiftUI
import MapKit

struct SurfMapView: View {

    @StateObject private var vm = SessionViewModel()
    @State private var showingCreate = false

    var body: some View {
        ZStack(alignment: .bottom) {

            // Carte avec clusters et sélection single
            SpotClusterMapViewSingle(
                spots: vm.spots,
                hasSession: { vm.hasSession(for: $0) },
                selectedSpotID: $vm.selectedSpotID,
                focusedSpotID: $vm.selectedSpotID
            )
            .edgesIgnoringSafeArea(.all)

            // Bottom sheet si un spot est sélectionné
            if vm.selectedSpotID != nil {
                bottomSheet
            }
        }
        // Sheet pour créer session
        .sheet(isPresented: $showingCreate) {
            CreateSessionView(vm: vm)
        }
        // Chargement initial
        .onAppear {
            vm.loadSpots()
            vm.startSessionListener()
        }
    }
}


extension SurfMapView {

    var bottomSheet: some View {
        VStack(spacing: 16) {

            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.4))

            header
            Divider()

            if vm.sessionsForSelectedSpot.isEmpty {
                emptyState
            } else {
                sessionList
            }

            createButton

        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 20)
        )
        .padding()
        .transition(.move(edge: .bottom))
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: vm.selectedSpotID)
    }

    var header: some View {
        HStack {
            if let spot = vm.spots.first(where: { $0.id == vm.selectedSpotID }) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(spot.name).font(.title3.bold())
                    Text(spot.city).font(.caption).foregroundColor(.secondary)
                }
            }
            Spacer()
            Button {
                vm.selectSpot(id: nil)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
    }

    var sessionList: some View {
        VStack(spacing: 10) {
            ForEach(vm.sessionsForSelectedSpot) { session in
                SessionRow(session: session)
            }
        }
    }

    var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: "water.waves").font(.title2).foregroundColor(.secondary)
            Text("Aucune session pour ce spot").font(.subheadline)
            Text("Soyez le premier à en créer une").font(.caption).foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }

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


struct SessionRow: View {
    let session: SurfSession

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(session.spotName)
                    .font(.subheadline.weight(.semibold))
                Text(session.date.sessionFormatted)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}
