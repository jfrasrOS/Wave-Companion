import SwiftUI

struct MainTabContainer: View {

    @State private var selectedTab: TabItem = .home
    @State private var selectedChatId: String?

    var body: some View {
        VStack(spacing: 0) {
            
            // HEADER minimal pour espace et separation
            Color.clear
                .frame(height: 12)
                .background(Color("Background"))
            
            // CONTENU PRINCIPAL
            ZStack {
                // HOME
                                NavigationStack {
                                    HomeView(selectedTab: $selectedTab,
                                             selectedChatId: $selectedChatId)
                                }
                                .id(selectedTab == .home)
                                .opacity(selectedTab == .home ? 1 : 0)

                                // MAP
                                NavigationStack {
                                    SurfMapView(selectedTab: $selectedTab,
                                                selectedChatId: $selectedChatId)
                                }
                                .id(selectedTab == .discover)
                                .opacity(selectedTab == .discover ? 1 : 0)

                                // SESSIONS
                                NavigationStack {
                                    MySessionsView(selectedTab: $selectedTab,
                                                   selectedChatId: $selectedChatId)
                                }
                                .id(selectedTab == .sessions)
                                .opacity(selectedTab == .sessions ? 1 : 0)

                                // COMMUNITY
                                NavigationStack {
                                    CommunityView(selectedTab: $selectedTab,
                                                  selectedChatId: $selectedChatId)
                                }
                                .id(selectedTab == .community)
                                .opacity(selectedTab == .community ? 1 : 0)

                                // PROFILE
                                NavigationStack {
                                    ProfileView()
                                }
                                .id(selectedTab == .profile)
                                .opacity(selectedTab == .profile ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // TAB BAR CUSTOM
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .background(Color("Background").ignoresSafeArea())
    }
}

