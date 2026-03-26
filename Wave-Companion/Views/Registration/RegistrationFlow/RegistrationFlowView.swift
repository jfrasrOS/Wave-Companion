import SwiftUI

struct RegistrationFlowView: View {
    @EnvironmentObject var registrationVM: RegistrationViewModel
    
    var body: some View {
        VStack {
            switch registrationVM.path.last {
            case .profile:
                RegistrationProfileView()
            case .surfLevel:
                RegistrationSurfLevelView()
            case .board:
                RegistrationBoardView()
            case .spots:
                RegistrationFavoritesSpotsView()
            default:
                AuthChoiceView()
            }
        }
    }
}

