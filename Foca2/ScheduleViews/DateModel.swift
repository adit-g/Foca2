//
//  DateModel.swift
//  Foca2
//
//  Created by Adit G on 11/2/23.
//

import Foundation

class DateModel: ObservableObject {
    @Published var week: [Date] = []
    
    init() {
        fetchCurrentWeek()
    }
    
    func fetchCurrentWeek() {
        let today = Date()
        let calendar = Calendar.current
        guard let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: today) else { return }
        let previousWeek = calendar.dateInterval(of: .weekOfMonth, for: oneWeekAgo)
        guard let firstWeekDay = previousWeek?.start else { return }
        
        (0...20).forEach { dayNum in
            if let weekday = calendar.date(byAdding: .day, value: dayNum, to: firstWeekDay) {
                week.append(weekday)
            }
        }
    }
    
    func incrementWeek() {
        let calendar = Calendar.current
        guard let lastDay = week.last else { return }
        var newWeek: [Date] = []
        
        (1...7).forEach { dayNum in
            if let weekday = calendar.date(byAdding: .day, value: dayNum, to: lastDay) {
                newWeek.append(weekday)
            }
        }

        week = Array(week.dropFirst(7)) + newWeek
    }
    
    func decrementWeek() {
        let calendar = Calendar.current
        guard let firstDay = week.first else { return }
        var newWeek: [Date] = []
        
        ((-7)...(-1)).forEach { dayNum in
            if let weekday = calendar.date(byAdding: .day, value: dayNum, to: firstDay) {
                newWeek.append(weekday)
            }
        }
        
        week = newWeek + Array(week.dropLast(7))
    }
    
    static func getDateStr(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
