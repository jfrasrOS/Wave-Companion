//
//  AvatarStackView.swift
//  Wave-Companion
//
//  Created by John on 29/04/2026.
//

import SwiftUI

//AvatarStackView pour  les participants
struct AvatarStackView: View {
    
    let imageURLs: [String]
    private let maxDisplayed = 2
    
    var body: some View {
        
        let displayed = Array(imageURLs.prefix(maxDisplayed))
        let remaining = imageURLs.count - displayed.count
        
        HStack(spacing: -6) {
            
            ForEach(0..<displayed.count, id: \.self) { _ in
                Circle()
                    .fill(Color.gray.opacity(0.25))
                    .frame(width: 26, height: 26)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
            }
            
            // +X utilisateurs
            if remaining > 0 {
                Text("+\(remaining)")
                    .font(.caption2.bold())
                    .frame(width: 26, height: 26)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
            }
        }
    }
}
