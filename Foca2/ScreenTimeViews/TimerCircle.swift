//
//  TimerCircle.swift
//  Foca2
//
//  Created by Adit G on 1/24/24.
//

import SwiftUI

struct TimerCircle: View {
    @EnvironmentObject var sessionModel: SessionModel
    
    @State private var size = CGSize.zero
    var endTime: Date {
        switch sessionModel.status {
        case .noSession:
            Date()
        case .session:
            sessionModel.endTime
        case .scheduledSession:
            sessionModel.nextEndDate
        }
    }
    
    private func secondsToString(seconds: Int) -> String {
        seconds < 0 ? "00:00:00" :
        String(format: "%02d", seconds / 3600) + ":" +
                        String(format: "%02d", (seconds % 3600) / 60) + ":" +
                        String(format: "%02d", seconds % 60)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.white), lineWidth: 30)
            
            TimelineView(.periodic(from: Date(), by: 1)) { context in
                ZStack {
                    let seconds = Int(endTime.timeIntervalSinceNow)
                    let percentage = CGFloat(seconds) / 3600
                    let formattedStr = secondsToString(seconds: seconds)
                    
                    VStack {
                        Text("Focus Session")
                            .font(.title)
                        Text("Remaining Time: " + formattedStr)
                    }
                    
                    Circle()
                        .trim(from: 0, to: percentage)
                        .stroke(
                            Color("eggplant"),
                            style: StrokeStyle(
                                lineWidth: percentage < 0.98 ? 30 : 35,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))
                    
                    let shadowAngle = percentage * 2 * .pi
                    let angle = shadowAngle - .pi / 2
                    let radius = size.width / 2
                    let xOffset = radius * cos(angle)
                    let yOffset = radius * sin(angle)
                    let xShadow = 20 * cos(shadowAngle)
                    let yShadow = 20 * sin(shadowAngle)
                    
                    Circle()
                        .fill(Color("eggplant"))
                        .opacity(percentage < 0.98 ? 0 : 1)
                        .frame(width: 34, height: 34)
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
            }
        }
        .readSize(onChange: { size = $0 })
        .padding(.horizontal)
        .padding(.horizontal, 15)
    }
}

#Preview {
    VStack {
        TimerCircle()
            .padding(.top)
        Spacer()
    }
    .background(Color(.blue))
}
