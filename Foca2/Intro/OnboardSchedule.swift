//
//  OnboardSchedule.swift
//  Foca2
//
//  Created by Adit G on 4/19/24.
//

import SwiftUI

struct OnboardSchedule: View {
    @EnvironmentObject var sessionModel: SessionModel
    let nextView: () -> ()
    let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    @State private var difficultySelectOpen = false
    private var difficultyLevel: Difficulty {
        Difficulty(rawValue: sessionModel.difficultyInt) ?? .normal
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Text("lets put you in a scheduled session")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color(.chineseViolet))
                .padding(.horizontal)
                .offset(x: -30)
                .padding(.bottom, 40)
            
            Text("when are you most distracted?")
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
                .padding(.bottom, 5)
            
            TimeSelector
                .padding(.bottom, 20)
            
            Button {
                difficultySelectOpen = true
            } label: {
                SomeSettingsView(
                    image: "speedometer",
                    title: "Difficulty",
                    subtitle: difficultyLevel.name,
                    subtitleMinimized: false
                )
                .padding(.bottom, 20)
            }
            .disabled(sessionModel.ssEnabled)
            
            DaySelector
            
            Spacer()
            
            Button {
                sessionModel.scheduleSS()
                nextView()
            } label: {
                Capsule()
                    .foregroundStyle(Color(.coolGray))
                    .frame(height: 45)
                    .padding(.horizontal, 30)
                    .overlay(Text("continue").foregroundStyle(Color(.white)))
            }
        }
        .foregroundStyle(Color(.spaceCadet))
        .background(Color(.ghostWhite))
        .sheet(isPresented: $difficultySelectOpen) {
            DifficultySelect()
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
    OnboardSchedule(nextView: {})
        .environmentObject(SessionModel())
}
