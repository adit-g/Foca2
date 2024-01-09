//
//  SubTask+CoreDataProperties.swift
//  Foca2
//
//  Created by Adit G on 11/2/23.
//
//

import Foundation
import CoreData


extension SubTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubTask> {
        return NSFetchRequest<SubTask>(entityName: "SubTask")
    }

    @NSManaged public var completed: Bool
    @NSManaged public var id: Int16
    @NSManaged public var title: String?
    @NSManaged public var task: Task?

    public var wrappedTitle: String {
        title ?? ""
    }
}

extension SubTask : Identifiable {

}
