//
//  Collapsable+List.swift
//  remindersExtra
//
//  Created by Nagy Peter on 2025. 05. 10..
//

import SwiftUI
import EventKit

struct CollapsableList: View {
    let calendar: EKCalendar
    let items: Reminders
    let showCompleted: Bool
    @State private var expanded: Bool = false

    var body: some View {
        let visibleCount = items[calendar]?.filter { showCompleted || !$0.isComplete }.count ?? 0
        VStack {
            DisclosureGroup(
                isExpanded: $expanded,
                content: {
                    if visibleCount != 0 {
                        ReminderList(
                            reminders: items[calendar] ?? [],
                            showCompleted: showCompleted
                        )
                        .background(.fill.opacity(0.5))
                        .padding(.top, expanded ? 1 : 0)
                    }
                },
                label: {
                    CalendarListButton(
                        title: calendar.title,
                        color: calendar.color,
                        count: visibleCount)
                }
            )
            .disabled(visibleCount == 0)
            .disclosureGroupStyle(PlainDisclosureStyle(calendarId: calendar.calendarIdentifier))
            .padding(.bottom, 1)
            .onChange(of: showCompleted) { _, newVal in
                if !newVal {
                    expanded = false
                }
            }
        }
        .onAppear {
            expanded = UserDefaults.standard.bool(forKey: "collapsible-expanded-\(calendar.calendarIdentifier)")
        }
    }
}

struct PlainDisclosureStyle: DisclosureGroupStyle {
    var calendarId: String
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Button {
                withAnimation {
                    configuration.isExpanded.toggle()
                    UserDefaults.standard.set(configuration.isExpanded, forKey: "collapsible-expanded-\(calendarId)")
                }
            } label: {
                configuration.label
            }
            .buttonStyle(HighlightButtonStyle())
            if configuration.isExpanded {
                configuration.content
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.easeInOut, value: configuration.isExpanded)
            }
        }
    }
}

struct HighlightButtonStyle: ButtonStyle {
    @State private var withHover = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background {
                if withHover {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(.fill.opacity(0.5))
                        .padding(.horizontal, 6)
                        .transition(.opacity.animation(.easeInOut(duration: 0.1)))
                }
            }
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.1)) {
                    withHover = hovering
                }
            }
    }
}
