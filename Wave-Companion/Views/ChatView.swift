import SwiftUI
import FirebaseAuth

struct ChatView: View {
    
    @StateObject private var vm: ChatViewModel
    @State private var scrollProxy: ScrollViewProxy?
    
    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    init(chatId: String) {
        _vm = StateObject(wrappedValue: ChatViewModel(chatId: chatId))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        
                        ForEach(messageRows) { row in
                            MessageBubble(
                                message: row.message,
                                isMe: row.isMe,
                                showAvatar: row.showAvatar,
                                senderName: row.senderName
                            )
                            .id(row.id)
                        }
                    }
                    .padding(.vertical)
                }
                .background(Color(.systemGroupedBackground))
                .onAppear {
                    scrollProxy = proxy
                }
                .onChange(of: vm.messages.count) { _, _ in
                    scrollToBottom()
                }
            }
            
            inputBar
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Input
extension ChatView {
    
    var inputBar: some View {
        HStack(spacing: 10) {
            
            TextField("Écrire un message...", text: $vm.text)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(20)
            
            Button {
                Task { await vm.sendMessage() }
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(vm.text.isEmpty ? Color.gray : AppColors.action)
                    )
            }
            .disabled(vm.text.trimmingCharacters(in: .whitespaces).isEmpty)
            .animation(.easeInOut(duration: 0.2), value: vm.text.isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }
}

// Auto scroll
extension ChatView {
    
    func scrollToBottom() {
        guard let last = vm.messages.last else { return }
        
        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 0.25)) {
                scrollProxy?.scrollTo(last.id, anchor: .bottom)
            }
        }
    }
}

// Messages
extension ChatView {
    
    struct MessageBubble: View {
        
        let message: Message
        let isMe: Bool
        let showAvatar: Bool
        let senderName: String
        
        var body: some View {
            HStack(alignment: .bottom, spacing: 8) {
                
                if !isMe {
                    if showAvatar {
                        avatar
                    } else {
                        Spacer().frame(width: 32)
                    }
                }
                
                VStack(alignment: isMe ? .trailing : .leading, spacing: 4) {
                    
                    if !isMe && showAvatar {
                        Text(senderName)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(message.text)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(bubbleColor)
                        .foregroundColor(isMe ? .white : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                
                if isMe {
                    if showAvatar {
                        avatar
                    } else {
                        Spacer().frame(width: 32)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: isMe ? .trailing : .leading)
            .padding(.horizontal)
        }
        
        var bubbleColor: Color {
            isMe ? AppColors.action : Color(.systemGray5)
        }
        
        var avatar: some View {
            Circle()
                .fill(isMe ? AppColors.action.opacity(0.3) : Color.gray.opacity(0.3))
                .frame(width: 32, height: 32)
        }
    }
    
   
    
    struct MessageRowData: Identifiable {
        let id: String
        let message: Message
        let isMe: Bool
        let showAvatar: Bool
        let senderName: String
    }
    
    var messageRows: [MessageRowData] {
        
        let currentUserId = Auth.auth().currentUser?.uid
        
        return vm.messages.enumerated().map { index, message in
            
            let isMe = message.senderId == currentUserId
            
            // Grouping (même user -> pas d'avatar)
            let previous = index > 0 ? vm.messages[index - 1] : nil
            let showAvatar = previous?.senderId != message.senderId
            
            let senderName = vm.users[message.senderId] ?? "Surfeur"
            
            return MessageRowData(
                id: message.id,
                message: message,
                isMe: isMe,
                showAvatar: showAvatar,
                senderName: senderName
            )
        }
    }
}
