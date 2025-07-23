//
//  RetroactiveMoodEntryView.swift
//  Mooday
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

struct RetroactiveMoodEntryView: View {
    @ObservedObject var viewModel: MoodViewModel
    let date: Date
    @Binding var isPresented: Bool
    
    @State private var selectedMood: MoodType?
    @State private var textEntry = ""
    @State private var showingSuccess = false
    @Environment(\.colorScheme) var colorScheme
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date) == DateFormatter().string(from: Date()) ? 
        DateFormatter() : {
            let f = DateFormatter()
            f.dateStyle = .full
            return f
        }()
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        let dateString = formatter.string(from: date)
        
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return dateString
        }
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    headerView
                    
                    // Mood Selection
                    moodSelectionView
                    
                    // Text Input (Optional)
                    if selectedMood != nil {
                        textInputView
                    }
                    
                    // Action Buttons
                    if selectedMood != nil {
                        actionButtonsView
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    isPresented = false
                }
                .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $showingSuccess) {
            SuccessView(date: date, mood: selectedMood!) {
                isPresented = false
            }
        }
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color(.systemGroupedBackground)
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Text("Add Entry")
                .font(.title2)
                .font(.system(.body, design: .default).weight(.bold))
                .foregroundColor(.primary)
            
            Text("How was \(formattedDate)?")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .animatedAppearance(delay: 0.1)
    }
    
    private var moodSelectionView: some View {
        VStack(spacing: 16) {
            Text("Select your mood")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                MoodButton(
                    title: MoodType.good.displayName,  // Konsistente Titel
                    icon: MoodType.good.icon,  // Konsistent mit anderen Views  
                    color: DesignSystem.moodColor(for: .good),
                    isSelected: selectedMood == .good
                ) {
                    withAnimation(.smoothSpring) {
                        selectedMood = .good
                    }
                    HapticFeedback.medium.trigger()
                }
                
                MoodButton(
                    title: MoodType.challenging.displayName,  // Konsistente Titel
                    icon: MoodType.challenging.icon,  // Konsistent mit anderen Views
                    color: DesignSystem.moodColor(for: .challenging),
                    isSelected: selectedMood == .challenging
                ) {
                    withAnimation(.smoothSpring) {
                        selectedMood = .challenging
                    }
                    HapticFeedback.medium.trigger()
                }
            }
        }
        .animatedAppearance(delay: 0.3)
    }
    
    private var textInputView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add a note (optional)")
                .font(.headline)
                .foregroundColor(.primary)
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(textFieldBackgroundColor)
                    .frame(minHeight: 120)
                
                if textEntry.isEmpty {
                    Text("How did this day feel? What happened?")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                
                TextEditor(text: $textEntry)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.clear)
                    .background(Color.clear)
            }
        }
        .animatedAppearance(delay: 0.5)
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 16) {
            // Save Button
            Button(action: { saveMoodEntry() }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                    Text("Save Entry")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [DesignSystem.Colors.success, DesignSystem.Colors.success.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: DesignSystem.Colors.success.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(SmoothButtonStyle())
            
            // Quick Save Button (without text)
            if !textEntry.isEmpty {
                Button(action: { saveMoodEntry(withoutText: true) }) {
                    Text("Save without note")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
        }
        .animatedAppearance(delay: 0.7)
    }
    
    private var moodColors: [Color] {
        guard let mood = selectedMood else { return [DesignSystem.Colors.secondary] }
        
        // ZENTRALE FARB-REFERENZ über DesignSystem
        let baseColor = DesignSystem.moodColor(for: mood)
        return [baseColor, baseColor.opacity(0.8)]
    }
    
    private var textFieldBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6).opacity(0.3)
    }
    
    private func saveMoodEntry(withoutText: Bool = false) {
        guard let mood = selectedMood else { return }
        
        let finalText = withoutText ? nil : (textEntry.isEmpty ? nil : textEntry)
        viewModel.saveMoodEntry(for: date, mood: mood, text: finalText)
        
        HapticFeedback.medium.trigger()
        showingSuccess = true
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct MoodButton: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? color : color.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .font(.system(.body, design: .default).weight(.medium))
                        .foregroundColor(isSelected ? .white : color)
                }
                
                Text(title)
                    .font(.caption)
                    .font(.system(.body, design: .default).weight(.medium))
                    .foregroundColor(isSelected ? color : .secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(SmoothButtonStyle())
        .animation(.smoothSpring, value: isSelected)
    }
}

struct SuccessView: View {
    let date: Date
    let mood: MoodType
    let onDismiss: () -> Void
    @State private var isVisible = false
    @Environment(\.colorScheme) var colorScheme
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }
            
            VStack(spacing: 24) {
                // Success Icon
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.success)
                        .frame(width: 80, height: 80)
                        .shadow(color: DesignSystem.Colors.success.opacity(0.3), radius: 12)
                    
                    Image(systemName: "checkmark")
                        .font(.title)
                        .font(.system(.body, design: .default).weight(.bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(isVisible ? 1.0 : 0.5)
                .animation(.smoothSpring.delay(0.1), value: isVisible)
                
                VStack(spacing: 8) {
                    Text("Entry Added!")
                        .font(.title2)
                        .font(.system(.body, design: .default).weight(.bold))
                        .foregroundColor(.primary)
                    
                    Text("Saved for \(formattedDate)")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .opacity(isVisible ? 1 : 0)
                .animation(.easeOut.delay(0.3), value: isVisible)
                
                Button("Done") {
                    onDismiss()
                }
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.accent)
                .opacity(isVisible ? 1 : 0)
                .animation(.easeOut.delay(0.5), value: isVisible)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 20)
            )
            .padding(.horizontal, 32)
            .scaleEffect(isVisible ? 1.0 : 0.8)
            .animation(.smoothSpring, value: isVisible)
        }
        .onAppear {
            isVisible = true
        }
    }
}

#Preview {
    RetroactiveMoodEntryView(
        viewModel: MoodViewModel(),
        date: Date(),
        isPresented: .constant(true)
    )
} 