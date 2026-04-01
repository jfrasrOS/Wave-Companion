//
//  Date.swift
//  Wave-Companion
//
//  Created by John on 19/03/2026.
//

import Foundation

extension Date {
    
    private static let sessionFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
    
    var sessionFormatted: String {
        
        let calendar = Calendar.current
        
        if calendar.isDateInToday(self) {
            Self.sessionFormatter.dateFormat = "'Aujourd’hui à' HH'h'mm"
        } else if calendar.isDateInTomorrow(self) {
            Self.sessionFormatter.dateFormat = "'Demain à' HH'h'mm"
        } else {
            Self.sessionFormatter.dateFormat = "dd MMM 'à' HH'h'mm"
        }
        
        return Self.sessionFormatter.string(from: self)
    }
}
