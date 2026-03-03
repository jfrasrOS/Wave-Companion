import Foundation
import CoreLocation
import Combine

@MainActor
final class SessionDashboardViewModel: ObservableObject {
    
    enum SessionCardState {
        case joined(session: SurfSession)
        case suggestion(main: SurfSession, others: [SurfSession])
        case noNearbySessions
        case locationDisabled
    }

    @Published var state: SessionCardState = .locationDisabled

    var userId: String?

    init(userId: String? = nil) {
        self.userId = userId
        computeState()
    }

    // Simulation
    private func computeState() {

        let locationEnabled = true // simulé
        let joinedSession: SurfSession? = nil // simulé
        let nearbySessions: [SurfSession] = MockData.nearbySessions

        if let joined = joinedSession {
            state = .joined(session: joined)
            return
        }

        if !locationEnabled {
            state = .locationDisabled
            return
        }

        if nearbySessions.isEmpty {
            state = .noNearbySessions
        } else {
            state = .suggestion(
                main: nearbySessions[0],
                others: Array(nearbySessions.dropFirst().prefix(2))
            )
        }
    }
}


extension Date {

    var sessionFormatted: String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")

        if calendar.isDateInToday(self) {
            formatter.dateFormat = "'Aujourd’hui' HH'h'mm"
        } else if calendar.isDateInTomorrow(self) {
            formatter.dateFormat = "'Demain' HH'h'mm"
        } else {
            formatter.dateFormat = "dd MMM HH'h'mm"
        }

        return formatter.string(from: self)
    }
}
