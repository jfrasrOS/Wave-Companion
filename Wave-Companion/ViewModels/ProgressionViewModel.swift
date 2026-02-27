import Combine
import Foundation
import SwiftUI

@MainActor
final class ProgressionViewModel: ObservableObject {

    // Callback vers HomeViewModel
    private let homeVM: HomeViewModel
    
    @Published var pendingLevelAction: LevelAction?
    
    enum LevelAction {
        case levelUp
        case levelDown
    }
    
    init(homeVM: HomeViewModel) {
        self.homeVM = homeVM
        checkLevelCompletion()
    }
    
    var surfLevelName: String { homeVM.surfLevelName }
    
    var currentLevelSkills: [String] {
        guard let user = homeVM.user else { return [] }
        let levels = SurfLevelService.loadLevels()
        guard let currentIndex = levels.firstIndex(where: { $0.id == user.surfLevelId }) else { return [] }
        return levels[currentIndex].skills
    }
    
    var nextLevelName: String? {
        guard let user = homeVM.user else { return nil }
        let levels = SurfLevelService.loadLevels()
        guard let currentIndex = levels.firstIndex(where: { $0.id == user.surfLevelId }) else { return nil }
        if currentIndex + 1 < levels.count {
            return levels[currentIndex + 1].name
        } else {
            return "Perfectionnement"
        }
    }
    
    var nextLevelSkills: [String] {
        guard let user = homeVM.user else { return [] }
        let levels = SurfLevelService.loadLevels()
        guard let currentIndex = levels.firstIndex(where: { $0.id == user.surfLevelId }) else { return [] }
        if currentIndex + 1 < levels.count {
            return levels[currentIndex + 1].skills
        } else {
            return levels[currentIndex].skills
        }
    }
    
    var completedNextLevelSkills: Set<String> {
        guard let user = homeVM.user else { return [] }
        return Set(user.completedSkills.filter { nextLevelSkills.contains($0) })
    }
    
    var nextLevelCompletedCount: Int { completedNextLevelSkills.count }
    
    var isAtLowestLevel: Bool { homeVM.isAtLowestLevel }
    var isAtHighestLevel: Bool { homeVM.isAtHighestLevel }
    
    
    func toggleNextLevelSkill(_ skill: String) {
        Task {
            await homeVM.toggleNextLevelSkill(skill)
            checkLevelCompletion()
        }
    }
    
    func confirmPendingLevelAction() {
        guard let action = pendingLevelAction else { return }
        switch action {
        case .levelUp: Task { await homeVM.levelUp() }
        case .levelDown: Task { await homeVM.levelDown() }
        }
        pendingLevelAction = nil
    }
    
    func requestLevelDown() {
        guard !isAtLowestLevel else { return }
        pendingLevelAction = .levelDown
    }
    
    // Vérifie si tous les skills du niveau sont validées, si oui -> alert
    private func checkLevelCompletion() {
        if !isAtHighestLevel && !nextLevelSkills.isEmpty &&
            nextLevelSkills.allSatisfy({ completedNextLevelSkills.contains($0) }) {
            pendingLevelAction = .levelUp
        }
    }
}
