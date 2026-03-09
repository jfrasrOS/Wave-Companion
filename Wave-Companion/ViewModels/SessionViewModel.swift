import Foundation
import FirebaseAuth
import Combine
import FirebaseFirestore

@MainActor
final class SessionViewModel: ObservableObject {

    // Liste des spots dispo & session rcupérées depuis Firestore
    @Published var spots: [Spot] = []
    @Published var sessions: [SurfSession] = []

    // Spot actuellement selectionné sur la map
    @Published var selectedSpotID: String? {
        didSet {
            // Dès qu'un spot change, on met à jour les sessions affichés
            updateSelectedSpotSessions()
        }
    }
    @Published var sessionsForSelectedSpot: [SurfSession] = []

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // Charge les spots
    func loadSpots() {
        spots = SpotService.loadAllSpots()
    }
    
    func hasSession(for spot: Spot) -> Bool {
        sessions.contains {
            $0.latitude == spot.latitude &&
            $0.longitude == spot.longitude &&
            $0.status == .open &&
            $0.date > Date()
        }
    }

    // Ecoute en temps réel les sessions
    func startSessionListener() {
        listener?.remove()
        listener = db.collection("sessions")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let docs = snapshot?.documents else { return }

                // Met à jour toutes les sessions
                self.sessions = docs.compactMap { doc in
                    try? doc.data(as: SurfSession.self)
                }

                // Met à jour les sessions du spot sélectionné
                self.updateSelectedSpotSessions()
            }
    }

    func sessions(for spot: Spot) -> [SurfSession] {
        sessions.filter {
            $0.latitude == spot.latitude &&
            $0.longitude == spot.longitude &&
            $0.status == .open &&
            $0.date > Date()
        }
    }

    func updateSelectedSpotSessions() {
        guard let spotID = selectedSpotID,
              let spot = spots.first(where: { $0.id == spotID }) else {
            sessionsForSelectedSpot = []
            return
        }

        sessionsForSelectedSpot = sessions(for: spot)
    }

    func selectSpot(id: String?) {
        selectedSpotID = id
    }

    // Créer une session
    func createSession(
        date: Date,
        minLevel: String,
        maxPeople: Int
    ) async {

        guard date > Date() else {
            errorMessage = "Impossible de créer une session dans le passé"
            return
        }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "Utilisateur non connecté"
            return
        }

        guard let spot = spots.first(where: { $0.id == selectedSpotID }) else {
            errorMessage = "Veuillez sélectionner un spot"
            return
        }

        isLoading = true
        defer { isLoading = false }

        let sessionId = UUID().uuidString

        let newSession = SurfSession(
            id: sessionId,
            spotName: spot.name,
            latitude: spot.latitude,
            longitude: spot.longitude,
            date: date,
            createdAt: Date(),
            creatorId: userId,
            minimumLevel: minLevel,
            maxPeople: maxPeople,
            participantIDs: [userId],
            chatId: sessionId,
            status: .open
        )

        do {
            try await db.collection("sessions")
                .document(sessionId)
                .setData([
                    "id": newSession.id,
                    "spotName": newSession.spotName,
                    "latitude": newSession.latitude,
                    "longitude": newSession.longitude,
                    "date": Timestamp(date: newSession.date),
                    "createdAt": Timestamp(date: newSession.createdAt),
                    "creatorId": newSession.creatorId,
                    "minimumLevel": newSession.minimumLevel,
                    "maxPeople": newSession.maxPeople,
                    "participantIDs": newSession.participantIDs,
                    "chatId": newSession.chatId,
                    "status": newSession.status.rawValue
                ])
        } catch {
            errorMessage = error.localizedDescription
        }

        // Met à jour la liste des sessions après création
        updateSelectedSpotSessions()
    }
}
