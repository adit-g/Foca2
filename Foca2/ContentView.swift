//
//  ContentView.swift
//  Foca2
//
//  Created by Adit G on 11/1/23.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("userOnboarded") private var userOnboarded = false
    @State private var selectedTab = Tab.first
    @StateObject private var sessionModel = SessionModel()
    
    @ObservedObject var appState = AppState.shared
    @State private var redirect = false
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        if userOnboarded {
            ZStack {
                TabView(selection: $selectedTab) {
                    ScreenTimeView()
                        .environmentObject(sessionModel)
                        .tag(Tab.first)
                    
                    TaskView()
                        .environmentObject(sessionModel)
                        .tag(Tab.second)
                    
                    Schedule()
                        .tag(Tab.third)
                }
                
                TabBar(selectedTab: $selectedTab)
            }
            .transition(.moveAndFade)
            .onAppear {
                sessionModel.updateStatus()
                UserDefaults(suiteName: "group.2L6XN9RA4T.focashared")!.set(ShieldStatus.one.rawValue, forKey: "shield")
            }
            .fullScreenCover(isPresented: $redirect) {
                RedirectView()
                    .environmentObject(sessionModel)
            }
            .onReceive(appState.$redirect) { red in
                redirect = red
            }
        } else {
            IntroTutorial(isFinished: $userOnboarded)
                .environmentObject(sessionModel)
        }
    }
}

enum Tab: Int, CaseIterable {
    case first
    case second
    case third
    
    var imageString: String {
        switch self {
        case .second: return "list.bullet.clipboard"
        case .third: return "calendar"
        case .first: return "hourglass"
        }
    }
}

#Preview {
    ContentView()
}
