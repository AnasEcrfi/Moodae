//
//  CategoryInsightsView.swift
//  Moodae
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

struct CategoryInsightsView: View {
    let entries: [MoodEntryData]
    let timeframe: InsightsTimeframe
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            // Frequently Recorded Section
            frequentlyRecordedSection
            
            // Best & Worst Patterns Section
            bestWorstPatternsSection
            
            // Category Correlations
            categoryCorrelationsSection
        }
    }
    
    // MARK: - Frequently Recorded Section
    private var frequentlyRecordedSection: some View {
        CleanCard(cardSize: DesignSystem.CardSizing.comfortable) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                sectionHeader(
                    title: "Most Active Categories",
                    subtitle: "Your most frequently selected patterns"
                )
                
                // Visual percentage bar
                categoryFrequencyBar
                
                // Top categories grid
                topCategoriesGrid
                
                // Summary insight
                if let topCategory = topCategories.first {
                    summaryInsight(for: topCategory)
                }
            }
        }
    }
    
    // MARK: - Category Frequency Bar
    private var categoryFrequencyBar: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(topCategories.prefix(5), id: \.category) { categoryData in
                    Text("\(categoryData.percentage)%")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.secondary)
                }
                Spacer()
            }
            
            GeometryReader { geometry in
                HStack(spacing: 2) {
                    ForEach(topCategories.prefix(5), id: \.category) { categoryData in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: gradientColors(for: categoryData.category),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(20, geometry.size.width * CGFloat(categoryData.percentage) / 100))
                            .animation(.easeInOut(duration: 0.6), value: categoryData.percentage)
                    }
                    Spacer()
                }
            }
            .frame(height: 8)
        }
    }
    
    // MARK: - Top Categories Grid
    private var topCategoriesGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
            ForEach(Array(topCategories.prefix(3).enumerated()), id: \.offset) { index, categoryData in
                categoryCard(
                    rank: index + 1,
                    category: categoryData.category,
                    count: categoryData.count,
                    percentage: categoryData.percentage
                )
            }
        }
    }
    
    // MARK: - Category Card
    private func categoryCard(rank: Int, category: String, count: Int, percentage: Int) -> some View {
        VStack(spacing: 12) {
            // Rank badge
            Text("\(rank)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(DesignSystem.Colors.secondary)
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(DesignSystem.Colors.surface)
                        .overlay(
                            Circle()
                                .stroke(DesignSystem.Colors.secondary.opacity(0.2), lineWidth: 1)
                        )
                )
            
            // Category icon and name
            VStack(spacing: 8) {
                if let categoryIcon = getCategoryIcon(for: category) {
                    Image(systemName: categoryIcon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(getCategoryColor(for: category))
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(getCategoryColor(for: category).opacity(0.15))
                        )
                }
                
                Text(category)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text("x\(count)")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(DesignSystem.Colors.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? DesignSystem.Colors.cardBackground : Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DesignSystem.Colors.secondary.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Best & Worst Patterns Section
    private var bestWorstPatternsSection: some View {
        CleanCard(cardSize: DesignSystem.CardSizing.comfortable) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                sectionHeader(
                    title: "Pattern Analysis",
                    subtitle: "Categories linked to all your different mood types"
                )
                
                // All 6 Mood Types Analysis
                modernMoodPatternAnalysis
            }
        }
    }
    
    // MARK: - Modern Mood Pattern Analysis
    private var modernMoodPatternAnalysis: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Positive Moods Section
            modernMoodSection(
                title: "Positive Days",
                moods: [.amazing, .good, .okay],
                color: DesignSystem.weatherIconColor(isGood: true)
            )
            
            Divider()
                .background(DesignSystem.Colors.separator.opacity(0.3))
            
            // Difficult Moods Section  
            modernMoodSection(
                title: "Challenging Days", 
                moods: [.challenging, .tough, .overwhelming],
                color: DesignSystem.weatherIconColor(isGood: false)
            )
        }
    }
    
    // MARK: - Modern Mood Section
    private func modernMoodSection(title: String, moods: [MoodType], color: Color) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            // Section Header
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: moods.first?.icon ?? "circle")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text("Common patterns for these moods")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(DesignSystem.Colors.secondary)
                }
                
                Spacer()
            }
            
            // Individual Mood Analysis
            VStack(spacing: DesignSystem.Spacing.md) {
                ForEach(moods, id: \.self) { mood in
                    if hasSufficientData(for: mood) {
                        modernPatternAnalysisView(for: mood)
                    }
                }
            }
        }
         }
     
     // MARK: - Modern Pattern Card
     private func modernPatternCard(category: String, score: Double, mood: MoodType, rank: Int) -> some View {
         VStack(spacing: DesignSystem.Spacing.xs) {
             // Rank badge
             Text("\(rank)")
                 .font(.system(size: 10, weight: .bold))
                 .foregroundColor(.white)
                 .frame(width: 16, height: 16)
                 .background(
                     Circle()
                         .fill(DesignSystem.moodColor(for: mood))
                 )
             
             // Category icon
             if let categoryIcon = getCategoryIcon(for: category) {
                 Image(systemName: categoryIcon)
                     .font(.system(size: 16, weight: .medium))
                     .foregroundColor(getCategoryColor(for: category))
                     .frame(width: 24, height: 24)
             }
             
             // Category name
             Text(category)
                 .font(.system(size: 10, weight: .medium))
                 .foregroundColor(DesignSystem.Colors.primary)
                 .multilineTextAlignment(.center)
                 .lineLimit(2)
                 .frame(maxWidth: 60)
             
             // Correlation strength
             HStack(spacing: 2) {
                 ForEach(0..<3, id: \.self) { index in
                     Circle()
                         .fill(index < Int(score) ? DesignSystem.moodColor(for: mood) : DesignSystem.Colors.separator)
                         .frame(width: 4, height: 4)
                 }
             }
         }
         .frame(width: 70, height: 90)
         .padding(.vertical, DesignSystem.Spacing.xs)
         .background(
             RoundedRectangle(cornerRadius: 10)
                 .fill(DesignSystem.Colors.cardBackground)
                 .overlay(
                     RoundedRectangle(cornerRadius: 10)
                         .stroke(DesignSystem.Colors.separator.opacity(0.2), lineWidth: 0.5)
                 )
                 .shadow(
                     color: DesignSystem.Colors.secondary.opacity(0.1),
                     radius: 2,
                     x: 0,
                     y: 1
                 )
         )
     }
     
     // MARK: - Modern Pattern Analysis View  
     private func modernPatternAnalysisView(for mood: MoodType) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Mood Header
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: mood.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignSystem.moodColor(for: mood))
                    .frame(width: 20, height: 20)
                
                Text(mood.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Spacer()
                
                // Entry count
                Text("\(getEntryCount(for: mood)) entries")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.tertiary)
            }
            
            // Top patterns for this mood
            let patterns = getPatterns(for: mood)
            
            if !patterns.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        ForEach(Array(patterns.prefix(5).enumerated()), id: \.offset) { index, pattern in
                            modernPatternCard(
                                category: pattern.category,
                                score: pattern.score,
                                mood: mood,
                                rank: index + 1
                            )
                        }
                    }
                    .padding(.horizontal, 2)
                }
            } else {
                Text("Not enough data for this mood type")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(DesignSystem.Colors.tertiary)
                    .padding(.leading, 24)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignSystem.moodColor(for: mood).opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DesignSystem.moodColor(for: mood).opacity(0.1), lineWidth: 0.5)
                )
        )
    }

    // MARK: - Pattern Analysis View (Legacy - keeping for compatibility)
    private func patternAnalysisView(for mood: MoodType) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: mood.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DesignSystem.moodColor(for: mood))
                
                Text("When you were feeling \(mood.displayName.lowercased())...")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.primary)
            }
            
            let patterns = getPatterns(for: mood)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(Array(patterns.prefix(3).enumerated()), id: \.offset) { index, pattern in
                    patternCard(
                        rank: index + 1,
                        category: pattern.category,
                        score: pattern.score,
                        mood: mood
                    )
                }
            }
        }
    }
    
    // MARK: - Pattern Card
    private func patternCard(rank: Int, category: String, score: Double, mood: MoodType) -> some View {
        VStack(spacing: 8) {
            Text("\(rank)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(DesignSystem.Colors.secondary)
            
            if let categoryIcon = getCategoryIcon(for: category) {
                Image(systemName: categoryIcon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(getCategoryColor(for: category))
            }
            
            Text(category)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(DesignSystem.Colors.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Score indicator
            HStack(spacing: 4) {
                Image(systemName: score >= 4.0 ? "star.fill" : (score >= 3.0 ? "star.leadinghalf.filled" : "star"))
                    .font(.system(size: 10))
                    .foregroundColor(DesignSystem.moodColor(for: mood))
                
                Text(String(format: "%.1f", score))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(DesignSystem.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(DesignSystem.Colors.secondary.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Category Correlations Section
    private var categoryCorrelationsSection: some View {
        CleanCard(cardSize: DesignSystem.CardSizing.comfortable) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                sectionHeader(
                    title: "Smart Insights",
                    subtitle: "Patterns discovered in your mood data"
                )
                
                LazyVStack(spacing: 12) {
                    ForEach(smartInsights, id: \.id) { insight in
                        insightCard(insight)
                    }
                }
            }
        }
    }
    
    // MARK: - Insight Card
    private func insightCard(_ insight: SmartInsight) -> some View {
        HStack(spacing: 16) {
            // Insight icon
            Image(systemName: insight.icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(insight.color)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(insight.color.opacity(0.15))
                )
            
            // Insight content
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text(insight.description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Confidence indicator
            Circle()
                .fill(insight.color)
                .frame(width: 8, height: 8)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignSystem.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DesignSystem.Colors.secondary.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Helper Views
    
    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.primary)
            
            Text(subtitle)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(DesignSystem.Colors.secondary)
        }
    }
    
    private func summaryInsight(for categoryData: CategoryData) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 14))
                .foregroundColor(DesignSystem.Colors.accent)
            
            Text("You recorded **\(categoryData.category)** the most.")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(DesignSystem.Colors.secondary)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Computed Properties
    
    private var topCategories: [CategoryData] {
        var categoryCount: [String: Int] = [:]
        
        for entry in entries {
            for categorySelection in entry.categories {
                for option in categorySelection.selectedOptions {
                    categoryCount[option, default: 0] += 1
                }
            }
        }
        
        let totalSelections = categoryCount.values.reduce(0, +)
        guard totalSelections > 0 else { return [] }
        
        return categoryCount.map { category, count in
            CategoryData(
                category: category,
                count: count,
                percentage: Int(Double(count) / Double(totalSelections) * 100)
            )
        }.sorted { $0.count > $1.count }
    }
    
    private var smartInsights: [SmartInsight] {
        var insights: [SmartInsight] = []
        
        // Most active emotion insight
        let emotionCategories = topCategories.filter { isEmotionCategory($0.category) }
        if let topEmotion = emotionCategories.first {
            insights.append(SmartInsight(
                id: "top_emotion",
                icon: "heart.fill",
                color: DesignSystem.Colors.accent,
                title: "Primary Emotion Pattern",
                description: "You most often feel \(topEmotion.category) (\(topEmotion.percentage)% of entries)"
            ))
        }
        
        // Social pattern insight
        let socialCategories = topCategories.filter { isSocialCategory($0.category) }
        if let topSocial = socialCategories.first {
            insights.append(SmartInsight(
                id: "social_pattern",
                icon: "person.2.fill",
                color: DesignSystem.weatherIconColor(for: .good),
                title: "Social Connection",
                description: "You're most often with \(topSocial.category) during mood tracking"
            ))
        }
        
        // Activity insight
        let activityCategories = topCategories.filter { isActivityCategory($0.category) }
        if let topActivity = activityCategories.first {
            insights.append(SmartInsight(
                id: "activity_pattern", 
                icon: "figure.walk",
                color: DesignSystem.Colors.accent,
                title: "Favorite Activity",
                description: "You engage in \(topActivity.category) most frequently"
            ))
        }
        
        return insights
    }
    
    // MARK: - Helper Functions
    
    private func getPatterns(for mood: MoodType) -> [PatternData] {
        var categoryMoodMap: [String: [Double]] = [:]
        
        for entry in entries.filter({ $0.mood == mood }) {
            for categorySelection in entry.categories {
                for option in categorySelection.selectedOptions {
                    if categoryMoodMap[option] == nil {
                        categoryMoodMap[option] = []
                    }
                    categoryMoodMap[option]?.append(mood == .good ? 5.0 : 2.0)
                }
            }
        }
        
        return categoryMoodMap.compactMap { category, scores in
            guard !scores.isEmpty else { return nil }
            let averageScore = scores.reduce(0, +) / Double(scores.count)
            return PatternData(category: category, score: averageScore)
        }.sorted { $0.score > $1.score }
    }
    
    private func gradientColors(for category: String) -> [Color] {
        let baseColor = getCategoryColor(for: category)
        return [baseColor, baseColor.opacity(0.7)]
    }
    
    private func getCategoryColor(for category: String) -> Color {
        if isEmotionCategory(category) {
            return isPositiveEmotion(category) ? DesignSystem.Colors.accent : DesignSystem.Colors.secondary
        } else if isSocialCategory(category) {
            return DesignSystem.Colors.accent
        } else if isActivityCategory(category) {
            return DesignSystem.Colors.accent
        }
        return DesignSystem.Colors.secondary
    }
    
    private func getCategoryIcon(for category: String) -> String? {
        let categoryOptions = MoodCategory.defaultCategories.flatMap { $0.options }
        return categoryOptions.first { $0.name == category }?.icon
    }
    
    private func isEmotionCategory(_ category: String) -> Bool {
        let emotionCategories = ["excited", "relaxed", "proud", "hopeful", "happy", "enthusiastic", "refreshed", "calm", "grateful", "depressed", "lonely", "anxious", "sad", "angry", "pressured", "annoyed", "tired", "stressed", "bored"]
        return emotionCategories.contains(category)
    }
    
    private func isPositiveEmotion(_ category: String) -> Bool {
        let positiveEmotions = ["excited", "relaxed", "proud", "hopeful", "happy", "enthusiastic", "refreshed", "calm", "grateful"]
        return positiveEmotions.contains(category)
    }
    
    private func isSocialCategory(_ category: String) -> Bool {
        let socialCategories = ["friends", "family", "partner", "none"]
        return socialCategories.contains(category)
    }
    
    private func isActivityCategory(_ category: String) -> Bool {
        let activityCategories = ["exercise", "TV & content", "movie", "gaming", "reading", "walk", "music", "drawing"]
        return activityCategories.contains(category)
    }

    private func hasSufficientData(for mood: MoodType) -> Bool {
        let moodEntries = entries.filter { $0.mood == mood }
        return !moodEntries.isEmpty
    }

    private func getEntryCount(for mood: MoodType) -> Int {
        let moodEntries = entries.filter { $0.mood == mood }
        return moodEntries.count
    }
}

// MARK: - Supporting Data Models

struct CategoryData {
    let category: String
    let count: Int
    let percentage: Int
}

struct PatternData {
    let category: String
    let score: Double
}

struct SmartInsight: Identifiable {
    let id: String
    let icon: String
    let color: Color
    let title: String
    let description: String
}

#Preview {
    let sampleEntries = [
        MoodEntryData(
            date: Date(),
            mood: .good,
            categories: [
                CategorySelection(categoryName: "Emotions", selectedOptions: ["happy", "relaxed"]),
                CategorySelection(categoryName: "People", selectedOptions: ["friends"]),
                CategorySelection(categoryName: "Hobbies", selectedOptions: ["music"])
            ]
        )
    ]
    
    CategoryInsightsView(entries: sampleEntries, timeframe: .week)
        .padding()
} 