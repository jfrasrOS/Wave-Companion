import SwiftUI

struct HomeView: View {
    @StateObject private var homeVM = HomeViewModel()
    @StateObject private var sessionVM = SessionViewModel()
    @StateObject private var dashboardVM = SessionDashboardViewModel()
    
    @Binding var selectedTab: TabItem
    @Binding var selectedChatId: String?
    

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
                                selectedTab = .discover
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
            .navigationDestination(for: SurfSession.self) { session in
                SessionDetailView(
                    vm: SessionDetailViewModel(session: session),
                    selectedTab: $selectedTab,
                    selectedChatId: $selectedChatId
                )
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


