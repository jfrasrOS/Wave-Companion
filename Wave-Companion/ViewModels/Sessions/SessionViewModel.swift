import Foundation
import FirebaseAuth
import Combine
import FirebaseFirestore
import MapKit

@MainActor
final class SessionViewModel: ObservableObject {

    // Liste des spots dispo (local JSON)
    @Published var spots: [Spot] = []

    // Sessions visibles sur la carte (temps réel Firestore)
    @Published var sessions: [SurfSession] = []

    // Spot sélectionné par l'utilisateur
    @Published var selectedSpotID: String? {
        didSet { updateSelectedSpotSessions() }
    }
    // Sessions filtrées pour un spot
    @Published var sessionsForSelectedSpot: [SurfSession] = []
    // Loading UI
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Firestore
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // Debounce pour éviter trop de requêtes map
    private var regionDebounceTask: Task<Void, Never>?
    
    //User
    private let surfLevels = SurfLevelService.loadLevels()
    @Published var currentUserLevelId: String?
    
    private var currentRegion: MKCoordinateRegion?
    
    // Niveau de surf
    func levelOrder(for id: String) -> Int? {
        surfLevels.first { $0.id == id }?.order
    }
    
    func category(for levelId: String) -> String {
        surfLevels.first { $0.id == levelId }?.category ?? levelId
    }
    
    // Vérifie si user peut voir la session
    func userCanSee(session: SurfSession) -> Bool {

        guard let userLevelId = currentUserLevelId else { return false }

        guard
            let userOrder = levelOrder(for: userLevelId),
            let sessionOrder = levelOrder(for: session.minimumLevel)
        else {
            return false
        }

        return userOrder >= sessionOrder
    }
    
    // User data
    func loadCurrentUserLevel() {

        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users")
            .document(uid)
            .getDocument { [weak self] snapshot, _ in

                guard let self else { return }
                guard let data = snapshot?.data() else { return }

                let levelId = data["surfLevelId"] as? String

                Task { @MainActor in
                    self.currentUserLevelId = levelId
                    
                    // Recharge sessions si map déjà active
                    if let region = self.currentRegion {
                        self.loadSessions(for: region)
                    }
                }
            }
    }
    
    // Spots
    func loadSpots() {
        spots = SpotService.loadAllSpots()
    }

    // Vérifie si un spot contient au moins une session active
    func hasSession(for spot: Spot) -> Bool {
        sessions.contains {
            $0.latitude == spot.latitude &&
            $0.longitude == spot.longitude &&
            $0.status == .open &&
            $0.date > Date()
        }
    }


    // Map listener
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

                let allSessions = docs.compactMap {
                    try? $0.data(as: SurfSession.self)
                }

                // Filtrage zone + niveau
                self.sessions = allSessions.filter { s in
                    
                    let inRegion =
                        s.latitude >= minLat &&
                        s.latitude <= maxLat &&
                        s.longitude >= minLng &&
                        s.longitude <= maxLng

                    let levelAllowed = self.userCanSee(session: s)

                    return inRegion && levelAllowed
                }

                self.updateSelectedSpotSessions()
            }
    }

    // filtre spot
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
            errorMessage = "Session passée interdite"
            return
        }

        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "User non connecté"
            return
        }

        guard let spot = spots.first(where: { $0.id == selectedSpotID }) else {
            errorMessage = "Sélectionne un spot"
            return
        }
        
        guard let userLevelId = currentUserLevelId,
              let userOrder = levelOrder(for: userLevelId),
              let sessionOrder = levelOrder(for: minLevel),
              sessionOrder <= userOrder
        else {
            errorMessage = "Niveau insuffisant"
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
          
            //Créer session
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

            // Calcul fin du chat
            let endAt = min(
                date.addingTimeInterval(4 * 3600),
                Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: date)!
            )

            // Création du chat
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
                    "lastMessageDate": Timestamp(date: Date()),
                    "spotName": spot.name,
                    "sessionDate": Timestamp(date: date),
                    "participantCount": 1,
                    "endAt": Timestamp(date: endAt)
                ])

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Rejoindre une session
    @MainActor
    func joinSession(_ session: SurfSession) async {

        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        guard userCanSee(session: session) else {
            errorMessage = "Niveau insuffisant"
            return
        }
        
        guard let index = sessions.firstIndex(where: { $0.id == session.id }) else { return }

        if sessions[index].participantIDs.contains(userId) { return }
        
        if sessions[index].participantIDs.count >= sessions[index].maxPeople {
            errorMessage = "Session complète"
            return
        }

        do {
            // Rejoindre une session (safe avec arrayUnion)
            try await db.collection("sessions")
                .document(session.id)
                .updateData([
                    "participantIDs": FieldValue.arrayUnion([userId])
                ])

            // Rejoindre le chat (sync UI)
            try await db.collection("chats")
                .document(session.id)
                .updateData([
                    "participantIDs": FieldValue.arrayUnion([userId]),
                    "participantCount": FieldValue.increment(Int64(1))
                ])

            // Update local UI
            sessions[index].participantIDs.append(userId)
            updateSelectedSpotSessions()

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Quitter une session
    func leaveSession(_ session: SurfSession) async {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }

        do {
            try await db.collection("sessions")
                .document(session.id)
                .updateData([
                    "participantIDs": FieldValue.arrayRemove([userId])
                ])

            try await db.collection("chats")
                .document(session.id)
                .updateData([
                    "participantIDs": FieldValue.arrayRemove([userId]),
                    "participantCount": FieldValue.increment(Int64(-1))
                ])
            
        } catch {
            print("leave session error:", error)
        }
    }
}
