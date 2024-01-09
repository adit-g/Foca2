//
//  CalendarNavigationController.swift
//  Foca2
//
//  Created by Adit G on 1/9/24.
//

import SwiftUI
import CalendarKit

class CalendarNavigationController: UINavigationController, DayViewStateUpdating {
    
    @Binding var date: Date
    public var calendarViewController: CalendarViewController
    
    public weak var state: DayViewState? {
        willSet(newValue) {
            state?.unsubscribe(client: self)
        }
        didSet {
            state?.subscribe(client: self)
            calendarViewController.dayView.state = state
        }
    }
    public var calendar: Calendar = Calendar.autoupdatingCurrent
    
    public init(date: Binding<Date>, calendar: Calendar = Calendar.autoupdatingCurrent, rootViewController: CalendarViewController) {
        self._date = date
        self.calendarViewController = rootViewController
        super.init(rootViewController: rootViewController)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self._date = .constant(Date())
        self.calendarViewController = CalendarViewController()
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        if state == nil {
            let newState = DayViewState(date: date, calendar: calendar)
            newState.move(to: date)
            state = newState
        }
    }
    
    func move(from oldDate: Date, to newDate: Date) {
        self.date = newDate
    }
}
