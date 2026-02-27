import SwiftUI


struct HomeView: View {
    @StateObject private var homeVM = HomeViewModel()
    
    //Preview
    init(homeVM: HomeViewModel = HomeViewModel()) {
            _homeVM = StateObject(wrappedValue: homeVM)
        }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if homeVM.user != nil {
                        NavigationLink {
                            ProgressionView(vm: ProgressionViewModel(homeVM: homeVM))
                        } label: {
                            SurfLevelCard(vm: homeVM)
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                }
                .padding(.top)
            }
        }
        .task {
            if homeVM.user == nil {
                await homeVM.fetchUser()
            }
        }
    }
}

#Preview("Home") {
    MainActor.assumeIsolated {
        let mockVM = HomeViewModel()
        mockVM.user = UserMock.shared.user
        mockVM.loadSurfLevelInfo(for: UserMock.shared.user)

        return HomeView(homeVM: mockVM)
    }
}
