import SwiftUI

struct AccessibilityHelpView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Header
                    headerSection
                    
                    // VoiceOver Guide
                    voiceOverSection
                    
                    // Voice Control Guide
                    voiceControlSection
                    
                    // Large Text Support
                    largeTextSection
                    
                    // Reduced Motion
                    reducedMotionSection
                    
                    // Getting Help
                    supportSection
                    
                    // Bottom spacing
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.top, DesignSystem.Spacing.lg)
            }
            .background(DesignSystem.Colors.surface)
            .navigationTitle("Accessibility Guide")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        HapticFeedback.light.trigger()
                        dismiss()
                    }
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.accent)
                    .accessibilityLabel("Close accessibility guide")
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Accessibility guide for Moodae")
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        CleanCard(padding: DesignSystem.Spacing.lg) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    Image(systemName: "accessibility")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(DesignSystem.Colors.accent)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Accessibility in Moodae")
                            .font(DesignSystem.Typography.title2)
                            .foregroundColor(DesignSystem.Colors.primary)
                            .accessibilityAddTraits(.isHeader)
                        
                        Text("Designed for everyone")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.secondary)
                    }
                }
                
                Text("Moodae is built with accessibility in mind. This guide helps you get the most out of the app using assistive technologies.")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .lineSpacing(2)
                    .accessibilityLabel("Moodae is built with accessibility in mind. This guide helps you get the most out of the app using assistive technologies.")
            }
        }
        .subtleAppearance(delay: 0.1)
    }
    
    // MARK: - VoiceOver Section
    private var voiceOverSection: some View {
        accessibilitySection(
            icon: "speaker.wave.3.fill",
            iconColor: DesignSystem.Colors.success,
            title: "VoiceOver Support",
            description: "Navigate Moodae seamlessly with VoiceOver's spoken feedback.",
            tips: [
                "Swipe right to move to the next element, left to go back",
                "Double-tap to activate buttons and mood selection cards",
                "Use the rotor to navigate by headings for quick section jumping",
                "All mood entries include descriptive labels with date and mood level",
                "Category selection announces available options clearly",
                "Voice recordings and text entries are properly labeled"
            ],
            delay: 0.2
        )
    }
    
    // MARK: - Voice Control Section
    private var voiceControlSection: some View {
        accessibilitySection(
            icon: "mic.fill",
            iconColor: DesignSystem.Colors.info,
            title: "Voice Control",
            description: "Control Moodae entirely with your voice using natural commands.",
            tips: [
                "Say \"Add mood entry\" to create a new mood entry",
                "Say \"Good day button\" or \"Difficult day button\" to select mood",
                "Say \"Save mood entry\" to complete your entry",
                "Say \"Timeline tab\" or \"Insights tab\" to navigate",
                "Use \"Show numbers\" to see numbered overlays for all controls",
                "All interactive elements have voice-friendly names"
            ],
            delay: 0.3
        )
    }
    
    // MARK: - Large Text Section
    private var largeTextSection: some View {
        accessibilitySection(
            icon: "textformat.size",
            iconColor: DesignSystem.Colors.warning,
            title: "Dynamic Type Support",
            description: "Moodae automatically adjusts to your preferred text size.",
            tips: [
                "All text scales with your iOS text size preferences",
                "Supports accessibility text sizes (larger than system maximum)",
                "Additional app-specific text scaling available in Moodae settings",
                "Override system text size for personal preference (80% to 160%)",
                "Button labels remain readable at all text sizes",
                "Icons and layout adapt to accommodate larger text",
                "Go to Settings → Display & Brightness → Text Size for system-wide adjustment",
                "Layout automatically reflows for optimal reading"
            ],
            delay: 0.4
        )
    }
    
    // MARK: - Reduced Motion Section
    private var reducedMotionSection: some View {
        accessibilitySection(
            icon: "tortoise.fill",
            iconColor: DesignSystem.Colors.secondary,
            title: "Reduced Motion",
            description: "Comfortable experience for users sensitive to motion.",
            tips: [
                "Moodae respects your iOS Reduce Motion setting",
                "Animations are minimized or removed when enabled",
                "Content appears instantly instead of sliding in",
                "Tab switching is immediate without transitions",
                "Enable in Settings → Accessibility → Motion → Reduce Motion",
                "App-specific reduce animations toggle available in Moodae settings"
            ],
            delay: 0.5
        )
    }
    
    // MARK: - Support Section
    private var supportSection: some View {
        CleanCard(padding: DesignSystem.Spacing.lg) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(DesignSystem.Colors.accent)
                    
                    Text("Need More Help?")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.primary)
                        .accessibilityAddTraits(.isHeader)
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("If you encounter any accessibility issues or have suggestions for improvement:")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        supportPoint("Email us at feedback@moodae.app")
                        supportPoint("Visit iOS Settings → Accessibility for system-wide options")
                        supportPoint("Check Apple's Accessibility documentation for device help")
                    }
                }
            }
        }
        .subtleAppearance(delay: 0.6)
    }
    
    // MARK: - Helper Views
    private func accessibilitySection(
        icon: String,
        iconColor: Color,
        title: String,
        description: String,
        tips: [String],
        delay: Double
    ) -> some View {
        CleanCard(padding: DesignSystem.Spacing.lg) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                // Header
                HStack(spacing: DesignSystem.Spacing.md) {
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(iconColor)
                    
                    Text(title)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.primary)
                        .accessibilityAddTraits(.isHeader)
                }
                
                // Description
                Text(description)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .lineSpacing(2)
                
                // Tips
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    ForEach(Array(tips.enumerated()), id: \.offset) { index, tip in
                        tipRow(tip)
                    }
                }
            }
        }
        .subtleAppearance(delay: delay)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(title) section")
    }
    
    private func tipRow(_ tip: String) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
            Circle()
                .fill(DesignSystem.Colors.accent)
                .frame(width: 6, height: 6)
                .padding(.top, 7) // Align with text baseline
            
            Text(tip)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.primary)
                .lineSpacing(2)
                .accessibilityLabel(tip)
        }
    }
    
    private func supportPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "arrow.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DesignSystem.Colors.accent)
                .padding(.top, 4)
            
            Text(text)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.secondary)
                .lineSpacing(2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }
}

#Preview {
    AccessibilityHelpView()
} 