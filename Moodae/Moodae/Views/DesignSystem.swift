//
//  DesignSystem.swift
//  Mooday
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI



// MARK: - Mooday Design System

struct DesignSystem {
    
    // MARK: - Colors
    struct Colors {
        // High Contrast Support
        private static var isHighContrastEnabled: Bool {
            UserDefaults.standard.bool(forKey: "highContrastEnabled")
        }
        
        // MARK: - Semantic Colors (Fully adaptive)
        static var primary: Color {
            isHighContrastEnabled ? Color(.label) : Color.primary
        }
        
        static var secondary: Color {
            isHighContrastEnabled ? Color(.secondaryLabel) : Color.secondary
        }
        
        static let tertiary = Color(.tertiaryLabel)
        
        // MARK: - Background Colors (Adaptive for Dark Mode)
        static let surface = Color(.systemBackground)
        static let cardBackground = Color(.secondarySystemBackground)
        static let groupedBackground = Color(.systemGroupedBackground)
        static let surfaceSecondary = Color(.tertiarySystemBackground)
        
        // MARK: - Adaptive Brand Colors
        static let accent = Color("AccentColor") // Will use adaptive Asset Colors if available
        
        // Fallback CI colors for manual implementation
        static let accentLight = Color(red: 158/255, green: 151/255, blue: 146/255) // Original CI #9E9792
        static let accentDark = Color(red: 178/255, green: 171/255, blue: 166/255)  // Lighter for dark mode
        
        // MARK: - 6-Stufen Mood Colors (Adaptive für Dark Mode)
        
        // POSITIVE GRADIENT (4.0-6.0)
        static let amazingMood: Color = {
            Color(.systemGreen) // Intensives Grün - großartige Tage
        }()
        
        static let goodMood: Color = {
            Color(red: 0.3, green: 0.7, blue: 0.4) // Mittleres Grün - gute Tage
        }()
        
        static let okayMood: Color = {
            Color(.systemYellow) // Gelb-Grün - okay Tage
        }()
        
        // DIFFICULT GRADIENT (1.0-3.0)
        static let challengingMood: Color = {
            Color(.systemOrange) // Orange - herausfordernde Tage
        }()
        
        static let toughMood: Color = {
            Color(red: 0.9, green: 0.5, blue: 0.2) // Orange-Rot - schwere Tage
        }()
        
        static let overwhelmingMood: Color = {
            Color(.systemRed) // Intensives Rot - überwältigende Tage
        }()
        
        // LEGACY SUPPORT (für alte Referenzen)
        static let badMood: Color = {
            challengingMood // Mappt auf challenging
        }()
        
        static let neutralMood = Color(.secondaryLabel)
        
        // MARK: - Mood Icon Colors (Adaptive)
        static let goodMoodIcon: Color = {
            Color(.systemYellow) // Sun icon - adapts to dark mode
        }()
        
        static let badMoodIcon: Color = {
            Color(.systemBlue) // Rain/cloud icon - adapts to dark mode
        }()
        
        // MARK: - Mood Background Colors (Adaptive)
        static var goodMoodBackground: Color {
            goodMood.opacity(0.15)
        }
        
        static var badMoodBackground: Color {
            challengingMood.opacity(0.15)
        }
        
        // MARK: - Mood Gradient Colors (Adaptive)
        static var goodMoodGradient: [Color] {
            [goodMood, goodMood.opacity(0.8)]
        }
        
        static var badMoodGradient: [Color] {
            [challengingMood, challengingMood.opacity(0.8)]
        }
        
        // MARK: - Functional Colors (Adaptive)
        static let success = Color(.systemGreen)
        static let warning = Color(.systemOrange)
        static let error = Color(.systemRed)
        static let info = Color(.systemBlue)
        
        // MARK: - Gradient Colors (Adaptive)
        static var gradientStart: Color {
            Color.primary.opacity(0.05)
        }
        
        static var gradientEnd: Color {
            Color.primary.opacity(0.02)
        }
        
        // MARK: - Shadow Colors (Adaptive)
        static var lightShadow: Color {
            Color(.systemGray).opacity(0.2)
        }
        
        static var mediumShadow: Color {
            Color(.systemGray).opacity(0.3)
        }
        
        static var darkShadow: Color {
            Color(.systemGray).opacity(0.1)
        }
        
        // MARK: - Separator Colors (Adaptive)
        static let separator = Color(.separator)
        static let separatorOpaque = Color(.opaqueSeparator)
    }
    
    // MARK: - Typography with Dynamic Type Support + Global Environment Scaling
    struct Typography {
        // Headers with Dynamic Type (automatically scaled via environment)
        static var largeTitle: Font {
            Font.largeTitle.weight(.light)
        }
        
        static var title: Font {
            Font.title.weight(.medium)
        }
        
        static var title2: Font {
            Font.title2.weight(.medium)
        }
        
        static var headline: Font {
            Font.headline.weight(.semibold)
        }
        
        // Body text with Dynamic Type (automatically scaled via environment)
        static var body: Font {
            Font.body.weight(.regular)
        }
        
        static var bodyMedium: Font {
            Font.body.weight(.medium)
        }
        
        static var bodyBold: Font {
            Font.body.weight(.bold)
        }
        
        // Supporting text with Dynamic Type (automatically scaled via environment)
        static var callout: Font {
            Font.callout.weight(.regular)
        }
        
        static var subheadline: Font {
            Font.subheadline.weight(.regular)
        }
        
        static var footnote: Font {
            Font.footnote.weight(.regular)
        }
        
        static var caption: Font {
            Font.caption.weight(.regular)
        }
        
        static var caption2: Font {
            Font.caption2.weight(.regular)
        }
        
        // ZUSÄTZLICHE FONT VARIANTE
        static var small: Font {
            Font.caption.weight(.medium)
        }
        
        // Custom styles with accessibility support
        static func customTitle(size: CGFloat) -> Font {
            Font.system(size: size, weight: .light, design: .default)
        }
        
        static func accessibleBody(weight: Font.Weight = .regular) -> Font {
            Font.body.weight(weight)
        }
    }
    
    // MARK: - Spacing (Generous but Clean)
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }
    
    // MARK: - Corner Radius (Subtle Rounding)
    struct CornerRadius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let pill: CGFloat = 50
    }
    
    // MARK: - Shadows (Adaptive for Dark Mode)
    struct Shadow {
        static var light: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
            (color: Colors.lightShadow, radius: 4.0, x: 0.0, y: 2.0)
        }
        
        static var medium: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
            (color: Colors.mediumShadow, radius: 8.0, x: 0.0, y: 4.0)
        }
        
        static var heavy: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
            (color: Colors.mediumShadow, radius: 12.0, x: 0.0, y: 6.0)
        }
    }
    
    // MARK: - 6-Stufen Mood Helper Methods
    static func moodColor(for mood: MoodType) -> Color {
        switch mood {
        // Harmonische Farbfamilien - Cool-to-Warm Progression
        case .amazing: return Color(red: 0.20, green: 0.78, blue: 0.55)    // Helles Mint-Grün
        case .good: return Color(red: 0.15, green: 0.68, blue: 0.48)       // Mittleres Türkis  
        case .okay: return Color(red: 0.45, green: 0.55, blue: 0.60)       // Neutrales Blau-Grau
        case .challenging: return Color(red: 0.85, green: 0.65, blue: 0.35) // Sanftes Bernstein
        case .tough: return Color(red: 0.75, green: 0.50, blue: 0.30)      // Mittleres Bronze
        case .overwhelming: return Color(red: 0.65, green: 0.35, blue: 0.25) // Dunkles Terracotta
        }
    }
    
    // NEUE METHODE: Mood Color für einfache good/bad Kategorien (Legacy Support)
    static func moodColor(isGood: Bool) -> Color {
        return isGood ? moodColor(for: .good) : moodColor(for: .challenging)
    }
    
    static func moodIconColor(for mood: MoodType) -> Color {
        switch mood {
        // Harmonische Monochrome Palette - Grün-Blau Basis mit verschiedenen Sättigungen
        case .amazing: return Color(red: 0.20, green: 0.78, blue: 0.55)    // Helles Mint-Grün
        case .good: return Color(red: 0.15, green: 0.68, blue: 0.48)       // Mittleres Türkis  
        case .okay: return Color(red: 0.45, green: 0.55, blue: 0.60)       // Neutrales Blau-Grau
        // Harmonische warme Palette - Orange-Rot Basis mit verschiedenen Sättigungen
        case .challenging: return Color(red: 0.85, green: 0.65, blue: 0.35) // Sanftes Bernstein
        case .tough: return Color(red: 0.75, green: 0.50, blue: 0.30)      // Mittleres Bronze
        case .overwhelming: return Color(red: 0.65, green: 0.35, blue: 0.25) // Dunkles Terracotta
        }
    }
    
    static func moodIconName(for mood: MoodType, filled: Bool = false) -> String {
        let iconName = mood.icon
        return filled ? iconName : iconName.replacingOccurrences(of: ".fill", with: "")
    }
    
    static func moodGradientColors(for mood: MoodType) -> [Color] {
        let baseColor = moodColor(for: mood)
        return [baseColor, baseColor.opacity(0.8)]
    }
    
    // MARK: - Adaptive Color Helpers
    static func adaptiveAccentColor(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark ? Colors.accentDark : Colors.accentLight
    }
}

// MARK: - Card Sizing System (Central Control)
extension DesignSystem {
    struct CardSizing {
        // Standard Card Types
        static let compact = CardSize(padding: Spacing.md, verticalPadding: Spacing.lg) // Timeline, Stats
        static let comfortable = CardSize(padding: Spacing.lg, verticalPadding: Spacing.xl) // Mood Cards, Insights
        static let spacious = CardSize(padding: Spacing.xl, verticalPadding: Spacing.xxl) // Special Cards
        
        struct CardSize {
            let padding: CGFloat
            let verticalPadding: CGFloat
        }
    }
}

// MARK: - Modern Clean Card Component (Updated)
struct CleanCard<Content: View>: View {
    let content: Content
    let cardSize: DesignSystem.CardSizing.CardSize
    let cornerRadius: CGFloat
    let hasShadow: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    init(
        cardSize: DesignSystem.CardSizing.CardSize = DesignSystem.CardSizing.compact,
        cornerRadius: CGFloat = DesignSystem.CornerRadius.lg,
        hasShadow: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.cardSize = cardSize
        self.cornerRadius = cornerRadius
        self.hasShadow = hasShadow
    }
    
    // Legacy init for backward compatibility
    init(
        padding: CGFloat = DesignSystem.Spacing.md,
        cornerRadius: CGFloat = DesignSystem.CornerRadius.lg,
        hasShadow: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.cardSize = DesignSystem.CardSizing.CardSize(padding: padding, verticalPadding: padding)
        self.cornerRadius = cornerRadius
        self.hasShadow = hasShadow
    }
    
    var body: some View {
        content
            .padding(.horizontal, cardSize.padding)
            .padding(.vertical, cardSize.verticalPadding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(DesignSystem.Colors.cardBackground)
                    .conditionalShadow(hasShadow: hasShadow, colorScheme: colorScheme)
            )
    }
}

// MARK: - Modern Button Styles (Subtle & Clean)
struct CleanPrimaryButtonStyle: ButtonStyle {
    let isEnabled: Bool
    
    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.bodyMedium)
            .foregroundColor(.white)
            .padding(.vertical, DesignSystem.Spacing.md)
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(isEnabled ? DesignSystem.Colors.accent : DesignSystem.Colors.secondary)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
            .disabled(!isEnabled)
    }
}

struct CleanSecondaryButtonStyle: ButtonStyle {
    let isEnabled: Bool
    
    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.bodyMedium)
            .foregroundColor(isEnabled ? DesignSystem.Colors.accent : DesignSystem.Colors.secondary)
            .padding(.vertical, DesignSystem.Spacing.md)
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(DesignSystem.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .stroke(isEnabled ? DesignSystem.Colors.accent : DesignSystem.Colors.secondary, lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
            .disabled(!isEnabled)
    }
}

struct CleanCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Clean Mood Card (Minimalist)
struct CleanMoodCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    let moodType: MoodType?
    let useAnimatedIcon: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    init(title: String, subtitle: String, icon: String, color: Color, action: @escaping () -> Void, moodType: MoodType? = nil, useAnimatedIcon: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.action = action
        self.moodType = moodType
        self.useAnimatedIcon = useAnimatedIcon
    }
    
    var body: some View {
        Button(action: {
            HapticFeedback.light.trigger()
            action()
        }) {
            VStack(spacing: DesignSystem.Spacing.md) {
                // Icon (Animated Weather or Static)
                Group {
                    if useAnimatedIcon, let mood = moodType {
                        AnimatedWeatherMoodIcon(mood: mood, size: 28)
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 28, weight: .light))
                            .foregroundColor(useAnimatedIcon ? DesignSystem.weatherIconColor(for: moodType ?? .good) : color)
                    }
                }
                
                // Text Content - Kompakter und strukturierter
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(DesignSystem.Colors.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 120)  // Feste Mindesthöhe für Konsistenz
            .padding(.vertical, DesignSystem.Spacing.lg)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(DesignSystem.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .stroke(DesignSystem.Colors.separator.opacity(0.1), lineWidth: 0.5)
                    )
                    .conditionalShadow(hasShadow: false, colorScheme: colorScheme)
            )
        }
        .buttonStyle(CleanCardButtonStyle())
    }
    
    // MARK: - Helper Functions
    private func weatherIconColor(for moodType: MoodType?) -> Color {
        guard let mood = moodType else { return color }
        switch mood.mainCategory {
        case .positive:
            return .yellow
        case .difficult:
            return Color(red: 0.4, green: 0.5, blue: 0.6) // Same blue-gray as AnimatedWeatherMoodIcon
        }
    }
}

// MARK: - Global Weather Icon Colors
extension DesignSystem {
    /// Zentrale Funktion für konsistente Wetter-Icon-Farben
    static func weatherIconColor(for moodType: MoodType) -> Color {
        switch moodType.mainCategory {
        case .positive:
            return .yellow
        case .difficult:
            return Color(red: 0.4, green: 0.5, blue: 0.6) // Same blue-gray as AnimatedWeatherMoodIcon
        }
    }
    
    /// Wetter-Icon-Farbe für einfache good/bad Kategorien
    static func weatherIconColor(isGood: Bool) -> Color {
        return isGood ? .yellow : Color(red: 0.4, green: 0.5, blue: 0.6)
    }
}

// MARK: - Clean Insight Card (Same size as Mood Cards)
struct CleanInsightCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20, weight: .light))
                .foregroundColor(iconColor)
                .frame(width: 32)
            
            // Content
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text(description)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xl)
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .fill(DesignSystem.Colors.cardBackground)
                .conditionalShadow(hasShadow: true, colorScheme: colorScheme)
        )
    }
}

// MARK: - Clean Section Header
struct CleanSectionHeader: View {
    let title: String
    let subtitle: String?
    let action: (() -> Void)?
    let actionTitle: String?
    
    init(
        _ title: String,
        subtitle: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                                            .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.primary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondary)
                }
            }
            
            Spacer()
            
            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.accent)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.sm)
    }
}

// MARK: - Clean Empty State
struct CleanEmptyState: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        subtitle: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            // Clean Icon
            Image(systemName: icon)
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundColor(DesignSystem.Colors.secondary)
            
            // Text Content
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(title)
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.xl)
            }
            
            // Optional Action Button
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                }
                .buttonStyle(CleanSecondaryButtonStyle())
                .padding(.top, DesignSystem.Spacing.sm)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.xxxl)
    }
}

// MARK: - Clean Stats Card
struct CleanStatsCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        CleanCard(cardSize: DesignSystem.CardSizing.compact) {
            VStack(spacing: DesignSystem.Spacing.md) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(color)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(value)
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text(title)
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text(subtitle)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - Helper Extensions
extension View {
    @ViewBuilder
    func conditionalShadow(hasShadow: Bool, colorScheme: ColorScheme) -> some View {
        if hasShadow {
            let shadow = DesignSystem.Shadow.light
            self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
        } else {
            self
        }
    }
}

// MARK: - View Extensions for Adaptive Colors
extension View {
    func adaptiveAccentForeground() -> some View {
        self.foregroundColor(DesignSystem.Colors.accent)
    }
    
    func adaptiveAccentBackground() -> some View {
        self.background(DesignSystem.Colors.accent)
    }
}

// Note: HapticFeedback is defined in AnimationExtensions.swift 