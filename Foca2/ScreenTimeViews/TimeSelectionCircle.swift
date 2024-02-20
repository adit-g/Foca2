//
//  TimeSelectionCircle.swift
//  Foca2
//
//  Created by Adit G on 1/24/24.
//

import SwiftUI

struct TimeSelectionCircle: View {
    
    @Binding var minutes: Int
    @State private var size = CGSize.zero
    
    private var percentage: CGFloat {
        CGFloat(minutes) / 60
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.white), lineWidth: 30)
            
            TimeSelectorView(size: size, minutes: $minutes)
            
            Circle()
                .trim(from: 0, to: percentage)
                .stroke(
                    Color("eggplant"),
                    style: StrokeStyle(
                        lineWidth: percentage < 0.98 ? 30 : 40,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
            
            let angle = percentage * 2 * .pi - .pi / 2
            let radius = size.width / 2
            let xOffset = radius * cos(angle)
            let yOffset = radius * sin(angle)
            let shadowAngle = angle + .pi / 2
            let xShadow = 20 * cos(shadowAngle)
            let yShadow = 20 * sin(shadowAngle)
            
            Circle()
                .fill(Color("eggplant"))
                .opacity(percentage < 0.98 ? 0 : 1)
                .frame(width: 40, height: 40)
                .offset(x: xOffset,
                        y: yOffset)
                .shadow(color: .black.opacity(0.2),
                        radius: 10,
                        x: xShadow,
                        y: yShadow)
                .transaction { transaction in
                    transaction.animation = nil
                }
        }
        .readSize(onChange: { size = $0 })
        .padding(.horizontal)
        .padding(.horizontal, 15)
    }
}

#Preview {
    VStack {
        TimeSelectionCircle(minutes: .constant(5))
            .padding(.top)
        Spacer()
    }
    .background(Color(.mediumBlue))
}
