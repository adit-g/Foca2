//
//  ScheduleSheet.swift
//  Foca2
//
//  Created by Adit G on 1/29/24.
//

import SwiftUI

struct ScheduleSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var sessionModel: SessionModel
    let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    @State private var sheetLength = CGFloat.zero
    @State private var difficultySelectOpen = false
    
    @State private var timeRemaining = 5
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var difficultyLevel: Difficulty {
        Difficulty(rawValue: sessionModel.difficultyInt) ?? .normal
    }
    
    var buttonTitle: String {
        if !sessionModel.ssEnabled {
            return "Save"
        } else if sessionModel.getStatus() == .scheduledSession {
            switch difficultyLevel {
            case .normal:
                return timeRemaining > 0 ? "Cancel Available in \(timeRemaining)" : "Cancel"
            case .timeout:
                return timeRemaining > 0 ? "Cancel Available in \(timeRemaining)" : "Cancel"
            case .deepfocus:
                return "Cancel Unavailable"
            }
        } else {
            return "Cancel"
        }
    }
    
    var buttonColor: Color {
        if !sessionModel.ssEnabled {
            return Color(.chineseViolet)
        } else if sessionModel.getStatus() == .scheduledSession && timeRemaining > 0 {
            return .gray
        } else {
            return .red
        }
    }
    
    var body: some View {
        VStack {
            VStack (spacing: 10) {
                Text("Scheduled Session")
                    .fontWeight(.semibold)
                    .font(.title)
                    .padding()
                
                Text("Set a Specific time")
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
              
                TimeSelector
                
                Button {
                    difficultySelectOpen = true
                } label: {
                    SomeSettingsView(
                        image: "speedometer",
                        title: "Difficulty",
                        subtitle: difficultyLevel.name,
                        subtitleMinimized: false
                    )
                    .padding(.bottom, 5)
                }
                .disabled(sessionModel.ssEnabled)
                
                DaySelector
                
                BigButton
                    .padding(.bottom)
            }
            .readSize(onChange: { sheetLength = $0.height })
            .foregroundStyle(Color(.spaceCadet))
            
            Spacer()
        }
        .background(Color(.ghostWhite))
        .presentationDetents([.height(sheetLength)])
        .presentationCornerRadius(20)
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $difficultySelectOpen) {
            DifficultySelect()
        }
    }
    
    var BigButton: some View {
        Button {
            if sessionModel.ssEnabled {
                sessionModel.cancelSS()
            } else {
                sessionModel.scheduleSS()
            }
        } label: {
            Capsule()
                .frame(height: 45)
                .foregroundStyle(.white)
                .overlay {
                    Text(buttonTitle)
                        .foregroundStyle(buttonColor)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)
        }
        .disabled(timeRemaining > 0 || (timeRemaining > 0 && difficultyLevel == .deepfocus))
        .onAppear {
            if sessionModel.getStatus() == .scheduledSession {
                timeRemaining = sessionModel.getCurrentWaitTime()
            } else {
                timeRemaining = 0
            }
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 && difficultyLevel != .deepfocus {
                timeRemaining -= 1
            }
        }
    }
    
    @State private var daysEnabled = UserDefaults(suiteName: "group.2L6XN9RA4T.focashared")!.object(forKey: "SSDaysEnabled") as? [Bool] ?? [false, true, true, true, true, true, false]
    
    var DaySelector: some View {
        VStack(spacing: 0) {
            Text("Days of Week Active")
                .fontWeight(.medium)
                .foregroundColor(Color(.spaceCadet))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical)
            
            HStack {
                ForEach(daysEnabled.indices, id: \.self) { index in
                    Circle()
                        .foregroundStyle(Color(.chineseViolet))
                        .opacity(daysEnabled[index] ? 1 : 0.3)
                        .overlay {
                            Text(weekdays[index])
                                .foregroundStyle(.white)
                        }
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            daysEnabled[index].toggle()
                            UserDefaults(suiteName: "group.2L6XN9RA4T.focashared")!.set(daysEnabled, forKey: "SSDaysEnabled")
                        }
                        .disabled(sessionModel.ssEnabled)
                }
            }
            .padding(.bottom)
        }
        .padding(.horizontal)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.white)
        }
        .padding(.horizontal)
    }
    
    var TimeSelector: some View {
        VStack(spacing: 0) {
            DatePicker("From", selection: $sessionModel.ssFromTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.compact)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .disabled(sessionModel.ssEnabled)
            
            Divider()
            
            DatePicker("To", selection: $sessionModel.ssToTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.compact)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .disabled(sessionModel.ssEnabled)
        }
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.white)
        }
        .padding(.horizontal)
    }
}

#Preview {
    ScheduleSheet()
        .environmentObject(SessionModel())
}
