//
//  ContentView.swift
//  Foca2
//
//  Created by Adit G on 11/1/23.
//

import SwiftUI

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

struct ContentView: View {
    
    @State private var selectedTab = Tab.first
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                Schedule()
                    .ignoresSafeArea(edges: .bottom)
                    .tag(Tab.first)
                
                
                Color.red
                    .tag(Tab.second)
            }
            
            TabBar(selectedTab: $selectedTab)
            
        }
    }
}

#Preview {
    ContentView()
}
