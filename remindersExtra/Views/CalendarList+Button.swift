//
//  CalendarList+Button.swift
//  remindersExtra
//
//  Created by Nagy Peter on 2025. 05. 12..
//

import SwiftUI
import EventKit

struct CalendarListButton: View {
    var title: String
    var color: NSColor
    var count: Int

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(color))
                .frame(width: 8, height: 8)
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
            Spacer()
            Text("\(count)")
                .font(.system(size: 12))
                .monospaced()
                .foregroundStyle(.gray)
        }
        .frame(height: 25)
        .padding(.horizontal, 10)
    }
}
