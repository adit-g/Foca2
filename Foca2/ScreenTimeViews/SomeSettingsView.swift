//
//  SomeSettingsView.swift
//  Foca2
//
//  Created by Adit G on 1/25/24.
//

import SwiftUI

struct SomeSettingsView: View {
    let image : String
    let title: String
    let subtitle: String
    let subtitleMinimized: Bool
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(height: 50)
            .foregroundStyle(.white)
            .overlay {
                HStack (spacing: 0) {
                    Image(systemName: image)
                        .frame(width: 15)
                        .padding(.trailing, 10)
                    Text(title)
                    Spacer()
                    Text(subtitle)
                        .opacity(0.6)
                        .font(.system(size: subtitleMinimized ? 12 : 16))
                    Image(systemName: "chevron.right")
                        .frame(width: 15)
                        .padding(.leading, 5)
                }
                .padding(.horizontal)
                .foregroundStyle(Color(.spaceCadet))
            }
            .padding(.horizontal)
    }
}

#Preview {
    SomeSettingsView(image: "shield", title: "Apps Blocked", subtitle: "whatever\nwhatever", subtitleMinimized: true)
}
