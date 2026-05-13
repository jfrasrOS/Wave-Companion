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
    private var allSessions: [SurfSession] = []

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

    //User
    private let surfLevels = SurfLevelService.loadLevels()
    @Published var currentUserLevelId: String?
    
    // Région actuellement visible sur la map
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

        // User sans niveau -> accès refusé
        guard let userLevelId = currentUserLevelId else { return false }

        guard
            let userOrder = levelOrder(for: userLevelId),
            let sessionOrder = levelOrder(for: session.minimumLevel)
        else {
            return false
        }

        // Le niveau user doit être supérieur ou égal au niveau requis
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

                    // Refiltre local des sessions
                    if let region = self.currentRegion {
                        self.updateVisibleSessions(for: region)
                    }
                }
            }
    }
    
    // Spots
    func loadSpots() {
        spots = SpotService.loadAllSpots()
    }
    
    // Vérifie si le spot possède au moins une session ouverte
    func hasOpenSession(for spot: Spot) -> Bool {

        sessions.contains {

            $0.spotId == spot.id
            && userCanSee(session: $0)
            && $0.status == .open
            && $0.date > Date()
            && $0.participantIDs.count < $0.maxPeople
        }
    }

    // Vérifie si le spot possède uniquement des sessions complètes
    func hasOnlyFullSession(for spot: Spot) -> Bool {

        let spotSessions = sessions.filter {

            $0.spotId == spot.id
            && userCanSee(session: $0)
            && $0.date > Date()
        }

        guard !spotSessions.isEmpty else {
            return false
        }

        let hasOpen = spotSessions.contains {

            $0.status == .open
            && $0.participantIDs.count < $0.maxPeople
        }

        return !hasOpen
    }

    // Listener temps réel des sessions Firestore
    func startGlobalSessionsListener() {

        listener?.remove()

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

                let all = docs.compactMap {
                    try? $0.data(as: SurfSession.self)
                }

                Task { @MainActor in

                    // Garde toutes les session
                    self.allSessions = all

                    // puis refiltre localement
                    if let region = self.currentRegion {
                        self.updateVisibleSessions(for: region)
                    }
                }
            }
    }
    
    // Filtre les sessions visibles dans la région affichée
    func updateVisibleSessions(
        for region: MKCoordinateRegion
    ) {

        // Sauvegarde la région actuelle
        currentRegion = region

        // Limites visibles de la map
        let minLat =
            region.center.latitude -
            region.span.latitudeDelta / 2

        let maxLat =
            region.center.latitude +
            region.span.latitudeDelta / 2

        let minLng =
            region.center.longitude -
            region.span.longitudeDelta / 2

        let maxLng =
            region.center.longitude +
            region.span.longitudeDelta / 2

        // Filtre uniquement les sessions visibles à l'écran
        let filtered = allSessions.filter { session in

            session.latitude >= minLat &&
            session.latitude <= maxLat &&
            session.longitude >= minLng &&
            session.longitude <= maxLng
        }

        // Update UI principal
        DispatchQueue.main.async {

            self.sessions = filtered
            self.updateSelectedSpotSessions()
        }
    }


    

   

    // sessions visible sur un spot
    func sessions(for spot: Spot) -> [SurfSession] {

        sessions.filter {

            $0.spotId == spot.id
            && userCanSee(session: $0)
        }
    }

    // Met à jour les sessions du spot actuellement sélectionné
    func updateSelectedSpotSessions() {

        let updatedSessions: [SurfSession]

        // Recharge les sessions du spot sélectionné
        if let spotID = selectedSpotID,
           let spot = spots.first(where: { $0.id == spotID }) {

            updatedSessions = sessions(for: spot)

        } else {
            // Aucun spot sélectionné
            updatedSessions = []
        }

        // Refresh UI principal
        DispatchQueue.main.async {

            self.sessionsForSelectedSpot = updatedSessions
        }
    }

    // Change le spot selectionné
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
        
        // expiration auto chat/session
        let endAt = Calendar.current.date(
            byAdding: .hour,
            value: 48,
            to: date
        )!

        // session local
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
            chatEndAt: endAt,
            status: .open
        )

        sessions.append(newSession)
        updateSelectedSpotSessions()

        do {
          
            //Créer session Firestore
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
                    "chatEndAt": Timestamp(date: endAt),
                    "status": newSession.status.rawValue
                ])

          
            let endAt = Calendar.current.date(
                byAdding: .hour,
                value: 48,
                to: date
            )!

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
