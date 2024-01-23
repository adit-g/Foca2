//
//  Schedule.swift
//  Foca2
//
//  Created by Adit G on 11/2/23.
//

import SwiftUI

struct Schedule: View {
    
    @State private var selectedDate = Date()
    let backgroundColor = "lightblue"
    
    var body: some View {
        VStack {
            DateSelector(date: $selectedDate, bgColor: backgroundColor)
            TaskTile(at: selectedDate)
            CalendarView(date: $selectedDate)
        }
        .background(Color(backgroundColor))
    }
}

#Preview {
    Schedule()
}
