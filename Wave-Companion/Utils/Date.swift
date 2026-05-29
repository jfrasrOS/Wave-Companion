//
//  Date.swift
//  Wave-Companion
//

import Foundation

extension Date {

    private static let sessionFormatter: DateFormatter = {

        let formatter = DateFormatter()

        formatter.locale = Locale(identifier: "fr_FR")

        return formatter
    }()

    // Format session
    var sessionFormatted: String {

        let calendar = Calendar.current

        if calendar.isDateInToday(self) {

            Self.sessionFormatter.dateFormat =
                "'Aujourd’hui à' HH'h'mm"

        } else if calendar.isDateInTomorrow(self) {

            Self.sessionFormatter.dateFormat =
                "'Demain à' HH'h'mm"

        } else {

            Self.sessionFormatter.dateFormat =
                "dd MMM 'à' HH'h'mm"
        }

        return Self.sessionFormatter.string(from: self)
    }

    // Minimum autorisé : maintenant + 30 min
    func minimumSessionDate() -> Date {

        let calendar = Calendar.current

        let plus30 = calendar.date(
            byAdding: .minute,
            value: 30,
            to: self
        )!

        let minutes = calendar.component(
            .minute,
            from: plus30
        )

        let remainder = minutes % 15

        let add =
            remainder == 0
            ? 0
            : 15 - remainder

        let rounded = calendar.date(
            byAdding: .minute,
            value: add,
            to: plus30
        )!

        var comps = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: rounded
        )

        comps.second = 0
        comps.nanosecond = 0

        return calendar.date(from: comps)!
    }

    // Maximum autorisé : J+7
    func maximumSessionDate() -> Date {

        Calendar.current.date(
            byAdding: .day,
            value: 7,
            to: minimumSessionDate()
        )!
    }

    // Arrondi au quart d’heure supérieur
    func roundedUpToQuarterHour() -> Date {

        let calendar = Calendar.current

        let minutes = calendar.component(
            .minute,
            from: self
        )

        let remainder = minutes % 15

        let add =
            remainder == 0
            ? 0
            : 15 - remainder

        let rounded = calendar.date(
            byAdding: .minute,
            value: add,
            to: self
        )!

        return calendar.date(
            bySetting: .second,
            value: 0,
            of: rounded
        )!
    }

    // Format card premium
    var formattedDateCard: String {

        let formatter = DateFormatter()

        formatter.locale = Locale(identifier: "fr_FR")

        formatter.dateFormat =
            "EEEE d MMM • HH:mm"

        return formatter.string(from: self)
    }
}
