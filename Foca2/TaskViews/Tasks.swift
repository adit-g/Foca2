//
//  Tasks.swift
//  Foca2
//
//  Created by Adit G on 4/12/24.
//

import SwiftUI

struct Tasks: View {
    @Environment(\.managedObjectContext) var moc
    
    @Binding var taskCreaterOpen: Bool
    @State private var taskToEdit: TaskItem? = nil
    @State private var completedOpen = false
    
    var request1 : FetchRequest<TaskItem>
    var todo : FetchedResults<TaskItem> { request1.wrappedValue }
    
    var request2 : FetchRequest<TaskItem>
    var completed : FetchedResults<TaskItem> { request2.wrappedValue }
    
    init(taskCreaterOpen: Binding<Bool>) {
        self._taskCreaterOpen = taskCreaterOpen
        self.request1 = FetchRequest(
            entity: TaskItem.entity(),
            sortDescriptors: [NSSortDescriptor(key: "doDate", ascending: true)],
            predicate: NSPredicate(
                format: "completed = %@",
                false as NSNumber)
        )
        self.request2 = FetchRequest(
            entity: TaskItem.entity(),
            sortDescriptors: [NSSortDescriptor(key: "doDate", ascending: false)],
            predicate: NSPredicate(
                format: "completed = %@",
                true as NSNumber)
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                ForEach(todo) { item in
                    TaskRow(passedTask: item, editTask: $taskToEdit, showDetails: true)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                if !completed.isEmpty {
                    HStack {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .rotationEffect(completedOpen ? .degrees(90) : .zero)
                        Text("completed")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .foregroundStyle(Color(.chineseViolet))
                    .background{
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
                        withAnimation {
                            completedOpen.toggle()
                        }
                    }
                }
                
                if completedOpen {
                    ForEach(completed) { item in
                        TaskRow(passedTask: item, editTask: $taskToEdit, showDetails: true)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 10)
        }
        .sheet(item: $taskToEdit) {
            TaskEditor(task: $0, context: moc)
        }
    }
}

#Preview {
    Tasks(taskCreaterOpen: .constant(false))
}
