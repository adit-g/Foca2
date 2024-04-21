//
//  RedirectView.swift
//  Foca2
//
//  Created by Adit G on 4/19/24.
//

import SwiftUI
import CoreData

struct RedirectView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    @State private var count = 0
    @State private var animationOver = false
    @State private var coverOffset = UIScreen.height
    @State private var startBreakOpen = false
    
    var body: some View {
        ZStack {
            if animationOver {
                Color(.ghostWhite)
                    .ignoresSafeArea()
                
                VStack {
                    Text("you have \(count) unfinished task\(count == 1 ? "" : "s")")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.chineseViolet))
                        .multilineTextAlignment(.center)
                        .padding(.top)
                    
                    Tasks(taskCreaterOpen: .constant(false))
                    
                    Button {
                        dismiss()
                    } label: {
                        Capsule()
                            .frame(height: 50)
                            .padding(.horizontal)
                            .foregroundStyle(Color(.coolGray))
                            .overlay(Text("avoid distraction").foregroundStyle(.white))
                    }
                    
                    Button {
                        startBreakOpen = true
                    } label: {
                        Text("take a break")
                            .foregroundStyle(Color(.spaceCadet).opacity(0.7))
                    }
                }
            } else {
                Color(.spaceCadet)
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    Text("it's time to take a deep breath...")
                        .font(.largeTitle)
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                    Spacer(minLength: UIScreen.height * 0.6)
                }
            }
            
            LinearGradient(colors: [Color(.coolGray), Color(.chineseViolet)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                .offset(y: coverOffset)
        }
        .sheet(isPresented: $startBreakOpen, onDismiss: { dismiss() }) { StartBreakView() }
        .onAppear {
            let request = NSFetchRequest<TaskItem>(entityName: "TaskItem")
            request.predicate = NSPredicate(format: "completed = %@", false as NSNumber)
            if let x = try? moc.count(for: request) {
                count = x
            }
            
            withAnimation(.easeInOut(duration: 6)) {
                coverOffset = 0
            } completion: {
                animationOver = true
                withAnimation(.easeInOut(duration: 6)) {
                    coverOffset = UIScreen.height
                }
            }
        }
    }
}

#Preview {
    RedirectView()
        .environment(\.managedObjectContext, DataController.previewTask.managedObjectContext!)
        
}
