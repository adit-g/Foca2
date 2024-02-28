//
//  Foca2App.swift
//  Foca2
//
//  Created by Adit G on 11/1/23.
//

import SwiftUI

@main
struct Foca2App: App {
    
    let dataController = DataController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .onAppear{ dataController.saveTasksImage() }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name.shieldStarted), perform: { _ in
                    UNUserNotificationCenter.scheduleNoti(title: "Click Me", subtitle: "nothing", identifier: "portal")
                })
        }
    }
}
