import SwiftUI

struct MoodSubcategorySelectionView: View {
    let category: MainMoodCategory
    let onMoodSelected: (MoodType) -> Void
    let onDismiss: () -> Void
    
    private var moods: [MoodType] {
        switch category {
        case .positive:
            return [.amazing, .good, .okay]
        case .difficult:
            return [.overwhelming, .tough, .challenging]
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                // Header
                headerSection
                
                // Mood Options
                moodOptionsSection
                
                Spacer()
            }
            .padding(DesignSystem.Spacing.lg)
            .background(DesignSystem.Colors.surface)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        HapticFeedback.light.trigger()
                        onDismiss()
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
            // Category Icon (Animated Weather Icon)
            AnimatedWeatherMoodIcon(
                mood: category == .positive ? .good : .challenging, 
                size: 48
            )
            .subtleAppearance(delay: 0.1)
            
            // Title & Description
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(category.displayName)
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .subtleAppearance(delay: 0.2)
                
                Text("How are you feeling exactly?")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .multilineTextAlignment(.center)
                    .subtleAppearance(delay: 0.3)
            }
        }
    }
    
    // MARK: - Mood Options Section
    private var moodOptionsSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            ForEach(Array(moods.enumerated()), id: \.offset) { index, mood in
                SubcategoryMoodCard(
                    mood: mood,
                    action: {
                        HapticFeedback.medium.trigger()
                        onMoodSelected(mood)
                    }
                )
                .subtleAppearance(delay: 0.4 + Double(index) * 0.1)
            }
        }
    }
    
    // MARK: - Computed Properties
    // Note: Using centralized AnimatedWeatherMoodIcon for consistency
}

// MARK: - Subcategory Mood Card
struct SubcategoryMoodCard: View {
    let mood: MoodType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.lg) {
                // Icon
                Image(systemName: mood.icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(DesignSystem.moodColor(for: mood))
                    .frame(width: 48, height: 48)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(mood.displayName)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text(moodDescription(for: mood))
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.secondary)
            }
            .padding(DesignSystem.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(DesignSystem.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .stroke(DesignSystem.moodColor(for: mood).opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func moodDescription(for mood: MoodType) -> String {
        switch mood {
        case .amazing: return "Exceptional day, feeling fantastic"
        case .good: return "Generally positive and content"
        case .okay: return "Balanced, neither great nor bad"
        case .challenging: return "Facing some difficulties, but manageable"
        case .tough: return "Having a rough time, struggling today"
        case .overwhelming: return "Feeling very overwhelmed and stressed"
        }
    }
}

#Preview {
    MoodSubcategorySelectionView(
        category: .positive,
        onMoodSelected: { _ in },
        onDismiss: { }
    )
} 