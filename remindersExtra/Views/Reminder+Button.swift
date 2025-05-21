//
//  Reminder+Button.swift
//  remindersExtra
//
//  Created by Nagy Peter on 2025. 05. 13..
//

import SwiftUI

struct ReminderButton: View {
    let reminder: Reminder
    @State private var withHover = false
    @State private var selected = false

    @Environment(ReminderStore.self)
        var store: ReminderStore
    @Environment(\.colorScheme)
        private var colorScheme

    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            Rectangle()
                .fill(reminder.expired && !reminder.isComplete ? .pink : .clear)
                .frame(width: 3)
            Image(systemName: selected || reminder.isComplete ? "inset.filled.circle" : "circle")
                .foregroundStyle(colorScheme == .light && reminder.highPriority ?
                .white.opacity(withHover ? 1.0 : 0.6) : .secondary.opacity(withHover ? 1.0 : 0.6))
            VStack(alignment: .leading) {
                Spacer()
                Text(reminder.title)
                    .foregroundStyle(colorScheme == .light && reminder.highPriority ? .white : .primary)
                HStack {
                    Text(reminder.dueDate.formatted())
                    if reminder.repeatInterval != nil {
                        Image(systemName: "repeat")
                        Text(reminder.frequency ?? "")
                    }
                }
                .font(.caption)
                .foregroundStyle(colorScheme == .light && reminder.highPriority ? .white : .secondary)
                Spacer()
            }
            Spacer()
        }
        .background(reminder.highPriority ? .indigo : .clear)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                withHover = hovering
            }
        }
        .onTapGesture {
            withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.5, blendDuration: 0)) {
                selected.toggle()
            }
            if selected {
                Task {
                    try? await store.saveReminder(reminder)
                }
            }
        }
    }
}
