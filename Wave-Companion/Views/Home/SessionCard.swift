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
        .padding(.horizontal)
    }
}

// Demande autorisation
func openAppSettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url)
}

// Session rejointe
private extension SessionCard {
    func joinedView(_ session: SurfSession) -> some View {
        SessionCardView(
            session: session,
            levelText: "Min. \(vm.category(for: session.minimumLevel))",
            sessionTitle: "Ta prochaine session",
            titleColor: .green,
            buttonTitle: "Voir",
            buttonEnabled: true,
            onButtonTap: {}
        )
    }
}

// Suggestions
private extension SessionCard {
    func suggestionView(_ main: SurfSession, _ others: [SurfSession]) -> some View {
        VStack(spacing: 12) {
            SessionCardView(
                session: main,
                levelText: "Min. \(vm.category(for: main.minimumLevel))",
                sessionTitle: "Session près de toi",
                titleColor: AppColors.primary,
                buttonTitle: "Rejoindre",
                buttonEnabled: max(0, main.maxPeople - main.participantIDs.count) > 0,
                onButtonTap: { onJoin(main) }
            )
            
            if !others.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Autres sessions proches")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(AppColors.primary)
                        .padding(.horizontal, 16)
                    
                    ForEach(others.prefix(2)) { session in
                        Button {
                            // voir plus tard (mapview ?)
                        } label: {
                            HStack {
                                Text(session.spotName)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .font(.caption)
                            .padding(.horizontal, 16)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// Aucune session
private extension SessionCard {
    var noSessionView: some View {
        SessionCardStyle {
            VStack(alignment: .leading, spacing: 16) {
                header(title: "Aucune session autour de toi",
                       icon: "waveform.path.ecg",
                       color: AppColors.primary)
                
                Text("Sois le premier à organiser une session près de toi.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
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
            }
        }
    }
}

// Localisation désactivée
private extension SessionCard {
    var locationDisabledView: some View {
        SessionCardStyle {
            VStack(alignment: .leading, spacing: 16) {
                header(title: "Localisation désactivée",
                       icon: "location.slash",
                       color: AppColors.action)
                
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

// Uniformise le design pour localisation desactivée + aucune session
struct SessionCardStyle<Content: View>: View {
    let content: () -> Content
    var body: some View {
        content()
            .padding(.horizontal, 16)
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(AppColors.primary, lineWidth: 1)
            )
    }
}

//AvatarStackView pour  les participants
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
