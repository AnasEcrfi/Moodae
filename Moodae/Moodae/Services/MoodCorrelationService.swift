//
//  MoodCorrelationService.swift
//  Moodae
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import Foundation
import SwiftUI

// MARK: - Supporting Types

struct MoodCorrelation {
    let impact: Double // Positive = good for mood, negative = bad for mood
    let strength: CorrelationStrength
    let frequency: Int
}

enum CorrelationStrength {
    case weak, moderate, strong
}

@MainActor
class MoodCorrelationService: ObservableObject {
    private let healthKitManager: HealthKitManager
    
    init(healthKitManager: HealthKitManager) {
        self.healthKitManager = healthKitManager
    }
    
    // MARK: - Correlation Analysis
    
    func analyzeCategoryCorrelations(_ entries: [MoodEntryData]) -> [String: MoodCorrelation] {
        var categoryMoods: [String: [Double]] = [:]
        
        for entry in entries {
            let moodValue = MoodType(rawValue: entry.moodType)?.numericValue ?? 3.0
            
            for category in entry.categories {
                for option in category.selectedOptions {
                    if categoryMoods[option] == nil {
                        categoryMoods[option] = []
                    }
                    categoryMoods[option]?.append(moodValue)
                }
            }
        }
        
        var correlations: [String: MoodCorrelation] = [:]
        
        for (category, moods) in categoryMoods {
            guard moods.count >= 3 else { continue }
            
            let averageMood = moods.reduce(0, +) / Double(moods.count)
            let overallAverage = entries.compactMap { MoodType(rawValue: $0.moodType)?.numericValue }.reduce(0, +) / Double(entries.count)
            
            let impact = averageMood - overallAverage
            let strength = determineStrength(impact: abs(impact), frequency: moods.count)
            
            correlations[category] = MoodCorrelation(
                impact: impact,
                strength: strength,
                frequency: moods.count
            )
        }
        
        return correlations
    }
    
    func analyzeHealthCorrelations(_ entries: [MoodEntryData]) async -> [String: Double] {
        guard healthKitManager.isAuthorized else { return [:] }
        
        var healthCorrelations: [String: Double] = [:]
        
        // Sleep correlation
        let sleepMoodPairs = entries.compactMap { entry -> (sleep: Double, mood: Double)? in
            let calendar = Calendar.current
            let dayStart = calendar.startOfDay(for: entry.date)
            guard let healthData = healthKitManager.dailyHealthData[dayStart],
                  healthData.sleepHours > 0,
                  let mood = MoodType(rawValue: entry.moodType)?.numericValue else {
                return nil
            }
            return (sleep: healthData.sleepHours, mood: mood)
        }
        
        if sleepMoodPairs.count >= 3 {
            let sleepValues = sleepMoodPairs.map { $0.sleep }
            let moodValues = sleepMoodPairs.map { $0.mood }
            healthCorrelations["sleep"] = calculateCorrelation(x: sleepValues, y: moodValues)
        }
        
        // Activity correlation
        let activityMoodPairs = entries.compactMap { entry -> (activity: Double, mood: Double)? in
            let calendar = Calendar.current
            let dayStart = calendar.startOfDay(for: entry.date)
            guard let healthData = healthKitManager.dailyHealthData[dayStart],
                  healthData.stepCount > 0,
                  let mood = MoodType(rawValue: entry.moodType)?.numericValue else {
                return nil
            }
            return (activity: Double(healthData.stepCount), mood: mood)
        }
        
        if activityMoodPairs.count >= 3 {
            let activityValues = activityMoodPairs.map { $0.activity }
            let moodValues = activityMoodPairs.map { $0.mood }
            healthCorrelations["activity"] = calculateCorrelation(x: activityValues, y: moodValues)
        }
        
        return healthCorrelations
    }
    
    // MARK: - Helper Methods
    
    private func determineStrength(impact: Double, frequency: Int) -> CorrelationStrength {
        if abs(impact) > 1.0 && frequency > 5 {
            return .strong
        } else if abs(impact) > 0.5 && frequency > 3 {
            return .moderate
        } else {
            return .weak
        }
    }
    
    private func calculateCorrelation(x: [Double], y: [Double]) -> Double {
        guard x.count == y.count && x.count > 1 else { return 0 }
        
        let n = Double(x.count)
        let sumX = x.reduce(0, +)
        let sumY = y.reduce(0, +)
        let sumXY = zip(x, y).map(*).reduce(0, +)
        let sumX2 = x.map { $0 * $0 }.reduce(0, +)
        let sumY2 = y.map { $0 * $0 }.reduce(0, +)
        
        let numerator = n * sumXY - sumX * sumY
        let denominator = sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY))
        
        return denominator != 0 ? numerator / denominator : 0
    }
} 