//
//  DateSelector.swift
//  Foca2
//
//  Created by Adit G on 11/2/23.
//

import SwiftUI
import Combine

struct DateSelector: View {
    
    @Binding var date: Date
    let bgColor: String
    
    @StateObject var dateModel = DateModel()
    @State private var xOffset = CGFloat.zero
    @State private var dateSize = CGSize.zero
    @State private var lineSize = CGSize.zero
    
    var datesWidth: CGFloat {
        UIScreen.width - dateSize.width - lineSize.width + 5
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(DateModel.getDescriptiveDateStr(date: date, format: "MMM d"))
                .fontWeight(.semibold)
                .font(.title)
                .padding(.bottom)
                .foregroundStyle(Color(.spaceCadet))
            
            HStack(spacing: 0) {
                YearView
                
                Divider

                DatesView
            }
        }
        .onChange(of: date) { _, newVal in
            if newVal >= dateModel.week[14] {
                incWeek()
            } else if newVal < dateModel.week[7] {
                decWeek()
            }
        }
    }
    
    private func decWeek() {
        withAnimation(.linear(duration: 0.2)) {
            xOffset = datesWidth
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.none) {
                dateModel.decrementWeek()
                xOffset = 0
            }
        }
    }
    
    private func incWeek() {
        withAnimation(.linear(duration: 0.2)) {
            xOffset = -datesWidth
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.none) {
                dateModel.incrementWeek()
                xOffset = 0
            }
        }
    }
    
    var YearView: some View {
        VStack(spacing: 0) {
            Text(DateModel.getDateStr(date: dateModel.week[7], format: "yyyy"))
                .fontWeight(.semibold)
                .font(.subheadline)
                .foregroundStyle(Color(.spaceCadet))
            
            Text(DateModel.getDateStr(date: dateModel.week[7], format: "MMM"))
                .fontWeight(.semibold)
                .font(.title2)
                .padding(.vertical, 5)
                .foregroundStyle(Color(.spaceCadet))
        }
        .frame(minWidth: 50)
        .padding(.leading)
        .background(Color(bgColor))
        .zIndex(2.0)
        .readSize(onChange: { dateSize = $0 })
    }
    
    var Divider: some View {
        RoundedRectangle(cornerRadius: 3)
            .frame(width: 2, height: 20)
            .foregroundStyle(.gray)
            .padding([.leading, .vertical])
            .padding(.trailing, 6)
            .zIndex(2.0)
            .background(Color(bgColor))
            .padding(.trailing, 8)
            .readSize(onChange: { lineSize = $0 })
    }
    
    var DatesView: some View {
        HStack (spacing: 0) {
            ForEach(dateModel.week, id: \.self) { day in
                getDateView(day: day)
            }
        }
        .frame(width: datesWidth)
        .offset(x: xOffset)
        .highPriorityGesture(DragGesture()
            .onChanged { xOffset = $0.translation.width }
            .onEnded { handleWeekChange(swipeOffset: $0.translation.width) }
        )
        .offset(x:-7)
    }
    
    func handleWeekChange(swipeOffset: CGFloat) {
        if swipeOffset > 80 {
            decWeek()
        } else if swipeOffset < -80 {
            incWeek()
        } else {
            withAnimation(.linear.speed(2)) {
                xOffset = 0
            }
        }
    }
    
    @ViewBuilder
    func getDateView(day: Date) -> some View {
        let isSelected = Calendar.current.isDate(date, equalTo: day, toGranularity: .day)
        VStack (spacing: 0) {
            Text(DateModel.getDateStr(date: day, format: "EEEEE"))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color(.spaceCadet))
                
            Text(DateModel.getDateStr(date: day, format: "d"))
                .foregroundColor(isSelected ? Color(bgColor) : Color(.spaceCadet))
                .font(.subheadline)
                .padding(.vertical, 5)
                .background {
                    Circle()
                        .frame(width: datesWidth / 7)
                        .opacity(isSelected ? 1 : 0)
                        .foregroundStyle(.black)
                }
                .padding(5)
        }
        .frame(width: datesWidth / 7)
        .onTapGesture { date = day }
    }
    
}

#Preview {
    DateSelector(date: .constant(Date()), bgColor: "blue")
}
