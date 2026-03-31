//
//  CommunityView.swift
//  Wave-Companion
//
//  Created by John on 31/03/2026.
//

import SwiftUI

struct CommunityView: View {
    
    @Binding var selectedTab: TabItem
    @Binding var selectedChatId: String?
    
    @State private var path: [String] = []
    @StateObject private var vm = ChatListViewModel()
    
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
        }
    }
}

extension CommunityView {
    
    var chatList: some View {
        List {
            ForEach(vm.chats) { chat in
                Button {
                    path.append(chat.id)
                } label: {
                    ChatRowView(chat: chat)
                }
            }
        }
        .listStyle(.plain)
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
    
    var body: some View {
        HStack(spacing: 12) {
            
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text("Session")
                    .font(.headline)
                
                Text(chat.lastMessage ?? "Aucun message")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if let date = chat.lastMessageDate {
                Text(date.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}
