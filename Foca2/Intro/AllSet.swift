//
//  AllSet.swift
//  Foca2
//
//  Created by Adit G on 4/12/24.
//

import SwiftUI

struct AllSet: View {
    let nextView: () -> ()
    var body: some View {
        VStack {
            Text("you're all set!")
                .font(.largeTitle)
                .frame(width: 300, alignment: .leading)
                .fontWeight(.bold)
                .foregroundStyle(Color(.chineseViolet))
                .padding(.top, 60)
            
            Text("when distracting apps are opened, foca will send you to your to-do list. you can then decide whether you actually want to open that app")
                .foregroundStyle(Color(.spaceCadet))
                .frame(width: 300, alignment: .leading)
                .font(.headline)
                .padding()
            
            Spacer()
            Image(uiImage: "🎉".textToImage()!)
            Spacer()
            
            Button {
                nextView()
            } label: {
                Capsule()
                    .foregroundStyle(Color(.coolGray))
                    .frame(height: 45)
                    .padding(.horizontal, 30)
                    .overlay(Text("finish").foregroundStyle(Color(.white)))
            }
        }
        .background(Color(.ghostWhite))
    }
}

#Preview {
    AllSet(nextView: {})
}
