//
//  DueDateSelection.swift
//  Foca2
//
//  Created by Adit G on 1/12/24.
//

import SwiftUI
import CoreData

struct DueDateSelection: View {
    @Environment(\.dismiss) var dismiss
    
    let isItMonday = Calendar.current.dateComponents([.weekday], from: Date()).weekday! == 1
    
    @ObservedObject var taskModel: TaskModel
    @State private var storedSheetLength = CGFloat.zero
    @State private var sheetLength = CGFloat.zero
    @State private var showDateView = false
    
    let today = Date()
    let tomorrow: Date = Date() + 86400
    let nextWeek: Date = Calendar.current.nextDate(
        after: Date() + 86400,
        matching: DateComponents(weekday: 2),
        matchingPolicy: .nextTime
    )!
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ZStack {
                        Text("Schedule")
                            .font(.system(size: 20, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Button("Done") {
                            dismiss()
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding()
                    }
                    
                    getConvenienceButton(imageName: "clock.arrow.circlepath", text: "Today", dateToSelect: today)
                    getConvenienceButton(imageName: "arrowshape.turn.up.right", text: "Tomorrow", dateToSelect: tomorrow)
                    getConvenienceButton(imageName: "arrowshape.turn.up.left.2", text: "Next Week", dateToSelect: nextWeek, flipImage: true)
                        .disabled(isItMonday)
                        .opacity(isItMonday ? 0.5 : 1)
                    
                    HStack (spacing: 0) {
                        Image(systemName: "calendar")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 24)
                            .padding(.horizontal)
                            .foregroundStyle(Color(.black))
                        
                        Text("Pick a Date")
                            .foregroundStyle(Color(.black))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 12, maxHeight: 12)
                            .padding(.horizontal)
                        
                    }
                    .padding(.bottom)
                    .onTapGesture {
                        sheetLength = 450
                        showDateView = true
                    }
                }
                .readSize(onChange: { sheetLength = $0.height })
                .navigationDestination(isPresented: $showDateView) {
                    ChooseDateView(
                        sheetSize: $sheetLength,
                        taskModel: taskModel,
                        previousDismissAction: dismiss,
                        storedSheetLength: storedSheetLength
                    )
                }
                .onAppear {
                    self.storedSheetLength = sheetLength
                }
            }
        }
        .presentationCornerRadius(20)
        .presentationDetents([.height(sheetLength)])
        .presentationBackground(Color(.blue))
    }
    
    @ViewBuilder
    private func getConvenienceButton(
        imageName: String,
        text: String,
        dateToSelect: Date,
        flipImage: Bool = false
    ) -> some View {
        Button {
            taskModel.setDate(dateToSelect)
            dismiss()
        } label: {
            HStack (spacing: 0) {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 24)
                    .padding(.horizontal)
                    .foregroundStyle(Color(.black))
                    .rotation3DEffect(
                        flipImage ? .degrees(180) : .zero,
                        axis: (x: 0.0, y: 1.0, z: 0.0)
                    )
                
                Text(text)
                    .foregroundStyle(Color(.black))
                
                Spacer()
                
                Text(DateModel.getDateStr(date: dateToSelect, format: "E"))
                    .font(.system(size: 14))
                    .foregroundStyle(Color(.darkGray))
                    .padding(.horizontal)
            }
            .padding(.bottom)
        }
    }
}
