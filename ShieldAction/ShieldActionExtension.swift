//
//  ShieldActionExtension.swift
//  ShieldAction
//
//  Created by Adit G on 3/17/24.
//

import ManagedSettings
import SwiftUI

// Override the functions below to customize the shield actions used in various situations.
// The system provides a default response for any functions that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldActionExtension: ShieldActionDelegate {
    private func handleBoss(action: ShieldAction, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        let statusInt = UserDefaults(suiteName: "group.2L6XN9RA4T.focashared")!.integer(forKey: "shield")
        let status = ShieldStatus(rawValue: statusInt) ?? .one
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UserDefaults(suiteName: "group.2L6XN9RA4T.focashared")!
                .set(ShieldStatus.one.rawValue, forKey: "shield")
        }
        
        // Handle the action as needed.
        switch action {
        case .primaryButtonPressed:
            switch status {
            case .one:
                let num = ShieldStatus.two.rawValue
                UNUserNotificationCenter.scheduleNoti(title: "click here", body: "to see your to-do list", identifier: "portal")
                UserDefaults(suiteName: "group.2L6XN9RA4T.focashared")!
                    .set(num, forKey: "shield")
                completionHandler(.defer)
            case .two:
                completionHandler(.defer)
            case .three:
                UNUserNotificationCenter.scheduleNoti(title: "click here", body: "to see your to-do list", identifier: "portal")
                UserDefaults(suiteName: "group.2L6XN9RA4T.focashared")!
                    .set(ShieldStatus.two.rawValue, forKey: "shield")
                completionHandler(.defer)
            case .four:
                UserDefaults(suiteName: "group.2L6XN9RA4T.focashared")!
                    .set(ShieldStatus.one.rawValue, forKey: "shield")
                completionHandler(.close)
            }
        case .secondaryButtonPressed:
            switch status {
            case .one:
                completionHandler(.defer)
            case .two:
                UserDefaults(suiteName: "group.2L6XN9RA4T.focashared")!
                    .set(ShieldStatus.three.rawValue, forKey: "shield")
                completionHandler(.defer)
            case .three:
                completionHandler(.defer)
            case .four:
                completionHandler(.defer)
            }
        @unknown default:
            fatalError()
        }
    }
    
    
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handleBoss(action: action, completionHandler: completionHandler)
    }
    
    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Handle the action as needed.
        handleBoss(action: action, completionHandler: completionHandler)
    }
    
    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Handle the action as needed.
        handleBoss(action: action, completionHandler: completionHandler)
    }
}
