//
//  ContentView.swift
//  Foca2
//
//  Created by Adit G on 11/1/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selectedTab = Tab.first
    @StateObject private var sessionModel = SessionModel()
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                Schedule()
                    .ignoresSafeArea(edges: .bottom)
                    .tag(Tab.first)
                
                ScreenTimeView(sessionModel: sessionModel)
                    .tag(Tab.second)
            }
            
            TabBar(selectedTab: $selectedTab)
        }
    }
}

enum Tab: Int, CaseIterable {
    case first
    case second
    
    var imageString: String {
        switch self {
        case .first: return "list.bullet.clipboard"
        case .second: return "hourglass.circle"
        }
    }
}

#Preview {
    ContentView()
}
