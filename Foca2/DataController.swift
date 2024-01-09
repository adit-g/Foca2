//
//  DataController.swift
//  Foca2
//
//  Created by Adit G on 11/1/23.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "Foca2")
    
    init(inMemory: Bool = false) {
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load \(error.localizedDescription)")
            }
            
            self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        }
    }
    
    static var previewTask: Task = {
        let controller = DataController(inMemory: true)

        let task = Task(context: controller.container.viewContext)
        task.title = "task 1"
        task.startTime = Date()
        task.endTime = Date() + 3600
        task.doDate = Date()
        try? controller.container.viewContext.save()

        return task
    }()
}
