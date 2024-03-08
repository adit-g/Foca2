//
//  TaskRow.swift
//  Foca2
//
//  Created by Adit G on 12/4/23.
//

import SwiftUI

struct TaskRow: View {
    @Environment(\.managedObjectContext) var moc
    @State var xOffset: CGFloat = 0
    @State var deleteButtonHidden = true
    
    @ObservedObject var passedTask: TaskItem
    @Binding var editTask: TaskItem?
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: .init(colors: [.pink, .red]), startPoint: .leading, endPoint: .trailing)
            
            HStack {
                Spacer()
                
                Button(action: { moc.delete(passedTask) }) {
                    Image(systemName: "trash")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 15, height: 15)
                }
                .padding(.horizontal, 20)
            }
            
            HStack(spacing: 0) {
                Image(systemName: passedTask.completed ? "largecircle.fill.circle" : "circle")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .padding(.horizontal, 15)
                    .onTapGesture {
                        withAnimation {
                            passedTask.completed.toggle()
                            try? moc.save()
                        }
                    }
                
                Text(passedTask.wrappedTitle)
                    .strikethrough(passedTask.completed)
                
                Spacer()
            }
            .padding(.vertical, 10)
            .foregroundStyle(passedTask.completed ? .gray : .black)
            .background(Rectangle().fill(.white))
            .offset(x: xOffset)
            .onTapGesture { editTask = passedTask }
            .highPriorityGesture(DragGesture().onChanged(onChanged).onEnded(onEnded))
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    func onChanged(_ value: DragGesture.Value) {
        if deleteButtonHidden && value.translation.width < 0 {
            xOffset = value.translation.width
        } else if !deleteButtonHidden && value.translation.width < 55 {
            xOffset = -55 + value.translation.width
        }
    }
    
    func onEnded(_ value: DragGesture.Value) {
        withAnimation(.easeOut) {
            if value.translation.width > -30 {
                xOffset = 0
                deleteButtonHidden = true
            } else if value.translation.width > -150 {
                xOffset = -55
                deleteButtonHidden = false
            } else {
                xOffset = 0
                moc.delete(passedTask)
            }
        }
    }
    
}
