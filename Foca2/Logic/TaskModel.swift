//
//  TaskModel.swift
//  Foca2
//
//  Created by Adit G on 11/30/23.
//

import SwiftUI
import CoreData

class TaskModel: ObservableObject {
    private var task: TaskItem
    private var moc: NSManagedObjectContext
    
    @Published var hasDueDate: Bool
    @Published var hasReminderDate: Bool
    @Published var hasNotes: Bool
    
    init(task: TaskItem, moc: NSManagedObjectContext) {
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
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
        
        task.reminderDate = date
        self.hasReminderDate = true
    }
    
    public func removeReminderDate() {
        self.hasReminderDate = false
        task.reminderDate = nil
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id?.uuidString ?? ""])
    }
    
    public func scheduleNotification(date: Date, id: String) {
        let content = UNMutableNotificationContent()
        content.title = task.wrappedTitle
        content.subtitle = date.formatted(date: .abbreviated, time: .shortened)
        content.interruptionLevel = .timeSensitive
        content.sound = UNNotificationSound.default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .minute, .hour], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
    
    public func rinseAndRepeat() throws {
        if task.wrappedTitle.isEmpty {
            throw TaskModelError.BlankTitle
        }
        
        if task.managedObjectContext == nil {
            let newTask = TaskItem(context: moc)
            newTask.title = task.title
            newTask.doDate = task.doDate
            newTask.reminderDate = task.reminderDate
            newTask.notes = task.notes
            newTask.completed = task.completed
            task = newTask
        }
        
        do {
            if task.id == nil {
                task.id = UUID()
            }
            task.createdDate = Date()
            try moc.save()
        } catch {
            task.createdDate = nil
            throw TaskModelError.CoreDataIssue
        }
        
        if hasReminderDate {
            scheduleNotification(date: task.reminderDate!, id: task.id!.uuidString)
        }
        
        hasDueDate = false
        hasReminderDate = false
        hasNotes = false
        let cachedDate = task.doDate
        task = TaskItem(entity: TaskItem.entity(), insertInto: nil)
        if cachedDate != nil {
            setDueDate(cachedDate!)
        }
    }
}

enum TaskModelError: Error {
    case BlankTitle
    case NilValue
    case CoreDataIssue
    case ImageSaveError
}
