//
//  YearInReviewView.swift
//  Moodae
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

struct YearInReviewView: View {
    let entries: [MoodEntryData]
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var viewMode: ViewMode = .entire
    @State private var showingDetailedCalendar = false
    @State private var showDetailedMoods = true // Toggle between 6 moods vs Good/Difficult
    @Environment(\.colorScheme) var colorScheme
    
    enum ViewMode: String, CaseIterable {
        case entire = "Entire year"
        case byMonth = "By month"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                // Header with year selector
                headerSection
                
                // View mode selector
                viewModeSelector
                
                // Year visualization
                yearVisualizationSection
                
                // Summary insights
                yearSummarySection
                
                // Category insights (reuse existing component)
                CategoryInsightsView(entries: yearEntries, timeframe: .year)
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .navigationTitle("Year in Review")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingDetailedCalendar) {
            DetailedCalendarView(entries: yearEntries, year: selectedYear)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Year selector
            HStack {
                Button(action: { selectedYear -= 1 }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.accent)
                }
                
                Spacer()
                
                Text(String(selectedYear))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Spacer()
                
                Button(action: { selectedYear += 1 }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(selectedYear >= Calendar.current.component(.year, from: Date()) ? DesignSystem.Colors.secondary : DesignSystem.Colors.accent)
                }
                .disabled(selectedYear >= Calendar.current.component(.year, from: Date()))
            }
            
            Text("Look back on your \(String(selectedYear)).")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(DesignSystem.Colors.secondary)
        }
    }
    
    // MARK: - View Mode Selector
    private var viewModeSelector: some View {
        HStack(spacing: 0) {
            ForEach(ViewMode.allCases, id: \.self) { mode in
                Button(action: { 
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewMode = mode
                    }
                }) {
                    Text(mode.rawValue)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(viewMode == mode ? DesignSystem.Colors.accent : DesignSystem.Colors.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            Rectangle()
                                .fill(viewMode == mode ? DesignSystem.Colors.accent.opacity(0.1) : Color.clear)
                        )
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignSystem.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DesignSystem.Colors.secondary.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Year Visualization
    private var yearVisualizationSection: some View {
        CleanCard(cardSize: DesignSystem.CardSizing.comfortable) {
            VStack(spacing: 20) {
                if viewMode == .entire {
                    entireYearView
                } else {
                    monthlyView
                }
                
                // Action button
                Button(action: {
                    // Navigate to detailed calendar view
                    showDetailedView()
                }) {
                    Text("Explore Details")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(DesignSystem.Colors.accent)
                        )
                }
            }
        }
    }
    
    // MARK: - Entire Year View
    private var entireYearView: some View {
        VStack(spacing: 16) {
            // Month headers
            HStack(spacing: 0) {
                Text("")
                    .frame(width: 20) // Space for day numbers
                
                ForEach(1...12, id: \.self) { month in
                    Text(monthAbbreviation(month))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Days grid - proper calendar layout
            VStack(spacing: 3) {
                ForEach(1...31, id: \.self) { day in
                    HStack(spacing: 3) {
                        // Day number
                        Text("\(day)")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.secondary)
                            .frame(width: 20, alignment: .trailing)
                        
                        // Month dots
                        ForEach(1...12, id: \.self) { month in
                            Circle()
                                .fill(getDayColor(day: day, month: month))
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Circle()
                                        .stroke(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white.opacity(0.3), lineWidth: 0.5)
                                )
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 8)
    }
    
    // MARK: - Monthly View
    private var monthlyView: some View {
        VStack(spacing: 20) {
            // Month headers
            HStack(spacing: 0) {
                Text("")
                    .frame(width: 24) // Space for week numbers
                
                ForEach(1...12, id: \.self) { month in
                    Text(monthAbbreviation(month))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Monthly mood visualization
            VStack(spacing: 12) {
                ForEach(1...4, id: \.self) { week in
                    HStack(spacing: 6) {
                        Text("W\(week)")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.secondary)
                            .frame(width: 24, alignment: .center)
                        
                        ForEach(1...12, id: \.self) { month in
                            RoundedRectangle(cornerRadius: 6)
                                .fill(getMonthlyMoodColor(month: month))
                                .frame(width: 20, height: 20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(DesignSystem.Colors.secondary.opacity(0.2), lineWidth: 0.5)
                                )
                                .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                        }
                    }
                }
            }
            
            // Enhanced Legend with all 6 moods
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(MoodType.allCases, id: \.self) { moodType in
                    legendItem(
                        color: DesignSystem.moodColor(for: moodType),
                        label: moodType.displayName
                    )
                }
                
                // No data item
                legendItem(
                    color: DesignSystem.Colors.secondary.opacity(0.3),
                    label: "No data"
                )
            }
            .font(.system(size: 10, weight: .medium))
        }
        .padding(.horizontal, 8)
    }
    
    // MARK: - Year Summary Section
    private var yearSummarySection: some View {
        CleanCard(cardSize: DesignSystem.CardSizing.comfortable) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                Text("Year Summary")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.primary)
                
                // Mood Distribution for all 6 types
                modernMoodDistribution
                
                // Summary Statistics Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    summaryCard(
                        title: "Total Entries",
                        value: String(yearEntries.count),
                        icon: "calendar",
                        color: DesignSystem.Colors.accent
                    )
                        
                    summaryCard(
                        title: "Best Month",
                        value: bestMonth,
                        icon: "star.fill",
                        color: DesignSystem.weatherIconColor(isGood: true)
                    )
                        
                    summaryCard(
                        title: "Streak Record",
                        value: "\(String(longestStreak)) days",
                        icon: "flame.fill",
                        color: DesignSystem.Colors.accent
                    )
                        
                    summaryCard(
                        title: "Avg Mood",
                        value: String(format: "%.1f", averageYearMood),
                        icon: "chart.line.uptrend.xyaxis",
                        color: moodColorForAverage(averageYearMood)
                    )
                }
                
                // Year insights
                yearInsights
            }
        }
    }
    
    // MARK: - Modern Mood Distribution
    private var modernMoodDistribution: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            // Header with toggle
            HStack {
                Text("Mood Distribution")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Spacer()
                
                // Toggle between detailed and simplified view
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Text("6 Types")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(showDetailedMoods ? DesignSystem.Colors.accent : DesignSystem.Colors.secondary)
                    
                    Toggle("", isOn: $showDetailedMoods)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: DesignSystem.Colors.accent))
                        .scaleEffect(0.8)
                    
                    Text("Simple")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(showDetailedMoods ? DesignSystem.Colors.secondary : DesignSystem.Colors.accent)
                }
                
                Text("\(yearEntries.count) total")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .padding(.leading, DesignSystem.Spacing.sm)
            }
            
            // Mood type breakdown
            if showDetailedMoods {
                // Show all 6 mood types
                VStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(MoodType.allCases, id: \.self) { moodType in
                        modernMoodDistributionRow(for: moodType)
                    }
                }
            } else {
                // Show simplified Good vs Difficult
                VStack(spacing: DesignSystem.Spacing.sm) {
                    simplifiedMoodDistributionRow(type: .positive)
                    simplifiedMoodDistributionRow(type: .difficult)
                }
            }
            
            // Visual bar representation
            if showDetailedMoods {
                modernMoodDistributionBar
            } else {
                simplifiedMoodDistributionBar
            }
        }
    }
    
    // MARK: - Modern Mood Distribution Row
    private func modernMoodDistributionRow(for moodType: MoodType) -> some View {
        let count = getMoodCount(for: moodType)
        let percentage = getMoodPercentage(for: moodType)
        
        return HStack(spacing: DesignSystem.Spacing.md) {
            // Mood icon and name
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: moodType.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignSystem.moodColor(for: moodType))
                    .frame(width: 20)
                
                Text(moodType.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
            
            // Count and percentage
            HStack(spacing: DesignSystem.Spacing.sm) {
                Text("\(count)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text("(\(percentage)%)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .frame(minWidth: 35, alignment: .trailing)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Simplified Mood Distribution
    private enum SimplifiedMoodType {
        case positive
        case difficult
        
        var title: String {
            switch self {
            case .positive: return "Good Days"
            case .difficult: return "Difficult Days"
            }
        }
        
        var icon: String {
            switch self {
            case .positive: return "sun.max.fill"
            case .difficult: return "cloud.rain.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .positive: return DesignSystem.Colors.accent
            case .difficult: return DesignSystem.Colors.secondary
            }
        }
        
        var includedMoods: [MoodType] {
            switch self {
            case .positive: return [.amazing, .good, .okay]
            case .difficult: return [.challenging, .tough, .overwhelming]
            }
        }
    }
    
    private func simplifiedMoodDistributionRow(type: SimplifiedMoodType) -> some View {
        let count = getSimplifiedMoodCount(for: type)
        let percentage = getSimplifiedMoodPercentage(for: type)
        
        return HStack(spacing: DesignSystem.Spacing.md) {
            // Mood icon and name
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: type.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(type.color)
                    .frame(width: 20)
                
                Text(type.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
            
            // Count and percentage
            HStack(spacing: DesignSystem.Spacing.sm) {
                Text("\(count)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text("(\(percentage)%)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .frame(minWidth: 35, alignment: .trailing)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func getSimplifiedMoodCount(for type: SimplifiedMoodType) -> Int {
        return yearEntries.filter { entry in
            type.includedMoods.contains(entry.mood)
        }.count
    }
    
    private func getSimplifiedMoodPercentage(for type: SimplifiedMoodType) -> Int {
        guard !yearEntries.isEmpty else { return 0 }
        let count = getSimplifiedMoodCount(for: type)
        return Int(round(Double(count) / Double(yearEntries.count) * 100))
    }
    
    // MARK: - Simplified Mood Distribution Bar
    private var simplifiedMoodDistributionBar: some View {
        HStack(spacing: 2) {
            let positiveCount = getSimplifiedMoodCount(for: .positive)
            let difficultCount = getSimplifiedMoodCount(for: .difficult)
            let totalCount = positiveCount + difficultCount
            
            if totalCount > 0 {
                // Positive segment
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [
                                SimplifiedMoodType.positive.color,
                                SimplifiedMoodType.positive.color.opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: CGFloat(positiveCount) / CGFloat(totalCount) * 280)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: positiveCount)
                
                // Difficult segment  
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [
                                SimplifiedMoodType.difficult.color,
                                SimplifiedMoodType.difficult.color.opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: CGFloat(difficultCount) / CGFloat(totalCount) * 280)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: difficultCount)
            } else {
                // Empty state
                RoundedRectangle(cornerRadius: 6)
                    .fill(DesignSystem.Colors.secondary.opacity(0.3))
                    .frame(width: 280)
            }
        }
        .frame(height: 12)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(DesignSystem.Colors.secondary.opacity(0.1))
        )
    }
    
    // MARK: - Modern Mood Distribution Bar
    private var modernMoodDistributionBar: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            // Percentage labels
            HStack(spacing: 0) {
                ForEach(MoodType.allCases, id: \.self) { moodType in
                    let percentage = getMoodPercentage(for: moodType)
                    if percentage > 0 {
                        Text("\(percentage)%")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(DesignSystem.moodColor(for: moodType))
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            
            // Visual bar
            GeometryReader { geometry in
                HStack(spacing: 1) {
                    ForEach(MoodType.allCases, id: \.self) { moodType in
                        let percentage = getMoodPercentage(for: moodType)
                        if percentage > 0 {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            DesignSystem.moodColor(for: moodType),
                                            DesignSystem.moodColor(for: moodType).opacity(0.8)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: max(4, geometry.size.width * CGFloat(percentage) / 100))
                                .animation(.easeInOut(duration: 0.6), value: percentage)
                        }
                    }
                    
                    Spacer()
                }
            }
            .frame(height: 12)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(DesignSystem.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(DesignSystem.Colors.separator.opacity(0.2), lineWidth: 0.5)
                    )
            )
            
            // Legend with all 6 moods
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(MoodType.allCases, id: \.self) { moodType in
                    modernLegendItem(for: moodType)
                }
            }
        }
    }
    
    // MARK: - Modern Legend Item
    private func modernLegendItem(for moodType: MoodType) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(DesignSystem.moodColor(for: moodType))
                .frame(width: 8, height: 8)
            
            Text(moodType.displayName)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(DesignSystem.Colors.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Summary Card
    private func summaryCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(DesignSystem.Colors.primary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DesignSystem.Colors.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignSystem.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DesignSystem.Colors.secondary.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Year Insights
    private var yearInsights: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Year Insights")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.primary)
            
            LazyVStack(spacing: 8) {
                ForEach(getYearInsights(), id: \.id) { insight in
                    HStack(spacing: 12) {
                        Image(systemName: insight.icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(insight.color)
                            .frame(width: 24)
                        
                        Text(insight.message)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(DesignSystem.Colors.secondary)
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var yearEntries: [MoodEntryData] {
        let calendar = Calendar.current
        return entries.filter { entry in
            calendar.component(.year, from: entry.date) == selectedYear
        }
    }
    
    private var bestMonth: String {
        let calendar = Calendar.current
        var monthMoods: [Int: [Double]] = [:]
        
        for entry in yearEntries {
            let month = calendar.component(.month, from: entry.date)
            let moodValue = moodToValue(entry.mood)
            monthMoods[month, default: []].append(moodValue)
        }
        
        let bestMonthNum = monthMoods.max { first, second in
            let firstAvg = first.value.isEmpty ? 0 : first.value.reduce(0, +) / Double(first.value.count)
            let secondAvg = second.value.isEmpty ? 0 : second.value.reduce(0, +) / Double(second.value.count)
            return firstAvg < secondAvg
        }?.key ?? 1
        
        return monthName(bestMonthNum)
    }
    
    private var longestStreak: Int {
        guard !yearEntries.isEmpty else { return 0 }
        
        let sortedEntries = yearEntries.sorted { $0.date < $1.date }
        var currentStreak = 1
        var maxStreak = 1
        
        for i in 1..<sortedEntries.count {
            let daysDifference = Calendar.current.dateComponents([.day], from: sortedEntries[i-1].date, to: sortedEntries[i].date).day ?? 0
            
            if daysDifference == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return maxStreak
    }
    
    private var averageYearMood: Double {
        guard !yearEntries.isEmpty else { return 0 }
        let moodValues = yearEntries.map { moodToValue($0.mood) }
        return moodValues.reduce(0, +) / Double(moodValues.count)
    }
    
    // MARK: - Helper Functions
    
    private func showDetailedView() {
        HapticFeedback.light.trigger()
        showingDetailedCalendar = true
    }
    
    private func getDayColor(day: Int, month: Int) -> Color {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: selectedYear, month: month, day: day)
        
        // Check if this is a valid date for the month
        guard let date = calendar.date(from: dateComponents),
              calendar.component(.month, from: date) == month,
              date <= Date() else {
            return DesignSystem.Colors.secondary.opacity(0.15)
        }
        
        // Filter entries for this specific day
        let entriesForDay = yearEntries.filter { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
        
        // Return appropriate color based on entry data
        if entriesForDay.isEmpty {
            return DesignSystem.Colors.secondary.opacity(0.25)
        }
        
        // Calculate mood value for this day
        let moodValues = entriesForDay.map { moodToValue($0.mood) }
        let averageMood = moodValues.reduce(0, +) / Double(moodValues.count)
        
        return moodColor(for: averageMood)
    }
    
    private func getMonthlyMoodColor(month: Int) -> Color {
        let calendar = Calendar.current
        let monthEntries = yearEntries.filter { entry in
            calendar.component(.month, from: entry.date) == month &&
            calendar.component(.year, from: entry.date) == selectedYear
        }
        
        if monthEntries.isEmpty {
            return DesignSystem.Colors.secondary.opacity(0.25)
        }
        
        let moodValues = monthEntries.map { moodToValue($0.mood) }
        let averageMood = moodValues.reduce(0, +) / Double(moodValues.count)
        
        return moodColor(for: averageMood)
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(label)
                .foregroundColor(DesignSystem.Colors.secondary)
        }
    }
    
    private func moodColor(for value: Double) -> Color {
        switch value {
        case 5.5...6.0:
            return DesignSystem.moodColor(for: .amazing)        // Amazing
        case 4.5..<5.5:
            return DesignSystem.moodColor(for: .good)           // Good
        case 3.5..<4.5:
            return DesignSystem.moodColor(for: .okay)           // Okay
        case 2.5..<3.5:
            return DesignSystem.moodColor(for: .challenging)    // Challenging
        case 1.5..<2.5:
            return DesignSystem.moodColor(for: .tough)          // Tough
        case 1.0..<1.5:
            return DesignSystem.moodColor(for: .overwhelming)   // Overwhelming
        default:
            return DesignSystem.Colors.secondary.opacity(0.3)  // No data
        }
    }
    
    private func moodToValue(_ mood: MoodType) -> Double {
        return mood.numericValue
    }
    
    private func moodColorForAverage(_ value: Double) -> Color {
        switch value {
        case 5.5...6.0: return DesignSystem.moodColor(for: .amazing)
        case 4.5..<5.5: return DesignSystem.moodColor(for: .good) 
        case 3.5..<4.5: return DesignSystem.moodColor(for: .okay)
        case 2.5..<3.5: return DesignSystem.moodColor(for: .challenging)
        case 1.5..<2.5: return DesignSystem.moodColor(for: .tough)
        case 1.0..<1.5: return DesignSystem.moodColor(for: .overwhelming)
        default: return DesignSystem.Colors.secondary
        }
    }
    
    private func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        let date = Calendar.current.date(from: DateComponents(month: month)) ?? Date()
        return formatter.string(from: date)
    }
    
    private func monthAbbreviation(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        let date = Calendar.current.date(from: DateComponents(month: month)) ?? Date()
        return String(formatter.string(from: date).prefix(3))
    }
    
    private func getYearInsights() -> [YearInsight] {
        var insights: [YearInsight] = []
        
        // Most active month
        let calendar = Calendar.current
        var monthCounts: [Int: Int] = [:]
        for entry in yearEntries {
            let month = calendar.component(.month, from: entry.date)
            monthCounts[month, default: 0] += 1
        }
        
        if let mostActiveMonth = monthCounts.max(by: { $0.value < $1.value }) {
            insights.append(YearInsight(
                id: "active_month",
                icon: "calendar.badge.plus",
                color: DesignSystem.Colors.accent,
                message: "You were most active in \(monthName(mostActiveMonth.key)) with \(String(mostActiveMonth.value)) entries"
            ))
        }
        
        // Mood trend
        if averageYearMood >= 3.5 {
            insights.append(YearInsight(
                id: "positive_year",
                icon: "heart.fill",
                color: DesignSystem.weatherIconColor(isGood: true),
                message: "This was a positive year with an average mood of \(String(format: "%.1f", averageYearMood))"
            ))
        }
        
        // Consistency
        if yearEntries.count >= 100 {
            insights.append(YearInsight(
                id: "consistent",
                icon: "star.fill",
                color: DesignSystem.Colors.accent,
                message: "Great consistency! You tracked your mood \(String(yearEntries.count)) times this year"
            ))
        }
        
        return insights
    }
    
    private func getMoodCount(for moodType: MoodType) -> Int {
        return yearEntries.filter { $0.mood == moodType }.count
    }
    
    private func getMoodPercentage(for moodType: MoodType) -> Int {
        guard !yearEntries.isEmpty else { return 0 }
        let count = getMoodCount(for: moodType)
        return Int(Double(count) / Double(yearEntries.count) * 100)
    }
}

// MARK: - Supporting Models

struct YearInsight: Identifiable {
    let id: String
    let icon: String
    let color: Color
    let message: String
}

#Preview {
    NavigationView {
        YearInReviewView(entries: [
            MoodEntryData(
                date: Date(),
                mood: .good,
                categories: [
                    CategorySelection(categoryName: "Emotions", selectedOptions: ["happy"])
                ]
            )
        ])
    }
} 