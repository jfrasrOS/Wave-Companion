import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

// Gére la page "mes sessions"
@MainActor
final class MySessionsViewModel: ObservableObject {
    
    @Published var allSessions: [SurfSession] = []
    @Published var upcomingSessions: [SurfSession] = []
    @Published var ongoingSessions: [SurfSession] = []
    @Published var pastSessions: [SurfSession] = []
    
    private let surfLevels = SurfLevelService.loadLevels()
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // Démarre l'écoute des session en temps réel
    func startListening() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        listener?.remove()
        
        listener = db.collection("sessions")
            .whereField("participantIDs", arrayContains: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                
                guard let self else { return }
                guard let docs = snapshot?.documents else { return }
                
                let sessions = docs.compactMap {
                    try? $0.data(as: SurfSession.self)
                }
                
                // Liste complete
                self.allSessions = sessions
                self.sortSessions(sessions)
            }
    }
    
    // Convertit levelID en catégorie
    func category(for levelId: String) -> String {
        surfLevels.first { $0.id == levelId }?.category ?? levelId
    }
    
    // Tri des sessions
    private func sortSessions(_ sessions: [SurfSession]) {
        
        var upcoming: [SurfSession] = []
        var ongoing: [SurfSession] = []
        var past: [SurfSession] = []
        
        let now = Date()
        
        for session in sessions {
            if now < session.date {
                upcoming.append(session)
            } else if now < session.date.addingTimeInterval(7200) {
                ongoing.append(session)
            } else {
                past.append(session)
            }
        }
        
        // Par ordre croissant
        upcomingSessions = upcoming.sorted { $0.date < $1.date }
        ongoingSessions = ongoing.sorted { $0.date < $1.date }
        pastSessions = past.sorted { $0.date > $1.date }
    }
    

    
    var totalSessions: Int {
        allSessions.count
    }
    
    // Nombre de spot unique surfés (Set pour enlever doublons)
    var uniqueSpots: Int {
        Set(allSessions.map { $0.spotId }).count
    }
    
    var totalWaves: Int {
        allSessions.compactMap { $0.wavesCount }.reduce(0, +)
    }
    
  
    // Retourne les sessions à une date précise
    func sessions(on date: Date) -> [SurfSession] {
        let calendar = Calendar.current
        
        return allSessions.filter {
            calendar.isDate($0.date, inSameDayAs: date)
        }
    }
    
    func sessionsCount(on date: Date) -> Int {
        sessions(on: date).count
    }
}
