import SwiftUI

struct CustomTabBarView: View {
    @StateObject private var moodViewModel = MoodViewModel()
    @StateObject private var healthKitManager = HealthKitManager()
    @EnvironmentObject var appearanceManager: AppearanceManager
    @EnvironmentObject var weekStartManager: WeekStartManager
    @State private var selectedTab: TabItem = .home
    
    // KOORDINIERTE SHEET STATES
    @State private var showingMoodInput = false
    @State private var selectedMoodType: MoodType? = nil
    @State private var showingEnhancedInput = false
    @State private var showingDateSelectableInput = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            contentView
                .padding(.bottom, 62) // Match reduced tab bar height (58 + 4 padding)
            
            customTabBar
                .ignoresSafeArea(.all, edges: .bottom) // Extend to absolute bottom
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showingMoodInput) {
            NavigationView {
                MoodCategorySelectionView(
                    title: "How was your day?",
                    subtitle: "Track your daily mood",
                    onMoodSelected: { mood in
                        showMoodInput(mood)
                    },
                    onDismiss: {
                        dismissAllSheets()
                    },
                    onDateTapped: {
                        // Close current sheet and open date selectable mood input
                        showingMoodInput = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showDateSelectableMoodInput()
                        }
                    },
                    showAllMoods: true  // Zeige alle 6 Mood-Optionen direkt an
                )
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            dismissAllSheets()
                        }
                        .foregroundColor(DesignSystem.Colors.accent)
                    }
                }
            }
        }
        .sheet(isPresented: $showingEnhancedInput) {
            if let moodType = selectedMoodType {
                EnhancedMoodInputView(
                    viewModel: moodViewModel,
                    moodType: moodType,
                    isPresented: $showingEnhancedInput,
                    onComplete: {
                        // KOORDINIERTES DISMISSAL
                        dismissAllSheets()
                    }
                )
                .environmentObject(moodViewModel)
            }
        }
        .sheet(isPresented: $showingDateSelectableInput) {
            DateSelectableMoodInputView(
                viewModel: moodViewModel,
                isPresented: $showingDateSelectableInput,
                onComplete: {
                    dismissAllSheets()
                }
            )
        }
        .onChange(of: showingEnhancedInput) { _, isShowing in
            // Additional safety: clear selectedMoodType when sheet is manually closed
            if !isShowing {
                selectedMoodType = nil
            }
        }
    }
    
    // MARK: - Content View
    private var contentView: some View {
        Group {
            switch selectedTab {
            case .home:
                ContentView()
                    .environmentObject(moodViewModel)
                    .environmentObject(healthKitManager)
            case .insights:
                InsightsView(viewModel: moodViewModel)
                    .environmentObject(moodViewModel)
                    .environmentObject(healthKitManager)
            case .timeline:
                TimelineView(viewModel: moodViewModel)
                    .environmentObject(moodViewModel)
                    .environmentObject(healthKitManager)
                    .environmentObject(weekStartManager)
            case .settings:
                SettingsView(viewModel: moodViewModel)
                    .environmentObject(moodViewModel)
                    .environmentObject(healthKitManager)
                    .environmentObject(appearanceManager)
                    .environmentObject(weekStartManager)
            }
        }
    }
    
    // MARK: - Custom Tab Bar
    private var customTabBar: some View {
        VStack(spacing: 0) {
            // Top border for clean separation
            Rectangle()
                .fill(DesignSystem.Colors.separator.opacity(0.1))
                .frame(height: 0.5)
            
            // Tab content with refined background
            HStack {
                // Home Tab
                TabBarButton(
                    icon: "house",
                    filledIcon: "house.fill",
                    label: "Home",
                    isSelected: selectedTab == .home,
                    action: { selectTab(.home) }
                )
                
                // Timeline Tab (Neue Position 2)
                TabBarButton(
                    icon: "calendar",
                    filledIcon: "calendar",
                    label: "Timeline",
                    isSelected: selectedTab == .timeline,
                    action: { selectTab(.timeline) }
                )
                
                // Center Plus Button
                Button(action: {
                    triggerMoodInput()
                }) {
                    ZStack {
                        Circle()
                            .fill(DesignSystem.Colors.accent)
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(0.95)
                .accessibilityLabel("Add mood entry")
                .accessibilityHint("Double tap to add a new mood entry")
                
                // Insights Tab (Neue Position 4)
                TabBarButton(
                    icon: "chart.bar",
                    filledIcon: "chart.bar.fill",
                    label: "Insights",
                    isSelected: selectedTab == .insights,
                    action: { selectTab(.insights) }
                )
                
                // Settings Tab
                TabBarButton(
                    icon: "gear",
                    filledIcon: "gear",
                    label: "Settings",
                    isSelected: selectedTab == .settings,
                    action: { selectTab(.settings) }
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 4)
            .background(TabBarBackground())
        }
        .frame(height: 62)
    }
    
    // MARK: - KOORDINIERTE SHEET NAVIGATION
    
    private func dismissAllSheets() {
        showingMoodInput = false
        showingEnhancedInput = false
        showingDateSelectableInput = false
        
        // Reset state after dismissal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            selectedMoodType = nil
        }
    }
    
    private func triggerMoodInput() {
        HapticFeedback.medium.trigger()
        dismissAllSheets() // Ensure clean state
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            showingMoodInput = true
        }
    }
    
    private func showDateSelectableMoodInput() {
        HapticFeedback.medium.trigger()
        dismissAllSheets()
        
        // Wait for current sheet to fully dismiss before showing new one
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if !showingDateSelectableInput {
                showingDateSelectableInput = true
            }
        }
    }
    
    private func showMoodInput(_ mood: MoodType) {
        HapticFeedback.medium.trigger()
        selectedMoodType = mood
        showingMoodInput = false
        
        // Wait for current sheet to fully dismiss before showing new one
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Double-check that we're not already showing the enhanced input
            if !showingEnhancedInput {
                showingEnhancedInput = true
            }
        }
    }
    
    // MARK: - Tab Selection
    private func selectTab(_ tab: TabItem) {
        HapticFeedback.light.trigger()
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedTab = tab
        }
    }
}

// MARK: - Tab Bar Button Component
struct TabBarButton: View {
    let icon: String
    let filledIcon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? filledIcon : icon)
                    .font(.system(size: 24, weight: isSelected ? .medium : .light))
                    .foregroundColor(isSelected ? DesignSystem.Colors.accent : Color(.systemGray))
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? DesignSystem.Colors.accent : Color(.systemGray))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .accessibilityLabel("\(label) tab")
        .accessibilityHint("Double tap to navigate to \(label) section")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

// MARK: - Tab Item Enum
enum TabItem: CaseIterable {
    case home, insights, timeline, settings
}

// MARK: - Tab Bar Background
struct TabBarBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Main background with top rounded corners
            Rectangle()
                .fill(Color(.systemBackground))
                .mask(
                    RoundedRectangle(cornerRadius: 24)
                        .padding(.bottom, -24) // Extend beyond bottom to create flat bottom
                )
                .shadow(
                    color: colorScheme == .dark 
                        ? Color(.systemGray).opacity(0.3) 
                        : Color.black.opacity(0.08), 
                    radius: 1, 
                    x: 0, 
                    y: -1
                )
        }
    }
}

#Preview {
    CustomTabBarView()
} 