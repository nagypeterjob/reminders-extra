//
//  Reminder.swift
//  remindersExtra
//
//  Created by Nagy Peter on 2025. 05. 07..
//

import Foundation
import EventKit

typealias Reminders = [EKCalendar: [Reminder]]

struct Reminder: Equatable, Identifiable, Hashable {
    let id: String
    var title: String
    var dueDate: Date
    var notes: String?
    var isComplete: Bool
    var repeatFrequency: EKRecurrenceFrequency?
    var repeatInterval: Int?
    var priority: Int
    var highPriority: Bool {
        (1...4).contains(priority)
    }

    var expired: Bool {
        dueDate < Date.now
    }

    var frequency: String? {
        guard let freq = repeatFrequency, let interval = repeatInterval else {
            return nil
        }

        let singular: String
        let plural: String

        switch freq {
        case .daily:
            singular = "daily"
            plural = "days"
        case .weekly:
            singular = "weekly"
            plural = "weeks"
        case .monthly:
            singular = "monthly"
            plural = "months"
        case .yearly:
            singular = "yearly"
            plural = "years"
        @unknown default:
            return nil
        }

        if interval > 1 {
            return "every \(interval) \(plural)"
        } else {
            return singular
        }
    }

    init(title: String, dueDate: Date, notes: String? = nil) {
        self.id = UUID().uuidString
        self.title = title
        self.dueDate = dueDate
        self.notes = notes
        self.priority = 0
        self.isComplete = false
    }

    init(with ekReminder: EKReminder) throws {
        guard let dueDateComponents = ekReminder.dueDateComponents, let dueDate = dueDateComponents.date else {
            throw ReminderError.reminderHasNoDueDate
        }

        id = ekReminder.calendarItemIdentifier
        title = ekReminder.title
        self.dueDate = dueDate
        notes = ekReminder.notes
        isComplete = ekReminder.isCompleted
        priority = ekReminder.priority
        repeatFrequency = ekReminder.recurrenceRules?.first?.frequency
        repeatInterval = ekReminder.recurrenceRules?.first?.interval
    }
}

func sortByTitleAsc(a: EKCalendar, b: EKCalendar) -> Bool {
    return a.title < b.title
}
