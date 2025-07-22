//
//  MoodViewModel.swift
//  Mooday
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class MoodViewModel: ObservableObject {
    @Published var moodEntries: [MoodEntryData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Current mood entry being created
    @Published var currentMoodType: MoodType?
    @Published var currentTextEntry: String = ""
    @Published var currentAudioURL: URL?
    @Published var currentAudioTranscript: String?
    
    // Insights data
    @Published var weeklyStats: WeeklyStats?
    @Published var commonWords: [String] = []
    
    // HealthKit integration
    @Published var healthKitManager: HealthKitManager
    @Published var showHealthKitPrompt = false
    
    // Simple analytics without AI
    @Published var currentInsight: MoodInsight?
    

    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.healthKitManager = HealthKitManager()
        
        loadMoodEntries()
        
        // Add demo data if no entries exist
        if moodEntries.isEmpty {
            addDemoData()
        }
        
        calculateInsights()
        calculateWeeklyStats()
        setupHealthKitIfNeeded()
    }
    
    // MARK: - Demo Data
    
    private func addDemoData() {
        let calendar = Calendar.current
        let now = Date()
        
        // Create demo entries for Emma (fictional user) over the past week
        let demoEntries: [MoodEntryData] = [
                        // Today
            MoodEntryData(
                id: UUID(),
                date: calendar.date(byAdding: .hour, value: -2, to: now)!,
                mood: .good,
                textEntry: "Had a wonderful morning workout! Feeling energized and ready for the day. Coffee tastes extra good today ☕️",
                audioURL: nil,
                audioTranscript: nil,
                photoURL: nil,
                categories: [
                    CategorySelection(categoryName: "Emotions", selectedOptions: ["happy"]),
                    CategorySelection(categoryName: "Hobbies", selectedOptions: ["exercise"]),
                    CategorySelection(categoryName: "People", selectedOptions: ["none"])
                ]
            ),
            
                        // Yesterday
            MoodEntryData(
                id: UUID(),
                date: calendar.date(byAdding: .day, value: -1, to: now)!,
                mood: .good,
                textEntry: "Team lunch was amazing! Sarah shared some great news about her promotion. Love working with such inspiring people.",
                audioURL: nil,
                audioTranscript: nil,
                photoURL: nil,
                categories: [
                    CategorySelection(categoryName: "Emotions", selectedOptions: ["proud"]),
                    CategorySelection(categoryName: "People", selectedOptions: ["friends"]),
                    CategorySelection(categoryName: "Hobbies", selectedOptions: ["TV & content"])
                ]
            ),
            
                        // 2 days ago
            MoodEntryData(
                id: UUID(),
                date: calendar.date(byAdding: .day, value: -2, to: now)!,
                mood: .tough,
                textEntry: "Stressful day at work. The presentation didn't go as planned and I'm feeling a bit overwhelmed. Need some self-care time tonight.",
                audioURL: nil,
                audioTranscript: nil,
                photoURL: nil,
                categories: [
                    CategorySelection(categoryName: "Emotions", selectedOptions: ["stressed", "anxious"]),
                    CategorySelection(categoryName: "People", selectedOptions: ["friends"])
                ]
            ),
            
                        // 3 days ago
            MoodEntryData(
                id: UUID(),
                date: calendar.date(byAdding: .day, value: -3, to: now)!,
                mood: .good,
                textEntry: "Perfect weather for a weekend hike! The view from the mountain was absolutely breathtaking. Grateful for moments like these 🏔️",
                audioURL: nil,
                audioTranscript: nil,
                photoURL: nil,
                categories: [
                    CategorySelection(categoryName: "Emotions", selectedOptions: ["grateful"]),
                    CategorySelection(categoryName: "Hobbies", selectedOptions: ["exercise"]),
                    CategorySelection(categoryName: "Weather", selectedOptions: ["sunny"])
                ]
            ),
            
                        // 4 days ago
            MoodEntryData(
                id: UUID(),
                date: calendar.date(byAdding: .day, value: -4, to: now)!,
                mood: .good,
                textEntry: "Movie night with mom. We watched her favorite classic and shared so many laughs. These simple moments mean everything 💕",
                audioURL: nil,
                audioTranscript: nil,
                photoURL: nil,
                categories: [
                    CategorySelection(categoryName: "Emotions", selectedOptions: ["happy"]),
                    CategorySelection(categoryName: "People", selectedOptions: ["family"]),
                    CategorySelection(categoryName: "Hobbies", selectedOptions: ["movie"])
                ]
            ),
            
                        // 5 days ago
            MoodEntryData(
                id: UUID(),
                date: calendar.date(byAdding: .day, value: -5, to: now)!,
                mood: .challenging,
                textEntry: "Feeling a bit lonely today. Friends are all busy and I'm missing having someone to talk to. Maybe I'll call my sister later.",
                audioURL: nil,
                audioTranscript: nil,
                photoURL: nil,
                categories: [
                    CategorySelection(categoryName: "Emotions", selectedOptions: ["lonely", "sad"]),
                    CategorySelection(categoryName: "People", selectedOptions: ["none"])
                ]
            ),
            
                        // 6 days ago
            MoodEntryData(
                id: UUID(),
                date: calendar.date(byAdding: .day, value: -6, to: now)!,
                mood: .good,
                textEntry: "Started reading a new book today - 'Atomic Habits'. Already feeling motivated to build better routines. Knowledge is power! 📚",
                audioURL: nil,
                audioTranscript: nil,
                photoURL: nil,
                categories: [
                    CategorySelection(categoryName: "Emotions", selectedOptions: ["excited"]),
                    CategorySelection(categoryName: "Hobbies", selectedOptions: ["reading"])
                ]
            )
        ]
        
        moodEntries = demoEntries
        saveMoodEntriesToUserDefaults()
    }
    
    // MARK: - Data Operations (UserDefaults for now, will be Core Data later)
    
    // MARK: - ZENTRALISIERTE SAVE METHODEN
    
    /// Kontext für Mood Entry Erstellung
    struct MoodEntryContext {
        let text: String?
        let audioURL: URL?
        let audioTranscript: String?
        let photoURL: URL?
        let categories: [CategorySelection]
        
        init(text: String? = nil, audioURL: URL? = nil, audioTranscript: String? = nil, photoURL: URL? = nil, categories: [CategorySelection] = []) {
            self.text = text
            self.audioURL = audioURL
            self.audioTranscript = audioTranscript
            self.photoURL = photoURL
            self.categories = categories
        }
    }
    
    /// HAUPT-METHODE: Speichert Mood Entry für heute
    func saveMoodEntry(mood: MoodType, context: MoodEntryContext = MoodEntryContext()) {
        let moodEntry = MoodEntryData(
            mood: mood,
            textEntry: context.text?.isEmpty == false ? context.text : currentTextEntry.isEmpty ? nil : currentTextEntry,
            audioURL: context.audioURL ?? currentAudioURL,
            audioTranscript: context.audioTranscript ?? currentAudioTranscript,
            photoURL: context.photoURL,
            categories: context.categories
        )
        
        moodEntries.insert(moodEntry, at: 0)
        saveMoodEntriesToUserDefaults()
        resetCurrentEntry()
        calculateInsights()
        calculateWeeklyStats()
    }
    
    /// SPEZIAL-METHODE: Speichert Mood Entry für spezifisches Datum
    func saveMoodEntry(for date: Date, mood: MoodType, context: MoodEntryContext = MoodEntryContext()) {
        let moodEntry = MoodEntryData(
            date: date,
            mood: mood,
            textEntry: context.text?.isEmpty == false ? context.text : currentTextEntry.isEmpty ? nil : currentTextEntry,
            audioURL: context.audioURL ?? currentAudioURL,
            audioTranscript: context.audioTranscript ?? currentAudioTranscript,
            photoURL: context.photoURL,
            categories: context.categories
        )
        
        // Insert in correct chronological order
        if let insertIndex = moodEntries.firstIndex(where: { $0.date < date }) {
            moodEntries.insert(moodEntry, at: insertIndex)
        } else {
            moodEntries.append(moodEntry)
        }
        
        saveMoodEntriesToUserDefaults()
        resetCurrentEntry()
        calculateInsights()
        calculateWeeklyStats()
    }
    
    // MARK: - LEGACY METHODS (für Rückwärtskompatibilität - werden intern weitergeleitet)
    
    func saveMoodEntry() {
        guard let moodType = currentMoodType else { return }
        saveMoodEntry(mood: moodType)
    }
    
    func saveMoodEntry(categories: [CategorySelection]) {
        guard let moodType = currentMoodType else { return }
        let context = MoodEntryContext(categories: categories)
        saveMoodEntry(mood: moodType, context: context)
    }
    
    func saveMoodEntry(categories: [CategorySelection], photoURL: URL?) {
        guard let moodType = currentMoodType else { return }
        let context = MoodEntryContext(photoURL: photoURL, categories: categories)
        saveMoodEntry(mood: moodType, context: context)
    }
    
    func saveMoodEntry(for date: Date, mood: MoodType, text: String? = nil) {
        let context = MoodEntryContext(text: text)
        saveMoodEntry(for: date, mood: mood, context: context)
    }
    
    func saveMoodEntry(for date: Date, categories: [CategorySelection], photoURL: URL?) {
        guard let moodType = currentMoodType else { return }
        let context = MoodEntryContext(photoURL: photoURL, categories: categories)
        saveMoodEntry(for: date, mood: moodType, context: context)
    }
    
    // MARK: - Persistence Methods
    
    func loadMoodEntries() {
        if let data = UserDefaults.standard.data(forKey: "MoodEntries") {
            do {
                let entries = try JSONDecoder().decode([MoodEntryData].self, from: data)
            moodEntries = entries.sorted { $0.date > $1.date }
            } catch {
                print("Failed to load mood entries: \(error)")
                // Clear corrupted data and start fresh
                UserDefaults.standard.removeObject(forKey: "MoodEntries")
                moodEntries = []
            }
        }
    }
    
    func saveMoodEntriesToUserDefaults() {
        do {
            let data = try JSONEncoder().encode(moodEntries)
            UserDefaults.standard.set(data, forKey: "MoodEntries")
        } catch {
            print("Failed to save mood entries: \(error)")
            errorMessage = "Failed to save mood entry. Please try again."
        }
    }
    
    func deleteMoodEntry(_ moodEntry: MoodEntryData) {
        moodEntries.removeAll { $0.id == moodEntry.id }
        saveMoodEntriesToUserDefaults()
        calculateInsights()
    }
    
    // MARK: - Mood Entry Management
    
    func selectMood(_ moodType: MoodType) {
        currentMoodType = moodType
    }
    
    func resetCurrentEntry() {
        currentMoodType = nil
        currentTextEntry = ""
        currentAudioURL = nil
        currentAudioTranscript = nil
    }
    
    // MARK: - Data Management
    
    func deleteAllEntries() {
        moodEntries.removeAll()
        weeklyStats = nil
        commonWords = []
        currentTextEntry = ""
        currentAudioURL = nil
        currentAudioTranscript = nil
    }
    
    // MARK: - Simple Insights without AI
    
    func calculateInsights() {
        guard !moodEntries.isEmpty else {
            currentInsight = nil
            return
        }
        
        let recentEntries = Array(moodEntries.prefix(7)) // Last 7 entries
        let goodDays = recentEntries.filter { $0.mood == .good }.count
        let percentage = Int(Double(goodDays) / Double(recentEntries.count) * 100)
        
        let insight = MoodInsight(
            type: percentage > 50 ? .moodImproving : .moodStable,
            title: "Weekly Summary",
            message: "\(percentage)% of your recent days were good days.",
            tips: ["Keep doing what works for you!"],
            confidence: 0.8,
            generatedAt: Date()
        )
        
        currentInsight = insight
    }

    // MARK: - Weekly Stats Calculation
    
    func calculateWeeklyStats() {
        guard moodEntries.count >= 5 else {
            weeklyStats = nil
            return
        }
        
        let lastWeekEntries = moodEntries.filter { entry in
            Calendar.current.isDate(entry.date, equalTo: Date(), toGranularity: .weekOfYear)
        }
        
        let goodDays = lastWeekEntries.filter { $0.mood == .good }.count
        let totalDays = lastWeekEntries.count
        let positivePercentage = totalDays > 0 ? Double(goodDays) / Double(totalDays) * 100 : 0
        
        weeklyStats = WeeklyStats(
            totalEntries: totalDays,
            positivePercentage: positivePercentage,
            streak: calculateCurrentStreak()
        )
        
        calculateCommonWords()
    }
    
    private func calculateCurrentStreak() -> Int {
        guard !moodEntries.isEmpty else { return 0 }
        
        var streak = 0
        let sortedEntries = moodEntries.sorted { $0.date > $1.date }
        
        for entry in sortedEntries {
            if entry.mood == .good {
                streak += 1
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func calculateCommonWords() {
        let allText = moodEntries.compactMap { $0.displayText }
            .joined(separator: " ")
            .lowercased()
        
        let words = allText.components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count > 3 } // Filter short words
        
        let wordCounts = Dictionary(grouping: words, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        commonWords = Array(wordCounts.prefix(10).map { $0.key })
    }
    
    // MARK: - Filtering
    
    func filteredEntries(moodType: MoodType? = nil, hasAudio: Bool? = nil) -> [MoodEntryData] {
        return moodEntries.filter { entry in
            if let moodType = moodType, entry.mood != moodType {
                return false
            }
            if let hasAudio = hasAudio, entry.hasAudio != hasAudio {
                return false
            }
            return true
        }
    }
    
    // MARK: - HealthKit Integration
    
    private func setupHealthKitIfNeeded() {
        // Check if user has previously declined HealthKit
        let hasPromptedForHealthKit = UserDefaults.standard.bool(forKey: "HasPromptedForHealthKit")
        
        if !hasPromptedForHealthKit && healthKitManager.isHealthKitAvailable {
            showHealthKitPrompt = true
        }
    }
    
    func requestHealthKitAccess() async {
        await healthKitManager.requestAuthorization()
        UserDefaults.standard.set(true, forKey: "HasPromptedForHealthKit")
        showHealthKitPrompt = false
        
        if healthKitManager.isAuthorized {
            // Load health data for existing mood entries
            await loadHealthDataForMoodEntries()
        }
    }
    
    func declineHealthKitAccess() {
        UserDefaults.standard.set(true, forKey: "HasPromptedForHealthKit")
        showHealthKitPrompt = false
    }
    
    private func loadHealthDataForMoodEntries() async {
        guard healthKitManager.isAuthorized else { return }
        
        // Get date range of mood entries
        let dates = Set(moodEntries.map { Calendar.current.startOfDay(for: $0.date) })
        
        for date in dates {
            await healthKitManager.loadHealthData(for: date)
        }
    }
    
    func getHealthDataForEntry(_ entry: MoodEntryData) -> HealthData? {
        return healthKitManager.getHealthDataForDate(entry.date)
    }
    
    func getMoodEntry(for date: Date) -> MoodEntryData? {
        let calendar = Calendar.current
        return moodEntries.first { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }
}

// MARK: - Supporting Types

struct WeeklyStats {
    let totalEntries: Int
    let positivePercentage: Double
    let streak: Int
}

// MARK: - Affirmations

extension MoodViewModel {
    func getAffirmation(for moodType: MoodType) -> String {
        let affirmations: [MoodType: [String]] = [
            .good: [
                "You made it through. That counts.",
                "Small wins matter too.",
                "This feeling is worth noting.",
                "You're building something beautiful."
            ],
            .challenging: [
                "Bad days don't define you.",
                "Noted. Now let it go.",
                "Tomorrow is unwritten.",
                "You're stronger than this moment.",
                "This too shall pass."
            ]
        ]
        
        let moodAffirmations = affirmations[moodType] ?? affirmations[.good]!
        return moodAffirmations.randomElement() ?? "You matter."
    }
}

// MARK: - AI Analysis Integration

extension MoodViewModel {
    private func setupAnalysisObservers() {
        // Analysis observers disabled - using simple local insights now
    }
    
    private func setupPredictionService() {
        // Prediction service disabled - using simple local processing now
    }
    
    // Removed AI-powered prediction and analysis functions
    
} 