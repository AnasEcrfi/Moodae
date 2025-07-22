import Foundation
import SwiftUI

// MARK: - Missing Types for Compilation

struct MoodInsight: Identifiable {
    let id = UUID()
    let type: InsightType
    let title: String
    let message: String
    let tips: [String]
    let confidence: Double
    let generatedAt: Date
}

enum InsightType {
    case sleepPositive, sleepNegative
    case activityPositive, activityLow
    case moodImproving, moodDeclining, moodStable
    case categoryPositive, categoryNegative
}



// MARK: - Simple structs to replace deleted AI services

struct WritingSuggestion: Identifiable {
    let id = UUID()
    let text: String
    let type: SuggestionType
}

enum SuggestionType {
    case starter, enhancer, alternative
}

enum WritingContext {
    case general, reflection, grateful, challenging
}

enum WritingStyle {
    case expressive, concise, analytical
}

// MARK: - Placeholder AI services (non-functional)

class AIWritingAssistant: ObservableObject {
    @Published var isGenerating = false
    @Published var suggestions: [WritingSuggestion] = []
    @Published var currentPrompt: String = ""
    
    func generateSuggestions(for input: String, mood: MoodType, context: WritingContext = .general) async {
        // Non-functional placeholder
        suggestions = []
    }
    
    func enhanceText(_ text: String, mood: MoodType, style: WritingStyle = .expressive) async -> String? {
        // Non-functional placeholder
        return nil
    }
}

struct AIGeneratedInsight {
    let title: String
    let content: String
    let confidence: Double
    let generatedAt: Date
    let keyInsights: [String]
}

struct PersonalizedTip: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: TipCategory
    let priority: TipPriority
    let isCompleted: Bool
}

enum TipCategory: String, CaseIterable {
    case sleep = "sleep"
    case activity = "activity" 
    case mood = "mood"
    case social = "social"
    
    var icon: String {
        switch self {
        case .sleep: return "bed.double.fill"
        case .activity: return "figure.walk"
        case .mood: return "heart.fill"
        case .social: return "person.2.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .sleep: return DesignSystem.Colors.accent
        case .activity: return DesignSystem.Colors.accent
        case .mood: return DesignSystem.Colors.accent
        case .social: return DesignSystem.Colors.accent
        }
    }
}

enum TipPriority: String, CaseIterable {
    case high = "high"
    case medium = "medium"
    case low = "low"
    
    var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .gray
        }
    }
} 