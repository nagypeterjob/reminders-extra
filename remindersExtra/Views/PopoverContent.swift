//
//  PopoverContent.swift
//  remindersExtra
//
//  Created by Nagy Peter on 2025. 05. 19..
//

import SwiftUI
import EventKit

struct PopoverContent: View {
    @State private var title = ""
    @State private var selectionIndex: Int?
    @State private var selectionColor: NSColor?
    @State private var selectionText: String = "Select list..."
    @State private var important: Bool = false
    @State private var date: String = (Calendar.current.date(byAdding: .day, value: 1, to: Date.now) ?? Date.now)
        .formatted(date: .numeric, time: .omitted)
    @State private var selectionHover: Bool = false

    @State private var titleValid: Bool = false
    @State private var dueDateValid: Bool = true
    @State private var calendarValid: Bool = false

    var list: [EKCalendar]

    @Environment(ReminderStore.self)
        var store: ReminderStore
    @Environment(\.dismiss)
        private var dismiss

    var body: some View {
        VStack(alignment: .leading) {
            TextField("Reminder title", text: $title)
                .textFieldStyle(.plain)
                .font(.title)
                .padding([.horizontal, .top])
                .padding(.bottom, 6)
                .onChange(of: title) { _, newVal in
                    if newVal.isEmpty {
                        titleValid = false
                    } else {
                        titleValid = true
                    }
                }
            Divider()
            VStack {
                HStack(alignment: .center) {
                    Text("Due date")
                        .padding(.leading, 6)
                        .fontWeight(.bold)
                    Spacer()
                    TextField("YYYY.MM.DD", text: $date)
                        .textFieldStyle(.plain)
                        .frame(width: 80)
                        .onChange(of: date) {
                            if Date.fromString(date) != nil {
                                dueDateValid = true
                            } else {
                                dueDateValid = false
                            }
                        }
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                HStack {
                    Text("Important")
                        .padding(.leading, 6)
                        .fontWeight(.bold)
                    Spacer()
                    Toggle("", isOn: $important)
                        .toggleStyle(ExtensionToggleStyle())
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
            }
            if !list.isEmpty {
                Divider()
                Menu($selectionText.wrappedValue) {
                    ForEach(Array(list.enumerated()), id: \.offset) { index, calendar in
                        Button {
                            selectionIndex = index
                            selectionText = calendar.title
                            selectionColor = calendar.color
                        } label: {
                            MenuItem(title: calendar.title, color: calendar.color)
                        }
                    }
                }
                .padding(5)
                .menuStyle(.borderlessButton)
                .background(RoundedRectangle(cornerRadius: 5)
                    .frame(height: 30)
                    .foregroundColor(selectionIndex == nil && selectionHover ?
                        .gray.opacity(0.5) : Color(selectionColor ?? .clear)))
                .padding(.horizontal)
                .padding(.vertical, 6)
                .onHover { hover in
                    selectionHover = hover
                }
                .onChange(of: selectionIndex) { _, newVal in
                    if newVal != nil {
                        calendarValid = true
                    } else {
                        calendarValid = false
                    }
                }
            }
            HStack {
                Spacer()
                Button {
                    var reminder = Reminder(title: title, dueDate: Date.fromString(date) ?? Date.now)
                    reminder.priority = important ? 1 : 0

                    var calendar: EKCalendar?
                    if list.isEmpty {
                        calendar = store.defaultCalendar()
                    } else {
                        guard let selectionIndex = selectionIndex else {
                            logger.error("No valid lists were selected")
                            return
                        }
                        calendar = list[selectionIndex]
                    }

                    Task {
                        try await store.newReminder(reminder: reminder, for: calendar)
                    }
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add reminder")
                    }
                }
                .buttonStyle(.borderless)
                .padding([.horizontal, .bottom])
                .tint(.blue)
                .disabled(!titleValid || !dueDateValid || (!list.isEmpty && !calendarValid))
                Spacer()
            }
        }
        .frame(width: 250)
        .onAppear {
            // If there is only one Calendar defined, pre-select it
            if list.count == 1 {
                selectionIndex = 0
                selectionText = list.first?.title ?? "Select list..."
                selectionColor = list.first?.color
            }
        }
    }
}

private struct MenuItem: View {
    var title: String
    var color: NSColor

    var body: some View {
        HStack {
            Image(systemName: "circle.fill")
                .frame(width: 8, height: 8)
                .foregroundStyle(Color(color), .clear)
            Text(title)
        }
    }
}

#Preview {
    PopoverContent(list: [EKCalendar(for: .reminder, eventStore: EKEventStore())])
        .environment(ReminderStore())
}
