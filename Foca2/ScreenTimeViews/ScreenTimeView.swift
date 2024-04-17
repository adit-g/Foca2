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
    
    @State private var minutes = 30
    @State private var tokenPickerOpen = false
    @State private var scheduleSheetOpen = false
    @State private var startBreakOpen = false
    
    @State private var alertOpen = false
    
    private var status: ScreenTimeStatus {
        ScreenTimeStatus(rawValue: statusInt) ?? .noSession
    }
    
    var body: some View {
        VStack {
            Text("Focus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(Color(.spaceCadet))
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
        .background(Color(.ghostWhite))
        .foregroundStyle(.black)
        .familyActivityPicker(
            isPresented: $tokenPickerOpen,
            selection: $sessionModel.tokens
        )
        .onChange(of: sessionModel.tokens) { sessionModel.saveTokens() }
        .sheet(isPresented: $scheduleSheetOpen) { ScheduleSheet() }
        .sheet(isPresented: $startBreakOpen) { StartBreakView() }
        .alert("no apps are blocked", isPresented: $alertOpen) {
            Button("lets block!", role: .cancel) {
                tokenPickerOpen = true
            }
                .keyboardShortcut(.defaultAction)
            Button("i'm good") { sessionModel.startFS(minutes: minutes) }
        } message: {
            Text("blocking distracting apps could help you maintain focus")
        }
        .onAppear {
            Task {
                do {
                    try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                } catch {
                    print("failed to enroll homie with error: \(error)")
                }
            }
        }
    }
    
    var BigButton: some View {
        Button {
            switch status {
            case .noSession:
                if sessionModel.tokens.applications.isEmpty && sessionModel.tokens.categories.isEmpty {
                    alertOpen = true
                } else {
                    sessionModel.startFS(minutes: minutes)
                }
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
                .foregroundStyle(Color(.coolGray))
                .overlay {
                    Text(status.buttonTitle)
                        .foregroundStyle(Color(.ghostWhite))
                        .fontWeight(.semibold)
                }
                .padding(.bottom)
                .shadow(radius: 3)
        }
    }
}

#Preview {
    ScreenTimeView()
        .environmentObject(SessionModel())
}
