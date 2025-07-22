//
//  MoodaeApp.swift
//  Moodae
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

@main
struct MoodaeApp: App {
    @StateObject private var pinManager = PINManager()
    @StateObject private var appearanceManager = AppearanceManager()
    @StateObject private var weekStartManager = WeekStartManager()
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(pinManager)
                .environmentObject(appearanceManager)
                .environmentObject(weekStartManager)
                .withAppTextScaling()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    pinManager.handleAppDidBecomeActive()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    pinManager.handleAppDidEnterBackground()
                }
        }
    }
}
