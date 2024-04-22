//
//  ReminderDateSelection.swift
//  Foca2
//
//  Created by Adit G on 1/17/24.
//

import SwiftUI
import CoreData

struct ReminderDateSelection: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var taskModel: TaskModel
    
    let isItSunday = Calendar.current.dateComponents([.weekday], from: Date()).weekday! == 1
    let isItLate = Calendar.current.dateComponents([.hour], from: Date()).hour! > 20
    let laterToday = {
        let date = Date()
        let currentHour = Calendar.current.dateComponents([.hour], from: date).hour!
        let reminderHour = min(currentHour + 3, 23)
        
        return Calendar.current.date(bySettingHour: reminderHour, minute: 0, second: 0, of: date)!
    }()
    let tomorrow = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date() + 86400)!
    let nextWeek = {
        let nextMonday = Calendar.current.nextDate(
            after: Date() + 86400,
            matching: DateComponents(weekday: 2),
            matchingPolicy: .nextTime
        )!
        return Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: nextMonday)!
    }()
    
    @State private var storedSheetLength = CGFloat.zero
    @State private var sheetLength = CGFloat.zero
    @State private var showDateView = false
    
    var body: some View {
        NavigationStack {
            VStack {
                SheetHeader(title: "reminder", doneAction: { dismiss() })
                
                getConvenienceButton(imageName: "clock.arrow.circlepath", text: "later today", dateToSelect: laterToday, hideDate: isItLate)
                    .disabled(isItLate)
                    .opacity(isItLate ? 0.5 : 1)
                
                getConvenienceButton(imageName: "arrowshape.turn.up.right", text: "tomorrow", dateToSelect: tomorrow)
                
                getConvenienceButton(imageName: "arrowshape.turn.up.left.2", text: "next week", dateToSelect: nextWeek, flipImage: true)
                    .disabled(isItSunday)
                    .opacity(isItSunday ? 0.5 : 1)
                
                PickADateButton(title: "pick a date & time")
                    .padding(.bottom)
                    .onTapGesture {
                        sheetLength = 520
                        showDateView = true
                    }
            }
            .readSize(onChange: { sheetLength = $0.height })
            .navigationDestination(isPresented: $showDateView) {
                ChooseDateView(
                    sheetSize: $sheetLength,
                    setAction: setAction,
                    storedSheetLength: storedSheetLength,
                    components: [.date, .hourAndMinute]
                )
            }
            .onAppear {
                self.storedSheetLength = sheetLength
            }
            
            Spacer()
        }
        .presentationCornerRadius(20)
        .presentationDetents([.height(sheetLength)])
        .presentationBackground(Color(.ghostWhite))
        .presentationDragIndicator(.visible)
    }
    
    private func setAction(_ date: Date) {
        taskModel.setReminderDate(date)
        dismiss()
    }
    
    @ViewBuilder
    private func getConvenienceButton(
        imageName: String,
        text: String,
        dateToSelect: Date,
        flipImage: Bool = false,
        hideDate: Bool = false
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
                
                Text(DateModel.getDateStr(date: dateToSelect, format: "E h:mm a"))
                    .font(.system(size: 14))
                    .foregroundStyle(Color(.darkGray))
                    .padding(.horizontal)
                    .opacity(hideDate ? 0 : 1)
            }
            .padding(.bottom)
        }
    }
}
