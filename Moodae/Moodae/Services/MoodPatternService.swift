//
//  MoodPatternService.swift
//  Moodae
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import Foundation
import SwiftUI

@MainActor
class MoodPatternService: ObservableObject {
    
    // MARK: - Pattern Analysis
    
    func analyzeTimePatterns(_ entries: [MoodEntryData]) -> [String: Double] {
        var timePatterns: [String: [Double]] = [:]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        
        for entry in entries {
            let hour = formatter.string(from: entry.date)
            let timeOfDay: String
            
            switch Int(hour) ?? 0 {
            case 6..<12: timeOfDay = "morning"
            case 12..<17: timeOfDay = "afternoon"
            case 17..<21: timeOfDay = "evening"
            default: timeOfDay = "night"
            }
            
            if timePatterns[timeOfDay] == nil {
                timePatterns[timeOfDay] = []
            }
            timePatterns[timeOfDay]?.append(MoodType(rawValue: entry.moodType)?.numericValue ?? 3.0)
        }
        
        return timePatterns.mapValues { moods in
            moods.reduce(0, +) / Double(moods.count)
        }
    }
    
    func analyzeWeeklyPatterns(_ entries: [MoodEntryData]) -> [String: Double] {
        var weeklyPatterns: [String: [Double]] = [:]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        
        for entry in entries {
            let dayName = formatter.string(from: entry.date)
            
            if weeklyPatterns[dayName] == nil {
                weeklyPatterns[dayName] = []
            }
            weeklyPatterns[dayName]?.append(MoodType(rawValue: entry.moodType)?.numericValue ?? 3.0)
        }
        
        return weeklyPatterns.mapValues { moods in
            moods.reduce(0, +) / Double(moods.count)
        }
    }
    
    func analyzeMoodTrend(_ entries: [MoodEntryData]) -> MoodTrend {
        guard entries.count >= 3 else { return .stable }
        
        let recentEntries = Array(entries.suffix(min(7, entries.count)))
        let moodValues = recentEntries.compactMap { MoodType(rawValue: $0.moodType)?.numericValue }
        
        guard moodValues.count >= 3 else { return .stable }
        
        // Simple trend calculation using first and last values
        let startMood = moodValues.prefix(3).reduce(0, +) / 3.0
        let endMood = moodValues.suffix(3).reduce(0, +) / 3.0
        
        let difference = endMood - startMood
        
        if difference > 0.5 {
            return .improving
        } else if difference < -0.5 {
            return .declining
        } else {
            return .stable
        }
    }
    
    func findBestTimeOfDay(_ timePatterns: [String: Double]) -> String? {
        return timePatterns.max(by: { $0.value < $1.value })?.key
    }
    
    func findBestDaysOfWeek(_ weeklyPatterns: [String: Double]) -> [String] {
        return weeklyPatterns
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }
    }
    
    // MARK: - Helper Methods
    
    func calculateVariance(_ values: [Double]) -> Double {
        guard values.count > 1 else { return 0 }
        let mean = values.reduce(0, +) / Double(values.count)
        let squaredDifferences = values.map { pow($0 - mean, 2) }
        return squaredDifferences.reduce(0, +) / Double(values.count - 1)
    }
}

// MARK: - Supporting Types

enum MoodTrend: String {
    case improving = "Improving"
    case declining = "Declining"
    case stable = "Stable"
} 