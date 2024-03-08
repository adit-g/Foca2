//
//  TimerCircle.swift
//  Foca2
//
//  Created by Adit G on 1/24/24.
//

import SwiftUI

struct TimerCircle: View {
    @EnvironmentObject var sessionModel: SessionModel
    
    @AppStorage("status", store: UserDefaults(suiteName: "group.2L6XN9RA4T.focashared"))
    var statusInt: Int = ScreenTimeStatus.noSession.rawValue
    
    @State private var size = CGSize.zero
    
    let circleColor = "coolGray"
    
    private var status: ScreenTimeStatus {
        ScreenTimeStatus(rawValue: statusInt) ?? .noSession
    }
    
    var endTime: Date {
        switch status {
        case .noSession:
            Date()
        case .session:
            sessionModel.fsEndTime
        case .scheduledSession:
            Calendar.current.nextDate(
                after: Date(),
                matching: sessionModel.ssToTimeComps,
                matchingPolicy: .nextTime)!
        case .onBreak:
            sessionModel.brEndTime
        }
    }
    
    var secondsToEnd: Int {
        Int(endTime.timeIntervalSinceNow)
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
                    let percentage = CGFloat(secondsToEnd) / 3600
                    let formattedStr = secondsToString(seconds: secondsToEnd)
                    
                    VStack {
                        Text(status.sessionName)
                            .font(.title)
                        Text("Remaining Time: " + formattedStr)
                    }
                    
                    Circle()
                        .trim(from: 0, to: percentage)
                        .stroke(
                            Color(circleColor),
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
                        .fill(Color(circleColor))
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
    .background(Color(.mediumBlue))
}
