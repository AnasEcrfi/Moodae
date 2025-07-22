//
//  InsightsView.swift
//  Mooday
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

// MARK: - Shared Timeframe Enum
enum InsightsTimeframe: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

struct InsightsView: View {
    @ObservedObject var viewModel: MoodViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTimeframe: InsightsTimeframe = .week
    @State private var showingDetailedAnalysis = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Clean Background
                DesignSystem.Colors.surface
                    .ignoresSafeArea()
                
                if viewModel.moodEntries.isEmpty {
                    emptyStateView
                } else {
                    mainContentView
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        CleanEmptyState(
            icon: "chart.bar",
            title: "No Insights Yet",
            subtitle: "Start tracking your moods to see patterns and insights about your wellbeing",
            actionTitle: "Start Tracking",
            action: { /* Navigate to mood input */ }
        )
    }
    
    // MARK: - Main Content
    private var mainContentView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xxxl) {
                // Timeframe Selector
                timeframeSelectorView
                
                // MoodFlow Graph
                moodFlowSection
                
                // Mood Bar Timeline
                moodBarSection
                
                // Category Insights
                categoryInsightsSection
                
                // Year in Review Button
                yearInReviewButton
                
                // Overview Stats
                overviewSection
                
                // Mood Distribution
                moodDistributionSection
                
                // Insights Cards
                insightsSection
                
                // Bottom spacing to prevent tab bar overlap
                Spacer(minLength: 12)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.top, DesignSystem.Spacing.lg)
        }
    }
    
    // MARK: - Timeframe Selector
    private var timeframeSelectorView: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(InsightsTimeframe.allCases, id: \.self) { option in
                Button(action: {
                    HapticFeedback.light.trigger()
                    selectedTimeframe = option
                }) {
                    Text(option.rawValue)
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(selectedTimeframe == option ? .white : DesignSystem.Colors.secondary)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.pill)
                                .fill(selectedTimeframe == option ? DesignSystem.Colors.accent : DesignSystem.Colors.cardBackground)
                                .shadow(color: selectedTimeframe == option ? DesignSystem.Colors.accent.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
                        )
                }
                .buttonStyle(CleanButtonStyle())
            }
            
            Spacer()
        }
        .subtleAppearance(delay: 0.1)
    }
    
    // MARK: - MoodFlow Section
    private var moodFlowSection: some View {
        MoodFlowGraphView(entries: viewModel.moodEntries, timeframe: selectedTimeframe)
            .subtleAppearance(delay: 0.2)
    }
    
    // MARK: - Mood Bar Section
    private var moodBarSection: some View {
        MoodBarView(entries: viewModel.moodEntries, timeframe: selectedTimeframe)
            .subtleAppearance(delay: 0.3)
    }
    
    // MARK: - Year in Review Button
    private var yearInReviewButton: some View {
        NavigationLink(destination: YearInReviewView(entries: viewModel.moodEntries)) {
            HStack(spacing: 16) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.accent)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Year in Review")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text("Look back at your complete year")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(DesignSystem.Colors.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.secondary)
            }
            .padding(DesignSystem.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(DesignSystem.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .stroke(DesignSystem.Colors.accent.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .subtleAppearance(delay: 0.1)
    }
    
    // MARK: - Category Insights Section
    private var categoryInsightsSection: some View {
        CategoryInsightsView(entries: viewModel.moodEntries, timeframe: selectedTimeframe)
            .subtleAppearance(delay: 0.4)
    }
    
    // MARK: - Overview Section
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            CleanSectionHeader("Overview", subtitle: "Your mood tracking summary")
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.md) {
                CleanStatsCard(
                    title: "Total Entries",
                    value: "\(filteredEntries.count)",
                    subtitle: "This \(selectedTimeframe.rawValue.lowercased())",
                    icon: "calendar.badge.plus",
                    color: DesignSystem.Colors.info
                )
                .subtleAppearance(delay: 0.3)
                
                CleanStatsCard(
                    title: timeframeSpecificTitle,
                    value: "\(entriesThisWeek)",
                    subtitle: "Last 7 days",
                    icon: "clock.badge",
                    color: DesignSystem.Colors.success
                )
                .subtleAppearance(delay: 0.4)
                
                CleanStatsCard(
                    title: "Positive Days",
                    value: "\(goodDaysCount)",
                    subtitle: "\(goodDaysPercentage)%",
                    icon: "sun.max",
                    color: DesignSystem.moodColor(for: .good)
                )
                .subtleAppearance(delay: 0.5)
                
                CleanStatsCard(
                    title: "Streak",
                    value: "\(currentStreak)",
                    subtitle: "Days",
                    icon: "flame",
                    color: DesignSystem.Colors.warning
                )
                .subtleAppearance(delay: 0.6)
            }
        }
    }
    
    // MARK: - Mood Distribution Section
    private var moodDistributionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            CleanSectionHeader("Mood Distribution", subtitle: "How you've been feeling")
            
            CleanCard(cardSize: DesignSystem.CardSizing.comfortable) {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Good Days
                    moodDistributionRow(
                        title: "Positive Days",
                        count: goodDaysCount,
                        percentage: goodDaysPercentage,
                        color: DesignSystem.moodColor(for: .good),
                        icon: "sun.max"
                    )
                    
                    Divider()
                        .background(DesignSystem.Colors.secondary.opacity(0.3))
                    
                    // Difficult Days
                    moodDistributionRow(
                        title: "Difficult Days",
                        count: badDaysCount,
                        percentage: badDaysPercentage,
                        color: DesignSystem.moodColor(for: .challenging),
                        icon: "cloud.rain"
                    )
                }
            }
            .subtleAppearance(delay: 0.7)
        }
    }
    
    // MARK: - Insights Section
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            CleanSectionHeader("Insights", subtitle: "Patterns in your mood")
            
            VStack(spacing: DesignSystem.Spacing.md) {
                // Most active day
                CleanInsightCard(
                    icon: "calendar",
                    iconColor: DesignSystem.Colors.info,
                    title: "Most Active Day",
                    description: mostActiveDay.isEmpty ? "Not enough data yet" : "You track most often on \(mostActiveDay)"
                )
                .subtleAppearance(delay: 0.8)
                
                // Mood trend
                CleanInsightCard(
                    icon: "chart.line.uptrend.xyaxis",
                    iconColor: DesignSystem.Colors.success,
                    title: "Recent Trend",
                    description: recentTrendDescription
                )
                .subtleAppearance(delay: 0.9)
                
                // Consistency insight
                CleanInsightCard(
                    icon: "target",
                    iconColor: DesignSystem.Colors.accent,
                    title: "Consistency",
                    description: consistencyDescription
                )
                .subtleAppearance(delay: 1.0)
            }
        }
    }
    
    // MARK: - Helper Views
    private func moodDistributionRow(
        title: String,
        count: Int,
        percentage: Int,
        color: Color,
        icon: String
    ) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 16, weight: .light))
                .foregroundColor(color)
                .frame(width: 24)
            
            // Title and count
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text("\(count) entries")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondary)
            }
            
            Spacer()
            
            // Percentage
            Text("\(percentage)%")
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(color)
        }
    }
    

    
    // MARK: - Computed Properties
    private var filteredEntries: [MoodEntryData] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeframe {
        case .week:
            let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            return viewModel.moodEntries.filter { $0.date >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return viewModel.moodEntries.filter { $0.date >= monthAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return viewModel.moodEntries.filter { $0.date >= yearAgo }
        }
    }
    
    private var entriesThisWeek: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return viewModel.moodEntries.filter { $0.date >= weekAgo }.count
    }
    
    private var goodDaysCount: Int {
        filteredEntries.filter { $0.mood.mainCategory == .positive }.count
    }
    
    private var badDaysCount: Int {
        filteredEntries.filter { $0.mood.mainCategory == .difficult }.count
    }
    
    private var goodDaysPercentage: Int {
        guard !filteredEntries.isEmpty else { return 0 }
        return Int((Double(goodDaysCount) / Double(filteredEntries.count)) * 100)
    }
    
    private var badDaysPercentage: Int {
        guard !filteredEntries.isEmpty else { return 0 }
        return Int((Double(badDaysCount) / Double(filteredEntries.count)) * 100)
    }
    
    private var currentStreak: Int {
        // Simple streak calculation - consecutive days with entries
        let sortedEntries = filteredEntries.sorted { $0.date > $1.date }
        var streak = 0
        var lastDate = Date()
        
        for entry in sortedEntries {
            let daysDifference = Calendar.current.dateComponents([.day], from: entry.date, to: lastDate).day ?? 0
            if daysDifference <= 1 {
                streak += 1
                lastDate = entry.date
            } else {
                break
            }
        }
        
        return streak
    }
    
    private var mostActiveDay: String {
        guard !filteredEntries.isEmpty else { return "" }
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        
        let dayGroups = Dictionary(grouping: filteredEntries) { entry in
            dayFormatter.string(from: entry.date)
        }
        
        let mostActive = dayGroups.max { $0.value.count < $1.value.count }
        return mostActive?.key ?? ""
    }
    
    private var recentTrendDescription: String {
        guard filteredEntries.count >= 3 else {
            return "Track more moods to see trends"
        }
        
        let recentEntries = filteredEntries.suffix(7)
        let goodDays = recentEntries.filter { $0.mood.mainCategory == .positive }.count
        let totalDays = recentEntries.count
        
        let timeframeText = selectedTimeframe.rawValue.lowercased()
        
        if goodDays > totalDays / 2 {
            return "You've been having more good days this \(timeframeText)"
        } else {
            return "Consider what might help improve your mood this \(timeframeText)"
        }
    }
    
    private var consistencyDescription: String {
        let entriesCount = filteredEntries.count
        
        switch selectedTimeframe {
        case .week:
            if entriesCount >= 5 {
                return "Great job staying consistent this week"
            } else if entriesCount >= 3 {
                return "Good consistency, try to track daily"
            } else {
                return "Try to track your mood more regularly"
            }
        case .month:
            if entriesCount >= 20 {
                return "Excellent tracking consistency this month"
            } else if entriesCount >= 10 {
                return "Good tracking frequency this month"
            } else {
                return "Consider tracking more frequently this month"
            }
        case .year:
            if entriesCount >= 200 {
                return "Amazing consistency throughout the year"
            } else if entriesCount >= 100 {
                return "Good tracking habits this year"
            } else {
                return "Room for improvement in tracking frequency"
            }
        }
    }
    
    // MARK: - Helper Properties
    private var timeframeSpecificTitle: String {
        switch selectedTimeframe {
        case .week:
            return "This Week"
        case .month:
            return "This Month"
        case .year:
            return "This Year"
        }
    }
}

#Preview {
    InsightsView(viewModel: MoodViewModel())
} 