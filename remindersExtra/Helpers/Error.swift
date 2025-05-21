//
//  Error.swift
//  remindersExtra
//
//  Created by Nagy Peter on 2025. 05. 07..
//

import Foundation

enum ReminderError: LocalizedError {
    case reminderHasNoDueDate
    case accessDenied
    case accessRestricted
    case unknown
    case failedReadingReminders
    case failedReadingReminderWithIdentifier(String)

    var errorDescription: String? {
    switch self {
        case .failedReadingReminders:
            return NSLocalizedString("Failed to read reminders.", comment: "failed to read reminders error description")
        case .failedReadingReminderWithIdentifier(let identifier):
            return NSLocalizedString(
                "Failed to read reminder with identifier '\(identifier)'.",
                comment: "failed to read reminder with identifier error description")
        case .accessDenied:
            return NSLocalizedString(
                "The app doesn't have permission to read reminders.",
                comment: "access denied error description")
        case .accessRestricted:
        return NSLocalizedString(
            "This device doesn't allow access to reminders.",
            comment: "access restricted error description")
        case .reminderHasNoDueDate:
            return NSLocalizedString(
                "A reminder has no due date.", comment: "reminder has no due date error description")
        case .unknown:
            return NSLocalizedString("An unknown error occurred.", comment: "unknown error description")
        }
    }
}
