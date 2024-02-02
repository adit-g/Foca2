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
    
    @AppStorage("SSDaysEnabled")
    var daysEnabled = [false, true, true, true, true, true, false]
    
    public func startSession(minutes: Int) {
        let now = Date()
        let beginTimeComps = now.getComponents([.hour, .minute, .second], minutesAhead: -15)
        let endDate = now + TimeInterval(minutes * 60)
        let endTimeComps = Calendar.current.dateComponents([.hour, .minute, .second], from: endDate)
        
        endTime = endDate
        try? dac.startMonitoring(.focusSessions, during: DeviceActivitySchedule(
            intervalStart: beginTimeComps,
            intervalEnd: endTimeComps,
            repeats: false)
        )
    }
    
    public func endSession() {
        dac.stopMonitoring([.focusSessions])
        endTime = Date()
    }
    
    public func createSS() {
        for i in 0...6 {
            if !daysEnabled[i] {
                continue
            }
            var beginComp = SSBeginTimeComps
            beginComp.setValue(i+1, for: .weekday)
            var endComp = SSEndTimeComps
            endComp.setValue(isSessionOvernight() ? (i+1)%7+1 : i+1, for: .weekday)
            try? dac.startMonitoring(
                .dayNames[i],
                during: DeviceActivitySchedule(
                    intervalStart: beginComp,
                    intervalEnd: endComp,
                    repeats: true
                )
            )
        }
        sessionEnabled = true
    }
    
    public func cancelSS() {
        dac.stopMonitoring(DeviceActivityName.dayNames)
        sessionEnabled = false
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
