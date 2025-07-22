import Foundation

// MARK: - Missing Data Models for AI Service

// MARK: - Temporal Context Models
struct TemporalContext {
    let timeOfDay: TimeOfDay
    let dayOfWeek: Int
    let season: Season
    let isWorkday: Bool
    let timeZone: TimeZone
}

enum TimeOfDay: String, Codable {
    case morning = "morning"
    case afternoon = "afternoon"
    case evening = "evening"
    case night = "night"
    
    static func from(date: Date) -> TimeOfDay {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 6..<12: return .morning
        case 12..<17: return .afternoon
        case 17..<21: return .evening
        default: return .night
        }
    }
}

enum Season: String, Codable {
    case spring = "spring"
    case summer = "summer"
    case autumn = "autumn"
    case winter = "winter"
    
    static func from(date: Date) -> Season {
        let month = Calendar.current.component(.month, from: date)
        switch month {
        case 3...5: return .spring
        case 6...8: return .summer
        case 9...11: return .autumn
        default: return .winter
        }
    }
}

// MARK: - Mood Context Models
struct MoodContextData {
    let recentEntries: [AIConversation]
    let trends: [AIMoodTrend]
    let averageMood: Double
    let moodVariability: Double
}

struct MoodContext {
    let currentMood: String
    let intensity: Double
    let timestamp: Date
    let triggers: [String]
    let patterns: [String]
}

// MARK: - Health Context Models
struct HealthContextData {
    let sleepQuality: Double?
    let activityLevel: Double?
    let heartRateVariability: Double?
}

// MARK: - Personality Models
struct PersonalityTraits: Codable {
    let openness: Double
    let conscientiousness: Double
    let extraversion: Double
    let agreeableness: Double
    let neuroticism: Double
    let description: String
    
    init() {
        self.openness = 0.5
        self.conscientiousness = 0.5
        self.extraversion = 0.5
        self.agreeableness = 0.5
        self.neuroticism = 0.5
        self.description = "Ausgewogene Persönlichkeit"
    }
}

struct UserPreferences: Codable {
    let communicationFrequency: CommunicationFrequency
    let preferredResponseLength: ResponseLength
    let topics: [String]
    let triggers: [String]
    
    init() {
        self.communicationFrequency = .moderate
        self.preferredResponseLength = .medium
        self.topics = []
        self.triggers = []
    }
}

enum CommunicationFrequency: String, Codable {
    case minimal = "minimal"
    case moderate = "moderate"
    case frequent = "frequent"
}

enum ResponseLength: String, Codable {
    case short = "short"
    case medium = "medium"
    case detailed = "detailed"
}

struct CommunicationStyle: Codable {
    let formality: Formality
    let empathy: Double
    let directness: Double
    
    init() {
        self.formality = .casual
        self.empathy = 0.8
        self.directness = 0.6
    }
}

enum Formality: String, Codable {
    case formal = "formal"
    case casual = "casual"
    case friendly = "friendly"
}

struct LearningStyle: Codable {
    let preferredFormat: LearningFormat
    let pace: LearningPace
    let interactionStyle: InteractionStyle
    
    init() {
        self.preferredFormat = .conversational
        self.pace = .moderate
        self.interactionStyle = .guided
    }
}

enum LearningFormat: String, Codable {
    case conversational = "conversational"
    case structured = "structured"
    case exploratory = "exploratory"
}

enum LearningPace: String, Codable {
    case slow = "slow"
    case moderate = "moderate"
    case fast = "fast"
}

enum InteractionStyle: String, Codable {
    case guided = "guided"
    case autonomous = "autonomous"
    case collaborative = "collaborative"
}

// MARK: - Emotional State Models

enum Valence: String, Codable {
    case positive = "positive"
    case negative = "negative"
    case neutral = "neutral"
}

struct EmotionalState: Codable {
    let primaryEmotion: String
    let intensity: Double
    let valence: Valence
    let urgency: AIUrgencyLevel
    let description: String
    
    static let neutral = EmotionalState(
        primaryEmotion: "neutral",
        intensity: 0.5,
        valence: .neutral,
        urgency: .low,
        description: "Ausgeglichener emotionaler Zustand"
    )
}

enum AIUrgencyLevel: String, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
}

// MARK: - Extensions

extension Calendar {
    func isWorkday(_ date: Date) -> Bool {
        let weekday = component(.weekday, from: date)
        return weekday >= 2 && weekday <= 6 // Monday to Friday
    }
}



    

    
    private func findDominantEmotion(in conversations: [AIConversation]) -> String {
        let emotions = conversations.map(\.emotionalState.primaryEmotion)
        let emotionCounts = Dictionary(emotions.map { ($0, 1) }, uniquingKeysWith: +)
        return emotionCounts.max(by: { $0.value < $1.value })?.key ?? "neutral"
    }
    
    func parseIntentResponse(_ response: String) -> UserIntent? {
        let cleanResponse = response.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        switch cleanResponse {
        case "moodtracking": return .moodTracking
        case "seekingsupport": return .seekingSupport
        case "requestinginsight": return .requestingInsight
        case "casual": return .casual
        case "crisis": return .crisis
        default: return .general
        }
    }
    
    func parseEmotionalResponse(_ response: String) -> EmotionalState? {
        // Try to parse JSON response
        guard let data = response.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let emotion = json["emotion"] as? String,
              let intensity = json["intensity"] as? Double,
              let valenceString = json["valence"] as? String,
              let urgencyString = json["urgency"] as? String else {
            return nil
        }
        
        let valence: Valence = switch valenceString {
        case "positive": .positive
        case "negative": .negative
        default: .neutral
        }
        
        let urgency: AIUrgencyLevel = switch urgencyString {
        case "high": .high
        case "medium": .medium
        default: .low
        }
        
        return EmotionalState(
            primaryEmotion: emotion,
            intensity: intensity,
            valence: valence,
            urgency: urgency,
            description: "\(emotion) mit \(Int(intensity * 100))% Intensität"
        )
    }
    
    func calculateResponseConfidence(context: ComprehensiveContext) -> Double {
        var confidence = 0.5 // Base confidence
        
        // Increase confidence based on conversation history
        if context.conversationHistory.count > 5 {
            confidence += 0.2
        }
        
        // Increase confidence if we have personality data
        if context.personality != nil {
            confidence += 0.15
        }
        
        // Increase confidence based on context richness
        if context.moodData.recentEntries.count > 3 {
            confidence += 0.1
        }
        
        return min(confidence, 1.0)
    }

// MARK: - Additional Supporting Models

struct AIMoodTrend {
    let direction: String
    let strength: Double
    let confidence: Double
} 