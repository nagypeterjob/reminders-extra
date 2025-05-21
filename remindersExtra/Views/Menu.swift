//
//  MenuView.swift
//  remindersExtra
//
//  Created by Nagy Peter on 2025. 05. 07..
//

import SwiftUI
import EventKit

struct MenuContent: View {
    @AppStorage("showCompleted")
        var showCompleted = false
    @State private var isShowingPopover = false

    @Environment(ReminderStore.self)
        var store: ReminderStore
    var body: some View {
        VStack {
            header
            content
        }
    }

    private var header: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Reminders")
                        .font(.system(size: 13, weight: .semibold))
                    Text(showCompleted ? "Displaying completed" : "Hiding completed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                HStack(alignment: .center, spacing: 15) {
                    Button {
                        self.isShowingPopover.toggle()
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 21))
                    }
                    .buttonStyle(.borderless)
                    .popover(isPresented: $isShowingPopover) {
                        PopoverContent(list: store.items.keys.sorted { $0.title < $1.title })
                    }
                    Toggle("", isOn: $showCompleted)
                        .toggleStyle(ExtensionToggleStyle())
                }
            }
            .padding(.top, 12)
            .padding(.horizontal, 12)
            .padding(.bottom, 3)
            Divider()
        }
        .onDisappear {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                self.isShowingPopover = false
            }
        }
    }

    private var content: some View {
        VStack {
            Spacer()
            VStack(spacing: 5) {
                ScrollView {
                    if !store.items.isEmpty {
                        ForEach(Array(store.items.keys.sorted { $0.title < $1.title }.enumerated()), id: \.offset) { _, calendar in
                            CollapsableList(
                                calendar: calendar,
                                items: store.items,
                                showCompleted: showCompleted)
                        }
                    } else {
                        Spacer()
                        HStack(alignment: .center, spacing: 10) {
                            Spacer()
                            Image(systemName: "shippingbox.fill")
                            Text("Reminders will appear here")
                            Spacer()
                        }
                        .font(.title2)
                        Spacer()
                    }
                }
                .scrollIndicators(.never)
            }
            Spacer()
        }
    }
}

#Preview {
    MenuContent(showCompleted: true).environment(ReminderStore())
}
