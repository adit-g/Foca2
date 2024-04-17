//
//  Permissions.swift
//  Foca2
//
//  Created by Adit G on 4/2/24.
//

import SwiftUI
import FamilyControls

enum PermStatus: Int {
case toggle, check
}

struct Permissions: View {
    @ObservedObject var stCenter = AuthorizationCenter.shared
    let notiCenter = UNUserNotificationCenter.current()
    let nextView: () -> ()
    
    @State private var garb1 = false
    @State private var garb2 = false
    @State private var stStatus = PermStatus.toggle
    @State private var notiStatus = PermStatus.toggle
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            Text("but first, we'll need some permissions")
                .foregroundStyle(Color(.chineseViolet))
                .fontWeight(.bold)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.top, 100)
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 50)
                .foregroundStyle(.white)
                .overlay { ScreenTimePermission }
                .padding(.horizontal)
                .transition(.moveAndFade)
            
            Text("screen time is used to help you block distracting apps and be more aware of your usage habits. your data is protected by apple and will not leave your device.")
                .padding(.horizontal)
                .font(.caption)
                .foregroundStyle(Color(.coolGray))
                .padding(.bottom, 30)
            
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 50)
                .foregroundStyle(.white)
                .overlay { NotificationPermission }
                .padding(.horizontal)
            
            Text("notifications are required to redirect distracting apps to your to-do list. we will never send you promotional notifications")
                .padding(.horizontal)
                .font(.caption)
                .foregroundStyle(Color(.coolGray))
                .padding(.bottom, 30)
            
            Spacer()
            
            Button {
                nextView()
            } label: {
                Capsule()
                    .foregroundStyle(Color(.coolGray))
                    .frame(height: 45)
                    .padding(.horizontal, 30)
                    .opacity(stStatus != .check || notiStatus != .check ? 0.4 : 1)
                    .overlay(Text("next").foregroundStyle(Color(.white)))
                    .padding(.bottom)
            }
            .disabled(stStatus != .check || notiStatus != .check)
        }
        .frame(width: UIScreen.width)
        .background(Color(.ghostWhite))
        .onChange(of: stCenter.authorizationStatus) {
            switch $1 {
            case .notDetermined:
                stStatus = .toggle
            case .denied:
                stStatus = .toggle
            case .approved:
                stStatus = .check
            @unknown default:
                stStatus = .toggle
            }
        }
        .onReceive (
            NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
        ) { _ in
            Task {
                let settings = await UNUserNotificationCenter.current().notificationSettings()
                if settings.authorizationStatus == .authorized {
                    notiStatus = .check
                } else {
                    notiStatus = .toggle
                }
            }
        }
        .alert("⚠️Limited Functionality⚠️", isPresented: $showAlert) {
            
            Button("Go to Settings") {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
            
            Button("Cancel") { }
            
        } message: {
            Text("Notifications are necessary to redirect you to your to-do list when distracting apps are opened. Without notifications, you will have to MANUALLY open foca every time you wish to unblock an app\n\nTo enable notifications:\nSettings -> Foca -> Notifications -> Allow Notifications")
        }
    }
    
    var NotificationPermission: some View {
        HStack (spacing: 0) {
            Image(systemName: "bell.badge.fill")
                .foregroundStyle(Color.white)
                .frame(width: 20)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 25, height: 25)
                        .foregroundStyle(.red)
                )
                .padding(.trailing, 15)
            
            switch notiStatus {
            case .toggle:
                Toggle(isOn: $garb2, label: {
                    Text("notifications")
                })
                .onChange(of: garb2) {
                    if !$1 { return }
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                        if let error = error {
                            print(error.localizedDescription)
                            garb2 = false
                            return
                        }
                        
                        if granted { notiStatus = .check }
                        else {
                            showAlert = true
                            garb2 = false
                        }
                    }
                }
            case .check:
                HStack(spacing: 0) {
                    Text("notifications")
                    Spacer()
                    Text("✅")
                        .padding(.trailing, 10)
                }
            }
        }
        .padding(.horizontal)
        .foregroundStyle(Color(.spaceCadet))
        .onAppear {
            Task {
                let settings = await UNUserNotificationCenter.current().notificationSettings()
                if settings.authorizationStatus == .authorized {
                    notiStatus = .check
                } else {
                    notiStatus = .toggle
                }
            }
        }
    }
    
    var ScreenTimePermission: some View {
        HStack (spacing: 0) {
            Image(systemName: "hourglass")
                .foregroundStyle(Color.white)
                .frame(width: 20)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 25, height: 25)
                        .foregroundStyle(Color(.darkpurple))
                )
                .padding(.trailing, 15)
            
            switch stStatus {
            case .toggle:
                Toggle(isOn: $garb1, label: {
                    Text("screen time")
                })
                .onChange(of: garb1) {
                    if !$1 { return }
                    
                    Task {
                        do {
                            try await stCenter.requestAuthorization(for: .individual)
                            stStatus = .check
                        } catch {
                            garb1 = false
                            stStatus = .toggle
                        }
                    }
                    
                }
            case .check:
                HStack(spacing: 0) {
                    Text("screen time")
                    Spacer()
                    Text("✅")
                        .padding(.trailing, 10)
                }
            }
        }
        .padding(.horizontal)
        .foregroundStyle(Color(.spaceCadet))
    }
}

#Preview {
    Permissions(nextView: {})
}

