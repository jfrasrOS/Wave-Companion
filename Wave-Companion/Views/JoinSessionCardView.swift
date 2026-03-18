import SwiftUI
import FirebaseAuth

struct JoinSessionCardView: View {

    let session: SurfSession
    let onJoin: () -> Void
    
    let levelCategory: String

    var uniqueParticipants: [String] {
        Array(Set(session.participantIDs))
    }

    var remainingSpots: Int {
        max(0, session.maxPeople - uniqueParticipants.count)
    }

    var isJoined: Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        return uniqueParticipants.contains(uid)
    }
    
    // Peut rejoindre ?
    var canJoin: Bool {
        !isJoined && remainingSpots > 0
    }

    // Titre dynamique
    var sessionTitle: String {
        if isJoined {
            return "Ta prochaine session"
        } else if remainingSpots == 0 {
            return "Session complète"
        } else {
            return "Session ouverte"
        }
    }

    // Bouton dynamique
    var buttonTitle: String {
        if isJoined { return "Détails" }
        else if remainingSpots == 0 { return "Complet" }
        else { return "Rejoindre" }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // HEADER
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(isJoined ? .green : (remainingSpots == 0 ? .red : .green))
                Text(sessionTitle)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(isJoined ? .green : (remainingSpots == 0 ? .red : .green))
                Spacer()
            }

            // INFOS SESSION
            VStack(alignment: .leading, spacing: 10) {

                // Nom spot
                Text(session.date.sessionFormatted)
                    .font(.subheadline.weight(.semibold))
                
                Spacer()

               

                HStack(spacing: 10) {

                    // Niveau min
                    HStack(spacing: 6) {
                        Image(systemName: "figure.surfing")
                        Text("Min. \(levelCategory) +")
                    }
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColors.primary.opacity(0.15))
                    .clipShape(Capsule())

                    // Badge places restantes ou complète
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                        Text(
                            remainingSpots == 0
                            ? "Session pleine"
                            : "\(remainingSpots) place\(remainingSpots > 1 ? "s" : "") restante\(remainingSpots > 1 ? "s" : "")"
                        )
                    }
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(badgeColor)
                    .clipShape(Capsule())
                }
            }

            // AVATARS + BOUTON
            HStack(alignment: .center) {

                // Participants
                VStack(alignment: .leading, spacing: 6) {
                    AvatarStackViewReal(participantIDs: uniqueParticipants)
                    Text(
                        uniqueParticipants.count == 1
                        ? "1 surfeur participe"
                        : "\(uniqueParticipants.count) surfeurs participent"
                    )
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }

                Spacer()

                Button {
                    if isJoined {
                        // navigation vers détails
                    } else {
                        onJoin()
                    }
                } label: {
                    Text(buttonTitle)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .frame(minWidth: 80)
                        .background(!canJoin && !isJoined ? AppColors.action : Color.clear)
                        .foregroundColor(!canJoin && !isJoined ? .white : AppColors.action)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(canJoin || isJoined ? AppColors.action : Color.clear, lineWidth: 1)
                        )
                }
                .disabled(!canJoin && !isJoined)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 15)
        )
    }

    var badgeColor: Color {
        if remainingSpots == 0 { return Color.red.opacity(0.2) }
        if remainingSpots <= 2 { return Color.orange.opacity(0.2) }
        return Color.green.opacity(0.2)
    }
}

struct AvatarStackViewReal: View {

    let participantIDs: [String]

    var body: some View {
        HStack(spacing: -8) {
            ForEach(participantIDs.prefix(5), id: \.self) { userID in
                Circle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 36, height: 36)
            }

            if participantIDs.count > 5 {
                Text("+\(participantIDs.count - 5)")
                    .font(.caption2.bold())
                    .frame(width: 36, height: 36)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(Circle())
            }
        }
    }
}
