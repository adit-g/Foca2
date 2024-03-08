//
//  StartBreakView.swift
//  Foca2
//
//  Created by Adit G on 2/12/24.
//

import SwiftUI

struct StartBreakView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var sessionModel: SessionModel
    @State private var sheetLength = CGFloat.zero
    @State private var minuteSelection = 5
    
    @State private var timeRemaining = 5
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Break Length")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .padding(.top, 5)
                
                ZStack {
                    Picker("Minute Picker", selection: $minuteSelection) {
                        ForEach(0..<16) { row in
                            Text(row.description)
                                .fontWeight(.bold)
                        }
                    }
                    .preferredColorScheme(.light)
                    .pickerStyle(.wheel)
                    
                    Text(minuteSelection < 2 ? "minute" : "minutes")
                        .offset(x: 50)
                }
                
                BreakButton(
                    counter: $timeRemaining,
                    minutes: minuteSelection,
                    dismiss: dismiss
                )
                    .onReceive(timer) { _ in
                        if timeRemaining > 0 {
                            timeRemaining -= 1
                        }
                    }
            }
            .foregroundStyle(Color(.spaceCadet))
            .readSize(onChange: { sheetLength = $0.height })
        }
        .onChange(of: minuteSelection) {
            if $1 == 0 { withAnimation { minuteSelection = 1 } }
        }
        .background(Color(.ghostWhite))
        .presentationDetents([.height(sheetLength)])
        .presentationCornerRadius(20)
        .presentationDragIndicator(.visible)
    }
}

struct BreakButton: View {
    @EnvironmentObject var sessionModel: SessionModel
    
    @Binding fileprivate var counter: Int
    let minutes: Int
    let dismiss: DismissAction
    
    var body: some View {
        Button {
            sessionModel.breakTimes.append(Date() + TimeInterval(minutes*60))
            if sessionModel.breakTimes.count > 10 {
                sessionModel.breakTimes.removeFirst()
            }
            sessionModel.startBreak(minutes: minutes)
            dismiss()
        } label: {
            Capsule()
                .frame(height: 45)
                .foregroundStyle(.white)
                .overlay {
                    Text(counter > 0 ? "Break Available in \(counter)" : "Start Break")
                        .foregroundStyle(counter > 0 ? Color.gray : Color(.eggplant))
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)
        }
        .disabled(counter > 0)
        .onAppear { counter = sessionModel.getCurrentWaitTime() }
    }
}

#Preview {
    StartBreakView()
}
