//
//  PredictionModels.swift
//  Moodae
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import Foundation

// MARK: - Prediction Models

struct MoodPrediction {
    let predictedMood: MoodType
    let confidence: Double
    let score: Double
    let reasons: [String]
    let suggestedCategories: [String]
    let timeOfPrediction: Date
    
    var confidenceText: String {
        "\(Int(confidence * 100))% sure"
    }
    
    var mainReason: String {
        reasons.first ?? "Based on your previous entries"
    }
}

struct PredictionPatterns {
    let hourlyAverage: Double
    let weeklyAverage: Double
    let recentTrend: Double
    let commonCategories: [String]
    let totalEntries: Int
}

struct TimeFactors {
    let hour: Int
    let weekday: Int
    let isWeekend: Bool
    let timeOfDay: String
}

struct WeatherData {
    let condition: String
    let temperature: Double
    let location: CLLocation?
}

// MARK: - Advanced Prediction Models

struct MoodPredictionInsight: Identifiable {
    let id = UUID()
    let date: Date
    let predictedMood: MoodType
    let confidence: Double
    let factors: [PredictionFactor]
    let recommendations: [String]
}

struct PredictionFactor {
    let name: String
    let impact: Double
    let description: String
}

// MARK: - Time Series Models

struct TimeSeriesAnalysis {
    let trend: TrendDirection
    let seasonality: [SeasonalComponent]
    let volatility: Double
    let forecast: [Double]
}

enum TrendDirection {
    case improving, declining, stable
}

struct SeasonalComponent {
    let type: SeasonalType
    let strength: Double
    let phase: Double
}

enum SeasonalType {
    case daily, weekly, monthly
}

// MARK: - Cyclical Pattern Models

struct CyclicalPattern {
    let type: CyclicalType
    let strength: Double
    let phase: Double
}

enum CyclicalType {
    case daily, weekly, monthly, yearly
}

// MARK: - External Factors

struct ExternalFactorsAnalysis {
    let weather: FactorCorrelation
    let social: FactorCorrelation
    let work: FactorCorrelation
    let health: FactorCorrelation
}

struct FactorCorrelation {
    let strength: Double
    let direction: CorrelationDirection
}

enum CorrelationDirection {
    case positive, negative, neutral
}

// MARK: - Trend Analysis

struct TrendAnalysis {
    let direction: TrendDirection
    let strength: Double
    let confidence: Double
}

// MARK: - Extensions

import CoreLocation

extension Array where Element == MoodEntryData {
    func averageMoodScore() -> Double {
        guard !isEmpty else { return 3.0 }
        
        let scores = compactMap { MoodType(rawValue: $0.moodType)?.numericValue }
        return scores.reduce(0, +) / Double(scores.count)
    }
} 