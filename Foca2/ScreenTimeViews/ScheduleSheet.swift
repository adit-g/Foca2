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
    
    @State private var timeRemaining = 5
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var buttonTitle: String {
        if !sessionModel.ssEnabled {
            return "Save"
        } else if sessionModel.getStatus() == .scheduledSession && timeRemaining > 0 {
            return "Cancel Available in \(timeRemaining)"
        } else {
            return "Cancel"
        }
    }
    
    var buttonColor: Color {
        if !sessionModel.ssEnabled {
            return Color(.eggplant)
        } else if sessionModel.getStatus() == .scheduledSession && timeRemaining > 0 {
            return .gray
        } else {
            return .red
        }
    }
    
    var body: some View {
        ScrollView {
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
                
                DaySelector
                
                BigButton
            }
            .readSize(onChange: { sheetLength = $0.height })
            .foregroundStyle(.black)
        }
        .background(Color(.mediumBlue))
        .presentationDetents([.height(sheetLength)])
        .presentationCornerRadius(20)
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
        .disabled(timeRemaining > 0)
        .onAppear {
            if sessionModel.getStatus() == .scheduledSession {
                timeRemaining = sessionModel.getCurrentWaitTime()
            } else {
                timeRemaining = 0
            }
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
    }
    
    var DaySelector: some View {
        VStack(spacing: 0) {
            Text("Days of Week Active")
                .fontWeight(.medium)
                .foregroundColor(Color("eggplant"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical)
            
            HStack {
                ForEach(sessionModel.daysEnabled.indices, id: \.self) { index in
                    Circle()
                        .foregroundStyle(Color(.eggplant))
                        .opacity(sessionModel.daysEnabled[index] ? 1 : 0.3)
                        .overlay {
                            Text(weekdays[index])
                                .foregroundStyle(.white)
                        }
                        .frame(width: 40)
                        .onTapGesture {
                            sessionModel.daysEnabled[index].toggle()
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
                .preferredColorScheme(.light)
                .datePickerStyle(.compact)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .disabled(sessionModel.ssEnabled)
            
            Divider()
            
            DatePicker("To", selection: $sessionModel.ssToTime, displayedComponents: .hourAndMinute)
                .preferredColorScheme(.light)
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
