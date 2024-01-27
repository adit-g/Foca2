//
//  ScreenTimeView.swift
//  Foca2
//
//  Created by Adit G on 1/23/24.
//

import SwiftUI
import FamilyControls

struct ScreenTimeView: View {
    
    @AppStorage("status", store: UserDefaults(suiteName: "group.sharedCode1234")) var statusInt: Int = ScreenTimeStatus.noSession.rawValue
    @ObservedObject var sessionModel: SessionModel
    @State private var minutes = 5
    @State private var tokenPickerOpen = false
    
    var body: some View {
        ScrollView {
            Text("Focus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(Color(.darkblue))
                .padding(.vertical, 10)
            
            switch sessionModel.status {
            case .noSession:
                TimeSelectionCircle(minutes: $minutes)
                    .padding(.vertical, 15)
                    .padding(.bottom)
            case .session:
                TimerCircle()
            }
            
            BigButton
            
            Button {
                tokenPickerOpen = true
            } label: {
                SomeSettingsView(
                    image: "shield",
                    title: "Apps Blocked",
                    subtitle: "\(sessionModel.tokens.categories.count) categories\n\(sessionModel.tokens.applications.count) applications",
                    subtitleMinimized: true
                )
                .padding(.bottom, 5)
            }
            
            SomeSettingsView(
                image: "speedometer",
                title: "Difficulty",
                subtitle: "Normal",
                subtitleMinimized: false
            )
            .padding(.bottom, 5)
            
            SomeSettingsView(
                image: "clock",
                title: "Schedule",
                subtitle: "",
                subtitleMinimized: false
            )
            .padding(.bottom, 5)
            
            switch sessionModel.status {
            case .noSession:
                Text("NO SESSION")
            case .session:
                Text("SESSION")
            }
            
            Spacer()
        }
        .background(Color(.blue))
        .familyActivityPicker(
            isPresented: $tokenPickerOpen,
            selection: $sessionModel.tokens
        )
        .onChange(of: sessionModel.tokens) { sessionModel.saveTokens() }
        .onChange(of: statusInt) {
            sessionModel.status = ScreenTimeStatus(rawValue: $1) ?? .noSession
        }
    }
    
    var BigButton: some View {
        Button {
            switch sessionModel.status {
            case .noSession:
                sessionModel.startSession(minutes: minutes)
            case .session:
                sessionModel.endSession()
            }
        } label: {
            Capsule()
                .frame(width: UIScreen.width * 7 / 12, height: 40)
                .foregroundStyle(.white)
                .overlay {
                    Text(sessionModel.status.buttonTitle)
                        .foregroundStyle(Color(.darkblue))
                        .fontWeight(.semibold)
                }
                .padding(.bottom)
        }
    }
}

#Preview {
    ScreenTimeView(sessionModel: SessionModel())
}
