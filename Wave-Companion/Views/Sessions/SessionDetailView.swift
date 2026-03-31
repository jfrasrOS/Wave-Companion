//
//  SessionDetailView.swift
//  Wave-Companion
//
//  Created by John on 24/03/2026.
//

import SwiftUI

struct SessionDetailView: View {
    
    @StateObject var vm: SessionDetailViewModel
    @Binding var selectedTab: TabItem
    @Binding var selectedChatId: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                header
                
                conditionsCard
                
                participantsSection
            }
            .padding()
            Button {
                selectedChatId = vm.session.chatId
                selectedTab = .community
            } label: {
                Text("Ouvrir le chat")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Session")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension SessionDetailView {
    
    var header: some View {
        ZStack(alignment: .bottomLeading) {
            
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.2)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 180)
            
            VStack(alignment: .leading, spacing: 6) {
                
                Text(vm.session.spotName)
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Text(vm.session.date.sessionFormatted)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
        }
    }
}

extension SessionDetailView {
    
    var conditionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Conditions")
                .font(.headline)
            
            HStack(spacing: 20) {
                
                conditionItem(icon: "water.waves", value: "1.2m", label: "Houle")
                conditionItem(icon: "wind", value: "Offshore", label: "Vent")
                conditionItem(icon: "clock", value: "12s", label: "Période")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
    }
    
    func conditionItem(icon: String, value: String, label: String) -> some View {
        VStack {
            Image(systemName: icon)
            Text(value).bold()
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

extension SessionDetailView {
    
    var participantsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Participants")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    
                    ForEach(vm.participants) { user in
                        ParticipantCard(user: user)
                    }
                }
            }
        }
    }
}

struct ParticipantCard: View {
    
    let user: SessionUser
    
    var body: some View {
        VStack(spacing: 8) {
            
            ZStack(alignment: .topLeading) {
                
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 70, height: 70)
                
                Text(flag(from: user.nationality))
                    .font(.caption)
                    .padding(4)
                    .background(Color.white)
                    .clipShape(Circle())
                    .offset(x: -6, y: -6)
            }
            
            Text(user.name)
                .font(.caption)
            
            VStack(spacing: 4) {

                ZStack {
                    Image(user.boardType.lowercased())
                        .resizable()
                        .scaledToFit()

                    Image(user.boardType.lowercased())
                        .resizable()
                        .scaledToFit()
                        .colorMultiply(Color(hex: user.boardColor))
                }
                .frame(width: 50, height: 40)

                Text(user.boardSize)
                    .font(.caption2.bold())

                Text(user.boardType)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(6)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .frame(width: 90)
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
