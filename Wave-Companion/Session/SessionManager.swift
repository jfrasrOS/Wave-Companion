import Foundation
import FirebaseAuth
import Combine
import FirebaseFirestore

class SessionManager: ObservableObject {
    
    @Published var currentUser: User? = nil
    @Published var isAuthenticated: Bool = false
    private var listener: ListenerRegistration?

    func login(user: User) {
        self.currentUser = user
        self.isAuthenticated = true
    }

    func logout() {
        self.currentUser = nil
        self.isAuthenticated = false
        listener?.remove() // stop écoute Firestore
        listener = nil
    }

    // Met à jour user en temps réel à chaque modification firestore
    func startListeningUser() {

        guard let uid = Auth.auth().currentUser?.uid else { return }

        listener = Firestore.firestore()
            .collection("users")
            .document(uid)
            .addSnapshotListener { snapshot, error in

                guard let data = snapshot?.data() else { return }

                let updatedUser = User(
                    id: data["id"] as? String ?? uid,
                    name: data["name"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    nationality: data["nationality"] as? String ?? "",
                    surfLevelId: data["surfLevelId"] as? String ?? "",
                    completedSkills: data["completedSkills"] as? [String] ?? [],
                    boardType: data["boardType"] as? String ?? "",
                    boardSize: data["boardSize"] as? String ?? "",
                    boardColor: data["boardColor"] as? String ?? "",
                    favoriteSpotIDs: data["favoriteSpotIDs"] as? [String] ?? [],
                    profileImage: data["profileImage"] as? String,
                    friends: data["friends"] as? [String] ?? []
                )

                DispatchQueue.main.async {
                    self.currentUser = updatedUser
                    self.isAuthenticated = true
                }
            }
    }
}

