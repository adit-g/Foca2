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
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        if userOnboarded {
            ZStack {
                TabView(selection: $selectedTab) {
                    TaskView()
                        .tag(Tab.first)
                    
                    Schedule()
                        .tag(Tab.second)
                    
                    ScreenTimeView()
                        .environmentObject(sessionModel)
                        .tag(Tab.third)
                }
                
                TabBar(selectedTab: $selectedTab)
            }
            .transition(.moveAndFade)
            .onAppear {
                sessionModel.updateStatus()
                UserDefaults(suiteName: "group.2L6XN9RA4T.focashared")!.set(ShieldStatus.one.rawValue, forKey: "shield")
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
        case .first: return "list.bullet.clipboard"
        case .second: return "calendar"
        case .third: return "hourglass"
        }
    }
}

#Preview {
    ContentView()
}
