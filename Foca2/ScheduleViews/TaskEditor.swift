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
    
    @State private var taskTitle: String
    @State private var sheetLength: CGFloat = .zero
    @State private var safeAreaBottom: CGFloat = .zero
    
    @State private var showDueDatePicker = false
    @State private var showReminderDatePicker = false
    @State private var showNotesEditor = false
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    
    init(task: TaskItem? = nil, context: NSManagedObjectContext) {
        let wrappedTask = task ?? TaskItem(context: context)
        self._taskTitle = State(wrappedValue: wrappedTask.wrappedTitle)
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
            .onAppear { safeAreaBottom = getSafeAreaBottom() }
        }
        .background(Color(.mediumBlue))
        .presentationDetents([.height(sheetLength)])
        .presentationCornerRadius(20)
        .safeAreaPadding(.top, min(15, safeAreaBottom / 2))
        .sheet(
            isPresented: $showDueDatePicker,
            content: { DueDateSelection(taskModel: taskModel) }
        )
        .sheet(
            isPresented: $showReminderDatePicker,
            content: { ReminderDateSelection(taskModel: taskModel) }
        )
        .sheet(
            isPresented: $showNotesEditor,
            content: {
                NotesEditor(taskModel: taskModel, notes: taskModel.getNote())
            }
        )
        .alert(alertTitle, isPresented: $showAlert) { Text("Cool") }
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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if taskModel.hasReminderDate {
                    ReminderDateCapsule
                        .padding(.leading)
                } else {
                    getPickerButton(
                        onClickBool:$showReminderDatePicker,
                        imageName: "bell"
                    )
                        .padding(.leading, 12)
                }
                
                if taskModel.hasDueDate {
                    DueDateCapsule
                } else {
                    getPickerButton(
                        onClickBool: $showDueDatePicker,
                        imageName: "calendar"
                    )
                }
                
                if taskModel.hasNotes {
                    NotesCapsule
                        .padding(.trailing)
                } else {
                    getPickerButton(
                        onClickBool: $showNotesEditor,
                        imageName: "pencil.and.scribble"
                    )
                }
                
                Spacer()
            }
            .padding(.top, 5)
        }
    }
    
    @ViewBuilder
    private func ImageTemplate(
        _ name: String,
        _ size: CGFloat,
        _ color: Color
    ) -> some View {
        Image(systemName: name)
            .font(.system(size: size))
            .foregroundStyle(color)
    }
    
    var NotesCapsule: some View {
        HStack (spacing: 10) {
            ImageTemplate("pencil.and.scribble", 20, Color(.mediumBlue))
                .onTapGesture { showNotesEditor = true }
            
            Text("Note")
                .foregroundStyle(Color(.mediumBlue))
                .font(.system(size: 16))
                .onTapGesture { showNotesEditor = true }
            
            XButton
                .onTapGesture { taskModel.setNote("") }
        }
        .modifier(CapsuleBackground())
    }
    
    var ReminderDateCapsule: some View {
        let reminderDate = try! taskModel.getReminderDate()
        let timeString = DateModel.getDateStr(date: reminderDate, format: "h:mm a")
        let dateString = DateModel.getDescriptiveDateStr(date: reminderDate, format: "E, MMMM d")
        return HStack(spacing: 10) {
            ImageTemplate("bell", 20, Color(.mediumBlue))
                .onTapGesture { showReminderDatePicker = true }
            
            VStack {
                Text("Remind me at \(timeString)")
                    .font(.system(size: 12))
                
                Text(dateString)
                    .font(.system(size: 10))
            }
            .foregroundStyle(Color(.mediumBlue))
            .onTapGesture { showReminderDatePicker = true }
            
            XButton
                .onTapGesture { taskModel.removeReminderDate() }
        }
        .modifier(CapsuleBackground())
    }
    
    var XButton: some View {
        Circle()
            .frame(width: 20, height: 20)
            .foregroundStyle(Color(.mediumBlue))
            .overlay{
                ImageTemplate("xmark", 10, Color(.eggplant))
                    .fontWeight(.bold)
            }
    }
    
    var DueDateCapsule: some View {
        let dueDateStr = DateModel.getDescriptiveDateStr(date: try! taskModel.getDueDate(), format: "E, MMM d")
        return HStack(spacing: 10) {
            ImageTemplate("calendar", 20, Color(.mediumBlue))
                .onTapGesture { showDueDatePicker = true }
            
            Text("Due \(dueDateStr)")
                .foregroundStyle(Color(.mediumBlue))
                .font(.system(size: 16))
                .onTapGesture { showDueDatePicker = true }
            
            XButton
                .onTapGesture { taskModel.removeDueDate() }
        }
        .modifier(CapsuleBackground())
    }
    
    @ViewBuilder
    private func getPickerButton(onClickBool: Binding<Bool>, imageName: String) -> some View {
        Button {
            onClickBool.wrappedValue = true
        } label: {
            ImageTemplate(imageName, 20, Color(.darkGray))
                .padding(5)
        }
    }
    
    var TitleRow: some View {
        HStack {
            ImageTemplate("circle", 24, Color(.darkGray))
            
            TextField("Add a Task", text: $taskTitle)
                .padding(.leading, 5)
                .foregroundStyle(Color(.darkgray))
                .focused($isFocused)
                .onSubmit {}
                .onAppear { self.isFocused = true }
            
            Spacer()
            
            Button {
                taskModel.setTitle(taskTitle)
                
                do {
                    try taskModel.rinseAndRepeat()
                    taskTitle = ""
                } catch TaskModelError.BlankTitle {
                    alertTitle = "The task title cannot be blank"
                    showAlert = true
                } catch TaskModelError.CoreDataIssue {
                    alertTitle = "There was an issue saving your task. Please try again later"
                    showAlert = true
                } catch { print(error.localizedDescription) }
            } label: {
                ImageTemplate("arrow.up.circle.fill", 30, .blue)
            }
        }
        .padding(.horizontal, 15)
        .padding(.bottom, 5)
    }
}

struct CapsuleBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background {
                Capsule()
                    .foregroundStyle(Color(.eggplant))
            }
    }
}

#Preview {
    TaskEditor(context: DataController.previewTask.managedObjectContext!)
}
