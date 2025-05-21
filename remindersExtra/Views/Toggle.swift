//
//  Toggle.swift
//  remindersExtra
//
//  Created by Nagy Peter on 2025. 05. 15..
//

import SwiftUI

struct ExtensionToggleStyle: ToggleStyle {
    private let animation = Animation.linear(duration: 0.1)

    func makeBody(configuration: Configuration) -> some View {
        Rectangle()
            .foregroundColor(configuration.isOn ? .blue : .gray)
            .frame(width: 40, height: 22)
            .cornerRadius(11)
            .overlay(
                Circle()
                    .foregroundColor(.white)
                    .padding(3)
                    .offset(x: configuration.isOn ? 8 : -8)
                    .animation(animation, value: configuration.isOn)
            )
            .onTapGesture { configuration.isOn.toggle() }
    }
}
