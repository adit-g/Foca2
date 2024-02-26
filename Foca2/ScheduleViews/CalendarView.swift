//
//  CalendarView.swift
//  Foca2
//
//  Created by Adit G on 1/9/24.
//

import SwiftUI
import CalendarKit

struct CalendarView: UIViewControllerRepresentable {
    
    @Binding var date: Date
    
    func makeUIViewController(context: Context) -> CalendarNavigationController {
        let calendarController = CalendarViewController()
        return CalendarNavigationController(date: $date, rootViewController: calendarController)
    }

    func updateUIViewController(_ uiViewController: CalendarNavigationController, context: Context) {
        uiViewController.state?.client(client: uiViewController, didMoveTo: date)
    }
}
