//
//  SessionCard.swift
//  Wave-Companion
//

import SwiftUI

struct SessionCard: View {
    
    @ObservedObject var vm: SessionDashboardViewModel
    
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
        .cornerRadius(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.primary, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        
    }
}

// Rejoindre une session
private extension SessionCard {
    
    func joinedView(_ session: SurfSession) -> some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
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
                    
                    
                    HStack(spacing: 6) {
                        Image(systemName: "figure.surfing")
                        Text("Min. \(session.minimumLevel)")
                    }
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColors.primary.opacity(0.15))
                    .clipShape(Capsule())
                    
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                        Text("\(session.participantIDs.count) participant\(session.participantIDs.count > 1 ? "s" : "")")
                    }
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.15))
                    .clipShape(Capsule())
                    
                    
                }
            }
            
            HStack {
                
                AvatarStackView(imageURLs: session.participantIDs)
                
                Spacer()
                
                Button {
                } label: {
                    Text("Voir")
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
            }
        }
    }
}

// Suggestion
private extension SessionCard {
    
    func suggestionView(_ main: SurfSession, _ others: [SurfSession]) -> some View {
        
        let remainingSpots = max(0, main.maxPeople - main.participantIDs.count)
        
        return VStack(alignment: .leading, spacing: 18) {
            
            header(
                title: "Session près de toi",
                icon: "location.fill",
                color: AppColors.primary
            )
            
            // HERO BLOCK
            VStack(alignment: .leading, spacing: 12) {
                
                Text(main.spotName)
                    .font(.title3.weight(.semibold))
                
                Text(main.date.sessionFormatted)
                    .font(.subheadline.bold())
                    .foregroundColor(.secondary)
                
                // BADGES ROW
                HStack(spacing: 10) {
                    
                    // Niveau minimum
                    HStack(spacing: 6) {
                        Image(systemName: "figure.surfing")
                        Text("Min. \(main.minimumLevel)")
                    }
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColors.primary.opacity(0.2))
                    .clipShape(Capsule())
                    
                    // Places restantes
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                        Text("\(remainingSpots) place\(remainingSpots > 1 ? "s" : "") restante\(remainingSpots > 1 ? "s" : "")")
                    }
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        remainingSpots <= 2 ?
                        Color.orange.opacity(0.2) :
                        Color.green.opacity(0.2)
                    )
                    .clipShape(Capsule())
                }
            }
            
            // SOCIAL + CTA
            HStack(alignment: .center) {
                
                VStack(alignment: .leading, spacing: 6) {
                    AvatarStackView(imageURLs: main.participantIDs)
                    
                    Text("\(main.participantIDs.count) surfeur\(main.participantIDs.count > 1 ? "s" : "") déjà inscrit\(main.participantIDs.count > 1 ? "s" : "")")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                } label: {
                    Text("Rejoindre")
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
               
                
            }
            
            if !others.isEmpty {
                
                Divider()
                
                VStack(alignment: .leading, spacing: 6) {
                    
                    Text("Autres sessions proches")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(AppColors.primary)
                    
                    ForEach(others.prefix(2)) { session in
                        
                        Button {
                            // Navigation vers détail session
                        } label: {
                            
                            HStack(spacing: 6) {
                                
                                Text(session.spotName)
                                    .font(.caption.weight(.medium))
                                
                                Text("•")
                                    .foregroundColor(.secondary)
                                
                                Text(session.date.sessionFormatted)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 2)
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

#Preview("Suggestion") {
    let vm = SessionDashboardViewModel()
    vm.state = .suggestion(
        main: MockData.nearbySessions[0],
        others: Array(MockData.nearbySessions.dropFirst())
    )
    return SessionCard(vm: vm)
        .background(Color(.systemBackground))
}

#Preview("Session rejointe") {
    let vm = SessionDashboardViewModel()
    vm.state = .joined(session: MockData.nearbySessions[0])
    return SessionCard(vm: vm)
        .background(Color(.systemBackground))
}

#Preview("Aucune session") {
    let vm = SessionDashboardViewModel()
    vm.state = .noNearbySessions
    return SessionCard(vm: vm)
        .background(Color(.systemBackground))
}

#Preview("Localisation désactivée") {
    let vm = SessionDashboardViewModel()
    vm.state = .locationDisabled
    return SessionCard(vm: vm)
        .background(Color(.systemBackground))
}
