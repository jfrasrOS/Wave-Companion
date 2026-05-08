import SwiftUI
import MapKit

struct SessionDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var vm: SessionDetailViewModel
    
    @Binding var selectedTab: TabItem
    @Binding var selectedChatId: String?
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: 0) {
                
                heroSection
                
                VStack(spacing: 24) {
                    
                    conditionsSection
                    
                    participantsSection
                    
                    if vm.state != .past {
                        friendHint
                        meetingPointSection
                    }
                    
                    if vm.isChatAvailable {
                        chatButton
                    }
                }
                .padding(.horizontal, 20)
                .offset(y: -34)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        
        
    }
}

// HERO (IMAGE SATELLITE)
extension SessionDetailView {
    
    var heroSection: some View {
        
        ZStack(alignment: .topLeading) {
            
            ZStack(alignment: .bottomLeading) {
                
                GeometryReader { geo in
                    
                    MapSnapshotImageView(
                        latitude: vm.session.latitude,
                        longitude: vm.session.longitude,
                        width: geo.size.width,
                        height: 290
                    )
                }
                .frame(height: 290)
                .overlay {
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.black.opacity(0.70)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    stateBadge
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        Text(vm.session.spotName)
                            .font(.system(size: 34, weight: .heavy))
                            .foregroundColor(.white)
                        
                        Text(vm.session.date.sessionFormatted)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.white.opacity(0.92))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 68)
            }
            
            Button {
                dismiss()
            } label: {
                
                Image(systemName: "chevron.left")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.black)
                    .frame(width: 52, height: 52)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .padding(.leading, 20)
            .padding(.top, 52)
        }
    }
    
    var stateBadge: some View {
        
        Text(vm.stateTitle)
            .font(.caption.weight(.bold))
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(.ultraThinMaterial.opacity(0.6))
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

// CONDITIONS METEO
extension SessionDetailView {
    
    var conditionsSection: some View {
        
        HStack(spacing: 0) {
            
            conditionItem(
                icon: "water.waves",
                value: "1.2m"
            )
            conditionItem(
                icon: "wind",
                value: "Offshore"
            )
            conditionItem(
                icon: "clock",
                value: "12s"
            )
            conditionItem(
                icon: "sun.max",
                value: "18°"
            )
        }
        .padding(.vertical, 18)
        .background(
            ZStack {
                
                RoundedRectangle(cornerRadius: 30)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.black.opacity(0.14))
                
                RoundedRectangle(cornerRadius: 30)
                    .fill(AppColors.primary.opacity(0.08))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 30))
        
    }
    
    func conditionItem(
        icon: String,
        value: String
    ) -> some View {
        
        VStack(spacing: 6) {
            
            Image(systemName: icon)
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(.white.opacity(0.95))
                    
                    Text(value)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.95))
        }
        .frame(maxWidth: .infinity)
    }
}


// PARTICIPANTS
extension SessionDetailView {
    
    var participantsSection: some View {
        
        VStack(alignment: .leading, spacing: 18) {
            
            HStack {
                
                Text("Participants")
                    .font(.headline)
                
                Spacer()
                
                Text("\(vm.participants.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: 12) {
                    
                    ForEach(vm.participants) { user in
                        
                        ParticipantCard(
                            user: user,
                            currentUserId: vm.currentUserId,
                            isPast: vm.state == .past,
                            isFriend: vm.currentUserFriends.contains(user.id),
                            isPending: vm.sentRequests.contains(user.id),
                            onAddFriend: {
                                vm.sendFriendRequest(to: user.id)
                            }
                        )
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }
}

// FRIENDS INFO
extension SessionDetailView {
    
    var friendHint: some View {
        
        HStack(spacing: 10) {
            
            HStack(spacing: 8) {
                
                Image(systemName: "figure.surfing")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppColors.primary.opacity(0.82))
                
                Text("Surfez ensemble avant de vous ajouter")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }
}

// OU SE RETROUVER
extension SessionDetailView {
    
    var meetingPointSection: some View {
        
        HStack(spacing: 16) {
            
            VStack(alignment: .leading, spacing: 10) {
                
                Text("Où se retrouver ?")
                    .font(.headline)
                
                Text("Parking sud de la plage, près du poste de secours")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button {
                    openInMaps()
                } label: {
                    HStack(spacing: 6) {
                           
                        Text("Voir sur la carte")
                        
                        Image(systemName: "location.fill")
                           
                           
                       }
                       .font(.caption.weight(.semibold))
                       .foregroundColor(AppColors.action)
                }
            }
            
            Spacer()
            
            MapSnapshotImageView(
                latitude: vm.session.latitude,
                longitude: vm.session.longitude,
                width: 92,
                height: 92
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.primary.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.primary.opacity(0.08), lineWidth: 1)
        )
    }
    
    func openInMaps() {
        
        let lat = vm.session.latitude
        let lon = vm.session.longitude
        
        if let url = URL(string: "http://maps.apple.com/?daddr=\(lat),\(lon)") {
            UIApplication.shared.open(url)
        }
    }
}



// CHAT BUTTON
extension SessionDetailView {
    
    var chatButton: some View {
        
        Button {
            
            selectedTab = .community
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                selectedChatId = vm.session.chatId
            }
            
        } label: {
            
            HStack(spacing: 10) {
                
                Image(systemName: "message.fill")
                
                Text("Ouvrir le chat")
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(.top, 8)
            .padding(.bottom, 20)
            
    
        }
        
    }
}


// PARTICIPANTS CARD
struct ParticipantCard: View {
    
    let user: SessionUser
    
    let currentUserId: String
    let isPast: Bool
    let isFriend: Bool
    let isPending: Bool
    
    let onAddFriend: (() -> Void)?

    var isCurrentUser: Bool {
        user.id == currentUserId
    }

    var levelTitle: String {
        
        switch user.level {
            
        case "mousse_1", "mousse_2":
            return "Débutant"
            
        case "bronze_1", "bronze_2":
            return "Intermédiaire"
            
        case "argent_1", "argent_2":
            return "Confirmé"
            
        case "or_1", "or_2":
            return "Expert"
            
        default:
            return "Niveau"
        }
    }
    
    var levelColor: Color {
        
        switch user.level {
            
        case "mousse_1", "mousse_2":
            return Color(hex: "#67D4EA")
            
        case "bronze_1", "bronze_2":
            return Color(hex: "#C98B5B")
            
        case "argent_1", "argent_2":
            return Color(hex: "#90A4B8")
            
        case "or_1", "or_2":
            return Color(hex: "#F4B942")
            
        default:
            return .gray
        }
    }

    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
    
            HStack(alignment: .top, spacing: 20) {
                
                VStack(spacing: 10) {
                    // Avatar
                    ZStack(alignment: .topTrailing) {
                        
                        Circle()
                            .fill(Color.gray.opacity(0.12))
                            .frame(width: 56, height: 56)
                        
                        Text(flag(from: user.nationality))
                            .font(.caption2)
                            .offset(x: 2, y: -2)
                    }
                    
                    // Name
                    HStack(spacing: 4) {
                        
                        Text(user.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .lineLimit(1)
                        
                    }
                    
                    // Level
                    Text(levelTitle)
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(levelColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(levelColor.opacity(0.10))
                        .clipShape(Capsule())
                        .fixedSize()
                }
                .frame(width: 88)
                
                // Colonne board + taille
                VStack(spacing: 10) {
                    
                    ZStack {
                        
                        Image(user.boardType.lowercased())
                            .resizable()
                            .scaledToFit()
                        
                        Image(user.boardType.lowercased())
                            .resizable()
                            .scaledToFit()
                            .colorMultiply(Color(hex: user.boardColor))
                    }
                    .frame(width: 24, height: 82)
                    
                    Text(user.boardSize)
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                }
                .frame(width: 40)
                
               
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            footerView
        }
        .padding(16)
        .frame(width: 185)
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

// FOOTER PARTICIPANT CARD
extension ParticipantCard {
    
    @ViewBuilder
    var footerView: some View {
        
        if isCurrentUser {
            
            footerCapsule(
                icon: "person.fill",
                text: "Tu participes",
                color: .secondary,
                background: Color.black.opacity(0.04)
            )
            
        } else if isFriend {
            
            footerCapsule(
                icon: "checkmark",
                text: "Ami",
                color: .green,
                background: Color.green.opacity(0.08)
            )
            
        } else if isPending {
            
            footerCapsule(
                icon: "paperplane.fill",
                text: "Envoyé",
                color: .gray,
                background: Color.black.opacity(0.04)
            )
            
        } else if isPast {
            
            Button {
                onAddFriend?()
            } label: {
                
                HStack(spacing: 6) {
                    
                    Image(systemName: "plus")
                    
                    Text("Ajouter")
                }
                .font(.caption.weight(.bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 28)
                .background(AppColors.action)
                .clipShape(Capsule())
            }
            
        } else {
            
            footerCapsule(
                icon: "lock.fill",
                text: "Ajouter",
                color: .gray,
                background: Color.black.opacity(0.04)
            )
        }
    }
    
    func footerCapsule(
        icon: String,
        text: String,
        color: Color,
        background: Color
    ) -> some View {
        
        HStack(spacing: 6) {
            
            Image(systemName: icon)
            
            Text(text)
        }
        .font(.caption.weight(.semibold))
        .foregroundColor(color)
        .frame(maxWidth: .infinity)
        .frame(height: 28)
        .background(background)
        .clipShape(Capsule())
    }
}

// DRAPEAU PARTICIPANT CARD
extension ParticipantCard {
    
    func flag(from country: String) -> String {
        country
            .uppercased()
            .unicodeScalars
            .map { 127397 + $0.value }
            .compactMap { UnicodeScalar($0) }
            .map { String($0) }
            .joined()
    }
}
