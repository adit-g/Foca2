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
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Break Length")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                
                ZStack {
                    Picker("Minute Picker", selection: $minuteSelection) {
                        ForEach(0..<16) { row in
                            Text(row.description)
                                .fontWeight(.bold)
                        }
                    }
                    .pickerStyle(.wheel)
                    
                    Text(minuteSelection < 2 ? "minute" : "minutes")
                        .offset(x: 50)
                }
                
                Button {
                    sessionModel.startBreak(minutes: minuteSelection)
                } label: {
                    Capsule()
                        .frame(height: 45)
                        .foregroundStyle(.white)
                        .overlay {
                            Text("Start Break")
                                .foregroundStyle(Color(.eggplant))
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal)
                }
            }
            .readSize(onChange: { sheetLength = $0.height })
            .onChange(of: minuteSelection) {
                if $1 == 0 { withAnimation { minuteSelection = 1 } }
            }
        }
        .background(Color(.mediumBlue))
        .presentationDetents([.height(sheetLength)])
        .presentationCornerRadius(20)
    }
}

#Preview {
    StartBreakView()
}
