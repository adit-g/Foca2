//
//  Task+CoreDataProperties.swift
//  Foca2
//
//  Created by Adit G on 12/1/23.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var completed: Bool
    @NSManaged public var doDate: Date?
    @NSManaged public var duration: Int16
    @NSManaged public var endTime: Date?
    @NSManaged public var createdDate: Date?
    @NSManaged public var startTime: Date?
    @NSManaged public var title: String?
    @NSManaged public var notes: String?
    @NSManaged public var subtasks: NSSet?

    public var wrappedTitle: String { title ?? "" }
    public var wrappedNotes: String { notes ?? "" }
    
    public var subtaskArray: [SubTask] {
        let set = subtasks as? Set<SubTask> ?? []
        return set.sorted {
            $0.id < $1.id
        }
    }
}

// MARK: Generated accessors for subtasks
extension Task {

    @objc(addSubtasksObject:)
    @NSManaged public func addToSubtasks(_ value: SubTask)

    @objc(removeSubtasksObject:)
    @NSManaged public func removeFromSubtasks(_ value: SubTask)

    @objc(addSubtasks:)
    @NSManaged public func addToSubtasks(_ values: NSSet)

    @objc(removeSubtasks:)
    @NSManaged public func removeFromSubtasks(_ values: NSSet)

}

extension Task : Identifiable {

}
