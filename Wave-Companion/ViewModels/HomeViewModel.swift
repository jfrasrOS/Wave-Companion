import Foundation
import SwiftUI
import FirebaseAuth
import Combine



final class HomeViewModel: ObservableObject {

    @Published var user: User?
    @Published var surfLevelName: String = ""
    @Published var nextLevelSkills: [String] = []
    @Published var completedNextLevelSkills: Set<String> = []

    var session: SessionManager?

    init(session: SessionManager? = nil) {
        self.session = session
        // Si session déjà existante → initialise l'état
        if let user = session?.currentUser {
            self.user = user
            loadSurfLevelInfo(for: user)
        }
    }

    // Récupére user depuis la session ou depuis firestore
    func fetchUser() async {
        // Session
        if let sessionUser = session?.currentUser {
            self.user = sessionUser
            loadSurfLevelInfo(for: sessionUser)
        // Firestore
        } else if let uid = Auth.auth().currentUser?.uid {
            do {
                if let fetchedUser = try await UserService.shared.fetchUser(uid: uid) {
                    self.user = fetchedUser
                    loadSurfLevelInfo(for: fetchedUser)
                }
            } catch {
                print("Erreur fetchUser:", error)
            }
        }
    }

    
    func loadSurfLevelInfo(for user: User) {
        
        let levels = SurfLevelService.loadLevels()
        // Recherche du niveau actuel
        guard let currentIndex = levels.firstIndex(where: { $0.id == user.surfLevelId }) else { return }

        let currentLevel = levels[currentIndex]
        surfLevelName = currentLevel.name

        // Si niveau supérieur existe
        if currentIndex + 1 < levels.count {
            let nextLevel = levels[currentIndex + 1]
            nextLevelSkills = nextLevel.skills
            completedNextLevelSkills = Set(user.completedSkills.filter { nextLevel.skills.contains($0) })
        } else {
            // Niveau max atteint
            nextLevelSkills = currentLevel.skills
            completedNextLevelSkills = Set(user.completedSkills)
        }
    }

    var isAtLowestLevel: Bool {
        guard let user = user else { return true }
        let levels = SurfLevelService.loadLevels()
        return levels.first?.id == user.surfLevelId
    }

    var isAtHighestLevel: Bool {
        guard let user = user else { return false }
        let levels = SurfLevelService.loadLevels()
        return levels.last?.id == user.surfLevelId
    }

    // Met à jour et sauvegarde instantanée
    func toggleNextLevelSkill(_ skill: String) async {
        guard var user = user else { return }

        if completedNextLevelSkills.contains(skill) {
            // retrait skills
            completedNextLevelSkills.remove(skill)
            user.completedSkills.removeAll { $0 == skill }
        } else {
            // Ajout
            completedNextLevelSkills.insert(skill)
            user.completedSkills.append(skill)
        }
        
        // Met à jour
        self.user = user
        // Recalcule
        loadSurfLevelInfo(for: user)

        do {
            try await UserService.shared.updateUserProgress(
                uid: user.id,
                surfLevelId: user.surfLevelId,
                completedSkills: Array(user.completedSkills)
            )
        } catch {
            print("Erreur save skills:", error)
        }
    }

    
    func levelUp() async {
        guard var user = user else { return }
        let levels = SurfLevelService.loadLevels()
        guard let index = levels.firstIndex(where: { $0.id == user.surfLevelId }),
              index + 1 < levels.count else { return }

        // Changement de niveau
        user.surfLevelId = levels[index + 1].id
        
        // Reset complet des skills
        user.completedSkills = []
        
        //Mise à jour locale
        self.user = user
        loadSurfLevelInfo(for: user)

        do {
            try await UserService.shared.updateUserProgress(
                uid: user.id,
                surfLevelId: user.surfLevelId,
                completedSkills: []   //Reset BDD
            )
        } catch {
            print("Erreur save level up:", error)
        }
    }

    func levelDown() async {
        guard var user = user else { return }
        let levels = SurfLevelService.loadLevels()
        guard let index = levels.firstIndex(where: { $0.id == user.surfLevelId }),
              index > 0 else { return }

        user.surfLevelId = levels[index - 1].id
        user.completedSkills = []
        self.user = user
        loadSurfLevelInfo(for: user)

        do {
            try await UserService.shared.updateUserProgress(
                uid: user.id,
                surfLevelId: user.surfLevelId,
                completedSkills: []
            )
        } catch {
            print("Erreur save level down:", error)
        }
    }
}
