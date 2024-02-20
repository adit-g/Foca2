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
    
    private func scheduleNoti(title: String, subtitle: String, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        scheduleNoti(title: "Interval started", subtitle: "", identifier: "start")
        // Handle the start of the interval.
        if activity == .focusSessions {
            blockApps()
            UserDefaults(suiteName: "group.2L6XN9RA4T.focashared")!.set(ScreenTimeStatus.session.rawValue, forKey: "status")
        } else if activity == .breaks {
            unblockApps()
            UserDefaults(suiteName: "group.2L6XN9RA4T.focashared")!.set(ScreenTimeStatus.onBreak.rawValue, forKey: "status")
        } else {
            blockApps()
            UserDefaults(suiteName: "group.2L6XN9RA4T.focashared")!.set(ScreenTimeStatus.scheduledSession.rawValue, forKey: "status")
        }
    }
    
    private func blockApps() {
        let tokens = SessionModel.loadTokens()
        let managedStore = ManagedSettingsStore(named: .schedule)
        managedStore.shield.applications = .some(tokens.applicationTokens)
        managedStore.shield.webDomains = .some(tokens.webDomainTokens)
        managedStore.shield.applicationCategories = .specific(tokens.categoryTokens)
        managedStore.shield.webDomainCategories = .specific(tokens.categoryTokens)
    }
    
    private func unblockApps() {
        let managedStore = ManagedSettingsStore(named: .schedule)
        managedStore.clearAllSettings()
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        scheduleNoti(title: "Interval ended", subtitle: "", identifier: "end")
        // Handle the end of the interval.
        if activity == .focusSessions {
            unblockApps()
            UserDefaults(suiteName: "group.2L6XN9RA4T.focashared")!.set(ScreenTimeStatus.noSession.rawValue, forKey: "status")
        } else if activity == .breaks {
            blockApps()
            UserDefaults(suiteName: "group.2L6XN9RA4T.focashared")!.set(ScreenTimeStatus.scheduledSession.rawValue, forKey: "status")
        } else {
            unblockApps()
            UserDefaults(suiteName: "group.2L6XN9RA4T.focashared")!.set(ScreenTimeStatus.noSession.rawValue, forKey: "status")
        }
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        // Handle the event reaching its threshold.
        scheduleNoti(title: "Click Me", subtitle: "", identifier: "portal")
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
