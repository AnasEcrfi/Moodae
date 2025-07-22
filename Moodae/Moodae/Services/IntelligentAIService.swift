import Foundation
import SwiftUI
import Combine

// MARK: - Modern Aesthetic Analytics Service

@MainActor
class AestheticAnalyticsService: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isProcessing = false
    @Published var contextualSuggestions: [ContextualSuggestion] = []
    @Published var proactiveInsights: [ProactiveInsight] = []
    @Published var conversationHistory: [AIConversation] = []
    @Published var userPersonality: UserPersonality?
    @Published var currentMoodContext: MoodContext?
    
    // MARK: - Private Properties
    private let healthKitManager: HealthKitManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Configuration
    private let maxContextHistorySize = 50
    private let proactiveCheckInterval: TimeInterval = 300 // 5 minutes
    private var lastProactiveCheck = Date()
    
    init(healthKitManager: HealthKitManager) {
        self.healthKitManager = healthKitManager
        
        setupProactiveMonitoring()
        loadUserPersonality()
    }
    
    // MARK: - Core AI Intelligence Methods
    
    /// Simple local processing without AI
    func processQuery(_ query: String) -> String {
        // Simple local response without AI
        return "Thank you for sharing. How can I help you today?"
    }
    
    /// Provides contextual suggestions based on current app state
    func getContextualSuggestions(for screen: AppScreen, moodData: [MoodEntryData]) async {
        // Simplified contextual suggestions without complex AI analysis
        var suggestions: [ContextualSuggestion] = []
        
        switch screen {
        case .home:
            suggestions.append(ContextualSuggestion(
                title: "Quick Check-in",
                description: "How are you feeling today?",
                action: SuggestedAction(title: "New Mood Entry", type: .moodEntry, parameters: [:]),
                priority: .high
            ))
        case .timeline:
            if moodData.count > 5 {
                suggestions.append(ContextualSuggestion(
                    title: "Review Patterns",
                    description: "Look at your recent mood trends",
                    action: SuggestedAction(title: "View Insights", type: .viewInsights, parameters: [:]),
                    priority: .medium
                ))
            }
        case .insights:
            suggestions.append(ContextualSuggestion(
                title: "Weekly Summary",
                description: "See your progress this week",
                action: SuggestedAction(title: "Weekly Report", type: .weeklyReport, parameters: [:]),
                priority: .medium
            ))
        default:
            break
        }
        
        contextualSuggestions = suggestions
    }
    
    /// Proactive mood check-in with intelligent timing
    func performProactiveMoodCheck() async {
        guard shouldPerformProactiveCheck() else { return }
        
        // Simplified proactive check without complex AI
        let recentConversations = Array(conversationHistory.suffix(10))
        
        if recentConversations.isEmpty || Date().timeIntervalSince(lastProactiveCheck) > proactiveCheckInterval {
            let insight = ProactiveInsight(
                title: "Time for a Check-in",
                message: "How has your day been so far?",
                type: .moodCheckIn,
                timestamp: Date(),
                action: SuggestedAction(title: "Mood Entry", type: .moodEntry, parameters: [:])
            )
            
            proactiveInsights.append(insight)
        }
        
        lastProactiveCheck = Date()
    }
    
    // MARK: - Context Building
    
    private func buildComprehensiveContext(for query: String, type: AIContext) async -> ComprehensiveContext {
        async let moodData = getMoodContextData()
        async let healthData = getHealthContextData()
        async let timeContext = getTemporalContext()
        async let conversationContext = getConversationContext()
        async let personalityContext = getPersonalityContext()
        
        return await ComprehensiveContext(
            query: query,
            contextType: type,
            moodData: moodData,
            healthData: healthData,
            timeContext: timeContext,
            conversationHistory: conversationContext,
            personality: personalityContext,
            appState: getCurrentAppState()
        )
    }
    
    private func getMoodContextData() async -> MoodContextData {
        // Get recent mood entries and patterns
        let recentEntries = Array(conversationHistory.suffix(20))
        let moodTrends = await analyzeMoodTrends(from: recentEntries)
        
        return MoodContextData(
            recentEntries: recentEntries,
            trends: moodTrends,
            averageMood: calculateAverageMood(from: recentEntries),
            moodVariability: calculateMoodVariability(from: recentEntries)
        )
    }
    
    private func getHealthContextData() async -> HealthContextData {
        // Integrate with HealthKit data if available
        return HealthContextData(
            sleepQuality: await healthKitManager.getRecentSleepData(),
            activityLevel: await healthKitManager.getRecentActivityData(),
            heartRateVariability: await healthKitManager.getHRVData()
        )
    }
    
    private func getTemporalContext() async -> TemporalContext {
        let now = Date()
        let calendar = Calendar.current
        
        return TemporalContext(
            timeOfDay: TimeOfDay.from(date: now),
            dayOfWeek: calendar.component(.weekday, from: now),
            season: Season.from(date: now),
            isWorkday: calendar.isWorkday(now),
            timeZone: TimeZone.current
        )
    }
    
    private func getConversationContext() async -> [AIConversation] {
        return Array(conversationHistory.suffix(10))
    }
    
    private func getPersonalityContext() async -> UserPersonality? {
        return userPersonality
    }
    
    // MARK: - Intent and Emotion Analysis
    
    private func analyzeUserIntent(_ query: String) -> UserIntent {
        // Simple local intent analysis
        if query.lowercased().contains("help") || query.lowercased().contains("support") {
            return .seekingSupport
        } else if query.lowercased().contains("mood") || query.lowercased().contains("feeling") {
            return .moodTracking
        }
        return .general
    }
    
    private func analyzeEmotionalState(_ query: String) -> EmotionalState {
        // Simple local emotional analysis
        return EmotionalState.neutral
    }
    
    // MARK: - Simple Response Generation
    
    private func generateSimpleResponse(_ query: String, intent: UserIntent) -> String {
        switch intent {
        case .seekingSupport:
            return "Thank you for sharing. I'm here to listen."
        case .moodTracking:
            return "Your mood entry has been recorded."
        default:
            return "How can I help you today?"
        }
    }
    
    // MARK: - Proactive Intelligence
    
    private func setupProactiveMonitoring() {
        Timer.publish(every: proactiveCheckInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.performProactiveMoodCheck()
                }
            }
            .store(in: &cancellables)
    }
    
    private func shouldPerformProactiveCheck() -> Bool {
        let timeSinceLastCheck = Date().timeIntervalSince(lastProactiveCheck)
        return timeSinceLastCheck >= proactiveCheckInterval
    }
    
    // MARK: - Simple Local Processing
    
    private func updatePersonalityModel() {
        // Simple local personality tracking
        userPersonality = UserPersonality(
            traits: PersonalityTraits(),
            preferences: UserPreferences(),
            communicationStyle: CommunicationStyle(),
            learningStyle: LearningStyle(),
            lastUpdated: Date()
        )
        saveUserPersonality()
    }
    
    // MARK: - Simple local functions without AI
    
    func analyzeMoodTrends(from conversations: [AIConversation]) async -> [AIMoodTrend] {
        // Simple local trend analysis
        return [AIMoodTrend(direction: "stable", strength: 0.5, confidence: 0.5)]
    }
    
    func calculateAverageMood(from conversations: [AIConversation]) -> Double {
        guard !conversations.isEmpty else { return 3.0 }
        
        let intensities = conversations.map(\.emotionalState.intensity)
        return intensities.reduce(0, +) / Double(intensities.count)
    }
    
    func calculateMoodVariability(from conversations: [AIConversation]) -> Double {
        guard conversations.count > 1 else { return 0.0 }
        
        let intensities = conversations.map(\.emotionalState.intensity)
        let average = intensities.reduce(0, +) / Double(intensities.count)
        
        let squaredDifferences = intensities.map { pow($0 - average, 2) }
        let variance = squaredDifferences.reduce(0, +) / Double(squaredDifferences.count)
        
        return sqrt(variance)
    }
    
    func generateSuggestedActions(intent: UserIntent, context: ComprehensiveContext) -> [SuggestedAction] {
        return []
    }
    
    func generateProactiveSuggestions(basedOn conversation: AIConversation) async {
        // Simple local processing
    }
    

    
    // MARK: - Helper Methods
    
    private func limitHistorySize() {
        if conversationHistory.count > maxContextHistorySize {
            conversationHistory.removeFirst(conversationHistory.count - maxContextHistorySize)
        }
    }
    
    private func getCurrentAppState() -> AppState {
        // Determine current app state based on active view
        return AppState(
            activeScreen: .home, // This would be dynamic
            userActivity: .browsing,
            lastInteraction: Date()
        )
    }
    
    // MARK: - Persistence
    
    private func loadUserPersonality() {
        // Load from UserDefaults or Core Data
        if let data = UserDefaults.standard.data(forKey: "userPersonality"),
           let personality = try? JSONDecoder().decode(UserPersonality.self, from: data) {
            self.userPersonality = personality
        }
    }
    
    private func saveUserPersonality() {
        guard let personality = userPersonality,
              let data = try? JSONEncoder().encode(personality) else { return }
        
        UserDefaults.standard.set(data, forKey: "userPersonality")
    }
}

// MARK: - Supporting Data Models

struct IntelligentResponse {
    let content: String
    let confidence: Double
    let suggestedActions: [SuggestedAction]
    let followUpQuestions: [String]
    let responseType: ResponseType
}

struct AIConversation: Codable, Identifiable {
    let id: UUID
    let userQuery: String
    let aiResponse: String
    let context: AIContext
    let timestamp: Date
    let emotionalState: EmotionalState
    let intent: UserIntent
}

struct ComprehensiveContext {
    let query: String
    let contextType: AIContext
    let moodData: MoodContextData
    let healthData: HealthContextData
    let timeContext: TemporalContext
    let conversationHistory: [AIConversation]
    let personality: UserPersonality?
    let appState: AppState
}

struct UserPersonality: Codable {
    let traits: PersonalityTraits
    let preferences: UserPreferences
    let communicationStyle: CommunicationStyle
    let learningStyle: LearningStyle
    let lastUpdated: Date
}

// MARK: - Supporting Types (using existing definitions from AIDataModels.swift)

enum UserIntent: String, Codable {
    case moodTracking
    case seekingSupport
    case requestingInsight
    case casual
    case crisis
    case general
}

enum ResponseType: String, Codable {
    case supportive
    case analytical
    case motivational
    case therapeutic
    case informational
}

enum AIContext: String, Codable {
    case general
    case moodEntry
    case crisis
    case insight
    case coaching
    case casual
}

// MARK: - Extensions for Prompt Building

private extension AestheticAnalyticsService {
    
    func buildIntelligentSystemPrompt(
        intent: UserIntent,
        emotionalState: EmotionalState,
        context: ComprehensiveContext
    ) -> String {
        var prompt = """
        Du bist ein intelligenter, empathischer KI-Coach für mentale Gesundheit. 
        
        KONTEXT:
        - Benutzerintention: \(intent.rawValue)
        - Emotionaler Zustand: \(emotionalState.description)
        - Tageszeit: \(context.timeContext.timeOfDay)
        - Persönlichkeit: \(context.personality?.traits.description ?? "Unbekannt")
        
        RICHTLINIEN:
        1. Sei empathisch und verständnisvoll
        2. Gib konkrete, umsetzbare Ratschläge
        3. Berücksichtige den emotionalen Zustand
        4. Halte Antworten prägnant aber hilfreich
        5. Bei Krisenindikatoren: Professionelle Hilfe empfehlen
        
        ANTWORT-STIL:
        """
        
        switch intent {
        case .crisis:
            prompt += "Calm, supportive, encouraging to seek professional help"
        case .moodTracking:
            prompt += "Analytical but warm, focused on patterns and improvements"
        case .seekingSupport:
            prompt += "Empathetic, validating, encouraging"
        case .casual:
            prompt += "Friendly, conversational, supportive"
        default:
            prompt += "Balanced, helpful, tailored to user"
        }
        
        return prompt
    }
    
    func buildIntentAnalysisPrompt(query: String, context: ComprehensiveContext) -> String {
        return """
        Analysiere die Benutzerintention in dieser Nachricht:
        "\(query)"
        
        Kontext: \(context.contextType.rawValue)
        Vorherige Gespräche: \(context.conversationHistory.count)
        
        Antworte nur mit einem der folgenden Werte:
        - moodTracking
        - seekingSupport  
        - requestingInsight
        - casual
        - crisis
        - general
        """
    }
    
    func buildEmotionalAnalysisPrompt(query: String, context: ComprehensiveContext) -> String {
        return """
        Analysiere den emotionalen Zustand in dieser Nachricht:
        "\(query)"
        
        Berücksichtige:
        - Wortschatz und Tonfall
        - Kontext der App-Nutzung
        - Tageszeit: \(context.timeContext.timeOfDay)
        
        Antworte im JSON-Format:
        {
            "emotion": "primary_emotion",
            "intensity": 0.0-1.0,
            "valence": "positive/negative/neutral",
            "urgency": "low/medium/high"
        }
        """
    }
}

// MARK: - Additional Supporting Types

struct ContextualSuggestion: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let action: SuggestedAction
    let priority: Priority
}

struct ProactiveInsight: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let type: AIInsightType
    let timestamp: Date
    let action: SuggestedAction?
}

struct SuggestedAction {
    let title: String
    let type: ActionType
    let parameters: [String: Any]
}

enum ActionType {
    case moodEntry
    case viewInsights
    case weeklyReport
    case breathingExercise
    case professionalHelp
    case reflection
}

enum Priority {
    case low, medium, high
}

enum AIInsightType {
    case moodCheckIn
    case pattern
    case recommendation
    case warning
}

enum AppScreen {
    case home
    case timeline
    case insights
    case settings
}

struct AppState {
    let activeScreen: AppScreen
    let userActivity: UserActivity
    let lastInteraction: Date
}

enum UserActivity {
    case browsing
    case inputting
    case analyzing
} 