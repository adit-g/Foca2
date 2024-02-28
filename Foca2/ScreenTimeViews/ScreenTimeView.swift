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
    
    @AppStorage("status", store: UserDefaults(suiteName: "group.2L6XN9RA4T.focashared"))
    var statusInt: Int = ScreenTimeStatus.noSession.rawValue
    
    @State private var minutes = 5
    @State private var tokenPickerOpen = false
    @State private var scheduleSheetOpen = false
    @State private var startBreakOpen = false
    @State private var difficultySelectOpen = false
    
    @State private var alertTitle = ""
    @State private var showingAlert = false
    
    private var status: ScreenTimeStatus {
        ScreenTimeStatus(rawValue: statusInt) ?? .noSession
    }
    
    private var difficultyLevel: Difficulty {
        Difficulty(rawValue: sessionModel.difficultyInt) ?? .normal
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
            
            Button {
                if sessionModel.getStatus() == .scheduledSession {
                    alertTitle = "You cannot edit session difficulty while in a scheduled session"
                    showingAlert = true
                } else {
                    difficultySelectOpen = true
                }
            } label: {
                SomeSettingsView(
                    image: "speedometer",
                    title: "Difficulty",
                    subtitle: difficultyLevel.name,
                    subtitleMinimized: false
                )
                .padding(.bottom, 5)
            }
            
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
            
            Spacer()
        }
        .background(Color(.mediumBlue))
        .familyActivityPicker(
            isPresented: $tokenPickerOpen,
            selection: $sessionModel.tokens
        )
        .onChange(of: sessionModel.tokens) { sessionModel.saveTokens() }
        .sheet(isPresented: $scheduleSheetOpen) { ScheduleSheet() }
        .sheet(isPresented: $startBreakOpen) { StartBreakView() }
        .sheet(isPresented: $difficultySelectOpen) { DifficultySelect() }
        .alert(alertTitle, isPresented: $showingAlert, actions: {})
        .onAppear {
            Task {
                do {
                    try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                } catch {
                    print("failed to enroll homie with error: \(error)")
                }
            }
            sessionModel.updateStatus()
        }
    }
    
    var BigButton: some View {
        Button {
            switch status {
            case .noSession:
                sessionModel.startFS(minutes: minutes)
            case .session:
                sessionModel.endFS()
            case .scheduledSession:
                startBreakOpen = true
            case .onBreak:
                sessionModel.endBreak()
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
