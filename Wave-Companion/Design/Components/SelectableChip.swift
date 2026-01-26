//
//  SelectableChip.swift
//  Wave-Companion
//
//  Created by John on 26/01/2026.
//

import Foundation
import SwiftUI

struct SelectableChip: View {

    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isSelected ? AppColors.action : Color(.systemGray6))
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
