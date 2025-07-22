//
//  EditEntryView.swift
//  Mooday
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

struct EditEntryView: View {
    let entry: MoodEntryData
    @ObservedObject var viewModel: MoodViewModel
    @Binding var isPresented: Bool
    
    @State private var selectedMood: MoodType
    @State private var textContent: String
    @State private var showingDeleteConfirmation = false
    @Environment(\.colorScheme) var colorScheme
    
    init(entry: MoodEntryData, viewModel: MoodViewModel, isPresented: Binding<Bool>) {
        self.entry = entry
        self.viewModel = viewModel
        self._isPresented = isPresented
        self._selectedMood = State(initialValue: entry.mood)
        self._textContent = State(initialValue: entry.textEntry ?? "")
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerView
                    
                    // Mood Selection
                    moodSelectionView
                    
                    // Text Content
                    textContentView
                    
                    // Delete Button
                    deleteButtonView
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
        .navigationTitle("Edit Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    isPresented = false
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveChanges()
                }
                .font(.system(.title2, design: .default).weight(.semibold))
            }
        }
        .alert("Delete Entry", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteEntry()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this mood entry? This action cannot be undone.")
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text(dateFormatter.string(from: entry.date))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(timeFormatter.string(from: entry.date))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var moodSelectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How were you feeling?")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                // Good Mood
                MoodOptionCard(
                    mood: .good,
                    isSelected: selectedMood == .good
                ) {
                    selectedMood = .good
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                
                // Challenging Mood
                MoodOptionCard(
                    mood: .challenging,
                    isSelected: selectedMood == .challenging
                ) {
                    selectedMood = .challenging
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
        }
    }
    
    private var textContentView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your thoughts")
                .font(.headline)
                .fontWeight(.semibold)
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(cardBackgroundColor)
                    .shadow(color: shadowColor, radius: 6, x: 0, y: 2)
                    .frame(minHeight: 120)
                
                TextEditor(text: $textContent)
                    .font(.body)
                    .padding(16)
                    .background(Color.clear)
                    .background(Color.clear)
                
                if textContent.isEmpty {
                    Text("Share your thoughts and feelings about this moment...")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .allowsHitTesting(false)
                }
            }
        }
    }
    
    private var deleteButtonView: some View {
        Button(action: {
            showingDeleteConfirmation = true
        }) {
            HStack {
                Image(systemName: "trash")
                Text("Delete Entry")
            }
            .font(.system(.body, design: .default).weight(.medium))
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(DesignSystem.weatherIconColor(isGood: false).opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(DesignSystem.weatherIconColor(isGood: false).opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    private func saveChanges() {
        // Update the entry in the view model
        if let index = viewModel.moodEntries.firstIndex(where: { $0.id == entry.id }) {
            viewModel.moodEntries[index] = MoodEntryData(
                id: entry.id,
                date: entry.date,
                mood: selectedMood,
                textEntry: textContent.isEmpty ? nil : textContent,
                audioURL: entry.audioURL,
                categories: entry.categories
            )
        }
        
        viewModel.saveMoodEntriesToUserDefaults()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        isPresented = false
    }
    
    private func deleteEntry() {
        viewModel.moodEntries.removeAll { $0.id == entry.id }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        isPresented = false
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color(.systemGroupedBackground)
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray6) : Color.white
    }
    
    private var shadowColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.06)
    }
}

struct MoodOptionCard: View {
    let mood: MoodType
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: DesignSystem.moodGradientColors(for: mood),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: DesignSystem.moodIconName(for: mood, filled: true))
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Text(mood == .good ? "Good" : "Difficult")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? DesignSystem.Colors.accent.opacity(0.1) : cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? DesignSystem.Colors.accent : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: shadowColor, radius: isSelected ? 8 : 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray6) : Color.white
    }
    
    private var shadowColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.06)
    }
}

#Preview {
    EditEntryView(
        entry: MoodEntryData(id: UUID(), date: Date(), mood: .good, textEntry: "Test entry", audioURL: nil),
        viewModel: MoodViewModel(),
        isPresented: .constant(true)
    )
} 