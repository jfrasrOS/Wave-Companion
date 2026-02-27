//
//  TabItem.swift
//  Wave-Companion
//
//  Created by John on 05/02/2026.
//

import SwiftUI

enum TabItem: String, CaseIterable, Identifiable {
    case home
    case discover
    case sessions
    case friends
    case profile

    var id: String { rawValue }

  

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .discover: return "safari.fill"
        case .sessions: return "wave.3.right"
        case .friends: return "person.2.fill"
        case .profile: return "person.crop.circle"
        }
    }
}
