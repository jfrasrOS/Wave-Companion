//
//  CommunityView.swift
//  Wave-Companion
//
//  Created by John on 31/03/2026.
//

import SwiftUI
import FirebaseFirestore

struct CommunityView: View {
    
    @Binding var selectedTab: TabItem
    @Binding var selectedChatId: String?
    
    @State private var path: [String] = []
    @StateObject private var vm = ChatListViewModel()
    @StateObject private var friendsVM = FriendsViewModel()
    
    var body: some View {
        
        NavigationStack(path: $path) {
            
            VStack {
                
                if vm.chats.isEmpty {
                    emptyState
                } else {
                    chatList
                }
            }
            .navigationDestination(for: String.self) { chatId in
                ChatView(chatId: chatId)
            }
        }
        
        // Ouvre automatiquement chat
        .onChange(of: selectedChatId) { _, chatId in
            guard let chatId else { return }

            if !path.contains(chatId) {
                path.append(chatId)
            }

            selectedChatId = nil
        }
        
        .onAppear {
            vm.listenChats()
            friendsVM.listenRequests()
            friendsVM.listenFriends()
        }
    }
}

extension CommunityView {
    
    var chatList: some View {
        List {
            
            // Section Chats actifs
            if !vm.activeChats.isEmpty {
                Section("Chats actifs") {
                    ForEach(vm.activeChats) { chat in
                        Button {
                            path.append(chat.id)
                        } label: {
                            ChatRowView(chat: chat, isExpired: false)
                        }
                    }
                }
            }
            
            // Section Historique
            if !vm.pastChats.isEmpty {
                Section("Historique") {
                    ForEach(vm.pastChats.prefix(10)) { chat in
                        Button {
                            path.append(chat.id)
                        } label: {
                            ChatRowView(chat: chat, isExpired: true)
                        }
                    }
                }
            }
            // Section Amis
            Section("Amis") {
                
                // Demandes reçus
                if !friendsVM.requests.isEmpty {
                    
                    ForEach(friendsVM.requests) { request in
                        
                        if let requestId = request.id {
                            
                            FriendRequestRow(request: request) {
                                Task {
                                    try? await FriendService.shared.acceptRequest(
                                        requestId: requestId,
                                        from: request.from
                                    )
                                }
                            } onReject: {
                                Task {
                                    try? await FriendService.shared.rejectRequest(
                                        requestId: requestId
                                    )
                                }
                            }
                        }
                    }
                }
                
                // Liste des amis
                if friendsVM.friends.isEmpty && friendsVM.requests.isEmpty {
                    Text("Aucun ami pour le moment")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(friendsVM.friends) { user in
                        FriendRow(user: user)
                    }
                }
            }
            
        }
        .listStyle(.insetGrouped)
    }
    
}

extension CommunityView {
    
    var emptyState: some View {
        VStack(spacing: 16) {
            
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("Aucune conversation")
                .font(.headline)
            
            Text("Rejoins une session pour discuter avec les participants")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct ChatRowView: View {
    
    let chat: Chat
    let isExpired: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            
            // Avatar groupe
            Circle()
                .fill(isExpired ? Color.gray.opacity(0.2) : AppColors.primary.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "waveform.path.ecg")
                        .foregroundColor(isExpired ? .gray : AppColors.primary)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                
                // NOM SPOT
                Text(chat.spotName ?? "Session")
                    .font(.headline)
                    .foregroundColor(isExpired ? .gray : .primary)
                
                // DATE + HEURE
                if let date = chat.sessionDate {
                    VStack(alignment: .leading, spacing: 2) {
                        
                        Text(date.sessionFormatted)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                
                // PARTICIPANTS
                if let count = chat.participantCount {
                    Text("\(count) participants")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // STATUS
            if isExpired {
                Text("Terminé")
                    .font(.caption2)
                    .foregroundColor(.gray)
            } else {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 6)
        .opacity(isExpired ? 0.6 : 1)
    }
}

struct FriendRequestRow: View {
    
    let request: FriendRequest
    let onAccept: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            
            // Avatar
            if let url = request.fromAvatar, !url.isEmpty {
                AsyncImage(url: URL(string: url)) { image in
                    image.resizable()
                } placeholder: {
                    Circle().fill(Color.gray.opacity(0.2))
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
            }
            
            // Texte
            VStack(alignment: .leading, spacing: 2) {
                Text(request.fromName ?? "Surfeur")
                    .font(.subheadline.bold())
                
            }
            
            Spacer()
            
            
            // Actions
            HStack(spacing: 8) {
                
                Button("Refuser") {
                    onReject()
                }
                .font(.caption)
                .foregroundColor(.gray)
                
                Button("Accepter") {
                    onAccept()
                }
                .font(.caption.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppColors.action)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}

struct FriendRow: View {
    
    let user: User
    
    var body: some View {
        HStack(spacing: 12) {
            
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 40, height: 40)
            
            Text(user.name)
                .font(.subheadline)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
