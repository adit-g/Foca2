//
//  ScreenTimeView.swift
//  Foca2
//
//  Created by Adit G on 1/23/24.
//

import SwiftUI
import FamilyControls

struct ScreenTimeView: View {
    @EnvironmentObject var sessionModel: SessionModel
    
    @AppStorage("status", store: UserDefaults(suiteName: "group.sharedCode1234"))
    var statusInt: Int = ScreenTimeStatus.noSession.rawValue
    
    @State private var minutes = 5
    @State private var tokenPickerOpen = false
    @State private var scheduleSheetOpen = false
    
    private var status: ScreenTimeStatus {
        ScreenTimeStatus(rawValue: statusInt) ?? .noSession
    }
    
    var body: some View {
        ScrollView {
            Text("Focus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(Color(.darkblue))
                .padding(.vertical, 10)
            
            if status == .noSession {
                TimeSelectionCircle(minutes: $minutes)
                    .padding(.vertical, 15)
                    .padding(.bottom)
            } else {
                TimerCircle()
                    .padding(.vertical, 15)
                    .padding(.bottom)
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
            
            Button {
                scheduleSheetOpen = true
            } label: {
                SomeSettingsView(
                    image: "clock",
                    title: "Schedule",
                    subtitle: sessionModel.ssEnabled ? "On" : "Off",
                    subtitleMinimized: false
                )
                .padding(.bottom, 5)
            }
            
            switch status {
            case .noSession:
                Text("NO SESSION")
            case .session:
                Text("SESSION")
            case .scheduledSession:
                Text("SCHEDULED")
            }
            
            Spacer()
        }
        .background(Color(.blue))
        .familyActivityPicker(
            isPresented: $tokenPickerOpen,
            selection: $sessionModel.tokens
        )
        .onChange(of: sessionModel.tokens) { sessionModel.saveTokens() }
        .sheet(isPresented: $scheduleSheetOpen) { ScheduleSheet() }
        .onAppear { sessionModel.updateStatus() }
    }
    
    var BigButton: some View {
        Button {
            switch status {
            case .noSession:
                sessionModel.startFS(minutes: minutes)
            case .session:
                sessionModel.endFS()
            case .scheduledSession:
                sessionModel.cancelSS()
            }
        } label: {
            Capsule()
                .frame(width: UIScreen.width * 7 / 12, height: 40)
                .foregroundStyle(.white)
                .overlay {
                    Text(status.buttonTitle)
                        .foregroundStyle(Color(.darkblue))
                        .fontWeight(.semibold)
                }
                .padding(.bottom)
        }
    }
}

#Preview {
    ScreenTimeView()
}
