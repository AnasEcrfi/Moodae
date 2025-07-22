//
//  EnhancedMoodInputView.swift
//  Mooday
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

struct EnhancedMoodInputView: View {
    @ObservedObject var viewModel: MoodViewModel
    let moodType: MoodType
    let selectedDate: Date
    @Binding var isPresented: Bool
    let onComplete: (() -> Void)?
    let showCancelButton: Bool
    
    @State private var textInput = ""
    @State private var selectedCategories: [String: [String]] = [:]
    @State private var selectedPhoto: UIImage?
    @State private var showingAffirmation = false
    @State private var availableCategories = MoodCategory.defaultCategories
    
    @Environment(\.colorScheme) var colorScheme
    
    // STANDARDISIERTER INITIALIZER - Alle Parameter mit Default-Werten
    init(
        viewModel: MoodViewModel, 
        moodType: MoodType, 
        selectedDate: Date = Date(), 
        isPresented: Binding<Bool>, 
        showCancelButton: Bool = true, 
        onComplete: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.moodType = moodType
        self.selectedDate = selectedDate
        self._isPresented = isPresented
        self.showCancelButton = showCancelButton
        self.onComplete = onComplete
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerView
                
                // Categories
                categoriesView
                
                // Text Input
                textInputView
                
                // Photo Section - Moderner CI-Style
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "camera.fill")
                            .foregroundColor(DesignSystem.Colors.accent)
                            .font(.system(size: 16, weight: .medium))
                        
                        Text("Add a photo (optional)")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.primary)
                            .accessibilityLabel("Photo attachment section")
                            .accessibilityAddTraits(.isHeader)
                    }
                    
                    PhotoPickerView(selectedPhoto: $selectedPhoto)
                        .accessibilityLabel("Photo picker")
                        .accessibilityHint("Double tap to add a photo to your mood entry")
                }
                .scaleIn(delay: 0.7)
                
                // Removed writing prompts for cleaner UI
                
                // Action Buttons
                actionButtonsView
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(backgroundColor)
        .onTapGesture {
            hideKeyboard()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if showCancelButton {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Cancel mood entry")
                    .accessibilityHint("Double tap to cancel and return to previous screen")
                }
            }
        }
        .sheet(isPresented: $showingAffirmation) {
            AffirmationView(moodType: moodType, isPresented: $showingAffirmation) {
                // Close affirmation first, then call completion immediately
                showingAffirmation = false
                onComplete?()
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Mood entry details")
    }
    
    private var backgroundColor: Color {
        DesignSystem.Colors.surface
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: DesignSystem.moodIconName(for: moodType, filled: true))
                .font(DesignSystem.Typography.largeTitle)
                .foregroundColor(DesignSystem.moodIconColor(for: moodType))
                .animatedAppearance(delay: 0.2)
            
            Text(moodType.displayName)
                .font(DesignSystem.Typography.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .animatedAppearance(delay: 0.3)
            
            Text("How would you describe your day?")
                .font(DesignSystem.Typography.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .animatedAppearance(delay: 0.4)
        }
        .padding(.bottom, 8)
    }
    
    private var categoriesView: some View {
        VStack(spacing: 16) {
            ForEach(availableCategories.filter { $0.isEnabled }) { category in
                CategorySectionView(
                    category: category,
                    selectedOptions: Binding(
                        get: { selectedCategories[category.name] ?? [] },
                        set: { selectedCategories[category.name] = $0 }
                    )
                )
                .scaleIn(delay: 0.5 + Double(availableCategories.firstIndex(where: { $0.id == category.id }) ?? 0) * 0.1)
            }
        }
    }
    
    private var textInputView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "text.bubble.fill")
                    .foregroundColor(DesignSystem.Colors.accent)
                    .font(.system(size: 16, weight: .medium))
                
                Text("Additional Notes")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer()
            }
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(DesignSystem.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .stroke(DesignSystem.Colors.separator.opacity(0.2), lineWidth: 1)
                    )
                    .frame(minHeight: 100)
                
                if textInput.isEmpty {
                    Text("What made your day special? (Optional)")
                        .foregroundColor(DesignSystem.Colors.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .accessibilityHidden(true)
                }
                
                TextEditor(text: $textInput)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                    .accessibilityLabel("Additional notes")
                    .accessibilityHint("Write optional notes about what made your day special")
                    .accessibilityIdentifier("mood-notes-text-editor")
            }
        }
        .scaleIn(delay: 0.8)
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 16) {
            Button(action: saveMoodEntry) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                    
                    Text("Save Entry")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [DesignSystem.Colors.success, DesignSystem.Colors.success.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .scaleIn(delay: 0.9)
            .accessibilityLabel("Save mood entry")
            .accessibilityHint("Double tap to save your mood entry with selected categories and notes")
            .accessibilityIdentifier("save-mood-entry-button")
            
            Button("Skip for now") {
                saveMoodEntry()
            }
            .foregroundColor(.secondary)
            .scaleIn(delay: 1.0)
            .accessibilityLabel("Skip mood entry")
            .accessibilityHint("Double tap to save a basic mood entry without additional details")
            .accessibilityIdentifier("skip-mood-entry-button")
        }
    }
    
    private func saveMoodEntry() {
        // Convert selected categories to CategorySelection objects
        let categorySelections = selectedCategories.compactMap { (categoryName, options) -> CategorySelection? in
            guard !options.isEmpty else { return nil }
            return CategorySelection(categoryName: categoryName, selectedOptions: options)
        }
        
        // Save photo if selected
        var photoURL: URL?
        if let photo = selectedPhoto {
            photoURL = savePhotoToDocuments(photo)
        }
        
        // Update viewModel with category data
        viewModel.currentTextEntry = textInput
        viewModel.selectMood(moodType)
        
        // Save with categories, photo and selected date
        viewModel.saveMoodEntry(for: selectedDate, categories: categorySelections, photoURL: photoURL)
        
        // Show affirmation
        showingAffirmation = true
    }
    
    private func savePhotoToDocuments(_ image: UIImage) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving photo: \(error)")
            return nil
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct CategorySectionView: View {
    let category: MoodCategory
    @Binding var selectedOptions: [String]
    @State private var isExpanded = true
    
    var body: some View {
        VStack(spacing: 12) {
            // Category Header - Moderner CI-Style
            HStack(spacing: DesignSystem.Spacing.md) {
                // Icon mit modernem Hintergrund
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .fill(DesignSystem.Colors.accent.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: category.icon)
                        .foregroundColor(DesignSystem.Colors.accent)
                        .font(.system(size: 16, weight: .medium))
                }
                
                Text(category.name)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Spacer()
                
                Button(action: { 
                    withAnimation(.moodayEase) {
                        isExpanded.toggle() 
                    }
                }) {
                    Image(systemName: "chevron.up")
                        .foregroundColor(DesignSystem.Colors.secondary)
                        .font(.system(size: 14, weight: .medium))
                        .rotationEffect(.degrees(isExpanded ? 0 : 180))
                }
                .accessibilityLabel(isExpanded ? "Collapse \(category.name)" : "Expand \(category.name)")
                .accessibilityHint("Double tap to \(isExpanded ? "collapse" : "expand") the \(category.name) category options")
                .accessibilityIdentifier("\(category.name.lowercased())-expand-button")
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.moodayEase) {
                    isExpanded.toggle()
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(category.name) category")
            .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
            .accessibilityHint("Double tap to \(isExpanded ? "collapse" : "expand") category options")
            
            // Category Options - Moderneres Grid
            if isExpanded {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 90), spacing: DesignSystem.Spacing.md)
                ], spacing: DesignSystem.Spacing.md) {
                    ForEach(category.options) { option in
                        CategoryOptionView(
                            option: option,
                            isSelected: selectedOptions.contains(option.name),
                            onTap: { toggleOption(option.name) }
                        )
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(option.name)
                        .accessibilityValue(selectedOptions.contains(option.name) ? "Selected" : "Not selected")
                        .accessibilityHint("Double tap to \(selectedOptions.contains(option.name) ? "deselect" : "select") \(option.name)")
                        .accessibilityAddTraits(.isButton)
                        .accessibilityIdentifier("\(category.name.lowercased())-\(option.name.lowercased())-option")
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
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
        .accessibilityElement(children: .contain)
    }
    
    private func toggleOption(_ optionName: String) {
        withAnimation(.moodayEase) {
            if selectedOptions.contains(optionName) {
                selectedOptions.removeAll { $0 == optionName }
            } else {
                selectedOptions.append(optionName)
            }
        }
        
        // Moderne Haptic Feedback
        HapticFeedback.light.trigger()
    }
}

struct CategoryOptionView: View {
    let option: CategoryOption
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            // Moderner Icon Container
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(isSelected ? optionColor : DesignSystem.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .stroke(isSelected ? optionColor.opacity(0.3) : DesignSystem.Colors.separator.opacity(0.2), lineWidth: 1)
                    )
                    .frame(width: 48, height: 48)
                
                Image(systemName: option.icon)
                    .foregroundColor(isSelected ? .white : optionColor)
                    .font(.system(size: 20, weight: .medium))
            }
            
            // Moderner Text mit CI-Farben
            Text(option.name)
                .font(DesignSystem.Typography.small)
                .foregroundColor(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(minWidth: 80, minHeight: 80)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.moodayEase, value: isSelected)
        .onTapGesture {
            onTap()
        }
    }
    
    private var optionColor: Color {
        guard let colorName = option.color else {
            return DesignSystem.Colors.accent
        }
        
        return stringToColor(colorName)
    }
    
    private func stringToColor(_ colorName: String) -> Color {
        switch colorName.lowercased() {
        case "accent": return DesignSystem.Colors.accent
        case "secondary": return DesignSystem.Colors.secondary
        case "tertiary": return DesignSystem.Colors.tertiary
        case "primary": return DesignSystem.Colors.primary
        default: return DesignSystem.Colors.accent
        }
    }
} 