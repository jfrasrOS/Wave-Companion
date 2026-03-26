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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Header optionnel
            if let sessionTitle, let titleColor {
                HStack(spacing: 6) {
                    
                    Text(sessionTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(titleColor)
                    
                    Spacer()
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(session.spotName)
                    .font(.title3.weight(.semibold))
                
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
                    .background(badgeColor())
                    .clipShape(Capsule())
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    AvatarStackView(imageURLs: participants)
                    Text("\(participants.count) surfeurs participent")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: onButtonTap) {
                    Text(buttonTitle)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .frame(minWidth: 80)
                        .background(buttonEnabled ? Color.clear : AppColors.action)
                        .foregroundColor(buttonEnabled ? AppColors.action : .white)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(buttonEnabled ? AppColors.action : Color.clear, lineWidth: 1)
                        )
                }
                .disabled(!buttonEnabled)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.primary, lineWidth: 1)
        )
    }
    
    func badgeColor() -> Color {
        if remaining == 0 { return Color.red.opacity(0.2) }
        if remaining <= 2 { return Color.orange.opacity(0.2) }
        return Color.green.opacity(0.2)
    }
}
