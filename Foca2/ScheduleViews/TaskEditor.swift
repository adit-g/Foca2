//
//  TaskEditor.swift
//  Foca2
//
//  Created by Adit G on 1/10/24.
//

import SwiftUI
import CoreData

struct TaskEditor: View {
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool
    
    @StateObject private var taskModel: TaskModel
    
    @State private var taskTitle: String = ""
    @State private var sheetLength: CGFloat = .zero
    @State private var safeAreaBottom: CGFloat = .zero
    
    @State private var showDueDatePicker = false
    @State private var showReminderDatePicker = false
    @State private var showNotesEditor = false
    
    init(task: Task? = nil, context: NSManagedObjectContext) {
        let wrappedTask = task ?? Task(context: context)
        self._taskModel = StateObject(
            wrappedValue: TaskModel(
                task: wrappedTask,
                moc: context
            )
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                TitleRow
                ButtonRow
            }
            .padding(.vertical, max(0, 15 - safeAreaBottom / 2))
            .readSize(onChange: { sheetLength = $0.height })
        }
        .background(Color(.blue))
        .onAppear {
            isFocused = true
            safeAreaBottom = getSafeAreaBottom()
        }
        .presentationDetents([.height(sheetLength)])
        .presentationCornerRadius(20)
        .safeAreaPadding(.top, min(15, safeAreaBottom / 2))
        .sheet(isPresented: $showDueDatePicker,content: { DueDateSelection(taskModel: taskModel) })
    }
    
    private func getSafeAreaBottom() -> CGFloat{
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        return (keyWindow?.safeAreaInsets.bottom)!
    }
        
    var ButtonRow: some View {
        ScrollView(.horizontal) {
            HStack {
                getPickerButton(onClickBool: $showReminderDatePicker, imageName: "bell")
                
                if taskModel.hasDueDate {
                    DueDateCapsule
                } else {
                    getPickerButton(onClickBool: $showDueDatePicker, imageName: "calendar")
                }
                
                getPickerButton(onClickBool: $showNotesEditor, imageName: "pencil.and.scribble")
                
                Spacer()
            }
            .padding(.top, 5)
            .padding(.leading, 2)
        }
    }
    
//    @ViewBuilder
//    private func Image(name: String, size: CGFloat, )
    
    var DueDateCapsule: some View {
        let dueDateStr = DateModel.getDescriptiveDateStr(date: try! taskModel.getDate(), format: "E, MMM d")
        return HStack(spacing: 10) {
            Image(systemName: "calendar")
                .font(.system(size: 20))
                .foregroundStyle(Color(.blue))
                .onTapGesture { showDueDatePicker = true }
            
            Text("Due \(dueDateStr)")
                .foregroundStyle(Color(.blue))
                .font(.system(size: 16))
                .onTapGesture { showDueDatePicker = true }
            
            Circle()
                .frame(width: 20, height: 20)
                .foregroundStyle(Color(.blue))
                .overlay{
                    Image(systemName: "xmark")
                        .font(.system(size: 10))
                        .foregroundStyle(Color(.eggplant))
                        .fontWeight(.bold)
                }
                .onTapGesture { taskModel.removeDueDate() }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background {
            Capsule()
                .foregroundStyle(Color(.eggplant))
        }
        .padding(.leading)
    }
    
    @ViewBuilder
    private func getPickerButton(onClickBool: Binding<Bool>, imageName: String) -> some View {
        Button {
            onClickBool.wrappedValue = true
        } label: {
            Image(systemName: imageName)
                .font(.system(size: 20))
                .padding(.leading)
                .foregroundStyle(Color(.darkGray))
                .padding(.vertical, 5)
        }
    }
    
    var TitleRow: some View {
        HStack {
            Image(systemName: "circle")
                .font(.system(size: 24))
                .foregroundStyle(Color(.darkGray))
            
            TextField("Add a Task", text: $taskTitle)
                .padding(.leading, 5)
                .foregroundStyle(Color(.darkgray))
                .focused($isFocused)
                .onChange(of: isFocused) { if !$1 {dismiss()} }
                .onSubmit {}
            
            Spacer()
            
            Button {
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.blue)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 5)
    }
}

#Preview {
    TaskEditor(context: DataController.previewTask.managedObjectContext!)
}
