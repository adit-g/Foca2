//
//  Budget.swift
//  Foca2
//
//  Created by Adit G on 4/7/24.
//

import SwiftUI

struct Budget: View {
    @EnvironmentObject var sessionModel: SessionModel
    let nextView: () -> ()
    var body: some View {
        VStack {
            Spacer()
            Text("how many times a day would you ideally use these apps?")
                .foregroundStyle(Color(.chineseViolet))
                .fontWeight(.bold)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()
            
            Text("just go with your gut, you can change this at any time")
                .foregroundStyle(Color(.coolGray))
                .frame(width: 300, alignment: .leading)
                .font(.subheadline)
            
            Spacer()
            
            HStack(spacing: 15) {
                Button {
                    sessionModel.appBudget -= 1
                } label: {
                    Image(systemName: "minus.circle")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(Color(.spaceCadet))
                }
                .disabled(sessionModel.appBudget == 0)
                
                Text(sessionModel.appBudget.description)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(.coolGray))
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(Material.ultraThinMaterial)
                    }
                
                Button {
                    sessionModel.appBudget += 1
                } label: {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(Color(.spaceCadet))
                }
            }
            
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
        .background(Color(.ghostWhite))
    }
}

#Preview {
    Budget(nextView: {})
        .environmentObject(SessionModel())
}
