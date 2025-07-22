import SwiftUI

/// Zentrale View für einheitliche Mood-Auswahl
/// Kann sowohl 2-stufige Auswahl (kategoriebasiert) als auch direkte 6-Mood-Auswahl zeigen
/// Wird in CustomTabBarView, TimelineView, DateSelectableMoodInputView etc. verwendet
struct MoodCategorySelectionView: View {
    let title: String
    let subtitle: String?
    let selectedDate: Date?
    let onMoodSelected: (MoodType) -> Void
    let onDismiss: () -> Void
    let onDateTapped: (() -> Void)?
    let showAllMoods: Bool // Neuer Parameter für direkte 6-Mood-Anzeige
    
    @State private var showingSubcategories: MainMoodCategory?
    
    init(
        title: String = "How was your day?",
        subtitle: String? = nil,
        selectedDate: Date? = nil,
        onMoodSelected: @escaping (MoodType) -> Void,
        onDismiss: @escaping () -> Void,
        onDateTapped: (() -> Void)? = nil,
        showAllMoods: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self.selectedDate = selectedDate
        self.onMoodSelected = onMoodSelected
        self.onDismiss = onDismiss
        self.onDateTapped = onDateTapped
        self.showAllMoods = showAllMoods
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            // Header
            headerSection
            
            // Mood Selection basierend auf showAllMoods Parameter
            if showAllMoods {
                allMoodsSection
            } else {
                mainCardsSection
            }
            
            // Optional Date Info
            if let date = selectedDate, !Calendar.current.isDateInToday(date) {
                dateInfoSection(for: date)
            }
            
            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.top, DesignSystem.Spacing.xl)
        .background(DesignSystem.Colors.surface)
        .sheet(item: $showingSubcategories) { category in
            // Nur bei 2-stufiger Auswahl (wenn showAllMoods = false)
            if !showAllMoods {
                MoodSubcategorySelectionView(
                    category: category,
                    onMoodSelected: { mood in
                        showingSubcategories = nil
                        onMoodSelected(mood)
                    },
                    onDismiss: {
                        showingSubcategories = nil
                    }
                )
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Text(title)
                .font(.system(size: 32, weight: .light))
                .foregroundColor(DesignSystem.Colors.primary)
                .multilineTextAlignment(.center)
                .subtleAppearance(delay: 0.1)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .multilineTextAlignment(.center)
                    .subtleAppearance(delay: 0.2)
            }
            
            // Prominent Date Display
            prominentDateSection
        }
    }
    
    // MARK: - Prominent Date Section
    private var prominentDateSection: some View {
        Button(action: {
            onDateTapped?()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 16, weight: .medium))
                
                Text(currentDateString)
                    .font(.system(size: 18, weight: .medium))
                
                if onDateTapped != nil {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                }
            }
            .foregroundColor(DesignSystem.Colors.accent)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(DesignSystem.Colors.accent.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(DesignSystem.Colors.accent.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(onDateTapped == nil)
        .subtleAppearance(delay: 0.25)
    }
    
    // MARK: - Current Date String
    private var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: selectedDate ?? Date())
    }
    
    // MARK: - All Moods Section (Direkte 6-Mood-Auswahl)
    private var allMoodsSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Positive Moods
            VStack(spacing: DesignSystem.Spacing.md) {
                HStack {
                    Text("Good Days")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.primary)
                    Spacer()
                }
                .padding(.horizontal, 4)
                
                VStack(spacing: DesignSystem.Spacing.sm) {
                    moodCard(for: .amazing, delay: 0.3)
                    moodCard(for: .good, delay: 0.35)
                    moodCard(for: .okay, delay: 0.4)
                }
            }
            
            // Difficult Moods
            VStack(spacing: DesignSystem.Spacing.md) {
                HStack {
                    Text("Difficult Days")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.primary)
                    Spacer()
                }
                .padding(.horizontal, 4)
                
                VStack(spacing: DesignSystem.Spacing.sm) {
                    moodCard(for: .challenging, delay: 0.45)
                    moodCard(for: .tough, delay: 0.5)
                    moodCard(for: .overwhelming, delay: 0.55)
                }
            }
        }
    }
    
    // MARK: - Main Cards Section (2-stufige Auswahl)
    private var mainCardsSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Good Day Card
            CleanMoodCard(
                title: "Good Day",
                subtitle: "Share positive moments",
                icon: "sun.max",
                color: DesignSystem.Colors.accent,
                action: { 
                    HapticFeedback.medium.trigger()
                    showingSubcategories = .positive 
                },
                moodType: .good,
                useAnimatedIcon: true
            )
            .subtleAppearance(delay: 0.3)
            
            // Difficult Day Card
            CleanMoodCard(
                title: "Difficult Day",
                subtitle: "Express your challenges",
                icon: "cloud.rain",
                color: DesignSystem.Colors.secondary,
                action: { 
                    HapticFeedback.medium.trigger()
                    showingSubcategories = .difficult 
                },
                moodType: .challenging,
                useAnimatedIcon: true
            )
            .subtleAppearance(delay: 0.4)
        }
    }
    
    // MARK: - Helper Methods
    private func moodCard(for mood: MoodType, delay: Double) -> some View {
        Button(action: {
            HapticFeedback.medium.trigger()
            onMoodSelected(mood)
        }) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Mood Icon
                Image(systemName: mood.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(DesignSystem.moodColor(for: mood))
                    .frame(width: 40, height: 40)
                
                // Mood Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(mood.displayName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text(moodDescription(for: mood))
                        .font(.system(size: 14))
                        .foregroundColor(DesignSystem.Colors.secondary)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.tertiary)
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(DesignSystem.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(DesignSystem.Colors.separator, lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .subtleAppearance(delay: delay)
    }
    
    private func moodDescription(for mood: MoodType) -> String {
        switch mood {
        case .amazing:
            return "Exceptional and joyful"
        case .good:
            return "Positive and content"
        case .okay:
            return "Balanced and neutral"
        case .challenging:
            return "Somewhat difficult"
        case .tough:
            return "Quite challenging"
        case .overwhelming:
            return "Very difficult"
        }
    }
    
    // MARK: - Date Info Section
    private func dateInfoSection(for date: Date) -> some View {
        HStack {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 14))
                .foregroundColor(DesignSystem.Colors.accent)
            
            Text("Adding entry for \(DateFormatter.dayMonth.string(from: date))")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(DesignSystem.Colors.accent)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(DesignSystem.Colors.accent.opacity(0.1))
                .overlay(
                    Capsule()
                        .stroke(DesignSystem.Colors.accent.opacity(0.3), lineWidth: 1)
                )
        )
        .subtleAppearance(delay: 0.5)
    }
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let dayMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
}

#Preview {
    NavigationView {
        MoodCategorySelectionView(
            title: "How was your day?",
            subtitle: "Track your daily mood",
            onMoodSelected: { mood in
                print("Selected: \(mood)")
            },
            onDismiss: {
                print("Dismissed")
            }
        )
    }
} 