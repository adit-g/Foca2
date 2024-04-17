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
                .preferredColorScheme(.light)
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
