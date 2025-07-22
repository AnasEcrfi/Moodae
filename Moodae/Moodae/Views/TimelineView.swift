//
//  TimelineView.swift
//  Mooday
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

struct TimelineView: View {
    @ObservedObject var viewModel: MoodViewModel
    @EnvironmentObject var weekStartManager: WeekStartManager
    @State private var selectedFilter: FilterOption = .all
    @State private var showingInsights = false
    @State private var selectedEntry: MoodEntryData?
    @State private var showingEditEntry = false
    @State private var currentMonth = Date()
    @State private var selectedCalendarDate: Date?
    @State private var showingYearPicker = false
    @State private var dragOffset: CGFloat = 0
    @State private var isAnimatingMonth = false
    @State private var showingNewEntrySheet = false
    @State private var newEntryDate: Date?
    
    private enum FilterOption: String, CaseIterable {
        case all = "All"
        case positive = "Good Days"
        case difficult = "Difficult Days"
        case today = "Today"
        case thisWeek = "This Week"
        
        var icon: String {
            switch self {
            case .all: return "list.bullet"
            case .positive: return "sun.max"
            case .difficult: return "cloud.rain"
            case .today: return "calendar"
            case .thisWeek: return "calendar.badge.clock"
            }
        }
        
        var color: Color {
            switch self {
            case .all: return DesignSystem.Colors.accent
            case .positive: return DesignSystem.Colors.accent // Konsistente CI-Farbe für positive
            case .difficult: return DesignSystem.Colors.secondary
            case .today: return DesignSystem.Colors.info
            case .thisWeek: return DesignSystem.Colors.secondary
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.surface
                    .ignoresSafeArea()
                
                if filteredEntries.isEmpty {
                    modernEmptyStateView
                } else {
                    mainContentView
                }
            }
            .navigationTitle("Timeline")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingInsights) {
                InsightsView(viewModel: viewModel)
            }
            .sheet(item: $selectedEntry) { entry in
                NavigationView {
                    ModernEntryDetailView(
                        entry: entry,
                        viewModel: viewModel
                    )
                }
            }
            .sheet(isPresented: $showingEditEntry) {
                if let entry = selectedEntry {
                    EditEntryView(
                        entry: entry,
                        viewModel: viewModel,
                        isPresented: $showingEditEntry
                    )
                }
            }
            .sheet(isPresented: $showingYearPicker) {
                yearPickerSheet
            }
            .sheet(isPresented: $showingNewEntrySheet) {
                newEntrySheet
            }
        }
    }
    
    // MARK: - Modern Empty State
    private var modernEmptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.accent.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(DesignSystem.Colors.accent)
            }
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("Start Your Journey")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text("Begin tracking your daily moods\nto see patterns and insights emerge")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.xl)
        .subtleAppearance(delay: 0.3)
    }
    
    // MARK: - Main Content
    private var mainContentView: some View {
        VStack(spacing: 0) {
            // Fixed top section
            VStack(spacing: 0) {
                modernFilterBar
                minimalistCalendar
            }
            
            // Scrollable content area with optimized sizing
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0, pinnedViews: []) {
                    // Content based on selection with stable transition
                    Group {
                        if let selectedDate = selectedCalendarDate {
                            selectedDayView(selectedDate)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                                    removal: .opacity.combined(with: .move(edge: .leading))
                                ))
                        } else {
                            VStack(spacing: 0) {
                                // Modern timeline with divider
                                Divider()
                                    .background(DesignSystem.Colors.separator.opacity(0.3))
                                    .padding(.horizontal, DesignSystem.Spacing.lg)
                                
                                modernTimelineContent
                        
                        // Bottom spacing to prevent tab bar overlap
                        Spacer(minLength: 12)
                            }
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .leading)),
                                removal: .opacity.combined(with: .move(edge: .trailing))
                            ))
                        }
                    }
                    .id(selectedCalendarDate?.timeIntervalSince1970 ?? -1)
                }
            }
            .clipped()
        }
        .animation(.easeInOut(duration: 0.25), value: selectedCalendarDate)
    }
    
    // MARK: - Modern Filter Bar
    private var modernFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(FilterOption.allCases, id: \.self) { filter in
                    filterButton(for: filter)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
        }
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.surface)
    }
    
    private func filterButton(for filter: FilterOption) -> some View {
        Button(action: {
            HapticFeedback.light.trigger()
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedFilter = filter
            }
        }) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: filter.icon)
                    .font(.system(size: 12, weight: .medium))
                
                Text(filter.rawValue)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(selectedFilter == filter ? .white : filter.color)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(selectedFilter == filter ? filter.color : filter.color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(filter.color.opacity(0.3), lineWidth: selectedFilter == filter ? 0 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(selectedFilter == filter ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedFilter)
    }
    
    // MARK: - Minimalist Calendar
    private var minimalistCalendar: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Month header with navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.accent)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(DesignSystem.Colors.accent.opacity(0.1))
                        )
                }
                .disabled(isAnimatingMonth)
                
                Spacer()
                
                Button(action: { showingYearPicker = true }) {
                    Text(monthYearFormatter.string(from: currentMonth))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.primary)
                }
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.accent)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(DesignSystem.Colors.accent.opacity(0.1))
                        )
                }
                .disabled(isAnimatingMonth)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            
            // Calendar grid
            calendarGrid
                .padding(.horizontal, DesignSystem.Spacing.lg)
        }
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(DesignSystem.Colors.cardBackground)
                .shadow(
                    color: DesignSystem.Colors.secondary.opacity(0.1),
                    radius: 4,
                    x: 0,
                    y: 2
                )
        )
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
    
    // MARK: - Calendar Grid
    private var calendarGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
        
        return LazyVGrid(columns: columns, spacing: 8) {
            // Weekday headers with unique IDs
            ForEach(Array(weekdayHeaders.enumerated()), id: \.offset) { index, weekday in
                Text(weekday)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .frame(height: 20)
            }
            
            // Calendar days with unique IDs
            ForEach(Array(calendarDays.enumerated()), id: \.offset) { index, date in
                if let date = date {
                    ModernTimelineCalendarDayView(
                        date: date,
                        currentMonth: currentMonth,
                        selectedDate: selectedCalendarDate,
                        moodEntries: viewModel.moodEntries,
                        onTap: { tappedDate in
                            handleDayTap(tappedDate)
                        }
                    )
                } else {
                    // Empty cell for padding with unique ID
                    Color.clear
                        .frame(height: 32)
                }
            }
        }
    }
    
    // MARK: - Modern Timeline Content
    private var modernTimelineContent: some View {
        LazyVStack(spacing: DesignSystem.Spacing.lg) {
            ForEach(filteredEntries, id: \.id) { entry in
                ModernTimelineEntryCard(
                    entry: entry,
                    viewModel: viewModel,
                    onTap: {
                        selectedEntry = entry
                        HapticFeedback.light.trigger()
                    },
                    onEdit: {
                        selectedEntry = entry
                        showingEditEntry = true
                        HapticFeedback.light.trigger()
                    }
                )
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.lg)
    }
    
    // MARK: - Helper Functions
    private func selectedDayView(_ date: Date) -> some View {
        SelectedDayContentView(
            date: date,
            moodEntries: viewModel.moodEntries,
            onDismiss: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    selectedCalendarDate = nil
                }
            },
            onSelectEntry: { entry in
                selectedEntry = entry
                HapticFeedback.light.trigger()
            },
            onEditEntry: { entry in
                selectedEntry = entry
                showingEditEntry = true
                HapticFeedback.light.trigger()
            },
            onShowNewEntry: { entryDate in
                newEntryDate = entryDate
                showingNewEntrySheet = true
                HapticFeedback.medium.trigger()
            }
        )
    }
    
    private func previousMonth() {
        guard !isAnimatingMonth else { return }
        
        withAnimation(.easeInOut(duration: 0.25)) {
            isAnimatingMonth = true
            currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isAnimatingMonth = false
        }
    }
    
    private func nextMonth() {
        guard !isAnimatingMonth else { return }
        
        withAnimation(.easeInOut(duration: 0.25)) {
            isAnimatingMonth = true
            currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isAnimatingMonth = false
        }
    }
    
    private func handleDayTap(_ date: Date) {
        HapticFeedback.medium.trigger()
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedCalendarDate = selectedCalendarDate == date ? nil : date
        }
    }
    
    // MARK: - Computed Properties
    private var filteredEntries: [MoodEntryData] {
        let entries = viewModel.moodEntries
        
        // Apply filter option (no calendar date filtering here)
        switch selectedFilter {
        case .all:
            return entries.sorted { $0.date > $1.date }
        case .positive:
            return entries.filter { $0.mood.mainCategory == .positive }.sorted { $0.date > $1.date }
        case .difficult:
            return entries.filter { $0.mood.mainCategory == .difficult }.sorted { $0.date > $1.date }
        case .today:
            return entries.filter { Calendar.current.isDateInToday($0.date) }.sorted { $0.date > $1.date }
        case .thisWeek:
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            return entries.filter { $0.date >= weekAgo }.sorted { $0.date > $1.date }
        }
    }
    
    // MARK: - Calendar Helpers
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    private var weekdayHeaders: [String] {
        weekStartManager.veryShortWeekdaySymbols
    }
    
    private var calendarDays: [Date?] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let range = calendar.range(of: .day, in: .month, for: currentMonth) ?? 1..<32
        
        // Get the weekday of the first day of the month
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        
        // Calculate days needed at start based on week start preference
        let daysFromPreviousMonth = (firstWeekday - weekStartManager.selectedWeekStart.calendarWeekday + 7) % 7
        
        var days: [Date?] = []
        
        // Add empty cells for previous month
        for _ in 0..<daysFromPreviousMonth {
            days.append(nil)
        }
        
        // Add days of current month
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    // MARK: - Sheet Views
    private var yearPickerSheet: some View {
        NavigationView {
            VStack {
                Picker("Year", selection: $currentMonth) {
                    ForEach(2020...2030, id: \.self) { year in
                        Text(String(year))
                            .tag(Calendar.current.date(from: DateComponents(year: year, month: Calendar.current.component(.month, from: currentMonth))) ?? currentMonth)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                
                Spacer()
            }
            .navigationTitle("Select Year")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingYearPicker = false
                    }
                }
            }
        }
    }
    
    private var newEntrySheet: some View {
        if let entryDate = newEntryDate {
            EnhancedMoodInputView(
                viewModel: viewModel,
                moodType: .good, // Default mood type
                selectedDate: entryDate,
                isPresented: $showingNewEntrySheet,
                onComplete: {
                    showingNewEntrySheet = false
                    newEntryDate = nil
                }
            )
        } else {
            EnhancedMoodInputView(
                viewModel: viewModel,
                moodType: .good, // Default mood type
                isPresented: $showingNewEntrySheet,
                onComplete: {
                    showingNewEntrySheet = false
                    newEntryDate = nil
                }
            )
        }
    }
}

// MARK: - Modern Timeline Entry Card
struct ModernTimelineEntryCard: View {
    let entry: MoodEntryData
    @ObservedObject var viewModel: MoodViewModel
    let onTap: () -> Void
    let onEdit: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: onTap) {
            cardContent
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            contextMenuContent
        }
    }
    
    private var cardContent: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            // Modern Mood Icon with background
            ZStack {
                Circle()
                    .fill(DesignSystem.moodColor(for: entry.mood).opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: entry.mood.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(DesignSystem.moodColor(for: entry.mood))
            }
            
            // Content
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack {
                    Text(formattedDate)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Spacer()
                    
                    Text(formattedTime)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(DesignSystem.Colors.secondary)
                }
                
                Text(entry.mood.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignSystem.moodColor(for: entry.mood))
                
                if let text = entry.textEntry, !text.isEmpty {
                    Text(text)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(DesignSystem.Colors.secondary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
                
                // Modern Tags
                if !entry.categories.isEmpty {
                    categoriesView
                }
            }
            
            // Action indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DesignSystem.Colors.tertiary)
        }
        .padding(DesignSystem.Spacing.lg)
        .background(cardBackground)
    }
    
    private var categoriesView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(entry.categories.prefix(3).indices, id: \.self) { index in
                    let category = entry.categories[index]
                    Text(category.selectedOptions.first ?? category.categoryName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.accent)
                        .padding(.horizontal, DesignSystem.Spacing.xs)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(DesignSystem.Colors.accent.opacity(0.1))
                        )
                }
                
                if entry.categories.count > 3 {
                    Text("+\(entry.categories.count - 3)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.secondary)
                        .padding(.horizontal, DesignSystem.Spacing.xs)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(DesignSystem.Colors.secondary.opacity(0.1))
                        )
                }
            }
        }
        .padding(.top, DesignSystem.Spacing.xs)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(DesignSystem.Colors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(DesignSystem.Colors.separator.opacity(0.3), lineWidth: 0.5)
            )
            .shadow(
                color: DesignSystem.Colors.secondary.opacity(0.08),
                radius: 8,
                x: 0,
                y: 2
            )
    }
    
    private var contextMenuContent: some View {
        Group {
            Button {
                onEdit()
            } label: {
                Label("Edit Entry", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                // Implement delete action if needed
            } label: {
                Label("Delete Entry", systemImage: "trash")
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        
        if Calendar.current.isDateInToday(entry.date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(entry.date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: entry.date)
        }
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: entry.date)
    }
}

// MARK: - Modern Calendar Day View
struct ModernTimelineCalendarDayView: View {
    let date: Date
    let currentMonth: Date
    let selectedDate: Date?
    let moodEntries: [MoodEntryData]
    let onTap: (Date) -> Void
    
    @State private var tapScale: CGFloat = 1.0
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var isCurrentMonth: Bool {
        Calendar.current.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private var isSelected: Bool {
        guard let selectedDate = selectedDate else { return false }
        return Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
    
    private var dayEntries: [MoodEntryData] {
        moodEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    private var moodIndicatorColor: Color {
        guard !dayEntries.isEmpty else { return Color.clear }
        
        if dayEntries.count == 1 {
            return DesignSystem.moodColor(for: dayEntries.first!.mood)
        }
        
        // For multiple entries, show dominant mood or mixed color
        let positiveCount = dayEntries.filter { $0.mood.mainCategory == .positive }.count
        let difficultCount = dayEntries.filter { $0.mood.mainCategory == .difficult }.count
        
        if positiveCount > difficultCount {
            return DesignSystem.weatherIconColor(isGood: true)
        } else if difficultCount > positiveCount {
            return DesignSystem.weatherIconColor(isGood: false)
        } else {
            return DesignSystem.Colors.accent // Mixed/balanced
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return DesignSystem.Colors.accent.opacity(0.1)
        } else if isToday {
            return DesignSystem.Colors.accent.opacity(0.05)
        } else {
            return Color.clear
        }
    }
    
    private var textColor: Color {
        if isSelected {
            return DesignSystem.Colors.accent
        } else if isToday {
            return DesignSystem.Colors.accent
        } else {
            return DesignSystem.Colors.primary
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return DesignSystem.Colors.accent
        } else {
            return Color.clear
        }
    }
    
    private var indicatorSize: CGFloat {
        return dayEntries.count > 1 ? 8 : 6
    }
    
    var body: some View {
        Button(action: { onTap(date) }) {
            VStack(spacing: 3) {
                Text(dayNumber)
                    .font(.system(size: 14, weight: isToday ? .semibold : .regular))
                    .foregroundColor(textColor)
                
                // Modern mood indicator
                ZStack {
                    Circle()
                        .fill(moodIndicatorColor)
                        .frame(width: indicatorSize, height: indicatorSize)
                        .opacity(dayEntries.isEmpty ? 0.0 : 1.0)
                    
                    // Entry count for multiple entries
                    if dayEntries.count > 1 {
                        Text("\(dayEntries.count)")
                            .font(.system(size: 6, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(width: 36, height: 36)
            .background(
                Circle()
                    .fill(backgroundColor)
                    .overlay(
                        Circle()
                            .stroke(borderColor, lineWidth: isSelected ? 2 : 0)
                    )
            )
            .scaleEffect(tapScale)
            .opacity(isCurrentMonth ? 1.0 : 0.4)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.1 : (isToday ? 1.05 : 1.0))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isToday)
        .onTapGesture {
            // Immediate visual feedback
            withAnimation(.easeInOut(duration: 0.1)) {
                tapScale = 0.95
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    tapScale = 1.0
                }
                onTap(date)
            }
        }
    }
}

// MARK: - Modern Entry Detail View
struct ModernEntryDetailView: View {
    let entry: MoodEntryData
    @ObservedObject var viewModel: MoodViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var showingEditEntry = false
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.surface.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: DesignSystem.Spacing.xl) {
                    // Modern Header with Mood
                    headerSection
                    
                    // Content sections
                    if let text = entry.textEntry, !text.isEmpty {
                        modernContentSection(title: "Thoughts", content: text)
                    }
                    
                    if !entry.categories.isEmpty {
                        categoriesSection
                    }
                    
                    // Media sections
                    if entry.hasAudio {
                        modernMediaSection(title: "Audio", icon: "waveform", color: DesignSystem.Colors.accent)
                    }
                    
                    if entry.hasPhoto {
                        modernMediaSection(title: "Photo", icon: "photo", color: DesignSystem.Colors.info)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Close") {
                    dismiss()
                }
                .foregroundColor(DesignSystem.Colors.accent)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditEntry = true
                }
                .foregroundColor(DesignSystem.Colors.accent)
            }
        }
        .sheet(isPresented: $showingEditEntry) {
            EditEntryView(
                entry: entry,
                viewModel: viewModel,
                isPresented: $showingEditEntry
            )
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Large Mood Icon with background
            ZStack {
                Circle()
                    .fill(DesignSystem.moodColor(for: entry.mood).opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: entry.mood.icon)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(DesignSystem.moodColor(for: entry.mood))
            }
            
            // Mood Title
            Text(entry.mood.displayName)
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(DesignSystem.Colors.primary)
            
            // Date and Time
            Text(formattedDateTime)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(DesignSystem.Colors.secondary)
        }
        .padding(.top, DesignSystem.Spacing.lg)
    }
    
    private func modernContentSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.primary)
            
            Text(content)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(DesignSystem.Colors.secondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(DesignSystem.Colors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(DesignSystem.Colors.separator.opacity(0.3), lineWidth: 0.5)
                )
        )
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Categories")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.primary)
            
            categoriesGrid
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(DesignSystem.Colors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(DesignSystem.Colors.separator.opacity(0.3), lineWidth: 0.5)
                )
        )
    }
    
    private var categoriesGrid: some View {
        LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 120), spacing: DesignSystem.Spacing.sm)
        ], spacing: DesignSystem.Spacing.sm) {
            ForEach(entry.categories, id: \.id) { category in
                categoryGridItem(for: category)
            }
        }
    }
    
    private func categoryGridItem(for category: CategorySelection) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(category.categoryName)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DesignSystem.Colors.secondary)
            
            Text(category.selectedOptions.joined(separator: ", "))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(DesignSystem.Colors.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignSystem.Colors.accent.opacity(0.1))
        )
    }
    
    private func modernMediaSection(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(color.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text("Available")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(DesignSystem.Colors.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DesignSystem.Colors.tertiary)
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(DesignSystem.Colors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(DesignSystem.Colors.separator.opacity(0.3), lineWidth: 0.5)
                )
        )
    }
    
    private var formattedDateTime: String {
        let formatter = DateFormatter()
        
        if Calendar.current.isDateInToday(entry.date) {
            formatter.timeStyle = .short
            return "Today at \(formatter.string(from: entry.date))"
        } else if Calendar.current.isDateInYesterday(entry.date) {
            formatter.timeStyle = .short
            return "Yesterday at \(formatter.string(from: entry.date))"
        } else {
            formatter.dateStyle = .full
            formatter.timeStyle = .short
            return formatter.string(from: entry.date)
        }
    }
}

// MARK: - Selected Day Content View
struct SelectedDayContentView: View {
    let date: Date
    let moodEntries: [MoodEntryData]
    let onDismiss: () -> Void
    let onSelectEntry: (MoodEntryData) -> Void
    let onEditEntry: (MoodEntryData) -> Void
    let onShowNewEntry: (Date) -> Void
    
    private var dayEntries: [MoodEntryData] {
        moodEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    private var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Day header with consistent height
            dayHeader
            
            // Content area - remove extra ScrollView
            if dayEntries.isEmpty {
                EmptyDayView(date: date, onShowNewEntry: onShowNewEntry)
                    .frame(maxWidth: .infinity)
            } else {
                DayEntriesListView(entries: dayEntries, onSelectEntry: onSelectEntry, onEditEntry: onEditEntry)
                    .frame(maxWidth: .infinity)
            }
            
            // Bottom spacer to prevent over-scrolling
            Spacer(minLength: 0)
        }
        .background(DesignSystem.Colors.surface)
    }
    
    private var dayHeader: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatter.string(from: date))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text("\(dayEntries.count) \(dayEntries.count == 1 ? "entry" : "entries")")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.secondary)
                }
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(DesignSystem.Colors.secondary.opacity(0.6))
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            
            Divider()
                .background(DesignSystem.Colors.secondary.opacity(0.2))
                .padding(.horizontal, DesignSystem.Spacing.lg)
        }
        .frame(height: 80) // Fixed header height
        .background(DesignSystem.Colors.surface)
    }
}

// MARK: - Empty Day View
struct EmptyDayView: View {
    let date: Date
    let onShowNewEntry: (Date) -> Void
    
    private func getEmptyDayIcon(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "sun.max"
        } else if date > Date() {
            return "calendar.badge.clock"
        } else {
            return "calendar.badge.plus"
        }
    }
    
    private func getEmptyDayTitle(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "How's your day?"
        } else if date > Date() {
            return "Future day"
        } else {
            return "No entries yet"
        }
    }
    
    private func getEmptyDayMessage(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Share how you're feeling today!"
        } else if date > Date() {
            return "This day hasn't happened yet"
        } else {
            return "Add your first entry for this day"
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: getEmptyDayIcon(for: date))
                .font(.system(size: 48))
                .foregroundColor(DesignSystem.Colors.secondary.opacity(0.4))
            
            VStack(spacing: 8) {
                Text(getEmptyDayTitle(for: date))
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text(getEmptyDayMessage(for: date))
                    .font(.system(size: 14))
                    .foregroundColor(DesignSystem.Colors.secondary.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            if date <= Date() {
                Button(action: {
                    onShowNewEntry(date)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16))
                        Text("Add Entry")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(DesignSystem.Colors.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 32)
        .padding(.bottom, 16)
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
}

// MARK: - Day Entries List View
struct DayEntriesListView: View {
    let entries: [MoodEntryData]
    let onSelectEntry: (MoodEntryData) -> Void
    let onEditEntry: (MoodEntryData) -> Void
    
    var body: some View {
        LazyVStack(spacing: DesignSystem.Spacing.md) {
            ForEach(entries, id: \.id) { entry in
                DayEntryCard(
                    entry: entry,
                    onTap: {
                        onSelectEntry(entry)
                    },
                    onEdit: {
                        onEditEntry(entry)
                    }
                )
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.top, DesignSystem.Spacing.sm)
        .padding(.bottom, DesignSystem.Spacing.lg)
    }
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let dayMonthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter
    }()
}

// MARK: - Day Entry Card
struct DayEntryCard: View {
    let entry: MoodEntryData
    let onTap: () -> Void
    let onEdit: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            cardContent
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            contextMenuContent
        }
    }
    
    private var cardContent: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            moodIcon
            contentSection
            actionIndicator
        }
        .padding(DesignSystem.Spacing.md)
        .background(cardBackground)
    }
    
    private var moodIcon: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.moodColor(for: entry.mood).opacity(0.15))
                .frame(width: 40, height: 40)
            
            Image(systemName: entry.mood.icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DesignSystem.moodColor(for: entry.mood))
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            headerRow
            
            if let text = entry.textEntry, !text.isEmpty {
                textContent(text)
            }
            
            if !entry.categories.isEmpty {
                categoriesSection
            }
        }
    }
    
    private var headerRow: some View {
        HStack {
            Text(entry.mood.displayName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(DesignSystem.Colors.primary)
            
            Spacer()
            
            Text(formattedTime)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(DesignSystem.Colors.secondary)
        }
    }
    
    private func textContent(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .regular))
            .foregroundColor(DesignSystem.Colors.secondary)
            .lineLimit(2)
    }
    
    private var categoriesSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(entry.categories.prefix(2).indices, id: \.self) { index in
                    let category = entry.categories[index]
                    categoryTag(for: category)
                }
                
                if entry.categories.count > 2 {
                    remainingCategoriesTag
                }
            }
        }
    }
    
    private func categoryTag(for category: CategorySelection) -> some View {
        Text(category.selectedOptions.first ?? category.categoryName)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(DesignSystem.Colors.accent)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(DesignSystem.Colors.accent.opacity(0.1))
            )
    }
    
    private var remainingCategoriesTag: some View {
        Text("+\(entry.categories.count - 2)")
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(DesignSystem.Colors.secondary)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(DesignSystem.Colors.secondary.opacity(0.1))
            )
    }
    
    private var actionIndicator: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(DesignSystem.Colors.tertiary)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(DesignSystem.Colors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(DesignSystem.Colors.separator.opacity(0.2), lineWidth: 0.5)
            )
    }
    
    private var contextMenuContent: some View {
        Button {
            onEdit()
        } label: {
            Label("Edit Entry", systemImage: "pencil")
        }
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: entry.date)
    }
}

#Preview {
    TimelineView(viewModel: MoodViewModel())
} 