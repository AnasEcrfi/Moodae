//
//  WeekStartPickerView.swift
//  Moodae
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

struct WeekStartPickerView: View {
    @ObservedObject var weekStartManager: WeekStartManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.surface
                    .ignoresSafeArea()
                
                VStack(spacing: DesignSystem.Spacing.xxxl) {
                    // Header
                    headerSection
                    
                    // Week Start Options
                    optionsSection
                    
                    // Preview Section
                    previewSection
                    
                    Spacer()
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.top, DesignSystem.Spacing.lg)
            }
            .navigationTitle("Start of Week")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        HapticFeedback.light.trigger()
                        dismiss()
                    }
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.accent)
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "calendar")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundColor(DesignSystem.Colors.accent)
                .subtleAppearance(delay: 0.1)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("Choose Week Start")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .subtleAppearance(delay: 0.2)
                
                Text("Select which day your week begins")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .multilineTextAlignment(.center)
                    .subtleAppearance(delay: 0.3)
            }
        }
    }
    
    // MARK: - Options Section
    private var optionsSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ForEach(WeekStartDay.allCases, id: \.self) { weekStart in
                weekStartOptionCard(weekStart: weekStart)
                    .subtleAppearance(delay: 0.4 + Double(WeekStartDay.allCases.firstIndex(of: weekStart) ?? 0) * 0.1)
            }
        }
    }
    
    // MARK: - Preview Section
    private var previewSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Text("Preview")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.primary)
                .subtleAppearance(delay: 0.6)
            
            // Mini Calendar Preview
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(weekStartManager.veryShortWeekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(DesignSystem.Colors.cardBackground)
                        )
                }
            }
            .subtleAppearance(delay: 0.7)
        }
    }
    
    // MARK: - Week Start Option Card
    private func weekStartOptionCard(weekStart: WeekStartDay) -> some View {
        Button(action: {
            HapticFeedback.medium.trigger()
            withAnimation(.easeInOut(duration: 0.3)) {
                weekStartManager.setWeekStart(weekStart)
            }
        }) {
            HStack(spacing: DesignSystem.Spacing.lg) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor(for: weekStart))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: weekStart.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(iconForegroundColor(for: weekStart))
                }
                
                // Content
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(weekStart.rawValue)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text(weekStart.description)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondary)
                }
                
                Spacer()
                
                // Selection Indicator
                ZStack {
                    Circle()
                        .stroke(DesignSystem.Colors.accent, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected(weekStart) {
                        Circle()
                            .fill(DesignSystem.Colors.accent)
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding(DesignSystem.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(cardBackgroundColor(for: weekStart))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .stroke(borderColor(for: weekStart), lineWidth: isSelected(weekStart) ? 2 : 0)
                    )
                    .conditionalShadow(hasShadow: isSelected(weekStart), colorScheme: colorScheme)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected(weekStart) ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected(weekStart))
    }
    
    // MARK: - Helper Methods
    private func isSelected(_ weekStart: WeekStartDay) -> Bool {
        weekStartManager.selectedWeekStart == weekStart
    }
    
    private func cardBackgroundColor(for weekStart: WeekStartDay) -> Color {
        if isSelected(weekStart) {
            return DesignSystem.Colors.accent.opacity(0.1)
        }
        return DesignSystem.Colors.cardBackground
    }
    
    private func borderColor(for weekStart: WeekStartDay) -> Color {
        isSelected(weekStart) ? DesignSystem.Colors.accent : Color.clear
    }
    
    private func iconBackgroundColor(for weekStart: WeekStartDay) -> Color {
        if isSelected(weekStart) {
            return DesignSystem.Colors.accent
        }
        return DesignSystem.Colors.accent.opacity(0.15)
    }
    
    private func iconForegroundColor(for weekStart: WeekStartDay) -> Color {
        if isSelected(weekStart) {
            return Color(.systemBackground)
        }
        return DesignSystem.Colors.accent
    }
}

#Preview {
    WeekStartPickerView(weekStartManager: WeekStartManager())
} 