import SwiftUI

struct MySessionsView: View {
    
    @StateObject private var vm = MySessionsViewModel()
    
    @State private var selectedSessions: [SurfSession] = []
    @State private var showPopup = false
    @State private var popupPosition: CGPoint = .zero
    
    @Binding var selectedTab: TabItem
    @Binding var selectedChatId: String?
    
    init(
        selectedTab: Binding<TabItem>,
        selectedChatId: Binding<String?>
    ) {
        _selectedTab = selectedTab
        _selectedChatId = selectedChatId
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    if let nextSession = vm.upcomingSessions.first {
                        NextSessionSection(session: nextSession, vm: vm)
                    }
                    
                    HeatmapSection(
                        vm: vm,
                        selectedSessions: $selectedSessions,
                        showPopup: $showPopup,
                        popupPosition: $popupPosition
                    )
                    
                    StatsSection(vm: vm)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
            }
            .navigationDestination(for: SurfSession.self) { session in
                SessionDetailView(
                    vm: SessionDetailViewModel(session: session),
                    selectedTab: $selectedTab,
                    selectedChatId: $selectedChatId
                )
            }
        }
        // PopUp
        .overlay {
            if showPopup {
                SmallSessionPopup(
                    sessions: selectedSessions,
                    showPopup: $showPopup
                )
                .position(popupPosition)
                .transition(.scale.combined(with: .opacity))
                .zIndex(10)
            }
        }
        // fermeture on tap n'importe où
        .simultaneousGesture(
            TapGesture().onEnded {
                if showPopup {
                    showPopup = false
                }
            }
        )
        .onAppear {
            vm.startListening()
        }
    }
}

// Prochaine session
struct NextSessionSection: View {
    
    let session: SurfSession
    let vm: MySessionsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Prochaine session")
                .font(.headline)
            
            NavigationLink(value: session) {
                SessionCardView(
                    session: session,
                    levelText: "Min. \(vm.category(for: session.minimumLevel))",
                    sessionTitle: nil,
                    titleColor: nil,
                    buttonTitle: "Voir",
                    buttonEnabled: true,
                    onButtonTap: {}
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// Activité sur l'année (heatmap)
struct HeatmapSection: View {
    
    @ObservedObject var vm: MySessionsViewModel
    
    @Binding var selectedSessions: [SurfSession]
    @Binding var showPopup: Bool
    @Binding var popupPosition: CGPoint
    
    let cellSize: CGFloat = 25
    let spacing: CGFloat = 6
    let rows = Array(repeating: GridItem(.fixed(25)), count: 7)
    
    var body: some View {
        
        let days = generateDaysWithOffset()
        
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Activité")
                .font(.headline)
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        MonthHeaderView(
                            cellSize: cellSize,
                            spacing: spacing,
                            days: days
                        )
                        
                        LazyHGrid(rows: rows, spacing: spacing) {
                            
                            ForEach(Array(days.enumerated()), id: \.offset) { index, date in
                                
                                if let date = date {
                                    
                                    let count = vm.sessionsCount(on: date)
                                    
                                    GeometryReader { geo in
                                        Rectangle()
                                            .fill(color(for: count))
                                            .frame(width: cellSize, height: cellSize)
                                            .cornerRadius(3)
                                            .overlay(
                                                Calendar.current.isDate(date, inSameDayAs: Date()) ?
                                                RoundedRectangle(cornerRadius: 3)
                                                    .stroke(AppColors.action, lineWidth: 2)
                                                : nil
                                            )
                                            .onTapGesture {
                                                
                                                let sessions = vm.sessions(on: date)
                                                
                                                if !sessions.isEmpty {
                                                    
                                                    selectedSessions = sessions
                                                    
                                                    let frame = geo.frame(in: .global)
                                                    
                                                    let popupHeight: CGFloat = 110
                                                    
                                                    popupPosition = CGPoint(
                                                        x: frame.midX,
                                                        y: frame.minY - popupHeight
                                                    )
                                                    
                                                    withAnimation(.spring(response: 0.25)) {
                                                        showPopup = true
                                                    }
                                                }
                                            }
                                    }
                                    .frame(width: cellSize, height: cellSize)
                                    
                                } else {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(width: cellSize, height: cellSize)
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    scrollToToday(proxy: proxy, days: days)
                }
                // Si scroll -> ferme PopUp
                .simultaneousGesture(
                    DragGesture(minimumDistance: 1)
                        .onChanged { _ in
                            if showPopup {
                                showPopup = false
                            }
                        }
                )
                // Si tap dans le scroll -> ferme PopUp
                .simultaneousGesture(
                    TapGesture().onEnded {
                        if showPopup {
                            showPopup = false
                        }
                    }
                )
            }
        }
    }
    
    // Scroll automatique sur aujourd'hui
    func scrollToToday(proxy: ScrollViewProxy, days: [Date?]) {
        let calendar = Calendar.current
        let today = Date()
        
        // Cherche l'index du jour actuel
        if let index = days.firstIndex(where: { date in
            if let date = date {
                return calendar.isDate(date, inSameDayAs: today)
            }
            return false
        }) {
            DispatchQueue.main.async {
                proxy.scrollTo(index, anchor: .center)
            }
        }
    }
    
    func color(for count: Int) -> Color {
        switch count {
        case 0: return Color.gray.opacity(0.12)
        case 1: return AppColors.action.opacity(0.3)
        case 2: return AppColors.action.opacity(0.5)
        case 3: return AppColors.action.opacity(0.7)
        default: return AppColors.action
        }
    }
    
    
    // Génére tous les jours de l'année + ajoute cases vides début/fin d'année
    func generateDaysWithOffset() -> [Date?] {
        let calendar = Calendar.current
        let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: Date()))!
        
        let weekday = calendar.component(.weekday, from: startOfYear)
        let emptyDays = (weekday + 5) % 7
        
        var days: [Date?] = Array(repeating: nil, count: emptyDays)
        
        let range = calendar.range(of: .day, in: .year, for: Date())!
        for i in 0..<range.count {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfYear) {
                days.append(date)
            }
        }
        
        return days
    }
}

// Affichage des mois
struct MonthHeaderView: View {
    
    let cellSize: CGFloat
    let spacing: CGFloat
    let days: [Date?]
    
    var body: some View {
        
        let weekCount = days.count / 7 + 1
        let monthColumns = monthColumnPositions()
        
        HStack(spacing: spacing) {
            ForEach(0..<weekCount, id: \.self) { week in
                if let month = monthColumns[week] {
                    Text(month)
                        .font(.caption2)
                        .frame(width: cellSize)
                } else {
                    Spacer()
                        .frame(width: cellSize)
                }
            }
        }
    }
    
    func monthColumnPositions() -> [Int: String] {
        let calendar = Calendar.current
        var positions: [Int: String] = [:]
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.shortMonthSymbols = [
            "janv.", "févr.", "mar.", "avr.", "mai", "juin",
            "juil.", "août", "sep.", "oct.", "nov.", "déc."
        ]
        
        for (index, date) in days.enumerated() {
            if let date = date {
                let day = calendar.component(.day, from: date)
                if day == 1 {
                    let month = calendar.component(.month, from: date)
                    let weekIndex = index / 7
                    positions[weekIndex] = formatter.shortMonthSymbols[month - 1]
                }
            }
        }
        
        return positions
    }
}

// POPUP
struct SmallSessionPopup: View {
    
    let sessions: [SurfSession]
    @Binding var showPopup: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(sessions) { session in
                    
                    VStack(alignment: .leading, spacing: 2) {
                        
                        Text(session.spotName)
                            .font(.caption.weight(.semibold))
                        
                        Text(session.date.sessionFormatted)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("1m • OffShore • 12s")// voir conditions météo plus tard API
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("Difficile • 3 vagues ") // voir plus tard
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 8)
            )
            
            Triangle()
                .fill(Color(.systemBackground))
                .frame(width: 12, height: 6)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}


// Stats
struct StatsSection: View {
        
        @ObservedObject var vm: MySessionsViewModel
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 12) {
                
                Text("Statistiques")
                    .font(.headline)
                
                HStack(spacing: 12) {
                    StatCard(title: "Sessions", value: "\(vm.totalSessions)")
                    StatCard(title: "Spots", value: "\(vm.uniqueSpots)")
                    StatCard(title: "Vagues", value: "\(vm.totalWaves)")
                }
            }
        }
    }
    
    struct StatCard: View {
        
        let title: String
        let value: String
        
        var body: some View {
            VStack {
                Text(value)
                    .font(.title2.bold())
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.08))
            )
        }
    }

