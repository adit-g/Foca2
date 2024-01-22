//
//  Task+CoreDataProperties.swift
//  Foca2
//
//  Created by Adit G on 1/17/24.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var completed: Bool
    @NSManaged public var createdDate: Date?
    @NSManaged public var doDate: Date?
    @NSManaged public var notes: String?
    @NSManaged public var title: String?
    @NSManaged public var reminderDate: Date?

    public var wrappedTitle: String {
        title ?? ""
    }
    
    public var wrappedNotes: String {
        notes ?? ""
    }
    
}

extension Task : Identifiable {

}
