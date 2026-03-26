import SwiftUI

struct MainTabContainer: View {

    @State private var selectedTab: TabItem = .home

    var body: some View {
        VStack(spacing: 0) {
            
            // HEADER minimal pour espace et separation
            Color.clear
                .frame(height: 12)
                .background(Color("Background"))
            
            // CONTENU PRINCIPAL
            ZStack {
                switch selectedTab {
                case .home:
                    HomeView()
                case .discover:
                    SurfMapView()
                case .sessions:
                    MySessionsView()
                case .friends:
                    Text("Amis")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .profile:
                    ProfileView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // TAB BAR CUSTOM
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .background(Color("Background").ignoresSafeArea())
    }
}

