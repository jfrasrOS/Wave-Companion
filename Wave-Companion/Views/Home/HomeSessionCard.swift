import SwiftUI

enum HomeSessionCardMode {
    case joined
    case suggestion

}

struct HomeSessionCard: View {
    
    let session: SurfSession
    let levelText: String
    let mode: HomeSessionCardMode
    var others: [SurfSession] = []
    var onJoin: (() -> Void)? = nil
    var onSelectSession: ((SurfSession) -> Void)? = nil
    
    var participants: [String] {
        Array(Set(session.participantIDs))
    }
    
    // Places restantes
    var remaining: Int {
        max(0, session.maxPeople - participants.count)
    }
    
    // Couleur dynamique selon dispo
    var placeColor: Color {
        if remaining <= 1 { return .red }
        if remaining <= 3 { return .orange }
        return .green
    }

    
    
    var body: some View {
        
            VStack(alignment: .leading, spacing: 16) {
                
                HStack(alignment: .center, spacing: 14) {
                    
                    MapSnapshotImageView(
                        latitude: session.latitude,
                        longitude: session.longitude,
                        width: 90,
                        height: 90
                    )
                    .cornerRadius(14)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(session.spotName)
                                .font(.headline)
                            
                            Text(session.city)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Text(session.date.sessionFormatted)
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            
                            if mode == .suggestion {
                                Text(levelText)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack {
                            
                            AvatarStackView(imageURLs: participants)
                            
                            if mode == .suggestion {
                                Label("\(remaining)", systemImage: "person.2.fill")
                                    .font(.caption.bold())
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(placeColor.opacity(0.2))
                                    .foregroundColor(placeColor)
                                    .clipShape(Capsule())
                                    .fixedSize()
                            }
                            
                            Spacer(minLength: 12)
                            
                            if mode == .suggestion {
                                Button {
                                    onJoin?()
                                } label: {
                                    Text("Rejoindre")
                                        .font(.caption.weight(.semibold))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(AppColors.action)
                                        .foregroundColor(.white)
                                        .clipShape(Capsule())
                                }
                                .fixedSize()
                            }
                        }
                    }
                }
                
                if mode == .suggestion && !others.isEmpty {
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        Text(others.count == 1 ? "Autre session" : "Autres sessions")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                        
                        ForEach(others.prefix(2)) { session in
                            
                            Button {
                                onSelectSession?(session)
                            } label: {
                                
                                HStack {
                                    
                                    HStack(spacing: 6) {
                                        Text(session.spotName)
                                            .font(.caption)
                                        
                                        Text("• \(session.date.sessionFormatted)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
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

