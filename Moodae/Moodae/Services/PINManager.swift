//
//  PINManager.swift
//  Moodae
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import Foundation
import LocalAuthentication

@MainActor
class PINManager: ObservableObject {
    @Published var isPINEnabled = false
    @Published var isUnlocked = false
    @Published var showingPINSetup = false
    @Published var showingPINUnlock = false
    
    private let pinKey = "app_pin"
    private let pinEnabledKey = "pin_enabled"
    
    init() {
        loadPINSettings()
    }
    
    // MARK: - PIN Settings
    
    private func loadPINSettings() {
        isPINEnabled = UserDefaults.standard.bool(forKey: pinEnabledKey)
        // App starts locked if PIN is enabled
        isUnlocked = !isPINEnabled
    }
    
    func enablePIN(_ pin: String) {
        guard pin.count == 4, pin.allSatisfy({ $0.isNumber }) else { return }
        
        UserDefaults.standard.set(pin, forKey: pinKey)
        UserDefaults.standard.set(true, forKey: pinEnabledKey)
        isPINEnabled = true
        isUnlocked = true
    }
    
    func disablePIN() {
        UserDefaults.standard.removeObject(forKey: pinKey)
        UserDefaults.standard.set(false, forKey: pinEnabledKey)
        isPINEnabled = false
        isUnlocked = true
    }
    
    func changePIN(_ newPIN: String) {
        guard newPIN.count == 4, newPIN.allSatisfy({ $0.isNumber }) else { return }
        
        UserDefaults.standard.set(newPIN, forKey: pinKey)
    }
    
    // MARK: - PIN Verification
    
    func verifyPIN(_ enteredPIN: String) -> Bool {
        guard let storedPIN = UserDefaults.standard.string(forKey: pinKey) else {
            return false
        }
        
        let isCorrect = enteredPIN == storedPIN
        if isCorrect {
            isUnlocked = true
        }
        return isCorrect
    }
    
    func lockApp() {
        if isPINEnabled {
            isUnlocked = false
            showingPINUnlock = true
        }
    }
    
    // MARK: - App Lifecycle
    
    func handleAppDidBecomeActive() {
        // Lock app when returning from background if PIN is enabled
        if isPINEnabled && !isUnlocked {
            showingPINUnlock = true
        }
    }
    
    func handleAppDidEnterBackground() {
        // Lock app when going to background
        if isPINEnabled {
            isUnlocked = false
        }
    }
} 