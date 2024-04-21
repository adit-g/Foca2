//
//  SessionModel.swift
//  Foca2
//
//  Created by Adit G on 1/25/24.
//

import SwiftUI
import DeviceActivity
import ManagedSettings
import FamilyControls

class SessionModel: ObservableObject {
    @Published var tokens = SessionModel.loadTokens()
    private let managedStore = ManagedSettingsStore(named: .schedule)
    private let dac = DeviceActivityCenter()
    
    @AppStorage("difficulty") var difficultyInt = Difficulty.normal.rawValue
    @AppStorage("appBudget") var appBudget = 3
    
    @AppStorage("breakTimes") var breakTimes: [Date] = []

    @AppStorage("FSEndTime") var fsEndTime = Date()
    @AppStorage("BREndTime") var brEndTime = Date()
    
    @AppStorage("SSFromTime") var ssFromTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
    @AppStorage("SSToTime") var ssToTime = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date())!
    @AppStorage("SSEnabled") var ssEnabled = false
    
    public var ssFromTimeComps: DateComponents {
        var c = Calendar.current.dateComponents([.hour, .minute], from: ssFromTime)
        c.second = 0
        return c
    }
    
    public var ssToTimeComps: DateComponents {
        var c = Calendar.current.dateComponents([.hour, .minute], from: ssToTime)
        c.second = 0
        return c
    }
    
    public static func compareComps(_ comp1: DateComponents, _ comp2: DateComponents) -> ComparisonResult {
        if comp1.hour! == comp2.hour! {
            if comp1.minute! == comp2.minute! {
                return .orderedSame
            } else if comp1.minute! < comp2.minute! {
                return .orderedAscending
            } else {
                return .orderedDescending
            }
        } else {
            if comp1.hour! < comp2.hour! {
                return .orderedAscending
            } else {
                return .orderedDescending
            }
        }
    }
    
    public var inScheduledSession: Bool {
        let nowComps = Calendar.current.dateComponents([.hour, .minute], from: Date())
        switch SessionModel.compareComps(ssFromTimeComps, ssToTimeComps) {
        case .orderedAscending:
            return SessionModel.compareComps(nowComps, ssFromTimeComps) != .orderedAscending && SessionModel.compareComps(nowComps, ssToTimeComps) == .orderedAscending
        case .orderedSame:
            return true
        case .orderedDescending:
            return SessionModel.compareComps(nowComps, ssFromTimeComps) != .orderedAscending || SessionModel.compareComps(nowComps, ssToTimeComps) == .orderedAscending
        }
    }
    
    public func getCurrentWaitTime() -> Int {
        let level = Difficulty(rawValue: difficultyInt) ?? .normal
        let now = Date()
        var wait = 0
        switch level {
        case .normal: wait = 5
        case .timeout:
            wait = 15
            for time in breakTimes {
                if time > now - 60 * 60 {
                    wait += 25
                } else if time > now - 120 * 60 {
                    wait += 20
                } else if time > now - 180 * 60 {
                    wait += 10
                }
            }
            wait = min(120, wait)
        case .deepfocus: wait = .max
        }
        return wait
    }
    
    public func scheduleSS() {
        try! dac.startMonitoring(
            .scheduled,
            during: DeviceActivitySchedule(
                intervalStart: ssFromTimeComps,
                intervalEnd: ssToTimeComps,
                repeats: true)
        )
        ssEnabled = true
    }
    
    public func cancelSS() {
        ssEnabled = false
        updateStatus()
    }
    
    public func isSessionOvernight() -> Bool {
        return SessionModel.compareComps(ssFromTimeComps, ssToTimeComps) != .orderedAscending
    }
    
    public func startBreak(minutes: Int) {
        breakTimes.append(Date() + TimeInterval(minutes*60))
        if breakTimes.count > 10 {
            breakTimes.removeFirst()
        }
        
        let now = Date()
        let beginTimeComps = now.getComponents([.hour, .minute, .second], minutesAhead: -15)
        let endDate = now + TimeInterval(minutes * 60)
        let endTimeComps = Calendar.current.dateComponents([.hour, .minute, .second], from: endDate)
        
        brEndTime = endDate
        try! dac.startMonitoring(
            .breaks,
            during: DeviceActivitySchedule(
                intervalStart: beginTimeComps,
                intervalEnd: endTimeComps,
                repeats: false)
        )
    }
    
    public func endBreak() {
        dac.stopMonitoring([.breaks])
        brEndTime = Date()
    }
    
    public func startFS(minutes: Int) {
        let now = Date()
        let beginTimeComps = now.getComponents([.hour, .minute, .second], minutesAhead: -15)
        let endDate = now + TimeInterval(minutes * 60)
        let endTimeComps = Calendar.current.dateComponents([.hour, .minute, .second], from: endDate)
        
        fsEndTime = endDate
        try! dac.startMonitoring(
            .focusSessions,
            during: DeviceActivitySchedule(
                intervalStart: beginTimeComps,
                intervalEnd: endTimeComps,
                repeats: false)
        )
    }
    
    public func endFS() {
        dac.stopMonitoring([.focusSessions])
        fsEndTime = Date()
    }
    
    public static func loadTokens() -> FamilyActivitySelection {
        let documentsDirectory = FileManager().containerURL(forSecurityApplicationGroupIdentifier: "group.2L6XN9RA4T.focashared")
        guard let archiveURL = documentsDirectory?.appendingPathComponent("tokens.data") else { return FamilyActivitySelection() }
        guard let codeData = try? Data(contentsOf: archiveURL) else { return FamilyActivitySelection() }

        let decoder = JSONDecoder()
        let loadedData = (try? decoder.decode(FamilyActivitySelection.self, from: codeData))
        
        return loadedData ?? FamilyActivitySelection()
    }
    
    public func saveTokens() {
        let documentsDirectory = FileManager().containerURL(forSecurityApplicationGroupIdentifier: "group.2L6XN9RA4T.focashared")
        let archiveURL = documentsDirectory?.appendingPathComponent("tokens.data")
        let encoder = JSONEncoder()
        if let dataToSave = try? encoder.encode(tokens) {
            do {
                try dataToSave.write(to: archiveURL!)
            } catch {
                // TODO: ("Error: Can't save Counters")
                return;
            }
        }
    }
    
    public func getStatus() -> ScreenTimeStatus {
        let now = Date()
        let weekday = Calendar.current.dateComponents([.weekday], from: now).weekday!
        let daysEnabled = UserDefaults(suiteName: "group.2L6XN9RA4T.focashared")!.object(forKey: "SSDaysEnabled") as? [Bool] ?? [false, true, true, true, true, true, false]
        if now.compare(fsEndTime) == .orderedAscending {
            return .session
        } else if now.compare(brEndTime) == .orderedAscending {
            return .onBreak
        } else if ssEnabled
                    && daysEnabled[weekday-1]
                    && inScheduledSession {
            return .scheduledSession
        } else {
            return .noSession
        }
    }
    
    public func updateStatus() {
        let status = getStatus()
        UserDefaults(suiteName: "group.2L6XN9RA4T.focashared")!.set(status.rawValue, forKey: "status")
        
        switch status {
        case .noSession:
            SessionModel.unblockApps()
        case .session:
            SessionModel.blockApps()
        case .scheduledSession:
            SessionModel.blockApps()
        case .onBreak:
            SessionModel.unblockApps()
        }
    }
    
    public static func blockApps() {
        let tokens = SessionModel.loadTokens()
        let managedStore = ManagedSettingsStore(named: .schedule)
        managedStore.shield.applications = .some(tokens.applicationTokens)
        managedStore.shield.webDomains = .some(tokens.webDomainTokens)
        managedStore.shield.applicationCategories = .specific(tokens.categoryTokens)
        managedStore.shield.webDomainCategories = .specific(tokens.categoryTokens)
    }
    
    public static func unblockApps() {
        let managedStore = ManagedSettingsStore(named: .schedule)
        managedStore.clearAllSettings()
    }
}

enum Difficulty: Int {
    case normal, timeout, deepfocus
    
    var name: String {
        switch self {
        case .normal:
            return "Normal"
        case .timeout:
            return "Timeout"
        case .deepfocus:
            return "Deep Focus"
        }
    }
    
    var caption: String {
        switch self {
        case .normal:
            return "You can easily take breaks or cancel this session"
        case .timeout:
            return "There will be increasing delays before you can take a break or cancel"
        case .deepfocus:
            return "You can't take breaks or end the session early"
        }
    }
}

enum ScreenTimeStatus: Int {
    case noSession, session, scheduledSession, onBreak
    
    var buttonTitle: String {
        switch self {
        case .noSession:
            return "Start Focus Session"
        case .scheduledSession:
            return "Take a Break"
        case .onBreak:
            return "End Break"
        case .session:
            return "End Focus Session"
        }
    }
    
    var sessionName: String {
        switch self {
        case .noSession:
            ""
        case .session:
            "Focus Session"
        case .scheduledSession:
            "Scheduled Session"
        case .onBreak:
            "Break"
        }
    }
}
