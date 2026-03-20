import SwiftUI

struct HomeView: View {
    @StateObject private var homeVM = HomeViewModel()
    @StateObject private var sessionVM = SessionViewModel()
    @StateObject private var dashboardVM = SessionDashboardViewModel()
    
    @State private var showMap = false
    
    // Preview
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

                        // SESSION CARD
                        SessionCard(
                            vm: dashboardVM,
                            onOpenMap: {
                                showMap = true
                            },
                            onJoin: { session in
                                Task {
                                    if !sessionVM.sessions.contains(where: { $0.id == session.id }) {
                                        sessionVM.sessions.append(session)
                                    }
                                    await sessionVM.joinSession(session)
                                }
                            }
                        )
                        .buttonStyle(.plain)
                    }

                    Spacer()
                }
                .padding(.top)
            }
            .navigationDestination(isPresented: $showMap) {
                SurfMapView()
            }
        }
        .task {
            if homeVM.user == nil {
                await homeVM.fetchUser()
            }
            sessionVM.loadCurrentUserLevel()
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
