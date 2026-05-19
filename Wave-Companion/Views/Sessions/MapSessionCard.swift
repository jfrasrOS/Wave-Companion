import SwiftUI

struct MapSessionCard: View {

    let session: SurfSession

    let statusText: String
    let statusColor: Color

    let buttonTitle: String
    let buttonEnabled: Bool

    let levelText: String

    let onTap: () -> Void

    var participants: [String] {
        Array(Set(session.participantIDs))
    }

    var remaining: Int {
        max(0, session.maxPeople - participants.count)
    }

    var displayedParticipants: Int {
        min(participants.count, 2)
    }

    var extraParticipants: Int {
        max(0, participants.count - 2)
    }

    var placeColor: Color {

        if remaining <= 1 {
            return .red
        }

        if remaining <= 3 {
            return .orange
        }

        return .green
    }

    
    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 18
        ) {

            VStack(
                alignment: .leading,
                spacing: 12
            ) {

                Text(statusText)
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        statusColor.opacity(0.14)
                    )
                    .clipShape(Capsule())

                HStack(spacing: 7) {

                    Image(systemName: "calendar")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text(session.date.sessionFormatted)
                }
                .font(.caption.weight(.medium))
                .foregroundColor(.primary)

                Text(levelText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

        
            HStack(alignment: .center) {

                HStack(spacing: 8) {
                    // Avatar
                    HStack(spacing: -8) {

                        ForEach(
                            0..<displayedParticipants,
                            id: \.self
                        ) { _ in

                            Circle()
                                .fill(
                                    Color.gray.opacity(0.22)
                                )
                                .frame(width: 29, height: 29)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            Color.white,
                                            lineWidth: 2
                                        )
                                )
                        }

                        if extraParticipants > 0 {

                            ZStack {

                                Circle()
                                    .fill(
                                        Color.gray.opacity(0.16)
                                    )

                                Text("+\(extraParticipants)")
                                    .font(.caption2.bold())
                                    .foregroundColor(.primary)
                            }
                            .frame(width: 29, height: 29)
                            .overlay(
                                Circle()
                                    .stroke(
                                        Color.white,
                                        lineWidth: 2
                                    )
                            )
                        }
                    }

                    // Places restantes
                    Label(
                        "\(remaining)",
                        systemImage: "person.2.fill"
                    )
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        placeColor.opacity(0.18)
                    )
                    .foregroundColor(placeColor)
                    .clipShape(Capsule())
                    .fixedSize()
                }

                Spacer(minLength: 8)

                Button(action: onTap) {

                    Text(buttonTitle)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            buttonEnabled
                            ? AppColors.action
                            : Color.gray.opacity(0.2)
                        )
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .fixedSize()
                .disabled(!buttonEnabled)
            }
        }
        .padding(18)
        .frame(width: 255, height: 155)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    Color.white.opacity(0.82)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(
                    Color.white.opacity(0.7),
                    lineWidth: 1
                )
        )
    }
}
