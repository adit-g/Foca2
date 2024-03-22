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
    
    let store = UserDefaults(suiteName: "group.2L6XN9RA4T.focashared")!
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        // Handle the start of the interval.
        if activity == .focusSessions {
            SessionModel.blockApps()
            store.set(ScreenTimeStatus.session.rawValue, forKey: "status")
        } else if activity == .breaks {
            SessionModel.unblockApps()
            store.set(ScreenTimeStatus.onBreak.rawValue, forKey: "status")
        } else if activity == .scheduled {
            let daysEnabled = store.object(forKey: "SSDaysEnabled") as? [Bool] ?? [false, true, true, true, true, true, false]
            let weekday = Calendar.current.dateComponents([.weekday], from: Date()).weekday!
            if daysEnabled[weekday - 1] {
                SessionModel.blockApps()
            }
            store.set(ScreenTimeStatus.scheduledSession.rawValue, forKey: "status")
        }
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        // Handle the end of the interval.
        if activity == .focusSessions {
            SessionModel.unblockApps()
            store.set(ScreenTimeStatus.noSession.rawValue, forKey: "status")
        } else if activity == .breaks {
            store.set(ShieldStatus.four.rawValue, forKey: "shield")
            store.set(Date(), forKey: "lastShieldDate")
            SessionModel.blockApps()
            store.set(ScreenTimeStatus.scheduledSession.rawValue, forKey: "status")
        } else if activity == .scheduled {
            SessionModel.unblockApps()
            store.set(ScreenTimeStatus.noSession.rawValue, forKey: "status")
        }
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
        UNUserNotificationCenter.scheduleNoti(title: "break ending soon", body: "your apps will be blocked in 1m", identifier: "warning")
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        
        // Handle the warning before the event reaches its threshold.
    }
}
