//
//  TaskRowExtraInfo.swift
//  Foca2
//
//  Created by Adit G on 4/9/24.
//

import SwiftUI

struct TaskRowExtraInfo: View {
    @ObservedObject var task: TaskItem
    let size: CGFloat = 12
    
    func isDatePast(date: Date) -> Bool {
        let now = Date()
        let nowComps = now.getComponents([.year, .month, .day])
        let dateComps = date.getComponents([.year, .month, .day])
        if nowComps.year == dateComps.year && nowComps.month == dateComps.month && nowComps.day == dateComps.day {
            return false
        }
        
        return date < now
    }
    
    var body: some View {
        HStack {
            if task.doDate != nil {
                Image(systemName: "calendar")
                
                Text(task.doDate!.formatted(date: .abbreviated, time: .omitted))
                    .foregroundStyle(isDatePast(date: task.doDate!) ? .red : Color(.coolGray))
                
                if task.reminderDate != nil {
                    Circle()
                        .frame(width: 3)
                    
                    Image(systemName: "bell")
                }
            }
            else if task.reminderDate != nil {
                Image(systemName: "bell")
                
                Text(task.reminderDate!.formatted(date: .abbreviated, time: .omitted) )
            }
            
            if task.notes != nil {
                Circle()
                    .frame(width: 3)
                
                Image(systemName: "pencil.and.scribble")
            }
            
            Spacer()
        }
        .font(.system(size: size))
        .foregroundStyle(Color(.coolGray))
    }
}

#Preview {
    TaskRowExtraInfo(task: DataController.previewTask)
}
