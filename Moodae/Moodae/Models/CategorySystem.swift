//
//  CategorySystem.swift
//  Mooday
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

// MARK: - Category System

struct MoodCategory: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let icon: String
    let color: Color
    let options: [CategoryOption]
    var isEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, icon, options, isEnabled
    }
    
    init(name: String, icon: String, color: Color, options: [CategoryOption]) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.color = color
        self.options = options
        self.isEnabled = true
    }
    
    // Custom Codable implementation for Color
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        icon = try container.decode(String.self, forKey: .icon)
        options = try container.decode([CategoryOption].self, forKey: .options)
        isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
        // If no match found, return the accent color
        color = DesignSystem.Colors.accent // Use adaptive accent color
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(icon, forKey: .icon)
        try container.encode(options, forKey: .options)
        try container.encode(isEnabled, forKey: .isEnabled)
    }
}

struct CategoryOption: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let icon: String
    let color: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, icon, color
    }
    
    init(name: String, icon: String, color: String? = nil) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.color = color
    }
}

struct CategorySelection: Identifiable, Codable {
    let id: UUID
    let categoryName: String
    let selectedOptions: [String]
    let date: Date
    
    init(categoryName: String, selectedOptions: [String]) {
        self.id = UUID()
        self.categoryName = categoryName
        self.selectedOptions = selectedOptions
        self.date = Date()
    }
}

// MARK: - Predefined Categories

extension MoodCategory {
    static let defaultCategories: [MoodCategory] = [
        MoodCategory(
            name: "Emotions",
            icon: "heart.fill",
            color: DesignSystem.Colors.accent,
            options: [
                CategoryOption(name: "excited", icon: "bolt.fill", color: "accent"),
                CategoryOption(name: "relaxed", icon: "leaf.fill", color: "accent"),
                CategoryOption(name: "proud", icon: "trophy.fill", color: "accent"),
                CategoryOption(name: "hopeful", icon: "lightbulb.fill", color: "accent"),
                CategoryOption(name: "happy", icon: "face.smiling.fill", color: "accent"),
                CategoryOption(name: "enthusiastic", icon: "flame.fill", color: "accent"),
                CategoryOption(name: "refreshed", icon: "drop.fill", color: "accent"),
                CategoryOption(name: "calm", icon: "circle.fill", color: "accent"),
                CategoryOption(name: "grateful", icon: "hands.sparkles.fill", color: "accent"),
                CategoryOption(name: "depressed", icon: "cloud.fill", color: "secondary"),
                CategoryOption(name: "lonely", icon: "person.fill.xmark", color: "secondary"),
                CategoryOption(name: "anxious", icon: "heart.slash.fill", color: "secondary"),
                CategoryOption(name: "sad", icon: "drop.triangle.fill", color: "secondary"),
                CategoryOption(name: "angry", icon: "exclamationmark.triangle.fill", color: "secondary"),
                CategoryOption(name: "pressured", icon: "gauge.high", color: "secondary"),
                CategoryOption(name: "annoyed", icon: "xmark.octagon.fill", color: "secondary"),
                CategoryOption(name: "tired", icon: "zzz", color: "secondary"),
                CategoryOption(name: "stressed", icon: "bolt.slash.fill", color: "secondary"),
                CategoryOption(name: "bored", icon: "ellipsis.circle.fill", color: "secondary")
            ]
        ),
        
        MoodCategory(
            name: "People",
            icon: "person.2.fill",
            color: DesignSystem.Colors.accent,
            options: [
                CategoryOption(name: "friends", icon: "star.fill", color: "accent"),
                CategoryOption(name: "family", icon: "house.fill", color: "accent"),
                CategoryOption(name: "partner", icon: "heart.fill", color: "accent"),
                CategoryOption(name: "none", icon: "xmark.circle", color: "tertiary")
            ]
        ),
        
        MoodCategory(
            name: "Weather",
            icon: "cloud.sun.fill",
            color: DesignSystem.Colors.accent,
            options: [
                CategoryOption(name: "sunny", icon: "sun.max.fill", color: "accent"),
                CategoryOption(name: "cloudy", icon: "cloud.fill", color: "secondary"),
                CategoryOption(name: "rainy", icon: "cloud.rain.fill", color: "secondary"),
                CategoryOption(name: "snowy", icon: "snowflake", color: "secondary"),
                CategoryOption(name: "windy", icon: "wind", color: "secondary"),
                CategoryOption(name: "stormy", icon: "cloud.bolt.fill", color: "secondary"),
                CategoryOption(name: "hot", icon: "flame.fill", color: "accent"),
                CategoryOption(name: "cold", icon: "snowflake", color: "tertiary")
            ]
        ),
        
        MoodCategory(
            name: "Hobbies",
            icon: "gamecontroller.fill",
            color: DesignSystem.Colors.accent,
            options: [
                CategoryOption(name: "exercise", icon: "figure.walk", color: "accent"),
                CategoryOption(name: "TV & content", icon: "tv.fill", color: "secondary"),
                CategoryOption(name: "movie", icon: "film.fill", color: "secondary"),
                CategoryOption(name: "gaming", icon: "gamecontroller.fill", color: "accent"),
                CategoryOption(name: "reading", icon: "book.fill", color: "secondary"),
                CategoryOption(name: "walk", icon: "figure.walk", color: "accent"),
                CategoryOption(name: "music", icon: "headphones", color: "accent"),
                CategoryOption(name: "drawing", icon: "paintpalette.fill", color: "secondary")
            ]
        )
    ]
} 