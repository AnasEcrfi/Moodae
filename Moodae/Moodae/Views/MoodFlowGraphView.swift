//
//  MoodFlowGraphView.swift
//  Moodae
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

struct MoodFlowGraphView: View {
    let entries: [MoodEntryData]
    let timeframe: InsightsTimeframe
    @Environment(\.colorScheme) var colorScheme
    
    @State private var animationProgress: CGFloat = 0
    @State private var showDataPoints = false
    @State private var selectedPointIndex: Int?
    @State private var showingPointDetail = false
    @State private var hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    private let graphHeight: CGFloat = 260  // Erhöht für bessere Touch-Targets
    private let cornerRadius: CGFloat = 20
    private let graphPadding: CGFloat = 16 // Reduziert für breiteren Graph
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
            // Modern Header with Insights
            modernHeaderWithInsights
            
            // Modern Graph Card with Interaction
            modernInteractiveGraphCard
        }
        .onAppear {
            startInitialAnimation()
        }
        .sheet(isPresented: $showingPointDetail) {
            if let index = selectedPointIndex,
               processedDataPoints.indices.contains(index) {
                dataPointDetailSheet(processedDataPoints[index])
            }
        }
        // Accessibility
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Mood flow graph for \(timeframe.rawValue)")
        .accessibilityHint("Shows your mood pattern over time. Double tap to explore data points.")
    }
    
    // MARK: - Enhanced Header with Insights
    private var modernHeaderWithInsights: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Mood Flow")
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text("Your emotional journey over \(timeframe.rawValue)")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(DesignSystem.Colors.secondary)
                }
                
                Spacer()
                
                // Enhanced Stats with Trend
                enhancedStatsView
            }
            
            // Quick Insights für den Zeitraum
            if !processedDataPoints.isEmpty {
                timeframeInsightsView
                    .subtleAppearance(delay: 0.3)
            }
        }
        .subtleAppearance(delay: 0.1)
    }
    
    // MARK: - Enhanced Stats View
    private var enhancedStatsView: some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack(spacing: 4) {
                Text("\(processedDataPoints.count)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(DesignSystem.Colors.accent)
                
                Text("entries")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.secondary)
            }
            
            if let avgMood = averageMoodValue {
                HStack(spacing: 4) {
                    Text("Ø \(avgMood, specifier: "%.1f")")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(moodTrendColor)
                    
                    Image(systemName: moodTrendIcon)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(moodTrendColor)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignSystem.Colors.accent.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DesignSystem.Colors.accent.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Timeframe Insights
    private var timeframeInsightsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Best Day
                if let bestDay = getBestDay() {
                    InsightChip(
                        icon: "star.fill",
                        text: "Best: \(formatInsightDate(bestDay.date))",
                        color: DesignSystem.Colors.success
                    )
                }
                
                // Consistency Score
                ConsistencyChip(score: getConsistencyScore())
                
                // Streak Info
                if let streak = getCurrentStreak() {
                    InsightChip(
                        icon: "flame.fill",
                        text: "\(streak) day streak",
                        color: DesignSystem.Colors.accent
                    )
                }
                
                // Weekly Pattern (nur für year timeframe)
                if timeframe == .year, let pattern = getWeeklyPattern() {
                    InsightChip(
                        icon: "calendar.badge.clock",
                        text: pattern,
                        color: DesignSystem.Colors.info
                    )
                }
            }
            .padding(.horizontal, 1) // Minimale horizontal Padding für ScrollView
        }
    }
    
    // MARK: - Interactive Graph Card
    private var modernInteractiveGraphCard: some View {
        VStack(spacing: 0) {
            if processedDataPoints.isEmpty {
                enhancedEmptyGraphView
            } else {
                interactiveGraphView
            }
        }
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(DesignSystem.Colors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(DesignSystem.Colors.separator.opacity(0.5), lineWidth: 0.5)
                )
                .shadow(
                    color: DesignSystem.Colors.secondary.opacity(0.05),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
        .subtleAppearance(delay: 0.2)
    }
    
    // MARK: - Interactive Graph View
    private var interactiveGraphView: some View {
        VStack(spacing: 0) {
            // Y-Axis and Graph Area
            HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                // Improved Y-Axis Labels
                improvedYAxisLabels
                
                // Interactive Graph Canvas
                interactiveGraphCanvas
                    .padding(.horizontal, graphPadding)
            }
            .padding(.top, DesignSystem.Spacing.lg)
            .padding(.horizontal, DesignSystem.Spacing.md) // Reduziert für mehr Graph-Platz
            
            // Selected Point Info
            if let selectedIndex = selectedPointIndex {
                selectedPointInfoView(processedDataPoints[selectedIndex])
                    .padding(.horizontal, DesignSystem.Spacing.md) // Reduziert für mehr Graph-Platz
                    .padding(.top, DesignSystem.Spacing.md)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Enhanced X-Axis
            enhancedXAxisLabels
                .padding(.horizontal, DesignSystem.Spacing.md) // Reduziert für mehr Graph-Platz
                .padding(.bottom, DesignSystem.Spacing.lg)
        }
    }
    
    // MARK: - Improved Y-Axis Labels mit allen Icons
    private var improvedYAxisLabels: some View {
        VStack(spacing: 0) {
            ForEach(0..<6, id: \.self) { index in
                HStack(spacing: 8) {
                    // Mood Value Label (6 oben, 1 unten) - weiter links
                    Text("\(6-index)")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(DesignSystem.Colors.secondary)
                        .frame(width: 18, alignment: .trailing)
                    
                    // Mood Icon für ALLE Werte (auch ungerade)
                    if let mood = yAxisMood(for: index) {
                        ZStack {
                            Circle()
                                .fill(DesignSystem.moodColor(for: mood).opacity(0.15))
                                .frame(width: 24, height: 24)
                            
                            Image(systemName: mood.icon)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(DesignSystem.moodIconColor(for: mood))
                        }
                    } else {
                        // Fallback für fehlende Moods
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 24, height: 24)
                    }
                }
                .scaleEffect(animationProgress)
                .opacity(animationProgress)
                .frame(height: graphHeight / 5)
            }
        }
        .frame(width: 60) // Erweitert für bessere Icon-Platzierung
    }
    
    // MARK: - Interactive Graph Canvas
    private var interactiveGraphCanvas: some View {
        ZStack {
            // Background Grid
            backgroundGridView
            
            // Smooth Curve
            modernCurveView
            
            // Interactive Data Points
            interactiveDataPointsView
        }
        .frame(height: graphHeight)
        .contentShape(Rectangle()) // Macht gesamte Fläche tappable
        .onTapGesture { location in
            // Einfacher Tap zum Deselektieren wenn kein Punkt getroffen wird
            withAnimation(.moodayEase) {
                selectedPointIndex = nil
            }
        }
    }
    
    // MARK: - Interactive Data Points
    private var interactiveDataPointsView: some View {
        GeometryReader { geometry in
            ForEach(processedDataPoints.indices, id: \.self) { index in
                let point = processedDataPoints[index]
                let position = preciseSmoothPointWithMargins(for: index, width: geometry.size.width, height: geometry.size.height)
                let isSelected = selectedPointIndex == index
                
                ZStack {
                    // Touch Target (größer für bessere Usability)
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                        .onTapGesture {
                            handlePointSelection(index)
                        }
                    
                    // Expanded glow für ausgewählten Punkt
                    if isSelected {
                        Circle()
                            .fill(DesignSystem.moodColor(for: point.mood).opacity(0.3))
                            .frame(width: 32, height: 32)
                            .blur(radius: 4)
                            .scaleEffect(1.2)
                    }
                    
                    // Outer glow
                    Circle()
                        .fill(DesignSystem.moodColor(for: point.mood).opacity(0.25))
                        .frame(width: isSelected ? 24 : 20, height: isSelected ? 24 : 20)
                        .blur(radius: 3)
                    
                    // Main point
                    Circle()
                        .fill(DesignSystem.moodColor(for: point.mood))
                        .frame(width: isSelected ? 16 : 12, height: isSelected ? 16 : 12)
                        .overlay(
                            Circle()
                                .stroke(DesignSystem.Colors.cardBackground, lineWidth: isSelected ? 3 : 2.5)
                        )
                        .shadow(
                            color: DesignSystem.moodColor(for: point.mood).opacity(0.4),
                            radius: isSelected ? 6 : 4,
                            x: 0,
                            y: 2
                        )
                    
                    // Mood Icon für ausgewählten Punkt
                    if isSelected {
                        Image(systemName: point.mood.icon)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .position(position)
                .scaleEffect(showDataPoints ? (isSelected ? 1.1 : 1.0) : 0.0)
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.8)
                    .delay(Double(index) * 0.08),
                    value: showDataPoints
                )
                .animation(.moodayEase, value: isSelected)
                // Accessibility
                .accessibilityElement()
                .accessibilityLabel("Mood entry from \(DateFormatter.localizedString(from: point.date, dateStyle: .medium, timeStyle: .none))")
                .accessibilityValue("Mood level: \(moodNumericValue(point.mood), specifier: "%.1f") out of 6")
                .accessibilityHint("Double tap to view details")
            }
        }
    }
    
    // MARK: - Enhanced Empty Graph View
    private var enhancedEmptyGraphView: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            ZStack {
                // Animated background
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                DesignSystem.Colors.accent.opacity(0.15),
                                DesignSystem.Colors.accent.opacity(0.05)
                            ]),
                            center: .center,
                            startRadius: 20,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .breathingEffect(intensity: 0.05)
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 36, weight: .light))
                    .foregroundColor(DesignSystem.Colors.accent.opacity(0.7))
                    .scaleEffect(animationProgress)
            }
            
            VStack(spacing: DesignSystem.Spacing.md) {
                Text("Start Your Journey")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text("Track your moods daily to see beautiful patterns and insights emerge over time")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                
                // Call to Action
                Button(action: {
                    // Action für Quick Entry
                    HapticFeedback.medium.trigger()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                        
                        Text("Add Your First Entry")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .fill(DesignSystem.Colors.accent)
                    )
                }
                .buttonStyle(CleanButtonStyle())
                .subtleAppearance(delay: 0.5)
            }
        }
        .frame(height: graphHeight + 80)
        .frame(maxWidth: .infinity)
        .subtleAppearance(delay: 0.3)
    }
    
    // MARK: - Präzise Helper Functions mit Margins
    
    /// KORRIGIERTE Position-Berechnung - nutzt graphPadding statt separater Margin
    private func preciseSmoothPointWithMargins(for index: Int, width: CGFloat, height: CGFloat) -> CGPoint {
        let point = processedDataPoints[index]
        
        // X-Position: Gleichmäßige Verteilung - KEIN zusätzlicher Margin, nur graphPadding wird außen verwendet
        let x: CGFloat
        if processedDataPoints.count == 1 {
            x = width / 2
        } else {
            x = (CGFloat(index) / CGFloat(processedDataPoints.count - 1)) * width
        }
        
        // Y-Position: Präzise Skalierung - OBEN = GUT, UNTEN = SCHLECHT
        let y = height - (point.preciseNormalizedValue * height)
        
        return CGPoint(x: x, y: y)
    }
    
    /// ALTE Methode für Rückwärtskompatibilität
    private func preciseSmoothPoint(for index: Int, width: CGFloat, height: CGFloat) -> CGPoint {
        return preciseSmoothPointWithMargins(for: index, width: width, height: height)
    }
    
    private func startInitialAnimation() {
        withAnimation(.easeInOut(duration: 1.4)) {
            animationProgress = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showDataPoints = true
        }
    }
    
    // MARK: - Verbesserte Computed Properties
    
    private var processedDataPoints: [MoodDataPoint] {
        let filteredEntries = entries.filter { entry in
            let calendar = Calendar.current
            let now = Date()
            
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
        
        guard !filteredEntries.isEmpty else { return [] }
        
        let sortedEntries = filteredEntries.sorted { $0.date < $1.date }
        
        return sortedEntries.map { entry in
            MoodDataPoint(
                date: entry.date,
                mood: entry.mood,
                normalizedValue: normalizedValueForMood(entry.mood),
                preciseNormalizedValue: preciseNormalizedValueForMood(entry.mood)
            )
        }
    }
    
    /// Verbesserte X-Axis Labels mit intelligenter Zeitraum-Darstellung
    private var enhancedXAxisLabelsArray: [String] {
        // Zeige Labels auch ohne Daten für bessere UX
        
        let formatter = DateFormatter()
        let calendar = Calendar.current
        let now = Date()
        
        switch timeframe {
        case .week:
            formatter.dateFormat = "E d"
            // Zeige die letzten 7 Tage
            var labels: [String] = []
            for i in 0..<7 {
                let date = calendar.date(byAdding: .day, value: -i, to: now) ?? now
                labels.insert(formatter.string(from: date), at: 0)
            }
            return labels
            
        case .month:
            formatter.dateFormat = "d/M"
            // Zeige gleichmäßig verteilte Tage über den letzten Monat
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            var labels: [String] = []
            
            // Erstelle 6 gleichmäßig verteilte Punkte über den Monat (ca. alle 5 Tage)
            for i in 0..<6 {
                let daysFromStart = i * 5 // Alle 5 Tage: 0, 5, 10, 15, 20, 25
                let date = calendar.date(byAdding: .day, value: daysFromStart, to: monthAgo) ?? monthAgo
                labels.append(formatter.string(from: date))
            }
            return labels
            
        case .year:
            formatter.dateFormat = "MMM"
            // Zeige 6 verschiedene Monate über das Jahr verteilt
            var labels: [String] = []
            
            // Erstelle Labels für die letzten 12 Monate, zeige jeden 2. Monat
            for i in 0..<6 {
                let monthsBack = (5 - i) * 2 // 10, 8, 6, 4, 2, 0 Monate zurück
                let date = calendar.date(byAdding: .month, value: -monthsBack, to: now) ?? now
                labels.append(formatter.string(from: date))
            }
            return labels
        }
    }
    
    private var averageMoodValue: Double? {
        guard !processedDataPoints.isEmpty else { return nil }
        let sum = processedDataPoints.map { moodNumericValue($0.mood) }.reduce(0, +)
        return sum / Double(processedDataPoints.count)
    }
    
    // MARK: - Korrigierte Y-Axis Mood Mapping
    private func yAxisMood(for index: Int) -> MoodType? {
        // KORRIGIERT: Index 0 = oben = amazing (6), Index 5 = unten = overwhelming (1)
        switch index {
        case 0: return .amazing       // 6 - Oben
        case 1: return .good          // 5
        case 2: return .okay          // 4
        case 3: return .challenging   // 3
        case 4: return .tough         // 2
        case 5: return .overwhelming  // 1 - Unten
        default: return nil
        }
    }
    
    private func normalizedValueForMood(_ mood: MoodType) -> Double {
        switch mood {
        case .amazing: return 1.0
        case .good: return 0.8
        case .okay: return 0.6
        case .challenging: return 0.4
        case .tough: return 0.2
        case .overwhelming: return 0.0
        }
    }
    
    /// PRÄZISERE Normalisierung für bessere Darstellung
    private func preciseNormalizedValueForMood(_ mood: MoodType) -> Double {
        switch mood {
        case .amazing: return 1.0        // 6.0
        case .good: return 0.833         // 5.0  
        case .okay: return 0.666         // 4.0
        case .challenging: return 0.5    // 3.0
        case .tough: return 0.333        // 2.0
        case .overwhelming: return 0.166 // 1.0
        }
    }
    
    private func moodNumericValue(_ mood: MoodType) -> Double {
        switch mood {
        case .amazing: return 6.0
        case .good: return 5.0
        case .okay: return 4.0
        case .challenging: return 3.0
        case .tough: return 2.0
        case .overwhelming: return 1.0
        }
    }
    
    // MARK: - Point Selection Handling
    
    private func handlePointSelection(_ index: Int) {
        selectedPointIndex = index
        showingPointDetail = true
        hapticFeedback.prepare()
        hapticFeedback.impactOccurred()
    }
    
    // MARK: - Data Point Detail Sheet
    private func dataPointDetailSheet(_ point: MoodDataPoint) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Mood Entry Details")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.primary)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                DetailRow(title: "Date", value: DateFormatter.localizedString(from: point.date, dateStyle: .medium, timeStyle: .none))
                DetailRow(title: "Mood", value: point.mood.rawValue)
                DetailRow(title: "Normalized Value", value: String(format: "%.2f", point.normalizedValue))
                DetailRow(title: "Precise Normalized Value", value: String(format: "%.2f", point.preciseNormalizedValue))
            }
            .padding(.top, DesignSystem.Spacing.sm)
            
            Spacer()
            
            Button(action: {
                showingPointDetail = false
            }) {
                Text("Close")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.accent)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .fill(DesignSystem.Colors.accent.opacity(0.1))
                    )
            }
            .buttonStyle(CleanButtonStyle())
        }
        .padding(DesignSystem.Spacing.lg)
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
    
    // MARK: - Insights Calculations
    private func getBestDay() -> MoodDataPoint? {
        guard !processedDataPoints.isEmpty else { return nil }
        return processedDataPoints.max(by: { $0.normalizedValue < $1.normalizedValue })
    }
    
    private func getConsistencyScore() -> Double {
        guard !processedDataPoints.isEmpty else { return 0.0 }
        let uniqueMoods = Set(processedDataPoints.map(\.mood))
        let totalMoods = Double(processedDataPoints.count)
        
        if totalMoods == 0 { return 0.0 }
        
        let consistency = Double(uniqueMoods.count) / totalMoods
        return round(consistency * 100) / 100.0
    }
    
    private func getCurrentStreak() -> Int? {
        guard !processedDataPoints.isEmpty else { return nil }
        
        let sortedPoints = processedDataPoints.sorted { $0.date < $1.date }
        var currentStreak = 0
        var lastMood: MoodType? = nil
        
        for point in sortedPoints {
            if lastMood == nil {
                lastMood = point.mood
                currentStreak = 1
            } else if point.mood == lastMood {
                currentStreak += 1
            } else {
                break
            }
        }
        
        return currentStreak
    }
    
    private func getWeeklyPattern() -> String? {
        guard timeframe == .year, !processedDataPoints.isEmpty else { return nil }
        
        let moodCounts: [MoodType: Int] = processedDataPoints.reduce(into: [:]) { counts, point in
            if let count = counts[point.mood] {
                counts[point.mood] = count + 1
            } else {
                counts[point.mood] = 1
            }
        }
        
        let sortedMoods = moodCounts.sorted { $0.value > $1.value }
        
        if sortedMoods.isEmpty { return nil }
        
        let topMood = sortedMoods[0]
        let topCount = topMood.value
        
        let otherMoods = sortedMoods.dropFirst()
        let otherCount = otherMoods.reduce(0) { $0 + $1.value }
        
        if otherCount == 0 {
            return "\(topMood.key.rawValue) \(topCount)x"
        } else {
            return "\(topMood.key.rawValue) \(topCount)x, \(otherMoods.count) others"
        }
    }
    
    private var moodTrendColor: Color {
        guard let bestDay = getBestDay() else { return DesignSystem.Colors.secondary }
        let currentAvg = averageMoodValue ?? 0.0
        return currentAvg < bestDay.normalizedValue ? DesignSystem.Colors.success : DesignSystem.Colors.warning
    }
    
    private var moodTrendIcon: String {
        guard let bestDay = getBestDay() else { return "arrow.up.right.and.arrow.down.left" }
        let currentAvg = averageMoodValue ?? 0.0
        return currentAvg < bestDay.normalizedValue ? "arrow.up.right.and.arrow.down.left" : "arrow.down.right.and.arrow.up.left"
    }
    
    private func formatInsightDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    // MARK: - Selected Point Info View
    private func selectedPointInfoView(_ point: MoodDataPoint) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Mood Icon
            ZStack {
                Circle()
                    .fill(DesignSystem.moodColor(for: point.mood).opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: point.mood.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignSystem.moodIconColor(for: point.mood))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(DateFormatter.localizedString(from: point.date, dateStyle: .medium, timeStyle: .none))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text("\(point.mood.rawValue) • \(moodNumericValue(point.mood), specifier: "%.1f")/6")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.secondary)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.moodayEase) {
                    selectedPointIndex = nil
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.secondary.opacity(0.6))
            }
            .buttonStyle(CleanButtonStyle())
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(DesignSystem.Colors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .stroke(DesignSystem.moodColor(for: point.mood).opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Background Grid
    private var backgroundGridView: some View {
        VStack(spacing: 0) {
            // 6 horizontale Grid-Linien: OBEN = GUT (6), UNTEN = SCHLECHT (1)
            ForEach(0..<6, id: \.self) { index in
                Rectangle()
                    .fill(DesignSystem.Colors.separator.opacity(0.12))
                    .frame(height: 0.5)
                
                if index < 5 {
                    Spacer()
                }
            }
        }
        .opacity(animationProgress * 0.6)
    }
    
    // MARK: - Modern Curve View
    private var modernCurveView: some View {
        GeometryReader { geometry in
            // Gradient Area under curve
            modernGradientArea(geometry: geometry)
            
            // Main smooth curve line
            modernSmoothCurve(geometry: geometry)
        }
    }
    
    private func modernGradientArea(geometry: GeometryProxy) -> some View {
        Path { path in
            guard processedDataPoints.count > 1 else { return }
            
            let availableWidth = geometry.size.width
            let height = geometry.size.height
            let controlPointOffset: CGFloat = availableWidth / CGFloat(max(processedDataPoints.count - 1, 1)) * 0.25
            
            // Start from bottom at first point's X position
            let firstPoint = preciseSmoothPointWithMargins(for: 0, width: availableWidth, height: height)
            path.move(to: CGPoint(x: firstPoint.x, y: height))
            
            // Move to first point
            path.addLine(to: CGPoint(x: firstPoint.x, y: firstPoint.y))
            
            // Create smooth curve through all points
            for i in 1..<processedDataPoints.count {
                let currentPoint = preciseSmoothPointWithMargins(for: i, width: availableWidth, height: height)
                let previousPoint = preciseSmoothPointWithMargins(for: i-1, width: availableWidth, height: height)
                
                let controlPoint1 = CGPoint(
                    x: previousPoint.x + controlPointOffset,
                    y: previousPoint.y
                )
                let controlPoint2 = CGPoint(
                    x: currentPoint.x - controlPointOffset,
                    y: currentPoint.y
                )
                
                path.addCurve(
                    to: currentPoint,
                    control1: controlPoint1,
                    control2: controlPoint2
                )
            }
            
            // Close the path at bottom at last point's X position
            let lastPoint = preciseSmoothPointWithMargins(for: processedDataPoints.count - 1, width: availableWidth, height: height)
            path.addLine(to: CGPoint(x: lastPoint.x, y: height))
            path.closeSubpath()
        }
        .fill(
            LinearGradient(
                stops: [
                    .init(color: DesignSystem.Colors.accent.opacity(0.25), location: 0.0),
                    .init(color: DesignSystem.Colors.accent.opacity(0.15), location: 0.4),
                    .init(color: DesignSystem.Colors.accent.opacity(0.08), location: 0.7),
                    .init(color: DesignSystem.Colors.accent.opacity(0.0), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .scaleEffect(x: animationProgress, y: 1, anchor: .leading)
        .opacity(animationProgress)
    }
    
    private func modernSmoothCurve(geometry: GeometryProxy) -> some View {
        Path { path in
            guard processedDataPoints.count >= 1 else { return }
            
            let availableWidth = geometry.size.width
            let height = geometry.size.height
            
            // Für einzelnen Punkt: einfache Linie
            if processedDataPoints.count == 1 {
                let point = preciseSmoothPointWithMargins(for: 0, width: availableWidth, height: height)
                path.move(to: point)
                path.addLine(to: point)
                return
            }
            
            let controlPointOffset: CGFloat = availableWidth / CGFloat(max(processedDataPoints.count - 1, 1)) * 0.25
            
            // Start at first point
            let firstPoint = preciseSmoothPointWithMargins(for: 0, width: availableWidth, height: height)
            path.move(to: firstPoint)
            
            // Create smooth curve through all points
            for i in 1..<processedDataPoints.count {
                let currentPoint = preciseSmoothPointWithMargins(for: i, width: availableWidth, height: height)
                let previousPoint = preciseSmoothPointWithMargins(for: i-1, width: availableWidth, height: height)
                
                let controlPoint1 = CGPoint(
                    x: previousPoint.x + controlPointOffset,
                    y: previousPoint.y
                )
                let controlPoint2 = CGPoint(
                    x: currentPoint.x - controlPointOffset,
                    y: currentPoint.y
                )
                
                path.addCurve(
                    to: currentPoint,
                    control1: controlPoint1,
                    control2: controlPoint2
                )
            }
        }
        .trim(from: 0, to: animationProgress)
        .stroke(
            LinearGradient(
                colors: [
                    DesignSystem.Colors.accent.opacity(0.9),
                    DesignSystem.Colors.accent.opacity(0.7),
                    DesignSystem.Colors.accent.opacity(0.8)
                ],
                startPoint: .leading,
                endPoint: .trailing
            ),
            style: StrokeStyle(
                lineWidth: 3.0,
                lineCap: .round,
                lineJoin: .round
            )
        )
        .shadow(
            color: DesignSystem.Colors.accent.opacity(0.25),
            radius: 3,
            x: 0,
            y: 1
        )
    }
    
    // MARK: - Enhanced X-Axis Labels
    private var enhancedXAxisLabels: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                                ForEach(enhancedXAxisLabelsArray.indices, id: \.self) { index in
                                         Text(enhancedXAxisLabelsArray[index])
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.secondary)
                        .frame(width: index == 0 || index == enhancedXAxisLabelsArray.count - 1 ? 
                               geometry.size.width / CGFloat(enhancedXAxisLabelsArray.count) : 
                               geometry.size.width / CGFloat(enhancedXAxisLabelsArray.count), 
                               alignment: index == 0 ? .leading : 
                                         index == enhancedXAxisLabelsArray.count - 1 ? .trailing : .center)
                        .opacity(animationProgress)
                }
            }
        }
        .frame(height: 20)
        .padding(.top, DesignSystem.Spacing.md)
        .padding(.leading, 78) // Angepasst für erweiterte Y-axis (60 + 18 padding)
        .padding(.trailing, DesignSystem.Spacing.md) // Matcht das reduzierte äußere Padding
        .padding(.horizontal, graphPadding) // Exakt das gleiche Padding wie der Graph
    }
}

// MARK: - Supporting Components

struct InsightChip: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color)
            
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DesignSystem.Colors.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct ConsistencyChip: View {
    let score: Double
    
    private var consistencyColor: Color {
        switch score {
        case 0.8...1.0: return DesignSystem.Colors.success
        case 0.5..<0.8: return DesignSystem.Colors.warning
        default: return DesignSystem.Colors.error
        }
    }
    
    private var consistencyText: String {
        switch score {
        case 0.8...1.0: return "High consistency"
        case 0.5..<0.8: return "Moderate consistency"
        default: return "Low consistency"
        }
    }
    
    var body: some View {
        InsightChip(
            icon: "checkmark.circle.fill",
            text: consistencyText,
            color: consistencyColor
        )
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(DesignSystem.Colors.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.primary)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Verbesserte Supporting Data Models
struct MoodDataPoint {
    let date: Date
    let mood: MoodType
    let normalizedValue: Double
    let preciseNormalizedValue: Double
}

#Preview {
    let sampleEntries = [
        MoodEntryData(date: Date().addingTimeInterval(-6 * 24 * 3600), mood: .good, textEntry: nil, audioURL: nil, categories: []),
        MoodEntryData(date: Date().addingTimeInterval(-5 * 24 * 3600), mood: .challenging, textEntry: nil, audioURL: nil, categories: []),
        MoodEntryData(date: Date().addingTimeInterval(-4 * 24 * 3600), mood: .amazing, textEntry: nil, audioURL: nil, categories: []),
        MoodEntryData(date: Date().addingTimeInterval(-3 * 24 * 3600), mood: .okay, textEntry: nil, audioURL: nil, categories: []),
        MoodEntryData(date: Date().addingTimeInterval(-2 * 24 * 3600), mood: .tough, textEntry: nil, audioURL: nil, categories: []),
        MoodEntryData(date: Date().addingTimeInterval(-1 * 24 * 3600), mood: .good, textEntry: nil, audioURL: nil, categories: [])
    ]
    
    MoodFlowGraphView(entries: sampleEntries, timeframe: .week)
        .padding()
        .background(DesignSystem.Colors.surface)
} 