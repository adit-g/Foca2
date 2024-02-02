//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitor
//
//  Created by Adit G on 1/26/24.
//

import DeviceActivity
import ManagedSettings
import SwiftUI

// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        // Handle the start of the interval.
        let tokens = SessionModel.loadTokens()
        let managedStore = ManagedSettingsStore(named: .schedule)
        managedStore.shield.applications = .some(tokens.applicationTokens)
        managedStore.shield.webDomains = .some(tokens.webDomainTokens)
        managedStore.shield.applicationCategories = .specific(tokens.categoryTokens)
        managedStore.shield.webDomainCategories = .specific(tokens.categoryTokens)
        
        let currentStatus: Int
        if DeviceActivityName.dayNames.contains(activity) {
            currentStatus = ScreenTimeStatus.scheduledSession.rawValue
        } else {
            currentStatus = ScreenTimeStatus.session.rawValue
        }
        UserDefaults(suiteName: "group.sharedCode1234")?.set(currentStatus, forKey: "status")
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        // Handle the end of the interval.
        let managedStore = ManagedSettingsStore(named: .schedule)
        managedStore.clearAllSettings()
        UserDefaults(suiteName: "group.sharedCode1234")?.set(ScreenTimeStatus.noSession.rawValue, forKey: "status")
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        // Handle the event reaching its threshold.
    }
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        
        // Handle the warning before the interval starts.
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        
        // Handle the warning before the interval ends.
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        
        // Handle the warning before the event reaches its threshold.
    }
}
