//
//  MoodSelectorView.swift
//  Mooday
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

struct MoodSelectorView: View {
    @ObservedObject var viewModel: MoodViewModel
    @State private var showingTextInput = false
    @State private var showingEnhancedInput = false
    @State private var selectedMoodType: MoodType?
    @State private var showingCalendar = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Clean Background
            DesignSystem.Colors.surface
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: DesignSystem.Spacing.xxxl) {
                    // Header Section
                    headerSection
                    
                    // Main Content
                    mainContentSection
                    
                    // Bottom Padding
                    Spacer(minLength: 120)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.top, DesignSystem.Spacing.lg)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEnhancedInput) {
            if let moodType = selectedMoodType {
                EnhancedMoodInputView(
                    viewModel: viewModel,
                    moodType: moodType,
                    isPresented: $showingEnhancedInput,
                    onComplete: {
                        // Close both the EnhancedMoodInputView and MoodSelectorView
                        showingEnhancedInput = false
                        dismiss()
                    }
                )
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Date
            Text(currentDateString)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.secondary)
                .subtleAppearance(delay: 0.1)
            
            // Main Question
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("How was your day?")
                    .font(.system(size: 32, weight: .light, design: .default))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .multilineTextAlignment(.center)
                    .subtleAppearance(delay: 0.2)
                
                Text("Take a moment to reflect")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .multilineTextAlignment(.center)
                    .subtleAppearance(delay: 0.3)
            }
        }
    }
    
    // MARK: - Main Content Section
    private var mainContentSection: some View {
        VStack(spacing: DesignSystem.Spacing.xxxl) {
            // Simple Insight (if available)
            if moodEntries.count >= 3 {
                predictionSection
            }
            
            // Mood Selection Cards
            moodSelectionSection
            
                    // AI Insights (if available)
        if viewModel.currentInsight != nil {
            insightsSection
        }
        }
    }
    
    // MARK: - Prediction Section
    private var predictionSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Einfache lokale Prediction ohne AI Service
            if moodEntries.count >= 3 {
                simplePredictionCard
                    .subtleAppearance(delay: 0.4)
            }
        }
    }
    
    private var simplePredictionCard: some View {
        CleanCard(cardSize: DesignSystem.CardSizing.comfortable) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "brain")
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(DesignSystem.Colors.info)
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Quick Insight")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text(getSimplePrediction())
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Computed Properties
    private var moodEntries: [MoodEntryData] {
        return viewModel.moodEntries
    }
    
    private func getSimplePrediction() -> String {
        let recentEntries = Array(moodEntries.prefix(7))
        let goodDays = recentEntries.filter { $0.mood == .good }.count
        
        if goodDays > recentEntries.count / 2 {
            return "You've been having mostly good days lately!"
        } else {
            return "Consider doing something that makes you happy today."
        }
    }
    
    // MARK: - Mood Selection Section
    private var moodSelectionSection: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            // Good Day Card
            CleanMoodCard(
                title: "Good Day",
                subtitle: "Share positive moments",
                icon: "sun.max",
                color: DesignSystem.weatherIconColor(for: .good),
                action: { selectMood(.good) },
                moodType: .good,
                useAnimatedIcon: true
            )
            .subtleAppearance(delay: 0.5)
            
            // Difficult Day Card
            CleanMoodCard(
                title: "Difficult Day",
                subtitle: "Express your challenges",
                icon: "cloud.rain",
                color: DesignSystem.moodColor(for: .challenging),
                action: { selectMood(.challenging) },
                moodType: .challenging,
                useAnimatedIcon: true
            )
            .subtleAppearance(delay: 0.6)
        }
    }
    
    // MARK: - Insights Section
    private var insightsSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            if let insight = viewModel.currentInsight {
                insightCard(insight: insight)
                    .subtleAppearance(delay: 0.7)
            }
        }
    }
    
    // MARK: - Helper Views
    private func insightCard(insight: MoodInsight) -> some View {
        CleanCard(cardSize: DesignSystem.CardSizing.comfortable) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "brain")
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(DesignSystem.Colors.info)
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(insight.title)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text(insight.message)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
        }
    }
    

    
    // MARK: - Helper Properties
    private var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
    
    // MARK: - Actions
    private func selectMood(_ mood: MoodType) {
        HapticFeedback.medium.trigger()
        
        selectedMoodType = mood
        showingEnhancedInput = true
    }
}

// MARK: - Legacy Components (Cleaned Up)
struct CleanMoodCard_Legacy: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            HapticFeedback.light.trigger()
            action()
        }) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Clean Icon
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(color)
                
                // Title
                Text(title)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.xxl)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(DesignSystem.Colors.cardBackground)
                    .conditionalShadow(hasShadow: true, colorScheme: colorScheme)
            )
        }
        .buttonStyle(CleanButtonStyle())
    }
}

#Preview {
    MoodSelectorView(viewModel: MoodViewModel())
} 