//
//  Welcome.swift
//  Foca2
//
//  Created by Adit G on 4/2/24.
//

import SwiftUI

struct Welcome: View {
    let nextView: () -> ()
    var body: some View {
        VStack {
            Image(.digitalWellness)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: UIScreen.height / 2)
            
            Text("your time is yours.")
                .foregroundStyle(Color(.chineseViolet))
                .fontWeight(.bold)
                .font(.title)
                .frame(width: 300)
            Text("foca can help you be more aware of how you spend it")
                .foregroundStyle(Color(.coolGray))
                .frame(width: 300, alignment: .leading)
                .font(.subheadline)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button {
                nextView()
            } label: {
                Capsule()
                    .foregroundStyle(Color(.chineseViolet))
                    .frame(height: 45)
                    .padding(.horizontal, 30)
                    .overlay(Text("continue").foregroundStyle(Color(.white)))
                    .padding(.bottom)
            }
            
        }
        .frame(width: UIScreen.width)
        .background(Color(.ghostWhite))
    }
}

#Preview {
    Welcome(nextView: {})
}
