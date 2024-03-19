//
//  ShieldConfigurationExtension.swift
//  ShieldConfiguration
//
//  Created by Adit G on 2/15/24.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    private func getShield(appName: String?) -> ShieldConfiguration {
        let statusInt = UserDefaults(suiteName: "group.2L6XN9RA4T.focashared")!.integer(forKey: "shield")
        let status = ShieldStatus(rawValue: statusInt) ?? .one
        switch status {
        case .one:
            return shield1(name: appName)
        case .two:
            return shield2
        case .three:
            return shield3
        case .four:
            return shield4
        }
    }
    
    private func shield1(name: String?) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundColor: UIColor(named: "ghostWhite"),
            icon: UIImage(named: "logo"),
            title: ShieldConfiguration.Label(
                text:  "\(name?.lowercased() ?? "this app") is blocked\n",
                color: UIColor(named: "coolGray")!),
            subtitle: ShieldConfiguration.Label(
                text: "\n\nto enter, look at your to-do list first",
                color: UIColor(named: "coolGray")!),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "continue",
                color: UIColor(named: "ghostWhite")!),
            primaryButtonBackgroundColor: UIColor(named: "coolGray")
        )
    }
    
    private var shield2: ShieldConfiguration {
        ShieldConfiguration(
            backgroundColor: UIColor(named: "ghostWhite"),
            icon: UIImage(named: "clock"),
            title: ShieldConfiguration.Label(
                text:  "lets pause\n",
                color: UIColor(named: "coolGray")!),
            subtitle: ShieldConfiguration.Label(
                text: "\n\n↑ tap the notification ↑",
                color: UIColor(named: "coolGray")!),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "",
                color: UIColor.clear),
            primaryButtonBackgroundColor: UIColor.clear,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "didn't get a notification?",
                color: UIColor(named: "coolGray")!)
        )
    }
    
    private var shield3: ShieldConfiguration {
        ShieldConfiguration(
            backgroundColor: UIColor(named: "ghostWhite"),
            icon: UIImage(systemName: "moon.fill"),
            title: ShieldConfiguration.Label(
                text:  "do not disturb active\n",
                color: UIColor(named: "coolGray")!),
            subtitle: ShieldConfiguration.Label(
                text: "\n\nyou must enable notifications from foca in Settings -> Focus",
                color: UIColor(named: "coolGray")!),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "retry",
                color: UIColor(named: "ghostWhite")!),
            primaryButtonBackgroundColor: UIColor(named: "coolGray")
        )
    }
    
    private var shield4: ShieldConfiguration {
        ShieldConfiguration(
            backgroundColor: UIColor(named: "ghostWhite"),
            icon: UIImage(systemName: "clock"),
            title: ShieldConfiguration.Label(
                text:  "break ended\n",
                color: UIColor(named: "coolGray")!),
            subtitle: ShieldConfiguration.Label(
                text: "\n\nthe time you set aside for this break is up",
                color: UIColor(named: "coolGray")!),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "close",
                color: UIColor(named: "ghostWhite")!),
            primaryButtonBackgroundColor: UIColor(named: "coolGray")
        )
    }
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Customize the shield as needed for applications.
        getShield(appName: application.localizedDisplayName)
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for applications shielded because of their category.
        getShield(appName: application.localizedDisplayName)
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        // Customize the shield as needed for web domains.
        getShield(appName: webDomain.domain)
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for web domains shielded because of their category.
        getShield(appName: webDomain.domain)
    }
}
