//
//  remindersExtra.swift
//  remindersExtra
//
//  Created by Nagy Peter on 2025. 05. 07..
//

import SwiftUI
import EventKit

@main
struct RemindersExtraApp: App {
    @State private var reminderStore = ReminderStore()

    var body: some Scene {
        MenuBarExtra {
            MenuContent()
                .task {
                    do {
                        try await self.reminderStore.requestAccess()
                        try await self.reminderStore.fetchAll()
                    } catch {
                        logger.log(level: .error, "initial reminder fetch: \(error.localizedDescription)")
                    }
                }
                .environment(reminderStore)
        } label: {
            let image: NSImage = {
                let ratio = $0.size.height / $0.size.width
                $0.size.height = 18
                $0.size.width = 18 / ratio
                return $0
            }(NSImage(imageLiteralResourceName: "AppIcon"))
            Image(nsImage: image)
                .grayscale(0.99)
        }
        .menuBarExtraStyle(.window)
    }
}
