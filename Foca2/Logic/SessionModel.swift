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
    private let dac = DeviceActivityCenter()
    
    @AppStorage("status", store: UserDefaults(suiteName: "group.sharedCode1234"))
    private var statusInt: Int = ScreenTimeStatus.noSession.rawValue
    
    public var status: ScreenTimeStatus {
        ScreenTimeStatus(rawValue: statusInt) ?? .noSession
    }
    
    init() {
        let now = Date()
        let weekday = Calendar.current.dateComponents([.weekday], from: now).weekday!
        if sessionEnabled && daysEnabled[weekday-1] {
            if now.compare(todayStartDate) == .orderedAscending && now.compare(nextEndDate) == .orderedDescending {
                statusInt = ScreenTimeStatus.scheduledSession.rawValue
            }
        } else if now.compare(endTime) == .orderedAscending {
            statusInt = ScreenTimeStatus.session.rawValue
        } else {
            statusInt = ScreenTimeStatus.noSession.rawValue
        }
        
        print(status)
    }
    
    @AppStorage("FSEndTime") var endTime = Date()
    @AppStorage("SSFromTime") var fromTime = Date()
    @AppStorage("SSToTime") var toTime = Date() + 3600
    @AppStorage("SSEnabled") var sessionEnabled = false
    
    public var SSBeginTimeComps: DateComponents {
        Calendar.current.dateComponents([.hour, .minute, .second], from: fromTime)
    }
    
    public var SSEndTimeComps: DateComponents {
        Calendar.current.dateComponents([.hour, .minute, .second], from: toTime)
    }
    
    public var todayStartDate: Date {
        Calendar.current.date(
            bySettingHour: SSBeginTimeComps.hour!,
            minute: SSBeginTimeComps.minute!,
            second: SSBeginTimeComps.second!,
            of: Date()
        )!
    }
    
    public var nextEndDate: Date {
        Calendar.current.nextDate(
            after: Date(),
            matching: SSEndTimeComps,
            matchingPolicy: .nextTime
        ) ?? Date()
    }
    
    @AppStorage("SSDaysEnabled")
    var daysEnabled = [false, true, true, true, true, true, false]
    
    public func startSession(minutes: Int) {
        let now = Date()
        let beginTimeComps = now.getComponents([.hour, .minute, .second], minutesAhead: -15)
        let endDate = now + TimeInterval(minutes * 60)
        let endTimeComps = Calendar.current.dateComponents([.hour, .minute, .second], from: endDate)
        
        endTime = endDate
        try! dac.startMonitoring(.focusSessions, during: DeviceActivitySchedule(
            intervalStart: beginTimeComps,
            intervalEnd: endTimeComps,
            repeats: false)
        )
        print("made it here")
    }
    
    public func endSession() {
        dac.stopMonitoring([.focusSessions])
        endTime = Date()
    }
    
    public func createSS() {
        var ignoredDays: [DeviceActivityName] = []
        for i in 0...6 {
            if !daysEnabled[i] {
                ignoredDays.append(DeviceActivityName.dayNames[i])
                continue
            }
            var beginComp = SSBeginTimeComps
            beginComp.setValue(i+1, for: .weekday)
            var endComp = SSEndTimeComps
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
        dac.stopMonitoring(ignoredDays)
    }
    
    public func cancelSS() {
        dac.stopMonitoring(DeviceActivityName.dayNames)
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
    
    public func isSessionOvernight() -> Bool {
        (SSBeginTimeComps.hour! == SSEndTimeComps.hour!) ?
            (SSBeginTimeComps.minute! > SSEndTimeComps.minute!) :
            (SSBeginTimeComps.hour! > SSEndTimeComps.hour!)
    }
}

enum ScreenTimeStatus: Int {
    case noSession, session, scheduledSession
    
    var buttonTitle: String {
        switch self {
        case .noSession:
            return "Start Focus Session"
        case .scheduledSession:
            return "Take a Break"
//        case .onBreak:
//            return "End Break"
        case .session:
            return "End Focus Session"
        }
    }
}
