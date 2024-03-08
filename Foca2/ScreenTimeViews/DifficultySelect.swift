//
//  DifficultySelect.swift
//  Foca2
//
//  Created by Adit G on 2/22/24.
//

import SwiftUI

struct DifficultySelect: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var sessionModel: SessionModel
    @State private var sheetLength = CGFloat.zero
    
    private var difficultyLevel: Difficulty {
        Difficulty(rawValue: sessionModel.difficultyInt) ?? .normal
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 15) {
                Text("Session Difficulty")
                    .bold()
                    .fontWeight(.semibold)
                    .padding(.vertical, 10)
                    .padding(.top, 5)
                    .foregroundStyle(Color(.spaceCadet))
                
                getDiffButton(diff: .normal, image: "shield")
                getDiffButton(diff: .timeout, image: "shield.lefthalf.filled")
                getDiffButton(diff: .deepfocus, image: "shield.fill")
                
            }
            .readSize(onChange: { sheetLength = $0.height })
            
            Spacer()
        }
        .background(Color(.ghostWhite))
        .presentationDetents([.height(sheetLength)])
        .presentationCornerRadius(20)
        .presentationDragIndicator(.visible)
    }
    
    func getDiffButton(diff: Difficulty, image: String) -> some View {
        HStack (spacing: 0) {
            Image(systemName: image)
                .foregroundStyle(.white)
                .frame(width: 40)
                .background {
                    RoundedRectangle(cornerRadius: 7)
                        .frame(width: 40, height: 40)
                        .foregroundStyle(Color(.mountbattenPink))
                }
                .padding(.horizontal)
            
            VStack (spacing: 0) {
                Text(diff.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(Color(.spaceCadet))
                Text(diff.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondary)
            }
            Spacer()
            Circle()
                .stroke(.white.opacity(0.5))
                .frame(width: 20)
                .padding(.horizontal)
                .overlay {
                    if diff == difficultyLevel {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.white)
                    }
                }
        }
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.white.opacity(0.5))
                .fill(Color(.coolGray).opacity(0.5))
        }
        .onTapGesture {
            sessionModel.difficultyInt = diff.rawValue
            dismiss()
        }
        .padding(.horizontal)
    }
}

#Preview {
    DifficultySelect()
        .environmentObject(SessionModel())
}
