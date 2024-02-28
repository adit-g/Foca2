//
//  DataController.swift
//  Foca2
//
//  Created by Adit G on 11/1/23.
//

import CoreData
import SwiftUI

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "Foca2")
    static let shared = DataController()
    
    init(inMemory: Bool = false) {
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            let storeURL = URL.storeURL(for: "group.2L6XN9RA4T.focashared", databaseName: "Foca2")
            let storeDescription = NSPersistentStoreDescription(url: storeURL)
            container.persistentStoreDescriptions = [storeDescription]
        }
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load \(error.localizedDescription)")
            }
            
            self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        }
    }
    
    @MainActor func saveTasksImage() {
        let today = Date()
        let data0 = renderTaskImage(for: today)?.jpegData(compressionQuality: 1.0)
        
        UserDefaults(suiteName: "group.2L6XN9RA4T.focashared")!.set(data0, forKey: "image")
    }
    
    @MainActor func renderTaskImage(for date: Date) -> UIImage? {
        let renderer = ImageRenderer(content:
            DummyTaskTile(at: date)
                .environment(\.managedObjectContext, container.viewContext)
        )
        return renderer.uiImage
    }
    
    func getTasksImage() -> UIImage? {
        let data = UserDefaults(suiteName: "group.2L6XN9RA4T.focashared")!.value(forKey: "image")
        return UIImage(data: data as! Data)
    }
    
    static var previewTask: TaskItem = {
        let controller = DataController(inMemory: true)

        let task = TaskItem(context: controller.container.viewContext)
        task.title = "task 1"
        task.doDate = Date()
        try? controller.container.viewContext.save()

        return task
    }()
}
