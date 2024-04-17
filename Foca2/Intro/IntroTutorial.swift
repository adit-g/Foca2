//
//  IntroTutorial.swift
//  Foca2
//
//  Created by Adit G on 4/5/24.
//

import SwiftUI

enum IntroPhases: Int {
    case welcome, permissions, selectApps, budget, tasks, allset
}

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading)
        )
    }
}

struct IntroTutorial: View {
    @Binding var isFinished: Bool
    @State private var introStatus = IntroPhases.welcome
    
    var body: some View {
        switch introStatus {
        case .welcome:
            Welcome(nextView: increment)
                .transition(.moveAndFade)
        case .permissions:
            Permissions(nextView: increment)
                .transition(.moveAndFade)
        case .selectApps:
            SelectApps(nextView: increment)
                .transition(.moveAndFade)
        case .budget:
            Budget(nextView: increment)
                .transition(.moveAndFade)
        case .tasks:
            TaskIntro(nextView: increment)
                .transition(.moveAndFade)
        case .allset:
            AllSet(nextView: increment)
                .transition(.moveAndFade)
        }
    }
    
    func increment() {
        withAnimation {
            switch introStatus {
            case .welcome:
                introStatus = .permissions
            case .permissions:
                introStatus = .selectApps
            case .selectApps:
                introStatus = .budget
            case .budget:
                introStatus = .tasks
            case .tasks:
                introStatus = .allset
            case .allset:
                isFinished = true
            }
        }
    }
}

#Preview {
    IntroTutorial(isFinished: .constant(false))
}
