//
//  ChooseDateView.swift
//  Foca2
//
//  Created by Adit G on 1/14/24.
//

import SwiftUI

struct ChooseDateView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var sheetSize: CGFloat
    @ObservedObject var taskModel: TaskModel
    let previousDismissAction: DismissAction
    let storedSheetLength: CGFloat
    @State private var chosenDate = Date()
    
    var body: some View {
        Form {
            DatePicker("Pick a Date", selection: $chosenDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
        }
        .scrollContentBackground(.hidden)
        .background(Color(.blue))
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    sheetSize = storedSheetLength
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 12, maxHeight: 12)
                        
                        Text("Back")
                    }
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("Pick a Date")
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Set") {
                    taskModel.setDate(chosenDate)
                    previousDismissAction()
                }
            }
        }
    }
}
