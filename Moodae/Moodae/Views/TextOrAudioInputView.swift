//
//  TextOrAudioInputView.swift
//  Mooday
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

struct TextOrAudioInputView: View {
    @ObservedObject var viewModel: MoodViewModel
    let moodType: MoodType
    @Binding var isPresented: Bool
    
    @State private var textEntry = ""
    @State private var selectedInputMode: InputMode = .text
    @State private var showingSuccess = false
    @Environment(\.colorScheme) var colorScheme
    
    private enum InputMode: String, CaseIterable {
        case text = "Text"
        case audio = "Audio"
        
        var icon: String {
            switch self {
            case .text: return "text.alignleft"
            case .audio: return "waveform"
            }
        }
    }
    
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
                        
                        // Input Mode Selector
                        inputModeSelector
                        
                        // Input Section
                        inputSection
                        
                        // Action Buttons
                        actionButtonsSection
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.top, DesignSystem.Spacing.lg)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        HapticFeedback.light.trigger()
                        isPresented = false
                    }
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.secondary)
                }
            }
        }
        .alert("Entry Saved", isPresented: $showingSuccess) {
            Button("OK") {
                isPresented = false
            }
        } message: {
            Text("Your mood entry has been saved successfully.")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Mood Icon
            Image(systemName: DesignSystem.moodIconName(for: moodType))
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundColor(DesignSystem.moodIconColor(for: moodType))
                .subtleAppearance(delay: 0.1)
            
            // Title and Description
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(moodType.displayName)
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .subtleAppearance(delay: 0.2)
                
                Text("Share more about your day")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .multilineTextAlignment(.center)
                    .subtleAppearance(delay: 0.3)
            }
        }
    }
    
    // MARK: - Input Mode Selector
    private var inputModeSelector: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(InputMode.allCases, id: \.self) { mode in
                Button(action: {
                    HapticFeedback.light.trigger()
                    withAnimation(.moodayEase) {
                        selectedInputMode = mode
                    }
                }) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 14, weight: .light))
                        
                        Text(mode.rawValue)
                            .font(DesignSystem.Typography.bodyMedium)
                    }
                    .foregroundColor(selectedInputMode == mode ? .white : DesignSystem.Colors.secondary)
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.pill)
                            .fill(selectedInputMode == mode ? DesignSystem.Colors.accent : Color.clear)
                    )
                }
                .buttonStyle(CleanButtonStyle())
            }
            
            Spacer()
        }
        .subtleAppearance(delay: 0.4)
    }
    
    // MARK: - Input Section
    private var inputSection: some View {
        Group {
            if selectedInputMode == .text {
                textInputSection
            } else {
                audioInputSection
            }
        }
    }
    
    // MARK: - Text Input Section
    private var textInputSection: some View {
        CleanCard(padding: 0) {
            VStack(spacing: 0) {
                // Input Field
                TextField("How was your day?", text: $textEntry, axis: .vertical)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .padding(DesignSystem.Spacing.lg)
                    .lineLimit(8...12)
                    .textFieldStyle(PlainTextFieldStyle())
                
                // Character Count (if needed)
                if !textEntry.isEmpty {
                    HStack {
                        Spacer()
                        Text("\(textEntry.count) characters")
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(DesignSystem.Colors.secondary)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.md)
                }
            }
        }
        .subtleAppearance(delay: 0.5)
    }
    
    // MARK: - Audio Input Section
    private var audioInputSection: some View {
        CleanCard(padding: DesignSystem.Spacing.xl) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                // Audio Icon
                Image(systemName: "waveform.circle")
                    .font(.system(size: 64, weight: .ultraLight))
                    .foregroundColor(DesignSystem.Colors.accent)
                
                // Coming Soon Message
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text("Audio Recording")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text("Voice recording feature coming soon")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Placeholder Button
                Button(action: {
                    HapticFeedback.light.trigger()
                    // TODO: Implement audio recording
                }) {
                    Text("Start Recording")
                }
                .buttonStyle(CleanSecondaryButtonStyle(isEnabled: false))
            }
            .frame(minHeight: 200)
        }
        .subtleAppearance(delay: 0.5)
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Save Button
            Button(action: saveMoodEntry) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("Save Entry")
                        .font(DesignSystem.Typography.bodyMedium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .fill(
                            LinearGradient(
                                colors: [DesignSystem.Colors.success, DesignSystem.Colors.success.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            .buttonStyle(CleanCardButtonStyle())
            .disabled(selectedInputMode == .text && textEntry.isEmpty)
            .subtleAppearance(delay: 0.6)
            
            // Skip Button
            Button(action: skipEntry) {
                Text("Skip for now")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondary)
            }
            .buttonStyle(PlainButtonStyle())
            .subtleAppearance(delay: 0.7)
        }
    }
    
    // MARK: - Computed Properties
    private var moodColor: Color {
        DesignSystem.moodColor(for: moodType)
    }
    
    private var moodGradientColors: [Color] {
        return DesignSystem.moodGradientColors(for: moodType)
    }
    
    // MARK: - Actions
    private func saveMoodEntry() {
        HapticFeedback.medium.trigger()
        
        let finalText = selectedInputMode == .text && !textEntry.isEmpty ? textEntry : nil
        
        viewModel.saveMoodEntry(
            for: Date(),
            mood: moodType,
            text: finalText
        )
        
        withAnimation(.moodayEase) {
            showingSuccess = true
        }
    }
    
    private func skipEntry() {
        HapticFeedback.light.trigger()
        
        viewModel.saveMoodEntry(
            for: Date(),
            mood: moodType,
            text: nil
        )
        
        isPresented = false
    }
}

// MARK: - Legacy Components (Cleaned Up)
struct InputModeButton_Legacy: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let isEnabled: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: isEnabled ? action : {}) {
            VStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(iconColor)
                
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text(title)
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(titleColor)
                    
                    Text(subtitle)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .stroke(borderColor, lineWidth: isSelected ? 2 : 0)
                    )
                    .conditionalShadow(hasShadow: isSelected, colorScheme: colorScheme)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
    }
    
    private var backgroundColor: Color {
        if !isEnabled {
            return colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6)
        }
        return colorScheme == .dark ? Color(.systemGray5) : DesignSystem.Colors.cardBackground
    }
    
    private var borderColor: Color {
        isSelected ? DesignSystem.Colors.accent : .clear
    }
    
    private var iconColor: Color {
        if !isEnabled {
            return DesignSystem.Colors.secondary
        }
        return isSelected ? DesignSystem.Colors.accent : DesignSystem.Colors.primary
    }
    
    private var titleColor: Color {
        if !isEnabled {
            return DesignSystem.Colors.secondary
        }
        return isSelected ? DesignSystem.Colors.accent : DesignSystem.Colors.primary
    }
}

#Preview {
    TextOrAudioInputView(
        viewModel: MoodViewModel(),
        moodType: .good,
        isPresented: .constant(true)
    )
} 