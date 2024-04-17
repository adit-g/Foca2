//
//  Tasks.swift
//  Foca2
//
//  Created by Adit G on 4/8/24.
//

import SwiftUI
import CoreData

struct TaskView: View {
    @Environment(\.managedObjectContext) var moc
    @State private var taskCreaterOpen = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Tasks")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(.chineseViolet))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.horizontal, .top])
                    .padding(.bottom, 10)
                
                Button("+ Add") {
                    taskCreaterOpen = true
                }
                .foregroundStyle(Color(.chineseViolet))
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background {
                    Capsule()
                        .foregroundStyle(Color(.ghostWhite))
                        .shadow(radius: 3)
                }
                .padding(.horizontal)
            }
            
            Tasks(taskCreaterOpen: $taskCreaterOpen)
        }
        .background(Color(.ghostWhite))
        .sheet(isPresented: $taskCreaterOpen) {
            TaskEditor(date: Date(), context: moc)
        }
    }
    
}

#Preview {
    TaskView()
}
