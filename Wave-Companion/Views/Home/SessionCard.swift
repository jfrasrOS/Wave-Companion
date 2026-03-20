import SwiftUI

struct SessionCard: View {
    
    @ObservedObject var vm: SessionDashboardViewModel
    var onOpenMap: () -> Void
    var onJoin: (SurfSession) -> Void

    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            switch vm.state {
                
            case .joined(let session):
                joinedView(session)
                
            case .suggestion(let main, let others):
                suggestionView(main, others)
                
            case .noNearbySessions:
                noSessionView
                
            case .locationDisabled:
                locationDisabledView
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.primary, lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
}

func openAppSettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url)
}

// MARK: - LOGIC HELPERS
private extension SessionCard {
    
    func uniqueParticipants(_ session: SurfSession) -> [String] {
        Array(Set(session.participantIDs))
    }

    func remainingSpots(_ session: SurfSession) -> Int {
        max(0, session.maxPeople - uniqueParticipants(session).count)
    }

    func badgeColor(_ remaining: Int) -> Color {
        if remaining == 0 { return Color.red.opacity(0.2) }
        if remaining <= 2 { return Color.orange.opacity(0.2) }
        return Color.green.opacity(0.2)
    }
}

// MARK: - JOINED
private extension SessionCard {
    
    func joinedView(_ session: SurfSession) -> some View {
        
        let participants = uniqueParticipants(session)
        let remaining = remainingSpots(session)
        
        return VStack(alignment: .leading, spacing: 16) {
            
            header(
                title: "Ta prochaine session",
                icon: "calendar",
                color: .green
            )
            
            VStack(alignment: .leading, spacing: 10) {
                
                Text(session.spotName)
                    .font(.title3.weight(.semibold))
                
                Text(session.date.sessionFormatted)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 10) {
                    
                    // Niveau
                    HStack(spacing: 6) {
                        Image(systemName: "figure.surfing")
                        Text("Min. \(vm.category(for: session.minimumLevel))")
                    }
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColors.primary.opacity(0.15))
                    .clipShape(Capsule())
                    
                    // Places restantes
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                        Text(
                            remaining == 0
                            ? "Session pleine"
                            : "\(remaining) place\(remaining > 1 ? "s" : "") restante\(remaining > 1 ? "s" : "")"
                        )
                    }
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(badgeColor(remaining))
                    .clipShape(Capsule())
                }
            }
            
            HStack {
                
                VStack(alignment: .leading, spacing: 6) {
                    AvatarStackView(imageURLs: participants)
                    
                    Text(
                        participants.count == 1
                        ? "1 surfeur participe"
                        : "\(participants.count) surfeurs participent"
                    )
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                } label: {
                    Text("Voir")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                }
                .foregroundColor(AppColors.action)
                .overlay(
                    Capsule().stroke(AppColors.action, lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - SUGGESTION
private extension SessionCard {
    
    func suggestionView(_ main: SurfSession, _ others: [SurfSession]) -> some View {
        
        let participants = uniqueParticipants(main)
        let remaining = remainingSpots(main)
        
        return VStack(alignment: .leading, spacing: 18) {
            
            header(
                title: "Session près de toi",
                icon: "location.fill",
                color: AppColors.primary
            )
            
            VStack(alignment: .leading, spacing: 12) {
                
                Text(main.spotName)
                    .font(.title3.weight(.semibold))
                
                Text(main.date.sessionFormatted)
                    .font(.subheadline.bold())
                    .foregroundColor(.secondary)
                
                HStack(spacing: 10) {
                    
                    // Niveau
                    HStack(spacing: 6) {
                        Image(systemName: "figure.surfing")
                        Text("Min. \(vm.category(for: main.minimumLevel))")
                    }
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColors.primary.opacity(0.2))
                    .clipShape(Capsule())
                    
                    // Places restantes
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                        Text(
                            remaining == 0
                            ? "Session pleine"
                            : "\(remaining) place\(remaining > 1 ? "s" : "") restante\(remaining > 1 ? "s" : "")"
                        )
                    }
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(badgeColor(remaining))
                    .clipShape(Capsule())
                }
            }
            
            HStack {
                
                VStack(alignment: .leading, spacing: 6) {
                    AvatarStackView(imageURLs: participants)
                    
                    Text(
                        participants.count == 1
                        ? "1 surfeur participe"
                        : "\(participants.count) surfeurs participent"
                    )
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    onJoin(main)
                } label: {
                    Text("Rejoindre")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                }
                .foregroundColor(AppColors.action)
                .overlay(
                    Capsule().stroke(AppColors.action, lineWidth: 1)
                )
            }
            
            if !others.isEmpty {
                Divider()
                
                VStack(alignment: .leading, spacing: 6) {
                    
                    Text("Autres sessions proches")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(AppColors.primary)
                    
                    ForEach(others.prefix(2)) { session in
                        
                        Button {
                        } label: {
                            HStack {
                                Text(session.spotName)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .font(.caption)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
//Aucune session
private extension SessionCard {
    
    var noSessionView: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            header(
                title: "Aucune session autour de toi",
                icon: "waveform.path.ecg",
                color: AppColors.primary
            )
            
            Text("Sois le premier à organiser une session près de toi.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                
                Button {
                    onOpenMap()
                } label: {
                    Text("Créer")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                }
                .foregroundColor(AppColors.action)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(AppColors.action, lineWidth: 1)
                )
                
                Spacer()
                
                
            }
        }
    }
}

// Localisation désactivée
private extension SessionCard {
    
    var locationDisabledView: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            header(
                title: "Localisation désactivée",
                icon: "location.slash",
                color: AppColors.action
            )
            
            Text("Active la géolocalisation pour voir les sessions autour de toi.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                
                Button {
                    openAppSettings()
                } label: {
                    Text("Activer")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                }
                .foregroundColor(AppColors.action)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(AppColors.action, lineWidth: 1)
                )
                
                Spacer()
                
                Button {
                    onOpenMap()
                } label: {
                    HStack(spacing: 4) {
                        Text("Voir la carte")
                            .font(.caption.weight(.medium))
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(AppColors.primary)
            }
        }
    }
}

// Header
private extension SessionCard {
    
    func header(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundColor(color)
            
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(color)
            
            Spacer()
        }
    }
}

// Avatar
struct AvatarStackView: View {
    
    let imageURLs: [String]
    private let maxDisplayed = 4
    
    var body: some View {
        
        HStack(spacing: -10) {
            
            ForEach(0..<min(imageURLs.count, maxDisplayed), id: \.self) { _ in
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
            }
            
            if imageURLs.count > maxDisplayed {
                Text("+\(imageURLs.count - maxDisplayed)")
                    .font(.caption2.bold())
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
    }
}



