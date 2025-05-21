//
//  Date.swift
//  remindersExtra
//
//  Created by Nagy Peter on 2025. 05. 20..
//

import Foundation

extension Date {
    static func fromString(_ format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd."
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: format)
    }
}
