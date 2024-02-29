//
//  DummyTaskTile.swift
//  Foca2
//
//  Created by Adit G on 2/16/24.
//

import SwiftUI

struct DummyTaskTile: View {
    var itemsRequest : FetchRequest<TaskItem>
    var items : FetchedResults<TaskItem> { itemsRequest.wrappedValue }
    
    init(at date: Date) {
        let (startDate, endDate) = Date().getStartEndDates()

        self.itemsRequest = FetchRequest(
            entity: TaskItem.entity(),
            sortDescriptors: [NSSortDescriptor(key: "createdDate", ascending: true)],
            predicate: NSPredicate(
                format: "doDate BETWEEN {%@, %@} AND title != %@ AND title != nil",
                startDate as CVarArg, endDate as CVarArg, "")
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                HStack(spacing: 0) {
                    Image(systemName: "circle")
                        .font(.system(size: 15))
                        .padding(.horizontal, 10)
                        .foregroundStyle(.black)
                    Text(item.wrappedTitle)
                        .foregroundStyle(.black)
                }
                .padding(.vertical, 10)
                .padding(.trailing, 10)
                .background(Rectangle().fill(.white))
                
                if item.id != items.last?.id {
                    Divider()
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    DummyTaskTile(at: Date())
}
