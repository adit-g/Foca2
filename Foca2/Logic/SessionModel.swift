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
    @Published var tokens: FamilyActivitySelection
    let managedStore = ManagedSettingsStore(named: .schedule)
    let dac = DeviceActivityCenter()

    @AppStorage("FSEndTime") var fsEndTime = Date()
    
    @AppStorage("SSFromTime") var ssFromTime = Date()
    @AppStorage("SSToTime") var ssToTime = Date() + 3600
    @AppStorage("SSEnabled") var ssEnabled = false
    @AppStorage("SSDaysEnabled")
    var daysEnabled = [false, true, true, true, true, true, false]
    
    public var ssFromTimeComps: DateComponents {
        Calendar.current.dateComponents([.hour, .minute, .second], from: ssFromTime)
    }
    
    public var ssToTimeComps: DateComponents {
        Calendar.current.dateComponents([.hour, .minute, .second], from: ssToTime)
    }
    
    public var ssFromDate: Date {
        Calendar.current.date(
            bySettingHour: ssFromTimeComps.hour!,
            minute: ssFromTimeComps.minute!,
            second: ssFromTimeComps.second!,
            of: Date()
        )!
    }
    
    public var ssToDate: Date {
        Calendar.current.nextDate(
            after: ssFromDate,
            matching: ssToTimeComps,
            matchingPolicy: .nextTime
        )!
    }
    
    init() {
        self.tokens = SessionModel.loadTokens()
        updateStatus()
    }
    
    public func scheduleSS() {
        var ignoredDays: [DeviceActivityName] = []
        for i in 0...6 {
            if !daysEnabled[i] {
                ignoredDays.append(DeviceActivityName.dayNames[i])
                continue
            }
            var beginComp = ssFromTimeComps
            beginComp.setValue(i+1, for: .weekday)
            var endComp = ssToTimeComps
            endComp.setValue(isSessionOvernight() ? (i+1)%7+1 : i+1, for: .weekday)
            try! dac.startMonitoring(
                .dayNames[i],
                during: DeviceActivitySchedule(
                    intervalStart: beginComp,
                    intervalEnd: endComp,
                    repeats: true
                )
            )
        }
        ssEnabled = true
        dac.stopMonitoring(ignoredDays)
        updateStatus()
    }
    
    public func cancelSS() {
        ssEnabled = false
        dac.stopMonitoring(DeviceActivityName.dayNames)
        updateStatus()
    }
    
    public func isSessionOvernight() -> Bool {
        (ssFromTimeComps.hour! == ssToTimeComps.hour!) ?
            (ssFromTimeComps.minute! >= ssToTimeComps.minute!) :
            (ssFromTimeComps.hour! > ssToTimeComps.hour!)
    }
    
    public func updateStatus() {
        let now = Date()
        let weekday = Calendar.current.dateComponents([.weekday], from: now).weekday!
        if now.compare(fsEndTime) == .orderedAscending {
            UserDefaults(suiteName: "group.sharedCode1234")!.set(ScreenTimeStatus.session.rawValue, forKey: "status")
        } else if ssEnabled
                    && daysEnabled[weekday-1]
                    && now.compare(ssFromDate) == .orderedDescending
                    && now.compare(ssToDate) == .orderedAscending {
            UserDefaults(suiteName: "group.sharedCode1234")!.set(ScreenTimeStatus.scheduledSession.rawValue, forKey: "status")
        } else {
            UserDefaults(suiteName: "group.sharedCode1234")!.set(ScreenTimeStatus.noSession.rawValue, forKey: "status")
        }
    }
    
    public func startFS(minutes: Int) {
        let now = Date()
        let beginTimeComps = now.getComponents([.hour, .minute, .second], minutesAhead: -15)
        let endDate = now + TimeInterval(minutes * 60)
        let endTimeComps = Calendar.current.dateComponents([.hour, .minute, .second], from: endDate)
        
        fsEndTime = endDate
        try! dac.startMonitoring(.focusSessions, during: DeviceActivitySchedule(
            intervalStart: beginTimeComps,
            intervalEnd: endTimeComps,
            repeats: false)
        )
        updateStatus()
    }
    
    public func endFS() {
        dac.stopMonitoring([.focusSessions])
        fsEndTime = Date()
        updateStatus()
    }
    
    public static func loadTokens() -> FamilyActivitySelection {
        let documentsDirectory = FileManager().containerURL(forSecurityApplicationGroupIdentifier: "group.sharedCode1234")
        guard let archiveURL = documentsDirectory?.appendingPathComponent("tokens.data") else { return FamilyActivitySelection() }
        guard let codeData = try? Data(contentsOf: archiveURL) else { return FamilyActivitySelection() }

        let decoder = JSONDecoder()
        let loadedData = (try? decoder.decode(FamilyActivitySelection.self, from: codeData))
        
        return loadedData ?? FamilyActivitySelection()
    }
    
    public func saveTokens() {
        let documentsDirectory = FileManager().containerURL(forSecurityApplicationGroupIdentifier: "group.sharedCode1234")
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
}

enum ScreenTimeStatus: Int {
    case noSession, session, scheduledSession
    
    var buttonTitle: String {
        switch self {
        case .noSession:
            return "Start Focus Session"
        case .scheduledSession:
            return "Cancel"
//        case .onBreak:
//            return "End Break"
        case .session:
            return "End Focus Session"
        }
    }
}
