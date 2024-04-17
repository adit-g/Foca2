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
    
    let store = UserDefaults(suiteName: "group.2L6XN9RA4T.focashared")!
    
    private func handleBoss(action: ShieldAction, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        let lastDate = store.object(forKey: "lastShieldDate") as? Date ?? Date() - 35
        let shield = ShieldStatus(rawValue: store.integer(forKey: "shield")) ?? .one
        let status = lastDate > Date() - 30 ? shield : .one
        
        // Handle the action as needed.
        switch action {
        case .primaryButtonPressed:
            switch status {
            case .one:
                UNUserNotificationCenter.scheduleNoti(
                    title: "click here",
                    body: "to see your to-do list",
                    identifier: "portal",
                    userInfo: ["todo": true])
                store.set(ShieldStatus.two.rawValue, forKey: "shield")
                store.set(Date(), forKey: "lastShieldDate")
                completionHandler(.defer)
            case .two:
                completionHandler(.defer)
            case .three:
                UNUserNotificationCenter.scheduleNoti(
                    title: "click here",
                    body: "to see your to-do list",
                    identifier: "portal",
                    userInfo: ["todo": true])
                store.set(ShieldStatus.two.rawValue, forKey: "shield")
                store.set(Date(), forKey: "lastShieldDate")
                completionHandler(.defer)
            case .four:
                store.set(ShieldStatus.one.rawValue, forKey: "shield")
                completionHandler(.close)
            }
        case .secondaryButtonPressed:
            switch status {
            case .one:
                completionHandler(.defer)
            case .two:
                store.set(ShieldStatus.three.rawValue, forKey: "shield")
                store.set(Date(), forKey: "lastShieldDate")
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
