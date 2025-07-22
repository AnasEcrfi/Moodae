import SwiftUI

struct AccessibilitySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var highContrastEnabled = UserDefaults.standard.object(forKey: "highContrastEnabled") as? Bool ?? false
    @State private var reduceAnimationsEnabled = UserDefaults.standard.object(forKey: "reduceAnimationsEnabled") as? Bool ?? false
    @State private var customTextSizeEnabled = UserDefaults.standard.object(forKey: "customTextSizeEnabled") as? Bool ?? false
    @State private var customTextSize = UserDefaults.standard.object(forKey: "customTextSize") as? Double ?? 1.0
    @State private var showingAccessibilityHelp = false
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.surface.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        // App Settings Section
                        appSettingsSection
                        
                        // System Status Section
                        systemStatusSection
                        
                        // Help Section
                        helpSection
                        
                        // Bottom spacing
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.top, DesignSystem.Spacing.lg)
                }
            }
            .navigationTitle("Accessibility")
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
        .sheet(isPresented: $showingAccessibilityHelp) {
            AccessibilityHelpView()
        }
        .onChange(of: highContrastEnabled) {
            UserDefaults.standard.set(highContrastEnabled, forKey: "highContrastEnabled")
        }
        .onChange(of: reduceAnimationsEnabled) {
            UserDefaults.standard.set(reduceAnimationsEnabled, forKey: "reduceAnimationsEnabled")
        }
        .onChange(of: customTextSizeEnabled) {
            UserDefaults.standard.setTextSizeEnabled(customTextSizeEnabled)
        }
        .onChange(of: customTextSize) {
            UserDefaults.standard.setTextSize(customTextSize)
        }
        .withAppTextScaling()
    }
    
    // MARK: - App Settings Section
    private var appSettingsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            CleanSectionHeader("App Settings")
            
            CleanCard(padding: 0) {
                VStack(spacing: 0) {
                    // High Contrast Mode
                    settingsToggleRow(
                        icon: "circle.hexagongrid.circle.fill",
                        iconColor: DesignSystem.Colors.info,
                        title: "High Contrast",
                        subtitle: "Increase color contrast for better visibility",
                        isOn: $highContrastEnabled
                    )
                    
                    Divider()
                        .background(DesignSystem.Colors.secondary.opacity(0.3))
                        .padding(.leading, 56)
                    
                    // Reduce Animations
                    settingsToggleRow(
                        icon: "slowmo",
                        iconColor: DesignSystem.Colors.warning,
                        title: "Reduce Animations",
                        subtitle: "Minimize motion and transitions",
                        isOn: $reduceAnimationsEnabled
                    )
                    
                    Divider()
                        .background(DesignSystem.Colors.secondary.opacity(0.3))
                        .padding(.leading, 56)
                    
                    // Custom Text Size
                    VStack(spacing: 0) {
                        settingsToggleRow(
                            icon: "textformat.size.larger",
                            iconColor: DesignSystem.Colors.accent,
                            title: "App Text Size",
                            subtitle: "Override system text size within Moodae",
                            isOn: $customTextSizeEnabled
                        )
                        
                        if customTextSizeEnabled {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                                HStack {
                                    Text("Size: \(Int(customTextSize * 100))%")
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(DesignSystem.Colors.secondary)
                                    
                                    Spacer()
                                    
                                    Text("Sample Text")
                                        .font(.body)
                                        .foregroundColor(DesignSystem.Colors.primary)
                                        .environment(\.sizeCategory, calculatePreviewSizeCategory(from: customTextSize))
                                }
                                
                                Slider(value: $customTextSize, in: 0.8...1.6, step: 0.1)
                                    .accentColor(DesignSystem.Colors.accent)
                                
                                HStack {
                                    Text("Small")
                                        .font(DesignSystem.Typography.caption2)
                                        .foregroundColor(DesignSystem.Colors.secondary)
                                    
                                    Spacer()
                                    
                                    Text("Large")
                                        .font(DesignSystem.Typography.caption2)
                                        .foregroundColor(DesignSystem.Colors.secondary)
                                }
                            }
                            .padding(.horizontal, DesignSystem.Spacing.lg)
                            .padding(.bottom, DesignSystem.Spacing.md)
                        }
                    }
                }
            }
        }
        .subtleAppearance(delay: 0.1)
    }
    
    // MARK: - System Status Section
    private var systemStatusSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            CleanSectionHeader("System Status")
            
            CleanCard(padding: 0) {
                VStack(spacing: 0) {
                    // VoiceOver Status
                    accessibilityStatusRow(
                        icon: "speaker.wave.3.fill",
                        iconColor: UIAccessibility.isVoiceOverRunning ? DesignSystem.Colors.success : DesignSystem.Colors.secondary,
                        title: "VoiceOver",
                        subtitle: UIAccessibility.isVoiceOverRunning ? "Active" : "Inactive",
                        status: UIAccessibility.isVoiceOverRunning
                    )
                    
                    Divider()
                        .background(DesignSystem.Colors.secondary.opacity(0.3))
                        .padding(.leading, 56)
                    
                    // Large Text Status
                    accessibilityStatusRow(
                        icon: "textformat.size",
                        iconColor: UIContentSizeCategory.isAccessibilityCategory ? DesignSystem.Colors.success : DesignSystem.Colors.secondary,
                        title: "Large Text",
                        subtitle: UIContentSizeCategory.isAccessibilityCategory ? "Accessibility size" : "Standard size",
                        status: UIContentSizeCategory.isAccessibilityCategory
                    )
                    
                    Divider()
                        .background(DesignSystem.Colors.secondary.opacity(0.3))
                        .padding(.leading, 56)
                    
                    // Reduce Motion Status
                    accessibilityStatusRow(
                        icon: "tortoise.fill",
                        iconColor: UIAccessibility.isReduceMotionEnabled ? DesignSystem.Colors.success : DesignSystem.Colors.secondary,
                        title: "Reduce Motion",
                        subtitle: UIAccessibility.isReduceMotionEnabled ? "System enabled" : "System disabled",
                        status: UIAccessibility.isReduceMotionEnabled
                    )
                }
            }
        }
        .subtleAppearance(delay: 0.2)
    }
    
    // MARK: - Help Section
    private var helpSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            CleanSectionHeader("Help & Guidance")
            
            CleanCard(padding: 0) {
                settingsRow(
                    icon: "questionmark.circle.fill",
                    iconColor: DesignSystem.Colors.accent,
                    title: "Accessibility Guide",
                    subtitle: "Learn how to use Moodae with assistive technologies",
                    showChevron: true,
                    action: { showingAccessibilityHelp = true }
                )
            }
        }
        .subtleAppearance(delay: 0.3)
    }
    
    // MARK: - Helper Functions
    private func calculatePreviewSizeCategory(from scale: Double) -> ContentSizeCategory {
        switch scale {
        case ...0.85: return .small
        case 0.85...0.95: return .medium
        case 0.95...1.05: return .large
        case 1.05...1.15: return .extraLarge
        case 1.15...1.25: return .extraExtraLarge
        case 1.25...1.35: return .extraExtraExtraLarge
        case 1.35...1.45: return .accessibilityMedium
        case 1.45...1.55: return .accessibilityLarge
        case 1.55...: return .accessibilityExtraLarge
        default: return .large
        }
    }
    
    // MARK: - Settings Components (matching SettingsView style)
    private func settingsToggleRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            settingsIconView(icon: icon, color: iconColor)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text(subtitle)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(DesignSystem.Colors.accent)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.md)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(subtitle)")
        .accessibilityHint("Double tap to toggle")
    }
    
    private func settingsRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        showChevron: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            HapticFeedback.light.trigger()
            action()
        }) {
            HStack(spacing: DesignSystem.Spacing.md) {
                settingsIconView(icon: icon, color: iconColor)
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(title)
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text(subtitle)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondary)
                }
                
                Spacer()
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(DesignSystem.Colors.secondary)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(subtitle)")
        .accessibilityHint("Double tap to open")
    }
    
    private func settingsIconView(icon: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(color)
                .frame(width: 28, height: 28)
            
            Image(systemName: icon)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.white)
        }
    }
    
    private func accessibilityStatusRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        status: Bool
    ) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            settingsIconView(icon: icon, color: iconColor)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text(subtitle)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 6) {
                Circle()
                    .fill(status ? DesignSystem.Colors.success : DesignSystem.Colors.secondary.opacity(0.5))
                    .frame(width: 8, height: 8)
                
                Text(status ? "ON" : "OFF")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(status ? DesignSystem.Colors.success : DesignSystem.Colors.secondary)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.md)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(subtitle)")
        .accessibilityHint("This shows the current system accessibility setting status")
    }
}

#Preview {
    AccessibilitySettingsView()
} 