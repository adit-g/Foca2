//
//  TaskModel.swift
//  Foca2
//
//  Created by Adit G on 11/30/23.
//

import SwiftUI
import CoreData

class TaskModel: ObservableObject {
    let moc: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.moc = context
    }
    
    func deleteTask(_ task: Task) {
        moc.delete(task)
    }
    
    func updateTask(title: String, notes: String, isScheduled: Bool,
                 isTimed: Bool, isDurated: Bool, date: Date, startTime: Date,
                 endTime: Date, duration: Int, task: Task?) throws {
        let wrappedTask: Task = task ?? Task(context: moc)
        
        if title.isEmpty {
            throw TaskModelError.blankTitle
        }
        if isTimed && !isScheduled {
            throw TaskModelError.invalidTimes
        }
        
        wrappedTask.title = title
        wrappedTask.completed = false
        
        if task == nil { wrappedTask.createdDate = Date() }
        if !notes.isEmpty { wrappedTask.notes = notes }
        if isScheduled { wrappedTask.doDate = date }
        if isTimed {
            let startComponents = Calendar.current.dateComponents([.hour, .minute], from: startTime)
            let endComponents = Calendar.current.dateComponents([.hour, .minute], from: endTime)
            guard let correctStartTime = Calendar.current.date(
                bySettingHour: startComponents.hour!,
                minute: startComponents.minute!,
                second: 0, of: date
            ) else {
                throw TaskModelError.invalidTimes
            }
            
            let correctEndTime: Date
            if endComponents.hour! < startComponents.hour! || (endComponents.hour! == startComponents.hour! && endComponents.minute! < startComponents.minute!) {
                var comps = DateComponents()
                comps.day = 1
                let nextDay = Calendar.current.date(byAdding: comps, to: date)!
                let nextDayEndTime = Calendar.current.date(bySettingHour: endComponents.hour!, minute: endComponents.minute!, second: 0, of: nextDay)
                guard nextDayEndTime != nil else {
                    throw TaskModelError.invalidTimes
                }
                correctEndTime = nextDayEndTime!
            } else {
                let todayEndTime = Calendar.current.date(bySettingHour: endComponents.hour!, minute: endComponents.minute!, second: 0, of: date)
                guard todayEndTime != nil else {
                    throw TaskModelError.invalidTimes
                }
                correctEndTime = todayEndTime!
            }
            
            wrappedTask.startTime = correctStartTime
            wrappedTask.endTime = correctEndTime
        }
        //TODO: make duration tied up with start and end time
        if isDurated { wrappedTask.duration = Int16(duration) }
        else { wrappedTask.duration = -1 }
        
        try? moc.save()
    }
}
