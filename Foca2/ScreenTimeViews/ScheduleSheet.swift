//
//  ScheduleSheet.swift
//  Foca2
//
//  Created by Adit G on 1/29/24.
//

import SwiftUI

struct ScheduleSheet: View {
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
                
                VStack(spacing: 0) {
                    DatePicker("From", selection: $sessionModel.fromTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    
                    Divider()
                    
                    DatePicker("To", selection: $sessionModel.toTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                }
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.white)
                }
                .padding(.horizontal)
                
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
                
                Button {
                    if sessionModel.sessionEnabled {
                        sessionModel.cancelSS()
                    } else {
                        sessionModel.createSS()
                    }
                } label: {
                    Capsule()
                        .frame(height: 45)
                        .foregroundStyle(.white)
                        .overlay {
                            Text(sessionModel.sessionEnabled ? "Cancel Session" : "Save")
                                .foregroundStyle(sessionModel.sessionEnabled ? Color.red : Color(.eggplant))
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal)
                }
            }
            .readSize(onChange: { sheetLength = $0.height })
        }
        .background(Color(.blue))
        .presentationDetents([.height(sheetLength)])
        .presentationCornerRadius(20)
    }
}
