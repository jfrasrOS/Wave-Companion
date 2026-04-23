import SwiftUI

struct SessionDetailView: View {
    
    @StateObject var vm: SessionDetailViewModel
    @Binding var selectedTab: TabItem
    @Binding var selectedChatId: String?
    
    var isPast: Bool {
        vm.session.date < Date()
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                header
                
                participantsSection
                
                conditionsSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Session")
        .navigationBarTitleDisplayMode(.inline)
        
        .safeAreaInset(edge: .bottom) {
            chatButton
        }
    }
}

// Header
extension SessionDetailView {
    
    var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            Text(vm.session.spotName)
                .font(.title2.bold())
            
            Text(vm.session.date.sessionFormatted)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// Participants
extension SessionDetailView {
    
    var participantsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack {
                Text("Participants")
                    .font(.headline)
                
                Spacer()
                
                Text("\(vm.participants.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    
                    ForEach(vm.participants) { user in
                        ParticipantCard(
                            user: user,
                            isPast: isPast,
                            currentUserId: vm.currentUserId,
                            isFriend: vm.currentUserFriends.contains(user.id),
                            isPending: vm.sentRequests.contains(user.id),
                            onAddFriend: {
                                vm.sendFriendRequest(to: user.id)
                            }
                        )
                    }
                }
            }
        }
    }
}

// Conditions météo
extension SessionDetailView {
    
    var conditionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Conditions")
                .font(.headline)
            
            HStack(spacing: 8) {
                conditionChip("1.2m")
                conditionChip("Offshore")
                conditionChip("12s")
            }
        }
    }
    
    func conditionChip(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }
}

// Bouton vers le chat session
extension SessionDetailView {
    
    var chatButton: some View {
        Button {
            selectedTab = .community
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                selectedChatId = vm.session.chatId
            }
            
        } label: {
            Text("Ouvrir le chat")
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.primary)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 8)
        }
        .background(.ultraThinMaterial)
    }
}

// Participants card
struct ParticipantCard: View {
    
    let user: SessionUser
    let isPast: Bool
    let currentUserId: String
    let isFriend: Bool
    let isPending: Bool
    let onAddFriend: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 10) {
            
            // Avatar + flag
            ZStack(alignment: .topTrailing) {
                
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Text(flag(from: user.nationality))
                    .font(.caption2)
                    .padding(3)
                    .background(.white)
                    .clipShape(Circle())
                    .offset(x: 4, y: -4)
            }
            
            Text(user.name)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
            
            // Board
            ZStack {
                Image(user.boardType.lowercased())
                    .resizable()
                    .scaledToFit()
                
                Image(user.boardType.lowercased())
                    .resizable()
                    .scaledToFit()
                    .colorMultiply(Color(hex: user.boardColor))
            }
            .frame(width: 45, height: 30)
            
            Text("\(user.boardSize) • \(user.boardType)")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // Logique ami/envoyé/ajouter
            if isPast && user.id != currentUserId {
                
                if isFriend {
                    Text("Ami")
                        .font(.caption2.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.green.opacity(0.2))
                        .clipShape(Capsule())
                    
                } else if isPending {
                    Text("Envoyé")
                        .font(.caption2.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Capsule())
                    
                } else {
                    Button("Ajouter") {
                        onAddFriend?()
                    }
                    .font(.caption2.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppColors.action)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
            }
        }
        .frame(width: 110)
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 6)
    }
    
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
