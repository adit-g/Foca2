//
//  SheetHeader.swift
//  Foca2
//
//  Created by Adit G on 1/23/24.
//

import SwiftUI

struct SheetHeader: View {
    
    let title: String
    let doneAction: () -> Void
    
    var body: some View {
        ZStack {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .center)
            
            Button("Done") {
                doneAction()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()
        }
        .padding(.top, 10)
    }
}

#Preview {
    SheetHeader(title: "Reminder", doneAction: {})
}
