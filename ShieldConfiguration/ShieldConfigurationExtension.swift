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
        UNUserNotificationCenter.scheduleNoti(title: "Click Me", subtitle: "", identifier: "portal")
        
        let image = "✋".textToImage()!
        
        
        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterial,
            backgroundColor: UIColor.black,
            icon: image,
            title: ShieldConfiguration.Label(
                text:  "\(appName ?? "This app") is blocked",
                color: .lightText),
            subtitle: ShieldConfiguration.Label(
                text: "Lets get back to your tasks\n\nClick the notification above to see your schedule on Foca",
                color: .lightText),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Close",
                color: .darkText),
            primaryButtonBackgroundColor: .white
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
