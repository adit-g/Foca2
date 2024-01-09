//
//  EventCell.swift
//  Foca2
//
//  Created by Adit G on 12/20/23.
//

import SwiftUI
import CoreData

struct EventCell: View {
    @ObservedObject var task: Task
    let editMode: Bool
    
    var body: some View {
        if editMode {
            Rectangle()
                .foregroundColor(Color("darkblue"))
                .overlay {
                    HStack (spacing: 0) {
                        VStack (spacing: 0) {
                            Text(task.wrappedTitle)
                                .font(.system(size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.top, 3)
                        
                        Spacer()
                    }
                    .padding(.leading, 8)
                }
        } else {
            HStack (spacing: 0) {
                Rectangle()
                    .frame(width: 3)
                    .foregroundColor(Color("darkblue"))
                Rectangle()
                    .foregroundColor(.white.opacity(0.6))
                    .overlay {
                        HStack (spacing: 0) {
                            VStack (spacing: 0) {
                                Text(task.wrappedTitle)
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("darkblue"))
                                Spacer()
                            }
                            .padding(.top, 3)
                            
                            Spacer()
                        }
                        .padding(.leading, 5)
                    }
            }
        }
    }
}

struct EventCell_Previews: PreviewProvider {
    static let localTask = DataController.previewTask
    static var previews: some View {
        EventCell(task: localTask, editMode: true)
            .frame(maxHeight: .infinity)
            .background(Color("lightblue"))
    }
}
