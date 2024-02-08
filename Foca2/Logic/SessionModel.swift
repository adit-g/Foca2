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
    
    @AppStorage("status", store: UserDefaults(suiteName: "group.sharedCode1234"))
    var statusInt: Int = ScreenTimeStatus.noSession.rawValue
    @AppStorage("FSEndTime") var fsEndTime = Date()
    
    @AppStorage("SSFromTime") var ssFromTime = Date()
    @AppStorage("SSToTime") var ssToTime = Date() + 3600
    @AppStorage("SSEnabled") var ssEnabled = false
    
    @AppStorage("SSDaysEnabled")
    var daysEnabled = [false, true, true, true, true, true, false]
    
    public var status: ScreenTimeStatus {
        ScreenTimeStatus(rawValue: statusInt) ?? .noSession
    }
    
    init() {
        self.tokens = SessionModel.loadTokens()
    }
    
    public func updateStatus() {
        let now = Date()
        if now.compare(fsEndTime) == .orderedAscending {
            statusInt = ScreenTimeStatus.session.rawValue
        } else {
            statusInt = ScreenTimeStatus.noSession.rawValue
        }
    }
    
    public func startSession(minutes: Int) {
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
    
    public func endSession() {
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
    case noSession, session
    
    var buttonTitle: String {
        switch self {
        case .noSession:
            return "Start Focus Session"
//        case .scheduledSession:
//            return "Take a Break"
//        case .onBreak:
//            return "End Break"
        case .session:
            return "End Focus Session"
        }
    }
}
