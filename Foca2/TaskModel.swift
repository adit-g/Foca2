//
//  TaskModel.swift
//  Foca2
//
//  Created by Adit G on 11/30/23.
//

import SwiftUI
import CoreData

enum TaskModelError: Error {
    case BlankTitle
    case NilValue
    case CoreDataIssue
}

class TaskModel: ObservableObject {
    private var task: Task
    private var moc: NSManagedObjectContext
    
    @Published var hasDueDate: Bool
    @Published var hasReminderDate: Bool
    @Published var hasNotes: Bool
    
    init(task: Task, moc: NSManagedObjectContext) {
        self.task = task
        self.moc = moc
        self._hasDueDate = Published(wrappedValue: task.doDate != nil)
        self._hasReminderDate = Published(wrappedValue: task.reminderDate != nil)
        self._hasNotes = Published(wrappedValue: !task.wrappedNotes.isEmpty)
    }
    
    public func setTitle(_ title: String) {
        task.title = title
    }
    
    public func getNote() -> String {
        return task.wrappedNotes
    }
    
    public func setNote(_ note: String) {
        hasNotes = !note.isEmpty
        task.notes = note
    }
    
    public func getDueDate() throws -> Date {
        if task.doDate == nil {
            throw TaskModelError.NilValue
        }
        return task.doDate!
    }
    
    public func setDueDate(_ date: Date) {
        task.doDate = date
        self.hasDueDate = true
    }
    
    public func removeDueDate() {
        self.hasDueDate = false
        task.doDate = nil
    }
    
    public func getReminderDate() throws -> Date {
        if task.reminderDate == nil {
            throw TaskModelError.NilValue
        }
        return task.reminderDate!
    }
    
    public func setReminderDate(_ date: Date) {
        task.reminderDate = date
        self.hasReminderDate = true
    }
    
    public func removeReminderDate() {
        self.hasReminderDate = false
        task.reminderDate = nil
    }
    
    public func rinseAndRepeat() throws {
        if task.wrappedTitle.isEmpty {
            throw TaskModelError.BlankTitle
        }
        
        do {
            task.createdDate = Date()
            try moc.save()
        } catch {
            task.createdDate = nil
            throw TaskModelError.CoreDataIssue
        }
        
        hasDueDate = false
        hasReminderDate = false
        hasNotes = false
        task = Task(context: moc)
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
