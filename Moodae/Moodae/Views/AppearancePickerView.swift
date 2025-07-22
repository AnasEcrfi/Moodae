//
//  AppearancePickerView.swift
//  Moodae
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

struct AppearancePickerView: View {
    @ObservedObject var appearanceManager: AppearanceManager
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
                    
                    // Appearance Options
                    optionsSection
                    
                    Spacer()
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.top, DesignSystem.Spacing.lg)
            }
            .navigationTitle("Appearance")
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
            Image(systemName: "circle.lefthalf.filled")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundColor(DesignSystem.Colors.accent)
                .subtleAppearance(delay: 0.1)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("Choose Appearance")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .subtleAppearance(delay: 0.2)
                
                Text("Select how Moodae looks on your device")
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
            ForEach(AppearanceMode.allCases, id: \.self) { mode in
                appearanceOptionCard(mode: mode)
                    .subtleAppearance(delay: 0.4 + Double(AppearanceMode.allCases.firstIndex(of: mode) ?? 0) * 0.1)
            }
        }
    }
    
    // MARK: - Appearance Option Card
    private func appearanceOptionCard(mode: AppearanceMode) -> some View {
        Button(action: {
            HapticFeedback.medium.trigger()
            withAnimation(.easeInOut(duration: 0.3)) {
                appearanceManager.setAppearanceMode(mode)
            }
        }) {
            HStack(spacing: DesignSystem.Spacing.lg) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor(for: mode))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: mode.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(iconForegroundColor(for: mode))
                }
                
                // Content
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(mode.rawValue)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text(mode.description)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondary)
                }
                
                Spacer()
                
                // Selection Indicator
                ZStack {
                    Circle()
                        .stroke(DesignSystem.Colors.accent, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected(mode) {
                        Circle()
                            .fill(DesignSystem.Colors.accent)
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding(DesignSystem.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(cardBackgroundColor(for: mode))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .stroke(borderColor(for: mode), lineWidth: isSelected(mode) ? 2 : 0)
                    )
                    .conditionalShadow(hasShadow: isSelected(mode), colorScheme: colorScheme)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected(mode) ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected(mode))
    }
    
    // MARK: - Helper Methods
    private func isSelected(_ mode: AppearanceMode) -> Bool {
        appearanceManager.selectedMode == mode
    }
    
    private func cardBackgroundColor(for mode: AppearanceMode) -> Color {
        if isSelected(mode) {
            return DesignSystem.Colors.accent.opacity(0.1)
        }
        return DesignSystem.Colors.cardBackground
    }
    
    private func borderColor(for mode: AppearanceMode) -> Color {
        isSelected(mode) ? DesignSystem.Colors.accent : Color.clear
    }
    
    private func iconBackgroundColor(for mode: AppearanceMode) -> Color {
        if isSelected(mode) {
            return DesignSystem.Colors.accent
        }
        return DesignSystem.Colors.accent.opacity(0.15)
    }
    
    private func iconForegroundColor(for mode: AppearanceMode) -> Color {
        if isSelected(mode) {
            return Color(.systemBackground)
        }
        return DesignSystem.Colors.accent
    }
}

#Preview {
    AppearancePickerView(appearanceManager: AppearanceManager())
} 