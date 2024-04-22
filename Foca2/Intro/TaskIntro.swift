//
//  TaskIntro.swift
//  Foca2
//
//  Created by Adit G on 4/12/24.
//

import SwiftUI

struct TaskIntro: View {
    @Environment(\.managedObjectContext) var moc
    @State private var taskCreaterOpen = false
    let nextView: () -> ()
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("add at least one task that you have to do today")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(.chineseViolet))
                    .padding(.horizontal)
                
                Spacer()
                
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
            .padding(.top, 60)
            
            Tasks(taskCreaterOpen: $taskCreaterOpen)
            
            Spacer()
            
            Button {
                nextView()
            } label: {
                Capsule()
                    .foregroundStyle(Color(.chineseViolet))
                    .frame(height: 45)
                    .padding(.horizontal, 30)
                    .overlay(Text("continue").foregroundStyle(Color(.white)))
                    .padding(.bottom)
            }
        }
        .background(Color(.ghostWhite))
        .sheet(isPresented: $taskCreaterOpen) {
            TaskEditor(date: Date(), context: moc)
        }
        .onAppear {
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000)
                taskCreaterOpen = true
            }
            
        }
        
    }
}

#Preview {
    TaskIntro(nextView: {})
}
