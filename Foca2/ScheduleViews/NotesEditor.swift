//
//  NotesEditor.swift
//  Foca2
//
//  Created by Adit G on 1/18/24.
//

import SwiftUI

struct NotesEditor: View {
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focus: Bool
    @ObservedObject var taskModel: TaskModel
    @State var notes: String
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Note")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Button("Done") {
                    taskModel.setNote(notes)
                    dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()
            }
            
            Divider()

            ScrollView {
                TextField("Add Notes", text: $notes, axis: .vertical)
                    .padding()
                    .focused($focus)
                    .onAppear { focus = true }
            }
        }
        .presentationCornerRadius(20)
        .presentationBackground(Color(.blue))
    }
}
