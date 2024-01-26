//
//  TaskItem+CoreDataProperties.swift
//  Foca2
//
//  Created by Adit G on 1/26/24.
//
//

import Foundation
import CoreData


extension TaskItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskItem> {
        return NSFetchRequest<TaskItem>(entityName: "TaskItem")
    }

    @NSManaged public var completed: Bool
    @NSManaged public var createdDate: Date?
    @NSManaged public var doDate: Date?
    @NSManaged public var notes: String?
    @NSManaged public var reminderDate: Date?
    @NSManaged public var title: String?
    
    public var wrappedTitle: String {
        title ?? ""
    }
    
    public var wrappedNotes: String {
        notes ?? ""
    }

}

extension TaskItem : Identifiable {

}
