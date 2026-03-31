import Foundation
import FirebaseAuth
import Combine
import FirebaseFirestore
import MapKit

@MainActor
final class SessionViewModel: ObservableObject {

    // Liste des spots dispo
    @Published var spots: [Spot] = []

    // Sessions actuellement visibles sur la carte
    @Published var sessions: [SurfSession] = []

    // Spot actuellement sélectionné
    @Published var selectedSpotID: String? {
        didSet { updateSelectedSpotSessions() }
    }
    @Published var sessionsForSelectedSpot: [SurfSession] = []

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var regionDebounceTask: Task<Void, Never>?
    
    private let surfLevels = SurfLevelService.loadLevels()
    @Published var currentUserLevelId: String?
    
    private var currentRegion: MKCoordinateRegion?
    
    func levelOrder(for id: String) -> Int? {
        surfLevels.first { $0.id == id }?.order
    }
    
    func category(for levelId: String) -> String {
        surfLevels.first { $0.id == levelId }?.category ?? levelId
    }
    
    func userCanSee(session: SurfSession) -> Bool {

        print("USER LEVEL:", currentUserLevelId ?? "nil")
        print("SESSION MIN LEVEL RAW:", session.minimumLevel)

        guard let userLevelId = currentUserLevelId else { return false }

        guard
            let userOrder = levelOrder(for: userLevelId),
            let sessionOrder = levelOrder(for: session.minimumLevel)
        else {
            print("ORDER NOT FOUND")
            return false
        }

        print("USER ORDER:", userOrder)
        print("SESSION ORDER:", sessionOrder)

        return userOrder >= sessionOrder
    }
    
    func loadCurrentUserLevel() {

        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users")
            .document(uid)
            .getDocument { [weak self] snapshot, error in

                guard let self else { return }
                guard let data = snapshot?.data() else { return }

                let levelId = data["surfLevelId"] as? String

                Task { @MainActor in
                    self.currentUserLevelId = levelId

                    print("USER LEVEL LOADED:", self.currentUserLevelId ?? "nil")

                    if let region = self.currentRegion {
                        self.loadSessions(for: region)
                    }
                }
            }
    }
    

    func loadSpots() {
        spots = SpotService.loadAllSpots()
    }

    // Vérifie si un spot a au moins une session ouverte/future
    func hasSession(for spot: Spot) -> Bool {
        sessions.contains {
            $0.latitude == spot.latitude &&
            $0.longitude == spot.longitude &&
            $0.status == .open &&
            $0.date > Date()
        }
    }

    // Listener dynamique selon zone visible
    func startSessionListener(for region: MKCoordinateRegion) {
        currentRegion = region
        regionDebounceTask?.cancel()
        regionDebounceTask = Task { loadSessions(for: region) }
    }

    func loadSessions(for region: MKCoordinateRegion) {
        listener?.remove()

        let minLat = region.center.latitude - region.span.latitudeDelta / 2
        let maxLat = region.center.latitude + region.span.latitudeDelta / 2
        let minLng = region.center.longitude - region.span.longitudeDelta / 2
        let maxLng = region.center.longitude + region.span.longitudeDelta / 2

        print("Nouvelle zone carte")

        listener = db.collection("sessions")
            .whereField("status", isEqualTo: "open")
            .whereField("date", isGreaterThan: Timestamp(date: Date()))
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error {
                    print("Firestore error:", error)
                    return
                }

                guard let docs = snapshot?.documents else { return }

                print("Sessions Firestore:", docs.count)

                let allSessions = docs.compactMap { doc -> SurfSession? in
                    try? doc.data(as: SurfSession.self)
                }
                
                print("ALL SESSIONS:", allSessions.count)

                self.sessions = allSessions.filter { s in

                    let inRegion =
                        s.latitude >= minLat &&
                        s.latitude <= maxLat &&
                        s.longitude >= minLng &&
                        s.longitude <= maxLng

                    let levelAllowed = self.userCanSee(session: s)

                    return inRegion && levelAllowed
                }

                print("Sessions dans zone:", self.sessions.count)
                self.updateSelectedSpotSessions()
            }
    }

    // Récupère les sessions pour un spot donné
    func sessions(for spot: Spot) -> [SurfSession] {
        sessions.filter { $0.spotId == spot.id }
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
        
        guard let userLevelId = currentUserLevelId,
              let userOrder = levelOrder(for: userLevelId),
              let sessionOrder = levelOrder(for: minLevel),
              sessionOrder <= userOrder
        else {
            errorMessage = "Tu ne peux pas créer une session avec un niveau supérieur au tien"
            return
        }

        isLoading = true
        defer { isLoading = false }

        let sessionId = UUID().uuidString
        let geohash = GeoHash.encode(latitude: spot.latitude, longitude: spot.longitude)

        let newSession = SurfSession(
            id: sessionId,
            spotName: spot.name,
            spotId: spot.id,
            latitude: spot.latitude,
            longitude: spot.longitude,
            geohash: geohash,
            date: date,
            createdAt: Date(),
            creatorId: userId,
            minimumLevel: minLevel,
            maxPeople: maxPeople,
            participantIDs: [userId],
            chatId: sessionId,
            status: .open
        )

        sessions.append(newSession)
        updateSelectedSpotSessions()

        do {
            // Créer session
            try await db.collection("sessions")
                .document(sessionId)
                .setData([
                    "id": newSession.id,
                    "spotId": newSession.spotId,
                    "spotName": newSession.spotName,
                    "latitude": newSession.latitude,
                    "longitude": newSession.longitude,
                    "geohash": newSession.geohash,
                    "date": Timestamp(date: newSession.date),
                    "createdAt": Timestamp(date: newSession.createdAt),
                    "creatorId": newSession.creatorId,
                    "minimumLevel": newSession.minimumLevel,
                    "maxPeople": newSession.maxPeople,
                    "participantIDs": newSession.participantIDs,
                    "chatId": newSession.chatId,
                    "status": newSession.status.rawValue
                ])

            // Créer le chat de session
            try await db.collection("chats")
                .document(sessionId)
                .setData([
                    "id": sessionId,
                    "sessionId": sessionId,
                    "creatorId": userId,
                    "participantIDs": [userId],
                    "type": "session",
                    "createdAt": Timestamp(date: Date()),
                    "lastMessage": "",
                    "lastMessageDate": Timestamp(date: Date())
                ])

        } catch {
            errorMessage = error.localizedDescription
        }

        updateSelectedSpotSessions()
    }

    @MainActor
    func joinSession(_ session: SurfSession) async {

        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        guard userCanSee(session: session) else {
            errorMessage = "Niveau insuffisant pour cette session"
            return
        }
        
        guard let index = sessions.firstIndex(where: { $0.id == session.id }) else { return }

        if sessions[index].participantIDs.contains(userId) { return }
        
        if sessions[index].participantIDs.count >= sessions[index].maxPeople {
            errorMessage = "Session complète"
            return
        }

        do {
            // rejoindre la session
            try await db.collection("sessions")
                .document(session.id)
                .updateData([
                    "participantIDs": FieldValue.arrayUnion([userId])
                ])

            // rejoindre le chat
            let chatRef = db.collection("chats").document(session.id)
            let chatDoc = try await chatRef.getDocument()

            if chatDoc.exists {
                try await chatRef.updateData([
                    "participantIDs": FieldValue.arrayUnion([userId])
                ])
            } else {
                try await chatRef.setData([
                    "id": session.id,
                    "sessionId": session.id,
                    "participantIDs": [userId],
                    "type": "session",
                    "createdAt": Timestamp(date: Date()),
                    "lastMessage": "",
                    "lastMessageDate": Timestamp(date: Date())
                ], merge: true)
            }

            // Update local
            sessions[index].participantIDs.append(userId)
            updateSelectedSpotSessions()

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
