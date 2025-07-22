//
//  MoodEntry.swift
//  Mooday
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import Foundation

// Temporary data structure until Core Data model is created in Xcode
struct MoodEntryData: Identifiable, Codable {
    let id: UUID
    let date: Date
    let moodType: String
    let textEntry: String?
    let audioURL: URL?
    let audioTranscript: String?
    let photoURL: URL?
    let categories: [CategorySelection]
    let createdAt: Date
    let updatedAt: Date
    
    init(id: UUID = UUID(), date: Date = Date(), mood: MoodType, textEntry: String? = nil, audioURL: URL? = nil, audioTranscript: String? = nil, photoURL: URL? = nil, categories: [CategorySelection] = []) {
        self.id = id
        self.date = date
        self.moodType = mood.rawValue
        self.textEntry = textEntry
        self.audioURL = audioURL
        self.audioTranscript = audioTranscript
        self.photoURL = photoURL
        self.categories = categories
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var mood: MoodType {
        return MoodType(rawValue: moodType) ?? .good
    }
    
    var hasAudio: Bool {
        return audioURL != nil
    }
    
    var hasText: Bool {
        return textEntry != nil && !textEntry!.isEmpty
    }
    
    var hasPhoto: Bool {
        return photoURL != nil
    }
    
    var displayText: String {
        return audioTranscript ?? textEntry ?? ""
    }
}

enum MoodType: String, CaseIterable, Identifiable {
    // GOOD CATEGORY (3.5-6.0)
    case amazing = "amazing"
    case good = "good"
    case okay = "okay"
    
    // DIFFICULT CATEGORY (1.0-3.0)
    case challenging = "challenging"
    case tough = "tough"
    case overwhelming = "overwhelming"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .amazing:
            return "Amazing Day"
        case .good:
            return "Good Day"
        case .okay:
            return "Okay Day"
        case .challenging:
            return "Challenging Day"
        case .tough:
            return "Tough Day"
        case .overwhelming:
            return "Overwhelming Day"
        }
    }
    
    // ENTFERNT: String-basierte Farbreferenzen - Verwende stattdessen DesignSystem.moodColor(for:)
    
    // Numerischer Wert für Graphen (1.0-6.0)
    var numericValue: Double {
        switch self {
        case .overwhelming: return 1.0
        case .tough: return 2.0
        case .challenging: return 3.0
        case .okay: return 4.0
        case .good: return 5.0
        case .amazing: return 6.0
        }
    }
    
    // Hauptkategorie für Gruppierung
    var mainCategory: MainMoodCategory {
        switch self {
        case .amazing, .good, .okay:
            return .positive
        case .challenging, .tough, .overwhelming:
            return .difficult
        }
    }
    
    // Icon für UI - Moderne, ästhetische Symbole
    var icon: String {
        switch self {
        // Positive Icons: Moderne, aufsteigende Energie-Symbole
        case .amazing: return "star.circle.fill"       // Stern im Kreis - Exzellenz
        case .good: return "checkmark.circle.fill"      // Häkchen - Erfolg & Zufriedenheit
        case .okay: return "minus.circle.fill"          // Ausgewogener Strich - Neutral
        // Difficult Icons: Moderne, absteigende Abstraktionen
        case .challenging: return "questionmark.circle.fill"  // Fragezeichen - Unsicherheit
        case .tough: return "exclamationmark.circle.fill"     // Ausrufezeichen - Anstrengung
        case .overwhelming: return "xmark.circle.fill"        // X - Überforderung
        }
    }
}

// MARK: - Hauptkategorien für UI-Gruppierung
enum MainMoodCategory: String, CaseIterable, Identifiable {
    case positive = "positive"
    case difficult = "difficult"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .positive:
            return "Good Days"
        case .difficult:
            return "Difficult Days"
        }
    }
    
    var description: String {
        switch self {
        case .positive:
            return "Days when you're feeling well"
        case .difficult:
            return "Days that feel more challenging"
        }
    }
} 