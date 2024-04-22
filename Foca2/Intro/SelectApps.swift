//
//  SelectApps.swift
//  Foca2
//
//  Created by Adit G on 4/4/24.
//

import SwiftUI

struct SelectApps: View {
    @EnvironmentObject var sessionModel: SessionModel
    let nextView: () -> ()
    @State private var tokenPickerOpen = false
    @State private var sheetOpen = false
    
    var body: some View {
        VStack(spacing: 10) {
            Text("lets get you set up")
                .foregroundStyle(Color(.chineseViolet))
                .fontWeight(.semibold)
                .font(.title3)
                .padding(.horizontal)
                .padding(.top, 60)
                .frame(maxWidth: .infinity, alignment: .leading)
                
            
            Text("select your most distracting apps")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color(.chineseViolet))
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                
            Text("you can always change these later or pick a new group of apps to block")
                .padding(.horizontal)
                .font(.subheadline)
                .foregroundStyle(Color(.coolGray))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            Image(.distracted)
            Spacer()
            
            Button {
                tokenPickerOpen = true
            } label: {
                Capsule()
                    .foregroundStyle(Color(.chineseViolet))
                    .frame(height: 45)
                    .padding(.horizontal, 30)
                    .overlay(Text("select apps").foregroundStyle(Color(.white)))
                    .padding(.bottom)
            }
        }
        .background(Color(.ghostWhite))
        .familyActivityPicker(
            isPresented: $tokenPickerOpen,
            selection: $sessionModel.tokens
        )
        .onChange(of: tokenPickerOpen) {
            if !$1 {
                if sessionModel.tokens.applications.isEmpty && sessionModel.tokens.categories.isEmpty {
                    sheetOpen = true
                } else {
                    sessionModel.saveTokens()
                    nextView()
                }
            }
        }
        .sheet(isPresented: $sheetOpen) { MoveOnSheet() }
    }
}

struct MoveOnSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var sheetLength = CGFloat.zero
    var body: some View {
        VStack {
            VStack {
                Text("no apps selected")
                    .font(.title3)
                    .foregroundStyle(Color(.spaceCadet))
                    .padding(.top)
                
                Text("please select your distracting apps in order to continue")
                    .font(.subheadline)
                    .foregroundStyle(Color(.spaceCadet))
                
                Button {
                    dismiss()
                } label: {
                    Capsule()
                        .foregroundStyle(Color(.coolGray))
                        .frame(height: 45)
                        .padding(.horizontal, 30)
                        .overlay(Text("ok").foregroundStyle(Color(.white)))
                        .padding(.bottom)
                }
            }
            .readSize(onChange: { sheetLength = $0.height })
            
            Spacer()
        }
        .background(Color(.ghostWhite))
        .presentationDetents([.height(sheetLength)])
        .presentationCornerRadius(20)
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    SelectApps(nextView: {})
        .environmentObject(SessionModel())
}
