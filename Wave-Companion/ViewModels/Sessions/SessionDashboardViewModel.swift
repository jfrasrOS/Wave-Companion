import Foundation
import CoreLocation
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
final class SessionDashboardViewModel: NSObject, ObservableObject {
    

    // Tous les états de la sessionCard
    enum SessionCardState {
        case joined(session: SurfSession)
        case suggestion(main: SurfSession, others: [SurfSession])
        case noNearbySessions
        case locationDisabled
    }

    @Published var state: SessionCardState = .locationDisabled
    
    // Firestore + GPS
    private let db = Firestore.firestore()
    private let locationManager = CLLocationManager()
    
    // Dernière position user + recup sessions
    @Published var userLocation: CLLocation?
    @Published var sessions: [SurfSession] = []
    
    // Ecoute en temps réel
    private var listener: ListenerRegistration?
    
    var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    override init() {
        super.init()
        setupLocation()
        listenSessions()
    }
    
    private let surfLevels = SurfLevelService.loadLevels()

    // Converetit levelID en catégorie (UI)
    func category(for levelId: String) -> String {
        surfLevels.first { $0.id == levelId }?.category ?? levelId
    }
}


extension SessionDashboardViewModel: CLLocationManagerDelegate {
    
    private func setupLocation() {
        locationManager.delegate = self
        //Demande l'autorisation user
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Prend la positon la plus récente + recalcule de l'état de la map
        userLocation = locations.first
        computeState()
    }
    
    // Appellé quand user accepte/refuse localisation
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        computeState()
    }
}

extension SessionDashboardViewModel {
    
    private func listenSessions() {
        
        //Supprime l'ancien écouteur
        listener?.remove()
        
        //Ecoute temps réel Firestore
        listener = db.collection("sessions")
            .whereField("status", isEqualTo: "open") // Seulement sessions ouvertes
            .whereField("date", isGreaterThan: Timestamp(date: Date())) // Session futures
            .addSnapshotListener { [weak self] snapshot, error in
                
                guard let self else { return }
                
                if let error {
                    print("❌ Firestore:", error)
                    return
                }
                
                guard let docs = snapshot?.documents else { return }
                
                self.sessions = docs.compactMap {
                    try? $0.data(as: SurfSession.self)
                }
                
                print("🔥 Sessions Home:", self.sessions.count)
                
                self.computeState()
            }
    }
}

extension SessionDashboardViewModel {
    
    private func computeState() {
        
        // Session rejointe (priorité)
        if let userId {
            
            // filtre les sessions où user participe
            let joinedSessions = sessions
                .filter { $0.participantIDs.contains(userId) }
                .sorted { $0.date < $1.date }
            // Prend la prochaine session
            if let nextSession = joinedSessions.first {
                state = .joined(session: nextSession)
                return
            }
        }
        
        // Vérifier localisation
        
        // Si pas de position -> considère désactivé
        guard let location = userLocation else {
            state = .locationDisabled
            return
        }
        
        let status = locationManager.authorizationStatus
        
        // Vérifie permission iOS
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            state = .locationDisabled
            return
        }
        
       
        // Sessions proches (30km)
        let nearby = sessions
            .filter { session in
                
                // Transforme session en CLLocation
                let sessionLocation = CLLocation(
                    latitude: session.latitude,
                    longitude: session.longitude
                )
                
                // distance en mètre (vol d'oiseau)
                return location.distance(from: sessionLocation) < 30000
            }
            .sorted { $0.date < $1.date }// tri chronologique
        
        // Resultat final
        if nearby.isEmpty {
            //Aucune session proche
            state = .noNearbySessions
        } else {
            // session principale + 2 secondaires max
            state = .suggestion(
                main: nearby[0],
                others: Array(nearby.dropFirst().prefix(2))
            )
        }
    }
}
