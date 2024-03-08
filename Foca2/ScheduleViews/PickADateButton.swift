//
//  PickADateButton.swift
//  Foca2
//
//  Created by Adit G on 1/23/24.
//

import SwiftUI

struct PickADateButton: View {
    let title: String
    var body: some View {
        HStack (spacing: 0) {
            Image(systemName: "calendar")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 24)
                .padding(.horizontal)
                .foregroundStyle(Color(.spaceCadet))
            
            Text(title)
                .foregroundStyle(Color(.spaceCadet))
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 12, maxHeight: 12)
                .padding(.horizontal)
        }
    }
}

#Preview {
    PickADateButton(title: "Pick a Date")
}
