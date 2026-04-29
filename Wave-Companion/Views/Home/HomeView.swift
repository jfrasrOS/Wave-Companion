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
                
                VStack(spacing: 24) {
                
                    header
                    
                    // SurfLevel Card
                    if homeVM.user != nil {
                        NavigationLink {
                            ProgressionView(vm: ProgressionViewModel(homeVM: homeVM))
                        } label: {
                            SurfLevelCard(vm: homeVM)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // session Card
                    sessionSection
                    
                    // Activité des amis (à faire plus tard)
                    activitySection
                    
                    // météo sur spots favoris (à faire plus tard)
                    weatherSection
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
            .navigationBarHidden(true)
            
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

extension HomeView {
    
    var header: some View {
        HStack {
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text("Salut \(homeVM.user?.name ?? "surfeur") ! 👋")
                    .font(.title3)
                
                Text("Prêt pour une nouvelle session ?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            ZStack(alignment: .topTrailing) {
                
                Image(systemName: "bell")
                    .font(.title2)
                
                Circle()
                    .fill(Color.red)
                    .frame(width: 18, height: 18)
                    .overlay(
                        Text("3")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                    )
                    .offset(x: 8, y: -8)
            }
        }
    }
}

extension HomeView {
    
    var sessionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text(dashboardVM.homeTitle)
                .font(.headline)
            
            Group {
                switch dashboardVM.state {
                    
                case .joined(let session):
                    
                    NavigationLink(value: session) {
                        HomeSessionCard(
                            session: session,
                            levelText: "",
                            mode: .joined
                        )
                    }
                    .buttonStyle(.plain)
                    
                    
                case .suggestion(let main, let others):

                    VStack(spacing: 12) {
                        
                        HomeSessionCard(
                            session: main,
                            levelText: "Min. \(dashboardVM.category(for: main.minimumLevel))",
                            mode: .suggestion,
                            others: others,
                            onJoin: {
                                Task {
                                    if !sessionVM.sessions.contains(where: { $0.id == main.id }) {
                                        sessionVM.sessions.append(main)
                                    }
                                    await sessionVM.joinSession(main)
                                }
                            },
                            onSelectSession: { session in
                                    selectedTab = .discover
                                    selectedChatId = session.chatId
                                }
                        )
                        
                      
                    }
                    
                    
                case .noNearbySessions:

                    VStack(alignment: .leading, spacing: 14) {
                        
                        Text("C'est calme pour l'instant")
                            .font(.headline)
                        
                        Text("Lance une session et retrouve d’autres surfeurs")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                     
                        HStack {
                            Spacer()
                            
                            Button {
                                selectedTab = .discover
                            } label: {
                                Text("Créer une session")
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(AppColors.action)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.top, 6)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(AppColors.primary.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(AppColors.primary.opacity(0.08), lineWidth: 1)
                    )
                    
                case .locationDisabled:

                    VStack(alignment: .leading, spacing: 14) {
                        
                        Text("Active ta localisation")
                            .font(.headline)
                        
         
                        Text("Découvre ce qui se passe près de toi")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            

                        HStack {
                            Spacer()
                            
                            Button {
                                openAppSettings()
                            } label: {
                                Text("Ouvrir les réglages")
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(AppColors.action)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.top, 6)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(AppColors.primary.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(AppColors.primary.opacity(0.08), lineWidth: 1)
                    )
                    }
                }
            }
        }
    }


extension HomeView {
    
    var activitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Activité autour de toi")
                .font(.headline)
            
            VStack(spacing: 10) {
                
                activityRow(
                    icon: "person.fill",
                    text: "Pierre participe à une session demain à 14h"
                )
                
                activityRow(
                    icon: "person.fill",
                    text: "Lucie a surfé à Hendaye"
                )
            }
        }
    }
    
    func activityRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            
            Circle()
                .fill(AppColors.primary.opacity(0.15))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundColor(AppColors.primary)
                )
            
            Text(text)
                .font(.caption)
            
            Spacer()
        }
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(14)
    }
}

extension HomeView {
    
    var weatherSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Spots favoris")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    
                    weatherCard(
                        spot: "Hendaye",
                        temp: "18°",
                        wave: "1.2m",
                        wind: "Offshore"
                    )
                    
                    weatherCard(
                        spot: "Guéthary",
                        temp: "17°",
                        wave: "1.8m",
                        wind: "Side"
                    )
                }
            }
        }
    }
    
    func weatherCard(spot: String, temp: String, wave: String, wind: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Text(spot)
                .font(.subheadline.bold())
            
            Text(temp)
                .font(.title3.bold())
            
            Text("🌊 \(wave)")
                .font(.caption)
            
            Text("💨 \(wind)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 120)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}
