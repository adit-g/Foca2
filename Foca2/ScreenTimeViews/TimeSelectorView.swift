//
//  TimeSelectorView.swift
//  Foca2
//
//  Created by Adit G on 1/24/24.
//

import SwiftUI

struct TimeSelectorView: View {
    let size: CGSize
    @Binding var minutes: Int
    @State private var hourSelection = 0
    @State private var minuteSelection = 6
    
    private var selectedMinutes: Int {
        hourSelection * 60 + minuteSelection * 5
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            Picker("Hour Picker", selection: $hourSelection) {
                ForEach(0..<24) { row in
                    Text(row.description)
                        .fontWeight(.bold)
                }
            }
            .pickerStyle(.wheel)
            .frame(
                width: size.width / 4,
                height: size.height)
            
            Text("hours")
            
            Picker("Minute Picker", selection: $minuteSelection) {
                ForEach(0..<12) { row in
                    let row2 = row * 5
                    Text(row2.description)
                        .fontWeight(.bold)
                }
            }
            .pickerStyle(.wheel)
            .frame(
                width: size.width / 4,
                height: size.height)
            
            
            Text("mins")
            
            Spacer()
        }
        .foregroundStyle(Color(.spaceCadet))
        .onAppear { minutes = 30 }
        .onChange(of: selectedMinutes) {
            withAnimation {
                if hourSelection == 0 && minuteSelection == 0 {
                    minuteSelection = 1
                }
                
                minutes = selectedMinutes
            }
        }
    }
}
