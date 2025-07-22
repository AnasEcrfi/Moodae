//
//  DateSelectableMoodInputView.swift
//  Moodae
//
//  Created by Anas Ech-Cherfi on 21/07/2025.
//

import SwiftUI

struct DateSelectableMoodInputView: View {
    @ObservedObject var viewModel: MoodViewModel
    @Binding var isPresented: Bool
    let onComplete: (() -> Void)?
    
    @State private var selectedDate = Date()
    @State private var selectedMoodType: MoodType?
    @State private var showingEnhancedInput = false
    @State private var navigationPath = NavigationPath()
    @Environment(\.colorScheme) var colorScheme
    
    init(viewModel: MoodViewModel, isPresented: Binding<Bool>, onComplete: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self._isPresented = isPresented
        self.onComplete = onComplete
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                DesignSystem.Colors.surface
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: DesignSystem.Spacing.xxxl) {
                        // Header Section
                        headerSection
                        
                        // Date Selection
                        dateSelectionSection
                        
                        // Mood Selection Cards
                        moodSelectionSection
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.top, DesignSystem.Spacing.lg)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(DesignSystem.Colors.accent)
                }
            }
            .navigationDestination(isPresented: $showingEnhancedInput) {
                if let moodType = selectedMoodType {
                    EnhancedMoodInputView(
                        viewModel: viewModel,
                        moodType: moodType,
                        selectedDate: selectedDate,
                        isPresented: $showingEnhancedInput,
                        showCancelButton: false,
                        onComplete: {
                            // Close the entire sheet stack
                            isPresented = false
                            onComplete?()
                        }
                    )
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Back") {
                                showingEnhancedInput = false
                                selectedMoodType = nil
                            }
                            .foregroundColor(DesignSystem.Colors.accent)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("Add Mood Entry")
                    .font(DesignSystem.Typography.largeTitle)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .multilineTextAlignment(.center)
                    .subtleAppearance(delay: 0.1)
                
                Text("Choose a date and your mood")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .multilineTextAlignment(.center)
                    .subtleAppearance(delay: 0.2)
            }
        }
    }
    
    // MARK: - Date Selection Section
    private var dateSelectionSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Text("Select Date")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .subtleAppearance(delay: 0.3)
            
            DatePicker("", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .subtleAppearance(delay: 0.35)
            
            Text("Entry for \(selectedDate, style: .date)")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.secondary)
                .subtleAppearance(delay: 0.4)
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .fill(DesignSystem.Colors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .stroke(DesignSystem.Colors.separator.opacity(0.1), lineWidth: 0.5)
                )
        )
    }
    
    // MARK: - Mood Selection Section - ALLE 6 MOODS
    private var moodSelectionSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // POSITIVE MOODS (3 Karten)
            VStack(spacing: DesignSystem.Spacing.md) {
                CleanSectionHeader("Positive Days", subtitle: "Great moments and achievements")
                    .subtleAppearance(delay: 0.35)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: DesignSystem.Spacing.md) {
                    CleanMoodCard(
                        title: "Amazing",
                        subtitle: "Incredible day",
                        icon: "sun.max.trianglebadge.exclamationmark",
                        color: DesignSystem.moodColor(for: .amazing),
                        action: { selectMood(.amazing) },
                        moodType: .amazing,
                        useAnimatedIcon: false
                    )
                    .subtleAppearance(delay: 0.4)
                    
                    CleanMoodCard(
                        title: "Good",
                        subtitle: "Positive moments",
                        icon: "sun.max",
                        color: DesignSystem.moodColor(for: .good),
                        action: { selectMood(.good) },
                        moodType: .good,
                        useAnimatedIcon: false
                    )
                    .subtleAppearance(delay: 0.45)
                    
                    CleanMoodCard(
                        title: "Okay",
                        subtitle: "Balanced day",
                        icon: "sun.and.horizon",
                        color: DesignSystem.moodColor(for: .okay),
                        action: { selectMood(.okay) },
                        moodType: .okay,
                        useAnimatedIcon: false
                    )
                    .subtleAppearance(delay: 0.5)
                }
            }
            
            // DIFFICULT MOODS (3 Karten)
            VStack(spacing: DesignSystem.Spacing.md) {
                CleanSectionHeader("Difficult Days", subtitle: "Challenges and growth opportunities")
                    .subtleAppearance(delay: 0.55)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: DesignSystem.Spacing.md) {
                    CleanMoodCard(
                        title: "Challenging",
                        subtitle: "Some obstacles",
                        icon: "cloud.sun",
                        color: DesignSystem.moodColor(for: .challenging),
                        action: { selectMood(.challenging) },
                        moodType: .challenging,
                        useAnimatedIcon: false
                    )
                    .subtleAppearance(delay: 0.6)
                    
                    CleanMoodCard(
                        title: "Tough",
                        subtitle: "Hard moments",
                        icon: "cloud.rain",
                        color: DesignSystem.moodColor(for: .tough),
                        action: { selectMood(.tough) },
                        moodType: .tough,
                        useAnimatedIcon: false
                    )
                    .subtleAppearance(delay: 0.65)
                    
                    CleanMoodCard(
                        title: "Overwhelming",
                        subtitle: "Very difficult",
                        icon: "cloud.heavyrain",
                        color: DesignSystem.moodColor(for: .overwhelming),
                        action: { selectMood(.overwhelming) },
                        moodType: .overwhelming,
                        useAnimatedIcon: false
                    )
                    .subtleAppearance(delay: 0.7)
                }
            }
        }
    }
    
    // MARK: - Actions
    private func selectMood(_ mood: MoodType) {
        HapticFeedback.medium.trigger()
        
        selectedMoodType = mood
        
        withAnimation(.moodayEase) {
            showingEnhancedInput = true
        }
    }
}

#Preview {
    DateSelectableMoodInputView(
        viewModel: MoodViewModel(),
        isPresented: .constant(true)
    )
} 