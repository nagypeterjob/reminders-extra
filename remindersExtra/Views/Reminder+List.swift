//
//  Reminder+List.swift
//  remindersExtra
//
//  Created by Nagy Peter on 2025. 05. 12..
//

import SwiftUI
import EventKit

struct ReminderList: View {
    let reminders: [Reminder]
    let showCompleted: Bool

    var body: some View {
        VStack(spacing: 0) {
            ForEach(filteredReminders, id: \.id) { reminder in
                ReminderButton(reminder: reminder)
                    .font(.system(size: 13))
                if filteredReminders.last != reminder {
                    Divider()
                }
            }
        }
    }

    private var filteredReminders: [Reminder] {
        reminders.filter { showCompleted || !$0.isComplete }
    }
}
