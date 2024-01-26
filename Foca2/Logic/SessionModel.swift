//
//  SessionModel.swift
//  Foca2
//
//  Created by Adit G on 1/25/24.
//

import Foundation
import DeviceActivity
import ManagedSettings
import FamilyControls

class SessionModel: ObservableObject {
    @Published var tokens = FamilyActivitySelection()
    @Published var status: ScreenTimeStatus = .noSession
    let managedStore = ManagedSettingsStore(named: .schedule)
    
    public func startSession(minutes: Int) {
//        let nowComps = Calendar.current.dateComponents(
//            [.hour, .minute, .second],
//            from: Date.now
//        )
//        let endTimeComps = nowComps.addDelta(minutes)
//        let beginTimeComps = minutes < 15 ? endTimeComps.addDelta(-15) : nowComps
//        
//        try! dac.startMonitoring(.focusSessions, during: DeviceActivitySchedule(
//            intervalStart: beginTimeComps,
//            intervalEnd: endTimeComps,
//            repeats: false)
//        )
        
        managedStore.shield.applications = .some(tokens.applicationTokens)
        managedStore.shield.webDomains = .some(tokens.webDomainTokens)
        managedStore.shield.applicationCategories = .specific(tokens.categoryTokens)
        managedStore.shield.webDomainCategories = .specific(tokens.categoryTokens)
        status = .session
    }
    
    public func endSession() {
        managedStore.clearAllSettings()
        status = .noSession
    }
}

enum ScreenTimeStatus: Int {
    case noSession, session, onBreak, scheduledSession
    
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
}
