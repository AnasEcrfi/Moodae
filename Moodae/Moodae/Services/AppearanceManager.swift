//
//  AppearanceManager.swift
//  Moodae
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI
import UIKit

enum AppearanceMode: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max"
        case .dark: return "moon"
        }
    }
    
    var description: String {
        switch self {
        case .system: return "Follow system setting"
        case .light: return "Always light mode"
        case .dark: return "Always dark mode"
        }
    }
}

@MainActor
class AppearanceManager: ObservableObject {
    @Published var selectedMode: AppearanceMode = .system
    
    private let userDefaultsKey = "appearance_mode"
    
    init() {
        loadAppearanceMode()
        applyAppearanceMode()
    }
    
    func setAppearanceMode(_ mode: AppearanceMode) {
        selectedMode = mode
        saveAppearanceMode()
        applyAppearanceMode()
    }
    
    private func loadAppearanceMode() {
        if let savedMode = UserDefaults.standard.string(forKey: userDefaultsKey),
           let mode = AppearanceMode(rawValue: savedMode) {
            selectedMode = mode
        }
    }
    
    private func saveAppearanceMode() {
        UserDefaults.standard.set(selectedMode.rawValue, forKey: userDefaultsKey)
    }
    
    private func applyAppearanceMode() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        switch selectedMode {
        case .system:
            window.overrideUserInterfaceStyle = .unspecified
        case .light:
            window.overrideUserInterfaceStyle = .light
        case .dark:
            window.overrideUserInterfaceStyle = .dark
        }
    }
} 