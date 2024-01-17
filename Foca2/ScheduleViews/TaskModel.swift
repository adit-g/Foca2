//
//  TaskModel.swift
//  Foca2
//
//  Created by Adit G on 11/30/23.
//

import SwiftUI
import CoreData

enum TaskModelError: Error {
    case blankTitle
    case nilValue
}

class TaskModel: ObservableObject {
    private var task: Task
    private var moc: NSManagedObjectContext
    
    @Published var hasDueDate: Bool
    
    init(task: Task, moc: NSManagedObjectContext) {
        self.task = task
        self.moc = moc
        self._hasDueDate = Published(wrappedValue: task.doDate != nil)
    }
    
    public func getDate() throws -> Date {
        if task.doDate == nil {
            throw TaskModelError.nilValue
        }
        return task.doDate!
    }
    
    public func setDate(_ date: Date) {
        task.doDate = date
        self.hasDueDate = true
    }
    
    public func removeDueDate() {
        self.hasDueDate = false
        task.doDate = nil
    }
    
//    func deleteTask(_ task: Task) {
//        task.managedObjectContext?.delete(task)
//    }
//    
//    func addTask(title: String, notes: String, isScheduled: Bool, date: Date) throws {
//        let newTask = Task(context: moc)
//        newTask.createdDate = Date()
//        try updateTask(task: newTask, title: title, notes: notes, isScheduled: isScheduled, date: date)
//    }
//    
//    func updateTask(task: Task, title: String, notes: String, isScheduled: Bool, date: Date) throws {
//        if title.isEmpty {
//            throw TaskModelError.blankTitle
//        }
//        
//        task.title = title
//        task.completed = false
//        
//        if !notes.isEmpty { task.notes = notes }
//        if isScheduled { task.doDate = date }
//
//        try? moc.save()
//    }
}
