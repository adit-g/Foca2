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

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else { return nil }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

extension Date: RawRepresentable {
    public var rawValue: String {
        self.timeIntervalSinceReferenceDate.description
    }
    
    public init?(rawValue: String) {
        self = Date(timeIntervalSinceReferenceDate: Double(rawValue) ?? 0.0)
    }
    
    func getComponents(_ components: Set<Calendar.Component>, minutesAhead: Int = 0) -> DateComponents {
        let endDate = self + TimeInterval(minutesAhead * 60)
        return Calendar.current.dateComponents(components, from: endDate)
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

public extension URL {
    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}

extension DeviceActivityName {
    static let focusSessions = Self("focusSessions")
    static let breaks = Self("breaks")
    
    static let day1 = Self("day1")
    static let day2 = Self("day2")
    static let day3 = Self("day3")
    static let day4 = Self("day4")
    static let day5 = Self("day5")
    static let day6 = Self("day6")
    static let day7 = Self("day7")
    
    static let dayNames : [DeviceActivityName] = [.day1, .day2, .day3, .day4, .day5, .day6, .day7]
}

extension ManagedSettingsStore.Name {
    static let schedule = Self("schedule")
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
