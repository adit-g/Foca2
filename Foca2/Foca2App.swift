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
    
    @StateObject private var dataController = DataController()
    let center = AuthorizationCenter.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
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
