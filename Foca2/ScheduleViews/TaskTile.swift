//
//  TaskTile.swift
//  Foca2
//
//  Created by Adit G on 11/29/23.
//

import SwiftUI
import CoreData

struct TaskTile: View {
    @Environment(\.managedObjectContext) var moc
    @State private var taskCreaterOpen = false
    @State private var taskToEdit: Task? = nil
    
    var itemsRequest : FetchRequest<Task>
    var items : FetchedResults<Task> { itemsRequest.wrappedValue }
    
    init(at date: Date) {
        let startDate = Calendar.current.startOfDay(for: date)
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let endDate = Calendar.current.date(byAdding: components, to: startDate)!

        self.itemsRequest = FetchRequest(
            entity: Task.entity(),
            sortDescriptors: [NSSortDescriptor(key: "createdDate", ascending: true)],
            predicate: NSPredicate(
                format: "doDate BETWEEN {%@, %@} AND title != %@ AND title != nil",
                startDate as CVarArg, endDate as CVarArg, "")
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopBar
            
            ForEach(items, id: \.self) { item in
                Divider()
                
                TaskRow(passedTask: item, editTask: $taskToEdit)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
        .sheet(isPresented: $taskCreaterOpen) {
            TaskEditor(context: moc)
        }
        .sheet(item: $taskToEdit) {
            TaskEditor(task: $0, context: moc)
        }
    }
    
    var TopBar: some View {
        HStack {
            Text("Tasks:")
            Spacer()
            Button("+ Add Task") {
                taskCreaterOpen = true
            }
        }
        .foregroundStyle(Color(.darkgray))
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Rectangle().fill(Color("blue")))
    }
}

struct TaskTile_Previews: PreviewProvider {
    static var previews: some View {
        TaskTile(at: Date())
    }
}
