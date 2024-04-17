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
    
    private var difficulty: Difficulty {
        Difficulty(rawValue: sessionModel.difficultyInt) ?? .normal
    }
    
    var body: some View {
        VStack {
            VStack (spacing: 0) {
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
                    .pickerStyle(.wheel)
                    .frame(height: 220)
                    
                    Text(minuteSelection < 2 ? "minute" : "minutes")
                        .offset(x: 55)
                }
                
                BreakButton(
                    counter: $timeRemaining,
                    minutes: minuteSelection,
                    dismiss: dismiss,
                    difficulty: difficulty
                )
                .onReceive(timer) { _ in
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    }
                }
            }
            .foregroundStyle(Color(.spaceCadet))
            .readSize(onChange: { sheetLength = $0.height })
            Spacer()
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
    let difficulty: Difficulty
    
    var body: some View {
        Button {
            sessionModel.startBreak(minutes: minutes)
            dismiss()
        } label: {
            Capsule()
                .frame(height: 45)
                .foregroundStyle(.white)
                .overlay { BreakText }
                .padding(.horizontal)
        }
        .disabled(counter > 0 || difficulty == .deepfocus)
        .onAppear { counter = sessionModel.getCurrentWaitTime() }
    }
    
    var BreakText: some View {
        let txt: String
        switch difficulty {
        case .normal:
            txt = counter > 0 ? "Break Available in \(counter)" : "Start Break"
        case .timeout:
            txt = counter > 0 ? "Break Available in \(counter)" : "Start Break"
        case .deepfocus:
            txt = "Break Unavailable"
        }
        return Text(txt)
            .foregroundStyle(counter > 0 || difficulty == .deepfocus ? Color.gray : Color(.eggplant))
            .fontWeight(.semibold)
        
    }
}

#Preview {
    StartBreakView()
        .environmentObject(SessionModel())
}
