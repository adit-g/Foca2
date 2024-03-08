//
//  TabBar.swift
//  Foca2
//
//  Created by Adit G on 1/22/24.
//

import SwiftUI

struct TabBar: View {
    
    @Binding var selectedTab : Tab
    
    private var fillImage: String {
        selectedTab.imageString + ".fill"
    }
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                ForEach(Tab.allCases, id: \.imageString) { tab in
                    Image(systemName: selectedTab == tab ? fillImage : tab.imageString)
                        .scaleEffect(selectedTab == tab ? 1.25 : 1.0)
                        .foregroundStyle(selectedTab == tab ? Color(.spaceCadet) : .gray)
                        .font(.system(size: 22))
                        .onTapGesture {
                            withAnimation(.easeIn(duration: 0.1)) {
                                selectedTab = tab
                            }
                        }
                    Spacer()
                }
            }
            .frame(height: 50)
            .background(
                Color(.ghostWhite)
                .ignoresSafeArea()
                .shadow(radius: 1)
            )
        }
    }
}

#Preview {
    TabBar(selectedTab: .constant(.second))
        .background(Color(.lightblue))
}
