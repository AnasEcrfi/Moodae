//
//  ContentView.swift
//  Mooday
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: MoodViewModel
    @State private var selectedMoodType: MoodType?
    @State private var showingSubcategories: MainMoodCategory?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
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
                        
                        // Recent Entries
                        if !viewModel.moodEntries.isEmpty {
                            recentEntriesSection
                        }
                        
                        // Bottom Padding for Tab Bar
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.top, DesignSystem.Spacing.lg)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedMoodType) { moodType in
            EnhancedMoodInputView(
                viewModel: viewModel,
                moodType: moodType,
                isPresented: .constant(true),
                onComplete: {
                    selectedMoodType = nil
                }
            )
            .environmentObject(viewModel)
        }
        .sheet(item: $showingSubcategories) { category in
            MoodSubcategorySelectionView(
                category: category,
                onMoodSelected: { mood in
                    showingSubcategories = nil
                    selectedMoodType = mood
                },
                onDismiss: {
                    showingSubcategories = nil
                }
            )
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
            
            // Welcome Message
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("How are you feeling?")
                    .font(.system(size: 32, weight: .light, design: .default))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .subtleAppearance(delay: 0.2)
                
                Text("Track your daily mood")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .multilineTextAlignment(.center)
                    .subtleAppearance(delay: 0.3)
            }
        }
    }
    
    // MARK: - Main Content Section
    private var mainContentSection: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            // Mood Selection Cards (Original Design)
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Good Day Card
                CleanMoodCard(
                    title: "Good Day",
                    subtitle: "Share positive moments",
                    icon: "sun.max",
                    color: DesignSystem.Colors.accent,
                    action: { showMoodSubcategories(.positive) },
                    moodType: .good,
                    useAnimatedIcon: true
                )
                .subtleAppearance(delay: 0.4)
                
                // Difficult Day Card
                CleanMoodCard(
                    title: "Difficult Day",
                    subtitle: "Express your challenges",
                    icon: "cloud.rain",
                    color: DesignSystem.Colors.secondary,
                    action: { showMoodSubcategories(.difficult) },
                    moodType: .challenging,
                    useAnimatedIcon: true
                )
                .subtleAppearance(delay: 0.5)
            }
            
            // Today's Summary
            if let todayEntry = todaysMoodEntry {
                todaySummaryCard(todayEntry)
                    .subtleAppearance(delay: 0.6)
            }
        }
    }
    
    // MARK: - Recent Entries Section
    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            CleanSectionHeader("Recent Entries", subtitle: "Your latest mood entries")
            
            VStack(spacing: DesignSystem.Spacing.md) {
                ForEach(recentEntries.prefix(3), id: \.id) { entry in
                    recentEntryCard(entry)
                }
            }
            .subtleAppearance(delay: 0.6)
        }
    }
    
    // MARK: - Helper Views
    private func todaySummaryCard(_ entry: MoodEntryData) -> some View {
        CleanCard(padding: DesignSystem.Spacing.lg) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    Image(systemName: DesignSystem.moodIconName(for: entry.mood, filled: true))
                        .font(.system(size: 24))
                        .foregroundColor(DesignSystem.moodIconColor(for: entry.mood))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Today's Entry")
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.primary)
                        
                        Text(entry.mood.displayName)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.moodColor(for: entry.mood))
                    }
                    
                    Spacer()
                }
                
                if !entry.displayText.isEmpty {
                    Text(entry.displayText)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.secondary)
                        .lineLimit(3)
                }
            }
        }
    }
    
    private func recentEntryCard(_ entry: MoodEntryData) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: DesignSystem.moodIconName(for: entry.mood, filled: true))
                .font(.system(size: 20))
                .foregroundColor(DesignSystem.moodIconColor(for: entry.mood))
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(formattedDate(entry.date))
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text(entry.mood.displayName)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .light))
                .foregroundColor(DesignSystem.Colors.secondary)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(DesignSystem.Colors.cardBackground.opacity(0.5))
        )
    }
    
    // MARK: - Computed Properties
    private var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
    
    private var todaysMoodEntry: MoodEntryData? {
        let calendar = Calendar.current
        return viewModel.moodEntries.first { entry in
            calendar.isDate(entry.date, inSameDayAs: Date())
        }
    }
    
    private var recentEntries: [MoodEntryData] {
        return viewModel.moodEntries
            .sorted { $0.date > $1.date }
            .prefix(5)
            .map { $0 }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
    
    // MARK: - Actions
    private func showMoodSubcategories(_ category: MainMoodCategory) {
        HapticFeedback.medium.trigger()
        showingSubcategories = category
    }
}

#Preview {
    ContentView()
        .environmentObject(MoodViewModel())
}
