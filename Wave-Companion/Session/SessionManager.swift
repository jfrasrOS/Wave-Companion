import Foundation
import Combine

class SessionManager: ObservableObject {
    @Published var currentUser: User? = nil
    @Published var isAuthenticated: Bool = false

    func login(user: User) {
        self.currentUser = user
        self.isAuthenticated = true
    }

    func logout() {
        self.currentUser = nil
        self.isAuthenticated = false
    }
}

