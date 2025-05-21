//
//  Reminder.swift
//  remindersExtra
//
//  Created by Nagy Peter on 2025. 05. 07..
//

import EventKit
import Foundation
import SwiftUI
import OSLog

@MainActor
@Observable
class ReminderStore {
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storeChanged),
            name: .EKEventStoreChanged,
            object: nil)
    }

    @ObservationIgnored var ekStore = EKEventStore()
    var items: Reminders = [:]

    @ObservationIgnored var isAvailable: Bool {
        EKEventStore.authorizationStatus(for: .reminder) == .fullAccess
    }

    // Trigger the UI prompt for allowing the app Calendar (Reminder) Access
    func requestAccess() async throws {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        switch status {
        case .fullAccess:
            return
        case .restricted, .writeOnly:
            throw ReminderError.accessRestricted
        case .notDetermined:
            let accessGranted = try await ekStore.requestFullAccessToReminders()
            guard accessGranted else {
                throw ReminderError.accessDenied
            }
        case .denied:
            throw ReminderError.accessDenied
        @unknown default:
            throw ReminderError.unknown
        }
    }

    // Fetches all reminders from store & populates a dictionary
    func fetchAll() async throws {
        ekStore.refreshSourcesIfNecessary()
        guard isAvailable else { throw ReminderError.accessDenied }

        let calendars = ekStore.calendars(for: .reminder)
        var reminders = Reminders()
        for calendar in calendars {
            let predicate = ekStore.predicateForReminders(in: [calendar])
            let ekReminders = try await ekStore.fetchReminders(matching: predicate)
            let calReminders: [Reminder] = try ekReminders.compactMap { ekReminder in
                do {
                    return try Reminder(with: ekReminder)
                } catch ReminderError.reminderHasNoDueDate {
                    return nil
                }
            }
            reminders[calendar] = calReminders
        }
        self.items = reminders
    }

    // Persists reminder (completion depends on state), and synchronises local store
    func saveReminder(_ reminder: Reminder) async throws {
        guard let ekReminder = ekStore.calendarItem(withIdentifier: reminder.id) as? EKReminder else {
            return
        }
        ekReminder.isCompleted.toggle()
        try ekStore.save(ekReminder, commit: true)

        try await fetchAll()
    }

    func newReminder(reminder: Reminder, for calendar: EKCalendar?) async throws {
        let ekReminder = EKReminder(eventStore: ekStore)
        ekReminder.title = reminder.title
        ekReminder.priority = reminder.priority
        ekReminder.isCompleted = false
        if calendar != nil {
            ekReminder.calendar = calendar
        }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: reminder.dueDate)
        ekReminder.dueDateComponents = components

        try ekStore.save(ekReminder, commit: true)
        try await fetchAll()
    }

    func defaultCalendar() -> EKCalendar {
        let defaultCalendar = EKCalendar(for: .reminder, eventStore: ekStore)
        defaultCalendar.title = "Reminders"
        defaultCalendar.color = .systemBlue
        let localSource = ekStore.sources.first { $0.sourceType == .local } ?? ekStore.sources.first
        defaultCalendar.source = localSource
        return defaultCalendar
    }

    // Re-fetch reminders when there were changes made in Reminders app
    @objc
    func storeChanged(_ notification: Notification) {
        Task { [weak self] in
            do {
                try await self?.fetchAll()
            } catch {
                logger.log(level: .error, "fetch reminders: \(error.localizedDescription)")
            }
        }
    }
}

extension EKEventStore {
    func fetchReminders(matching predicate: NSPredicate) async throws -> [EKReminder] {
        try await withCheckedThrowingContinuation { continuation in
            fetchReminders(matching: predicate) { reminders in
                if let reminders {
                    continuation.resume(returning: reminders)
                } else {
                    continuation.resume(throwing: ReminderError.failedReadingReminders)
                }
            }
        }
    }
}
