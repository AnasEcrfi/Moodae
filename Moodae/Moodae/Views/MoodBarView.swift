//
//  MoodBarView.swift
//  Moodae
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

struct MoodBarView: View {
    let entries: [MoodEntryData]
    let timeframe: InsightsTimeframe
    @Environment(\.colorScheme) var colorScheme
    
    private let maxEntries: Int = 30
    
    var body: some View {
        CleanCard(cardSize: DesignSystem.CardSizing.comfortable) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                modernHeaderSection
                modernBarVisualization
                modernInsightsSection
            }
        }
    }
    
    // MARK: - Modern Header Section
    private var modernHeaderSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Mood Timeline")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text("Your recent mood journey")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(DesignSystem.Colors.secondary)
            }
            
            Spacer()
            
            // Modern Quick Stats Badge
            modernQuickStatsView
        }
    }
    
    // MARK: - Modern Quick Stats
    private var modernQuickStatsView: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Streak Counter
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(goodDaysCount)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(streakColor)
                
                Text("positive")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.secondary)
            }
            
            // Separator
            Rectangle()
                .fill(DesignSystem.Colors.separator.opacity(0.3))
                .frame(width: 1, height: 24)
            
            // Total count
            VStack(alignment: .leading, spacing: 2) {
                Text("\(filteredEntries.count)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text("total")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.secondary)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignSystem.Colors.accent.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DesignSystem.Colors.accent.opacity(0.2), lineWidth: 0.5)
                )
        )
    }
    
    // MARK: - Modern Bar Visualization
    private var modernBarVisualization: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            modernTimelineBar
            modernTimelineLabels
        }
    }
    
    // MARK: - Modern Timeline Bar
    private var modernTimelineBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track with modern styling
                RoundedRectangle(cornerRadius: 10)
                    .fill(DesignSystem.Colors.surface)
                    .frame(height: 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(DesignSystem.Colors.separator.opacity(0.2), lineWidth: 0.5)
                    )
                
                // Modern Mood segments
                HStack(spacing: 1) {
                    ForEach(Array(filteredEntries.enumerated()), id: \.offset) { index, entry in
                        modernMoodSegment(for: entry, at: index, totalWidth: geometry.size.width)
                    }
                    
                    // Future space indicators
                    if filteredEntries.count < maxEntries {
                        Spacer()
                            .overlay(
                                HStack(spacing: 3) {
                                    ForEach(0..<min(5, maxEntries - filteredEntries.count), id: \.self) { _ in
                                        Circle()
                                            .fill(DesignSystem.Colors.secondary.opacity(0.15))
                                            .frame(width: 4, height: 4)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            )
                    }
                }
                .padding(.horizontal, 3)
                .padding(.vertical, 3)
            }
        }
        .frame(height: 20)
    }
    
    // MARK: - Modern Mood Segment
    private func modernMoodSegment(for entry: MoodEntryData, at index: Int, totalWidth: CGFloat) -> some View {
        let isFirst = index == 0
        let isLast = index == filteredEntries.count - 1
        let cornerRadius: CGFloat = isFirst || isLast ? 8 : 4
        
        return RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    colors: modernGradientColors(for: entry.mood),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(height: 14)
            .overlay(
                // Subtle highlight for depth
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.25), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 7)
                    .offset(y: -3.5)
            )
            .scaleEffect(y: 1.0)
            .animation(
                .spring(response: 0.6, dampingFraction: 0.8)
                    .delay(Double(index) * 0.05),
                value: filteredEntries.count
            )
    }
    
    // MARK: - Modern Timeline Labels
    private var modernTimelineLabels: some View {
        HStack {
            if let firstEntry = filteredEntries.first {
                Text(formatDate(firstEntry.date))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.tertiary)
            }
            
            Spacer()
            
            Text("Now")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(DesignSystem.Colors.accent)
        }
    }
    
    // MARK: - Modern Insights Section
    private var modernInsightsSection: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            // Modern trend insight
            modernTrendInsightView
            
            Spacer()
            
            // Modern action hint
            modernActionHintView
        }
    }
    
    // MARK: - Modern Trend Insight
    private var modernTrendInsightView: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(trendColor.opacity(0.15))
                    .frame(width: 24, height: 24)
                
                Image(systemName: trendIcon)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(trendColor)
            }
            
            Text(trendMessage)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(DesignSystem.Colors.primary)
        }
    }
    
    // MARK: - Modern Action Hint
    private var modernActionHintView: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(DesignSystem.Colors.accent)
            
            Text("Add entry")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DesignSystem.Colors.accent)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(DesignSystem.Colors.accent.opacity(0.1))
        )
    }
    
    // MARK: - Computed Properties
    
    private var filteredEntries: [MoodEntryData] {
        let calendar = Calendar.current
        let now = Date()
        
        let filtered = entries.filter { entry in
            switch timeframe {
            case .week:
                let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
                return entry.date >= weekAgo
            case .month:
                let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
                return entry.date >= monthAgo
            case .year:
                let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
                return entry.date >= yearAgo
            }
        }
        
        return Array(filtered.sorted { $0.date < $1.date }.suffix(maxEntries))
    }
    
    private var goodDaysCount: Int {
        filteredEntries.filter { $0.mood.mainCategory == .positive }.count
    }
    
    private var streakColor: Color {
        switch goodDaysCount {
        case 0...2: return DesignSystem.Colors.secondary
        case 3...5: return DesignSystem.weatherIconColor(isGood: true)
        default: return DesignSystem.Colors.accent
        }
    }
    
    private var trendIcon: String {
        guard filteredEntries.count >= 3 else { return "minus" }
        
        let recentEntries = Array(filteredEntries.suffix(5))
        let averageRecent = recentEntries.map { $0.mood.numericValue }.reduce(0, +) / Double(recentEntries.count)
        
        if filteredEntries.count >= 6 {
            let olderEntries = Array(filteredEntries.prefix(filteredEntries.count - 3))
            let averageOlder = olderEntries.map { $0.mood.numericValue }.reduce(0, +) / Double(olderEntries.count)
            
            let difference = averageRecent - averageOlder
            
            if difference > 0.5 {
                return "arrow.up.right"
            } else if difference < -0.5 {
                return "arrow.down.right"
            }
        }
        
        return "minus"
    }
    
    private var trendColor: Color {
        switch trendIcon {
        case "arrow.up.right":
            return DesignSystem.weatherIconColor(isGood: true)
        case "arrow.down.right":
            return DesignSystem.weatherIconColor(isGood: false)
        default:
            return DesignSystem.Colors.secondary
        }
    }
    
    private var trendMessage: String {
        switch trendIcon {
        case "arrow.up.right":
            return "Trending positive"
        case "arrow.down.right":
            return "Room for improvement"
        default:
            return "Balanced pattern"
        }
    }
    
    // MARK: - Helper Functions
    
    private func modernGradientColors(for mood: MoodType) -> [Color] {
        let baseColor = DesignSystem.moodColor(for: mood)
        return [
            baseColor,
            baseColor.opacity(0.8)
        ]
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        
        if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .day) {
            return "Today"
        } else if Calendar.current.isDate(date, equalTo: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), toGranularity: .day) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}

#Preview {
    MoodBarView(entries: [], timeframe: .week)
} 