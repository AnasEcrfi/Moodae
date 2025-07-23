//
//  AppStoreReviewManager.swift
//  Moodae
//
//  Created by Anas Ech-Cherfi on 27/01/2025.
//

import Foundation
import StoreKit
import SwiftUI

/// Intelligenter App Store Review Manager
/// Fordert zur Bewertung auf, wenn der User am positivsten gestimmt ist
@MainActor
class AppStoreReviewManager: ObservableObject {
    
    // MARK: - UserDefaults Keys
    private let hasRequestedReviewKey = "HasRequestedAppStoreReview"
    private let firstMoodEntryDateKey = "FirstMoodEntryDate"
    private let totalMoodEntriesKey = "TotalMoodEntries"
    private let lastReviewRequestKey = "LastReviewRequestDate"
    
    // MARK: - Configuration
    private let minimumDaysBetweenRequests: TimeInterval = 7 * 24 * 60 * 60 // 7 Tage
    private let maximumRequestsPerYear = 3
    
    // MARK: - Review Request Logic
    
    /// Hauptmethode: Überprüft ob Review Request angezeigt werden soll
    func checkForReviewRequest(after moodEntry: MoodEntryData) {
        // Erst nach dem allerersten Mood Entry fragen
        if isFirstMoodEntry() {
            recordFirstMoodEntry()
            requestReviewAfterFirstEntry()
            return
        }
        
        // Weitere Review-Anfragen nach strategischen Meilensteinen
        checkForMilestoneReviewRequest()
    }
    
    /// Zeigt Review Request nach dem ersten Mood Entry
    private func requestReviewAfterFirstEntry() {
        // Kurze Verzögerung für bessere UX - User soll erst Erfolg feiern
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.requestReview(reason: "first_entry")
        }
    }
    
    /// Überprüft ob strategische Meilensteine erreicht wurden
    private func checkForMilestoneReviewRequest() {
        guard canRequestReview() else { return }
        
        let totalEntries = getTotalMoodEntries()
        
        // Meilensteine für Review-Anfragen
        let milestones = [7, 30, 100, 365] // Nach 1 Woche, 1 Monat, 100 Einträgen, 1 Jahr
        
        if milestones.contains(totalEntries) {
            requestReview(reason: "milestone_\(totalEntries)")
        }
    }
    
    /// Zeigt tatsächlich den App Store Review Dialog
    private func requestReview(reason: String) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            return
        }
        
        // Apple's nativer Review Request
        SKStoreReviewController.requestReview(in: windowScene)
        
        // Tracking für weitere Anfragen
        recordReviewRequest(reason: reason)
        
        print("🌟 App Store Review Request triggered: \(reason)")
    }
    
    // MARK: - Helper Methods
    
    /// Überprüft ob dies der erste Mood Entry ist
    private func isFirstMoodEntry() -> Bool {
        return UserDefaults.standard.object(forKey: firstMoodEntryDateKey) == nil
    }
    
    /// Speichert das Datum des ersten Mood Entries
    private func recordFirstMoodEntry() {
        UserDefaults.standard.set(Date(), forKey: firstMoodEntryDateKey)
        UserDefaults.standard.set(1, forKey: totalMoodEntriesKey)
    }
    
    /// Erhöht die Anzahl der Mood Entries
    func incrementMoodEntryCount() {
        let current = getTotalMoodEntries()
        UserDefaults.standard.set(current + 1, forKey: totalMoodEntriesKey)
    }
    
    /// Holt die Gesamtzahl der Mood Entries
    private func getTotalMoodEntries() -> Int {
        return UserDefaults.standard.integer(forKey: totalMoodEntriesKey)
    }
    
    /// Überprüft ob ein Review Request erlaubt ist
    private func canRequestReview() -> Bool {
        // Nicht zu oft fragen
        guard let lastRequest = UserDefaults.standard.object(forKey: lastReviewRequestKey) as? Date else {
            return true // Erste Anfrage
        }
        
        let daysSinceLastRequest = Date().timeIntervalSince(lastRequest)
        return daysSinceLastRequest >= minimumDaysBetweenRequests
    }
    
    /// Speichert wann ein Review Request gemacht wurde
    private func recordReviewRequest(reason: String) {
        UserDefaults.standard.set(Date(), forKey: lastReviewRequestKey)
        UserDefaults.standard.set(true, forKey: hasRequestedReviewKey)
        
        // Optional: Analytics tracking
        print("📊 Review request recorded: \(reason)")
    }
    
    // MARK: - Public Utilities
    
    /// Manueller Review Request (z.B. von Settings)
    func requestManualReview() {
        requestReview(reason: "manual_settings")
    }
    
    /// Reset für Testing
    func resetReviewData() {
        UserDefaults.standard.removeObject(forKey: hasRequestedReviewKey)
        UserDefaults.standard.removeObject(forKey: firstMoodEntryDateKey)
        UserDefaults.standard.removeObject(forKey: totalMoodEntriesKey)
        UserDefaults.standard.removeObject(forKey: lastReviewRequestKey)
    }
    
    /// Debug Info
    var debugInfo: String {
        let hasRequested = UserDefaults.standard.bool(forKey: hasRequestedReviewKey)
        let totalEntries = getTotalMoodEntries()
        let firstEntryDate = UserDefaults.standard.object(forKey: firstMoodEntryDateKey) as? Date
        let lastRequestDate = UserDefaults.standard.object(forKey: lastReviewRequestKey) as? Date
        
        return """
        📊 AppStore Review Manager Debug:
        • Has Requested: \(hasRequested)
        • Total Entries: \(totalEntries)
        • First Entry: \(firstEntryDate?.formatted() ?? "None")
        • Last Request: \(lastRequestDate?.formatted() ?? "None")
        • Can Request: \(canRequestReview())
        """
    }
}

// MARK: - SwiftUI Integration

/// View Modifier für automatische Review Requests
struct AppStoreReviewModifier: ViewModifier {
    let reviewManager: AppStoreReviewManager
    let moodEntry: MoodEntryData?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if let entry = moodEntry {
                    reviewManager.checkForReviewRequest(after: entry)
                }
            }
    }
}

extension View {
    /// Einfache Integration in Views
    func checkForAppStoreReview(manager: AppStoreReviewManager, after entry: MoodEntryData?) -> some View {
        modifier(AppStoreReviewModifier(reviewManager: manager, moodEntry: entry))
    }
} 