//
//  TaskEditorSheet.swift
//  Foca2
//
//  Created by Adit G on 12/1/23.
//

import SwiftUI
import CoreData

struct TaskEditorSheet: View {
    @Environment(\.dismiss) var dismiss
    
    let taskModel: TaskModel
    let selectedTask: Task?
    @State private var showAlert: Bool
    @State private var alertTitle: String
    
    @State private var title: String
    @State private var notes: String
    
    @State private var scheduled: Bool
    @State private var timed: Bool
    @State private var durated: Bool
    
    @State private var date: Date
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var hourSelection: Int
    @State private var minuteSelection: Int
    
    init(task: Task?, context: NSManagedObjectContext) {
        self.taskModel = TaskModel(context: context)
        self.selectedTask = task
        self._showAlert = State(initialValue: false)
        self._alertTitle = State(initialValue: "")
        self._title = State(initialValue: task?.wrappedTitle ?? "")
        self._notes = State(initialValue: task?.wrappedNotes ?? "")
        self._scheduled = State(initialValue: task?.doDate != nil)
        self._date = State(initialValue: task?.doDate ?? Date())
        self._timed = State(initialValue: task?.startTime != nil && task?.endTime != nil)
        self._startTime = State(initialValue: task?.startTime ?? Date())
        self._endTime = State(initialValue: task?.endTime ?? Date() + 3600)
        self._durated = State(initialValue: task?.duration ?? -1 >= 0)
        self._hourSelection = State(initialValue: Int(task?.duration ?? 0) / 60)
        self._minuteSelection = State(initialValue: (Int(task?.duration ?? 30) % 60) / 5)
    }
    
    var body: some View {
        NavigationView {
            Form {
                TitleView
                
                DateAndTimeView
                
                DurationView
                
                if selectedTask != nil {
                    Section {
                        Button {
                            taskModel.deleteTask(selectedTask!)
                            dismiss()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Task")
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .background(Color("blue"))
            .scrollContentBackground(.hidden)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: toolbarContent)
            .toolbarBackground(Material.ultraThinMaterial)
        }
    }
    
    var TitleView: some View {
        Section {
            TextField("Title", text: $title)
            TextField("Notes", text: $notes, axis: .vertical)
                .lineLimit(4...8)
        }
    }
    
    var DateAndTimeView: some View {
        Section {
            Toggle("Date", isOn: $scheduled)
                .fontWeight(scheduled ? .semibold: .regular)
                .onChange(of: scheduled) { _, newValue in
                    if !newValue { timed = false }
                }
            
            if scheduled {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
            }
            
            Toggle("Time", isOn: $timed)
                .fontWeight(timed ? .semibold : .regular)
                .onChange(of: timed) { _, newValue in
                    if newValue { scheduled = true }
                }
            
            if timed {
                DatePicker("Starts", selection: $startTime, displayedComponents: .hourAndMinute)
                DatePicker("Ends", selection: $endTime, displayedComponents: .hourAndMinute)
            }
        }
    }
    
    //TODO: tie up duration with startTime and endTimes
    var DurationView: some View {
        Section {
            Toggle("Duration", isOn: $durated)
            
            if durated {
                HStack(spacing: 0) {
                    Picker("picks2", selection: $hourSelection) {
                        ForEach(0..<24) { row in
                            Text(row.description)
                                .fontWeight(.bold)
                        }
                    }
                    .pickerStyle(.wheel)
                    
                    Text("Hours")
                    
                    Picker("picks1", selection: $minuteSelection) {
                        ForEach(0..<12) { row in
                            let row2 = row * 5
                            Text(row2.description)
                                .fontWeight(.bold)
                        }
                    }
                    .pickerStyle(.wheel)
                    
                    Text("Mins")
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
        }
        
        ToolbarItem(placement: .principal) {
            Text("New Task")
                .fontWeight(.semibold)
                .font(.title3)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(selectedTask == nil ? "Add" : "Update") {
                do {
                    if selectedTask == nil {
                        try taskModel.addTask(
                            title: title,
                            notes: notes,
                            isScheduled: scheduled,
                            isTimed: timed,
                            isDurated: durated,
                            date: date,
                            startTime: startTime,
                            endTime: endTime,
                            duration: 60 * hourSelection + 5 * minuteSelection)
                    } else {
                        try taskModel.updateTask(
                            task: selectedTask!,
                            title: title,
                            notes: notes,
                            isScheduled: scheduled,
                            isTimed: timed,
                            isDurated: durated,
                            date: date,
                            startTime: startTime,
                            endTime: endTime,
                            duration: 60 * hourSelection + 5 * minuteSelection)
                    }
                } catch TaskModelError.blankTitle {
                    showAlert = true
                    alertTitle = "The title must not be blank"
                } catch TaskModelError.invalidTimes {
                    showAlert = true
                    alertTitle = "Something went wrong"
                } catch { print(error.localizedDescription) }
                
                dismiss()
            }
            .disabled(title.isEmpty)
        }
    }
}
