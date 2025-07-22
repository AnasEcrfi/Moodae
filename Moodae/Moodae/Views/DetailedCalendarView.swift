//
//  DetailedCalendarView.swift
//  Moodae
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

struct DetailedCalendarView: View {
    let entries: [MoodEntryData]
    let year: Int
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Month selector
                    monthSelector
                    
                    // Calendar grid for selected month
                    monthCalendarView
                    
                    // Month statistics
                    monthStatsView
                    
                    // Entries list for selected month
                    monthEntriesView
                }
                .padding(DesignSystem.Spacing.lg)
            }
            .navigationTitle("\(String(year)) Calendar")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.accent)
                }
            }
        }
    }
    
    // MARK: - Month Selector
    private var monthSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(1...12, id: \.self) { month in
                    Button(action: {
                        HapticFeedback.light.trigger()
                        selectedMonth = month
                    }) {
                        VStack(spacing: 4) {
                            Text(monthName(month))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(selectedMonth == month ? .white : DesignSystem.Colors.secondary)
                            
                            Text(String(entriesCount(for: month)))
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(selectedMonth == month ? .white.opacity(0.8) : DesignSystem.Colors.secondary.opacity(0.7))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedMonth == month ? DesignSystem.Colors.accent : DesignSystem.Colors.surface)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    // MARK: - Month Calendar View
    private var monthCalendarView: some View {
        CleanCard(cardSize: DesignSystem.CardSizing.comfortable) {
            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("\(monthName(selectedMonth)) \(String(year))")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Spacer()
                    
                    Text("\(String(entriesCount(for: selectedMonth))) entries")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.secondary)
                }
                
                // Days of week header
                HStack {
                    ForEach(["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // Calendar grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(calendarDays(for: selectedMonth), id: \.self) { day in
                        dayCell(day: day)
                    }
                }
            }
        }
    }
    
    // MARK: - Day Cell
    private func dayCell(day: Int) -> some View {
        let dayColor = getDayColor(day: day, month: selectedMonth)
        let hasEntries = !entriesForDay(day: day, month: selectedMonth).isEmpty
        
        return ZStack {
            Circle()
                .fill(dayColor)
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(DesignSystem.Colors.secondary.opacity(0.2), lineWidth: 0.5)
                )
            
            Text(day > 0 ? String(day) : "")
                .font(.system(size: 13, weight: hasEntries ? .semibold : .regular))
                .foregroundColor(hasEntries ? (dayColor == DesignSystem.weatherIconColor(isGood: true) || dayColor == DesignSystem.Colors.accent ? .white : DesignSystem.Colors.primary) : DesignSystem.Colors.secondary)
        }
    }
    
    // MARK: - Month Stats
    private var monthStatsView: some View {
        let monthEntries = entriesForMonth(selectedMonth)
        
        guard !monthEntries.isEmpty else { return AnyView(EmptyView()) }
        
        return AnyView(
            CleanCard(cardSize: DesignSystem.CardSizing.comfortable) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Month Statistics")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    HStack(spacing: 20) {
                        statItem(title: "Good Days", value: String(goodDaysCount(in: monthEntries)), color: DesignSystem.weatherIconColor(isGood: true))
                        statItem(title: "Total Days", value: String(monthEntries.count), color: DesignSystem.Colors.accent)
                        statItem(title: "Avg Mood", value: String(format: "%.1f", averageMood(in: monthEntries)), color: DesignSystem.Colors.secondary)
                    }
                }
            }
        )
    }
    
    // MARK: - Month Entries
    private var monthEntriesView: some View {
        let monthEntries = entriesForMonth(selectedMonth).sorted { $0.date > $1.date }
        
        guard !monthEntries.isEmpty else { return AnyView(EmptyView()) }
        
        return AnyView(
            CleanCard(cardSize: DesignSystem.CardSizing.comfortable) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent Entries")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(Array(monthEntries.prefix(5)), id: \.id) { entry in
                            entryRow(entry: entry)
                        }
                        
                        if monthEntries.count > 5 {
                            Text("And \(String(monthEntries.count - 5)) more entries...")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(DesignSystem.Colors.secondary)
                                .padding(.top, 8)
                        }
                    }
                }
            }
        )
    }
    
    // MARK: - Entry Row
    private func entryRow(entry: MoodEntryData) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(DesignSystem.moodColor(for: entry.mood))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.date, style: .date)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.primary)
                
                if !entry.categories.isEmpty {
                    Text(entry.categories.flatMap(\.selectedOptions).prefix(3).joined(separator: ", "))
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(DesignSystem.Colors.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text(entry.mood.displayName)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(DesignSystem.Colors.secondary)
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Stat Item
    private func statItem(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(DesignSystem.Colors.secondary)
        }
    }
    
    // MARK: - Helper Functions
    
    private func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let date = Calendar.current.date(from: DateComponents(month: month)) ?? Date()
        return formatter.string(from: date)
    }
    
    private func entriesCount(for month: Int) -> Int {
        return entriesForMonth(month).count
    }
    
    private func entriesForMonth(_ month: Int) -> [MoodEntryData] {
        let calendar = Calendar.current
        return entries.filter { entry in
            calendar.component(.month, from: entry.date) == month &&
            calendar.component(.year, from: entry.date) == year
        }
    }
    
    private func entriesForDay(day: Int, month: Int) -> [MoodEntryData] {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: year, month: month, day: day)
        
        guard let date = calendar.date(from: dateComponents) else { return [] }
        
        return entries.filter { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }
    
    private func getDayColor(day: Int, month: Int) -> Color {
        let dayEntries = entriesForDay(day: day, month: month)
        
        if dayEntries.isEmpty {
            return DesignSystem.Colors.secondary.opacity(0.3)
        }
        
        let moodValues = dayEntries.map { $0.mood == .good ? 4.0 : 2.0 }
        let averageMood = moodValues.reduce(0, +) / Double(moodValues.count)
        
        return moodColor(for: averageMood)
    }
    
    private func moodColor(for value: Double) -> Color {
        switch value {
        case 4.0...5.0:
            return DesignSystem.weatherIconColor(isGood: true)
        case 3.0..<4.0:
            return DesignSystem.Colors.accent
        case 2.5..<3.0:
            return DesignSystem.Colors.secondary.opacity(0.7)
        case 2.0..<2.5:
            return DesignSystem.weatherIconColor(isGood: false)
        default:
            return DesignSystem.Colors.secondary.opacity(0.3)
        }
    }
    
    private func calendarDays(for month: Int) -> [Int] {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: year, month: month, day: 1)
        
        guard let firstDayOfMonth = calendar.date(from: dateComponents) else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)?.count ?? 30
        
        var days: [Int] = []
        
        // Add empty cells for days before month starts
        for _ in 0..<firstWeekday {
            days.append(0)
        }
        
        // Add days of the month
        for day in 1...daysInMonth {
            days.append(day)
        }
        
        return days
    }
    
    private func goodDaysCount(in entries: [MoodEntryData]) -> Int {
        return entries.filter { $0.mood == .good }.count
    }
    
    private func averageMood(in entries: [MoodEntryData]) -> Double {
        guard !entries.isEmpty else { return 0 }
        let moodValues = entries.map { $0.mood == .good ? 4.0 : 2.0 }
        return moodValues.reduce(0, +) / Double(moodValues.count)
    }
}

#Preview {
    DetailedCalendarView(entries: [
        MoodEntryData(
            date: Date(),
            mood: .good,
            categories: [
                CategorySelection(categoryName: "Emotions", selectedOptions: ["happy"])
            ]
        )
    ], year: 2025)
} 