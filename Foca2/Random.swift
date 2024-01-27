//
//  Random.swift
//  Foca2
//
//  Created by Adit G on 11/29/23.
//

import SwiftUI
import DeviceActivity
import ManagedSettings

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

extension DeviceActivityName {
    static let focusSessions = Self("focusSessions")
}

extension ManagedSettingsStore.Name {
    static let schedule = Self("schedule")
}

extension Date {
    func getComponents(_ components: Set<Calendar.Component>, minutesAhead: Int = 0) -> DateComponents {
        let endDate = self + TimeInterval(minutesAhead * 60)
        return Calendar.current.dateComponents(components, from: endDate)
    }
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

extension UIScreen {
    static let height = UIScreen.main.bounds.height
    static let width = UIScreen.main.bounds.width
}
