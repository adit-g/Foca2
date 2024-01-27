//
//  Foca2App.swift
//  Foca2
//
//  Created by Adit G on 11/1/23.
//

import SwiftUI
import FamilyControls

@main
struct Foca2App: App {
    
    let dataController = DataController()
    let center = AuthorizationCenter.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .onAppear {
                    Task {
                        do {
                            try await center.requestAuthorization(for: .individual)
                        } catch {
                            print("failed to enroll homie with error: \(error)")
                        }
                    }
                }
        }
    }
}
