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
    
    @ObservedObject var taskModel: TaskModel
    
    let isItSunday = Calendar.current.dateComponents([.weekday], from: Date()).weekday! == 1
    let today = Date()
    let tomorrow: Date = Date() + 86400
    let nextWeek: Date = Calendar.current.nextDate(
        after: Date() + 86400,
        matching: DateComponents(weekday: 2),
        matchingPolicy: .nextTime
    )!
    
    @State private var storedSheetLength = CGFloat.zero
    @State private var sheetLength = CGFloat.zero
    @State private var showDateView = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    SheetHeader(title: "Schedule", doneAction: { dismiss() })
                    
                    getConvenienceButton(imageName: "clock.arrow.circlepath", text: "Today", dateToSelect: today)
                    getConvenienceButton(imageName: "arrowshape.turn.up.right", text: "Tomorrow", dateToSelect: tomorrow)
                    getConvenienceButton(imageName: "arrowshape.turn.up.left.2", text: "Next Week", dateToSelect: nextWeek, flipImage: true)
                        .disabled(isItSunday)
                        .opacity(isItSunday ? 0.5 : 1)
                    
                    PickADateButton(title: "Pick a Date")
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
                        setAction: setAction,
                        storedSheetLength: storedSheetLength,
                        components: .date
                    )
                }
                .onAppear {
                    self.storedSheetLength = sheetLength
                }
            }
        }
        .presentationCornerRadius(20)
        .presentationDetents([.height(sheetLength)])
        .presentationBackground(Color(.mediumBlue))
    }
    
    private func setAction(_ date: Date) {
        taskModel.setDueDate(date)
        dismiss()
    }
    
    @ViewBuilder
    private func getConvenienceButton(
        imageName: String,
        text: String,
        dateToSelect: Date,
        flipImage: Bool = false
    ) -> some View {
        Button {
            setAction(dateToSelect)
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
