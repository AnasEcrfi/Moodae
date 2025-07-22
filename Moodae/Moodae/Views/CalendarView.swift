//
//  CalendarView.swift
//  Mooday
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: MoodViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var weekStartManager: WeekStartManager
    @State private var selectedDate = Date()
    @State private var showingDayDetail = false
    @State private var showingRetroEntry = false
    
    private var calendar: Calendar {
        weekStartManager.calendar
    }
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
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
                        
                        // Calendar Grid
                        calendarSection
                        
                        // Legend
                        legendSection
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.top, DesignSystem.Spacing.lg)
                }
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingDayDetail) {
            DayDetailView(
                viewModel: viewModel,
                selectedDate: selectedDate
            )
        }
        .sheet(isPresented: $showingRetroEntry) {
            RetroactiveMoodEntryView(
                viewModel: viewModel,
                date: selectedDate,
                isPresented: $showingRetroEntry
            )
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Month Navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(DesignSystem.Colors.secondary)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(CleanButtonStyle())
                
                Spacer()
                
                Text(dateFormatter.string(from: selectedDate))
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(DesignSystem.Colors.secondary)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(CleanButtonStyle())
            }
            .subtleAppearance(delay: 0.1)
            
            // Today Button
            if !calendar.isDate(selectedDate, equalTo: Date(), toGranularity: .month) {
                Button(action: goToToday) {
                    Text("Today")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.accent)
                }
                .buttonStyle(PlainButtonStyle())
                .subtleAppearance(delay: 0.2)
            }
        }
    }
    
    // MARK: - Calendar Section
    private var calendarSection: some View {
        CleanCard(cardSize: DesignSystem.CardSizing.comfortable) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Weekday Headers
                weekdayHeaders
                
                // Calendar Grid
                calendarGrid
            }
        }
        .subtleAppearance(delay: 0.3)
    }
    
    // MARK: - Weekday Headers
    private var weekdayHeaders: some View {
        HStack {
            ForEach(weekdaySymbols, id: \.self) { weekday in
                Text(weekday)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: - Calendar Grid
    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: DesignSystem.Spacing.xs) {
            ForEach(daysInMonth, id: \.self) { date in
                if let date = date {
                    CalendarDayView(
                        date: date,
                        moodEntry: viewModel.getMoodEntry(for: date),
                        isToday: calendar.isDateInToday(date),
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        viewModel: viewModel
                    )
                    .onTapGesture {
                        handleDayTap(date)
                    }
                } else {
                    Color.clear
                        .frame(height: 40)
                }
            }
        }
    }
    
    // MARK: - Legend Section
    private var legendSection: some View {
        CleanCard(cardSize: DesignSystem.CardSizing.comfortable) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text("Legend")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.primary)
                
                VStack(spacing: DesignSystem.Spacing.sm) {
                    legendItem(
                        color: DesignSystem.weatherIconColor(for: .good),
                        title: "Good Day",
                        description: "Positive mood entry"
                    )
                    
                    legendItem(
                        color: DesignSystem.moodColor(for: .challenging),
                        title: "Difficult Day",
                        description: "Challenging mood entry"
                    )
                    
                    legendItem(
                        color: DesignSystem.Colors.secondary,
                        title: "No Entry",
                        description: "No mood recorded"
                    )
                }
            }
        }
        .subtleAppearance(delay: 0.4)
    }
    
    private func legendItem(color: Color, title: String, description: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text(description)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondary)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Computed Properties
    private var weekdaySymbols: [String] {
        weekStartManager.weekdaySymbols
    }
    
    private var daysInMonth: [Date?] {
        guard let _ = calendar.dateInterval(of: .month, for: selectedDate),
              let firstDayOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 0
        
        var days: [Date?] = []
        
        // Add empty cells for days before the first day of the month
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add all days of the month
        for day in 1...numberOfDaysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    // MARK: - Actions
    private func previousMonth() {
        HapticFeedback.light.trigger()
        withAnimation(.moodayEase) {
            selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
        }
    }
    
    private func nextMonth() {
        HapticFeedback.light.trigger()
        withAnimation(.moodayEase) {
            selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
        }
    }
    
    private func goToToday() {
        HapticFeedback.light.trigger()
        withAnimation(.moodayEase) {
            selectedDate = Date()
        }
    }
    
    private func handleDayTap(_ date: Date) {
        HapticFeedback.light.trigger()
        selectedDate = date
        
        if viewModel.getMoodEntry(for: date) != nil {
            // Show existing entry
            showingDayDetail = true
        } else {
            // Allow retroactive entry for past dates, immediate entry for today
            if calendar.isDateInToday(date) {
                // Navigate to mood input for today
                // TODO: Implement navigation to mood input
            } else if date < Date() {
                // Show retroactive entry for past dates
                showingRetroEntry = true
            }
        }
    }
}

// MARK: - Calendar Day View
struct CalendarDayView: View {
    let date: Date
    let moodEntry: MoodEntryData?
    let isToday: Bool
    let isSelected: Bool
    @ObservedObject var viewModel: MoodViewModel
    @Environment(\.colorScheme) var colorScheme
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            // Day Number
            Text(dayNumber)
                .font(.system(size: 14, weight: isToday ? .medium : .regular))
                .foregroundColor(textColor)
            
            // Mood Indicator
            Circle()
                .fill(moodIndicatorColor)
                .frame(width: 8, height: 8)
                .opacity(moodEntry != nil ? 1.0 : 0.3)
        }
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .stroke(borderColor, lineWidth: isSelected ? 1 : 0)
                )
        )
        .scaleEffect(isToday ? 1.05 : 1.0)
        .animation(.moodayEase, value: isToday)
        .animation(.moodayEase, value: isSelected)
    }
    
    // MARK: - Computed Properties
    private var backgroundColor: Color {
        if isSelected {
            return DesignSystem.Colors.accent.opacity(0.1)
        }
        if isToday {
            return DesignSystem.Colors.accent.opacity(0.05)
        }
        return Color.clear
    }
    
    private var borderColor: Color {
        isSelected ? DesignSystem.Colors.accent : Color.clear
    }
    
    private var textColor: Color {
        if isToday {
            return DesignSystem.Colors.accent
        }
        return DesignSystem.Colors.primary
    }
    
    private var moodIndicatorColor: Color {
        guard let entry = moodEntry else {
            return DesignSystem.Colors.secondary
        }
        
        return DesignSystem.moodColor(for: entry.mood)
    }
}

// MARK: - Legacy Components (Cleaned Up)
struct CalendarDayView_Legacy: View {
    let date: Date
    let moodEntry: MoodEntryData?
    let isToday: Bool
    @ObservedObject var viewModel: MoodViewModel
    @Environment(\.colorScheme) var colorScheme
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(backgroundColor)
                .conditionalShadow(hasShadow: isToday, colorScheme: colorScheme)
            
            // Content
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text(dayNumber)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(textColor)
                
                // Dynamic mood indicator
                Circle()
                    .fill(dynamicMoodColor)
                    .frame(width: 8, height: 8)
            }
        }
        .frame(height: 48)
        .scaleEffect(isToday ? 1.05 : 1.0)
        .animation(.moodayEase, value: isToday)
    }
    
    private var backgroundColor: Color {
        if isToday {
            return colorScheme == .dark ? Color(.systemGray5) : DesignSystem.Colors.cardBackground
        }
        return colorScheme == .dark ? Color(.systemGray6) : Color(UIColor.secondarySystemGroupedBackground)
    }
    
    private var textColor: Color {
        isToday ? DesignSystem.Colors.primary : DesignSystem.Colors.secondary
    }
    
    private var dynamicMoodColor: Color {
        guard let entry = moodEntry else {
            return DesignSystem.Colors.secondary.opacity(0.3)
        }
        
        return DesignSystem.moodColor(for: entry.mood)
    }
}

#Preview {
    CalendarView(viewModel: MoodViewModel())
} 