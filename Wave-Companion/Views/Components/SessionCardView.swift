import SwiftUI

// Component réutilisé sur home (sessioncard), mapview et MySessionView
struct SessionCardView: View {
    
    let session: SurfSession
    let levelText: String

    var sessionTitle: String?
    var titleColor: Color?
    let buttonTitle: String
    let buttonEnabled: Bool
    let onButtonTap: () -> Void
    
    var participants: [String] {
        Array(Set(session.participantIDs))
    }
    
    var remaining: Int {
        max(0, session.maxPeople - participants.count)
    }
    
    var participantText: String {
        let count = participants.count
        return "\(count) participant\(count > 1 ? "s" : "")"
    }
    
    var isPast: Bool {
        session.date < Date()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Header
            HStack(spacing: 8) {
                
                Text(session.spotName)
                    .font(.title3.weight(.semibold))
                
                if let sessionTitle, let titleColor {
                    Text(sessionTitle)
                        .font(.caption2.weight(.medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(titleColor.opacity(0.15))
                        .foregroundColor(titleColor)
                        .clipShape(Capsule())
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 10) {
                
                Text(session.date.sessionFormatted)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 10) {
                    
                    // Niveau min
                    HStack(spacing: 6) {
                        Image(systemName: "figure.surfing")
                        Text(levelText)
                    }
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColors.primary.opacity(0.15))
                    .clipShape(Capsule())
                    
                    // Badge places restantes
                    if !isPast {
                        HStack(spacing: 6) {
                            Image(systemName: "person.2.fill")
                            Text(
                                remaining == 0
                                ? "Complet"
                                : "\(remaining) place\(remaining > 1 ? "s" : "")"
                            )
                        }
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(badgeColor())
                        .clipShape(Capsule())
                        
                    }
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    AvatarStackView(imageURLs: participants)
                    Text(participantText)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if buttonTitle == "Voir" {
                    NavigationLink(value: session) {
                        Text(buttonTitle)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .frame(minWidth: 80)
                            .background(Color.clear)
                            .foregroundColor(AppColors.action)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(AppColors.action, lineWidth: 1)
                            )
                    }
                } else {
                    Button(action: onButtonTap) {
                        Text(buttonTitle)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .frame(minWidth: 80)
                            .background(AppColors.action)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .disabled(!buttonEnabled)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.primary, lineWidth: 1)
        )
        .opacity(isPast ? 0.8 : 1)
    }
    
    func badgeColor() -> Color {
        if remaining == 0 { return Color.red.opacity(0.2) }
        if remaining <= 2 { return Color.orange.opacity(0.2) }
        return Color.green.opacity(0.2)
    }
}
