//
//  ScheduledEvents.swift
//  Foca2
//
//  Created by Adit G on 12/6/23.
//

import SwiftUI

struct ScheduledEvents: View {
    @Environment(\.managedObjectContext) var moc
    @State private var taskToModify: Task? = nil
    @State private var taskInEditMode: Task? = nil
    @State private var hourFrames = [CGRect](repeating: .zero, count: 24)
    @State private var dragging: Task? = nil
    
    let hourHeight: CGFloat = 60
    let textSize: CGFloat = 14
    let startDate: Date
    var itemsRequest : FetchRequest<Task>
    var items : FetchedResults<Task> { itemsRequest.wrappedValue }
    let hourlyComponents: [DateComponents] = (0...23).map { hour in
        DateComponents(hour: hour)
    }
    var itemsByHour: [DateComponents: [Task]] {
        Dictionary(grouping: items) { element in
            Calendar.current.dateComponents([.hour], from: element.startTime!)
        }
    }

    init(at date: Date) {
        self.startDate = Calendar.current.startOfDay(for: date)
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let endDate = Calendar.current.date(byAdding: components, to: startDate)!

        self.itemsRequest = FetchRequest(
            entity: Task.entity(),
            sortDescriptors: [NSSortDescriptor(key: "createdDate", ascending: true)],
            predicate: NSPredicate(format: "doDate >= %@ AND doDate <= %@ AND startTime != nil AND endTime != nil", startDate as CVarArg, endDate as CVarArg)
        )
    }
    
    var body: some View {
        ScrollView {
            VStack (spacing: 0) {
                ForEach(0...23, id: \.self) { hour in
                    getHourLine(hour: hour)                }
            }
        }
        .sheet(item: $taskToModify) { TaskEditorSheet(task: $0, context: moc) }
    }
    
    @ViewBuilder
    func getHourLine(hour: Int) -> some View {
        let time = Calendar.current.date(byAdding: .hour, value: hour, to: startDate) ?? startDate
        HStack (spacing: 0) {
            Text(DateModel.getDateStr(date: time, format: "h a"))
                .frame(width: 55)
                .font(.system(size: textSize))
                .fontWeight(.semibold)
                .foregroundColor(.gray)
                .frame(height: hourHeight)
            
            ZStack {
                Divider()
                    .frame(height: 1)
                
                itemsStartingAt(hour: hour)
            }
            .frame(height: hourHeight)
        }
        .overlay {
            GeometryReader { geo in
                Color.clear.onAppear {
                    self.hourFrames[hour] = geo.frame(in: .global)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { _ in
            if taskInEditMode != nil {
                taskInEditMode = nil
            }
        }
        .onDrop(of: [.text], delegate: BigDDelegate())
    }
    
    @ViewBuilder
    func itemsStartingAt(hour: Int) -> some View {
        ForEach(itemsByHour[DateComponents(hour: hour), default: []]) { item in
            let diffs = Calendar.current.dateComponents(
                [.hour, .minute],
                from: item.startTime ?? Date(),
                to: item.endTime ?? Date() + 3600)
            let hourBound = hourHeight * (CGFloat(diffs.hour!) + CGFloat(diffs.minute!) / 60)
            let startComps = Calendar.current.dateComponents([.minute],
                from: item.startTime ?? Date())
            let startingOffset = hourHeight * CGFloat(startComps.minute!) / 60
            
            EventCell(task: item, editMode: taskInEditMode == item)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .frame(height: hourBound)
                .offset(y: hourBound / 2 + startingOffset)
                .onTapGesture {
                    if taskInEditMode != nil {
                        taskInEditMode = nil
                    } else {
                        taskToModify = item
                    }
                }
                .onDrag {
                    self.dragging = item
                    return NSItemProvider(object: item.wrappedTitle as NSString)
                } preview: {
                    EventCell(task: item, editMode: taskInEditMode == item)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .frame(height: hourBound)
                }
                .onLongPressGesture { taskInEditMode = item }
                .padding(.horizontal, 4)
        }
    }
    
}

struct ScheduledEvents_Previews: PreviewProvider {
    static var previews: some View {
        ScheduledEvents(at: Date())
            .background(Color("lightblue"))
    }
}
