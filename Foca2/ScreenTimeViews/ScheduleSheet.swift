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
        }
        .background(Color(.blue))
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
                    Text(sessionModel.ssEnabled ? "Cancel Session" : "Save")
                        .foregroundStyle(sessionModel.ssEnabled ? Color.red : Color(.eggplant))
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)
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
