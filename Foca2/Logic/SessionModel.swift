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
    @Published var status: ScreenTimeStatus
    let managedStore = ManagedSettingsStore(named: .schedule)
    let dac = DeviceActivityCenter()
    
    init() {
        self.tokens = SessionModel.loadTokens()
        let statusInt = UserDefaults(suiteName: "group.sharedCode1234")?.integer(forKey: "status")
        self.status = ScreenTimeStatus(rawValue: statusInt ?? ScreenTimeStatus.noSession.rawValue) ?? .noSession
    }
    
    public func startSession(minutes: Int) {
        let now = Date()
        let endTimeComps = now.getComponents([.hour, .minute, .second], minutesAhead: minutes)
        let beginTimeComps = now.getComponents([.hour, .minute, .second], minutesAhead: -15)
        
        try? dac.startMonitoring(.focusSessions, during: DeviceActivitySchedule(
            intervalStart: beginTimeComps,
            intervalEnd: endTimeComps,
            repeats: false)
        )
    }
    
    public func endSession() {
        dac.stopMonitoring([.focusSessions])
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
