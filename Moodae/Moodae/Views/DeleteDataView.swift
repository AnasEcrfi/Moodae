//
//  DeleteDataView.swift
//  Moodae
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

struct DeleteDataView: View {
    @ObservedObject var viewModel: MoodViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showingDeleteEntriesConfirmation = false
    @State private var showingDeleteAccountConfirmation = false
    @State private var showingFinalAccountWarning = false
    @State private var confirmationText = ""
    @State private var isDeleteAccountEnabled = false
    
    private let requiredConfirmationText = "DELETE MY ACCOUNT"
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.surface
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: DesignSystem.Spacing.xxxl) {
                        // Header
                        headerSection
                        
                        // Delete Entries Section
                        deleteEntriesSection
                        
                        // Delete Account Section
                        deleteAccountSection
                        
                        Spacer(minLength: DesignSystem.Spacing.xl)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.top, DesignSystem.Spacing.lg)
                }
            }
            .navigationTitle("Delete Data")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        HapticFeedback.light.trigger()
                        dismiss()
                    }
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.secondary)
                }
            }
        }
        .alert("Delete All Mood Entries", isPresented: $showingDeleteEntriesConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAllEntries()
            }
        } message: {
            Text("This will permanently delete all your mood entries. This action cannot be undone.")
        }
        .alert("Delete Account", isPresented: $showingDeleteAccountConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Continue", role: .destructive) {
                showingFinalAccountWarning = true
            }
        } message: {
            Text("Are you sure you want to delete your account? This will remove all your data permanently.")
        }
        .alert("Final Warning", isPresented: $showingFinalAccountWarning) {
            Button("Cancel", role: .cancel) {
                confirmationText = ""
                isDeleteAccountEnabled = false
            }
            Button("Delete Account", role: .destructive) {
                deleteAccount()
            }
            .disabled(!isDeleteAccountEnabled)
        } message: {
            Text("This action is irreversible. All your data will be permanently deleted and cannot be recovered.")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundColor(DesignSystem.Colors.error)
                .subtleAppearance(delay: 0.1)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("Delete Data")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .subtleAppearance(delay: 0.2)
                
                Text("Choose what data you want to delete. These actions cannot be undone.")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .multilineTextAlignment(.center)
                    .subtleAppearance(delay: 0.3)
            }
        }
    }
    
    // MARK: - Delete Entries Section
    private var deleteEntriesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Mood Entries")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.primary)
                .subtleAppearance(delay: 0.4)
            
            deleteOptionCard(
                icon: "doc.text",
                iconColor: DesignSystem.Colors.warning,
                title: "Delete All Mood Entries",
                subtitle: "Remove all your mood data (\(viewModel.moodEntries.count) entries)",
                description: "This will delete all your mood entries but keep your account settings like preferences and app configuration.",
                buttonText: "Delete Entries",
                buttonColor: DesignSystem.Colors.warning,
                action: { showingDeleteEntriesConfirmation = true }
            )
            .subtleAppearance(delay: 0.5)
        }
    }
    
    // MARK: - Delete Account Section
    private var deleteAccountSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Account")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.primary)
                .subtleAppearance(delay: 0.6)
            
            deleteOptionCard(
                icon: "person.crop.circle.badge.xmark",
                iconColor: DesignSystem.Colors.error,
                title: "Delete Account",
                subtitle: "Permanently remove everything",
                description: "This will delete your entire account including all mood entries, settings, preferences, and any other data associated with your account. This action is irreversible.",
                buttonText: "Delete Account",
                buttonColor: DesignSystem.Colors.error,
                action: { showingDeleteAccountConfirmation = true }
            )
            .subtleAppearance(delay: 0.7)
            
            // Account deletion confirmation input
            if showingFinalAccountWarning {
                accountConfirmationSection
                    .subtleAppearance(delay: 0.8)
            }
        }
    }
    
    // MARK: - Account Confirmation Section
    private var accountConfirmationSection: some View {
        CleanCard(padding: DesignSystem.Spacing.lg) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.error)
                    
                    Text("Type \"DELETE MY ACCOUNT\" to confirm")
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.error)
                }
                
                TextField("DELETE MY ACCOUNT", text: $confirmationText)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .stroke(DesignSystem.Colors.secondary.opacity(0.3), lineWidth: 1)
                    )
                    .onChange(of: confirmationText) { _, newValue in
                        isDeleteAccountEnabled = newValue == requiredConfirmationText
                    }
                
                Text("Once you delete your account, there is no going back. Please be certain.")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondary)
            }
        }
    }
    
    // MARK: - Delete Option Card
    private func deleteOptionCard(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        description: String,
        buttonText: String,
        buttonColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        CleanCard(padding: DesignSystem.Spacing.lg) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                // Header
                HStack(spacing: DesignSystem.Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(iconColor.opacity(0.15))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: icon)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(iconColor)
                    }
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text(title)
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.primary)
                        
                        Text(subtitle)
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.secondary)
                    }
                    
                    Spacer()
                }
                
                // Description
                Text(description)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .lineSpacing(2)
                
                // Action Button
                Button(action: {
                    HapticFeedback.heavy.trigger()
                    action()
                }) {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .medium))
                        
                        Text(buttonText)
                            .font(DesignSystem.Typography.bodyMedium)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .fill(buttonColor)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Actions
    private func deleteAllEntries() {
        HapticFeedback.medium.trigger()
        
        // Delete all mood entries
        viewModel.deleteAllEntries()
        
        // Show success and dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
    
    private func deleteAccount() {
        HapticFeedback.medium.trigger()
        
        // Delete all mood entries
        viewModel.deleteAllEntries()
        
        // Reset all UserDefaults
        resetAllUserDefaults()
        
        // Reset app state
        resetAppState()
        
        // Show success and dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
    
    private func resetAllUserDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        
        // Remove all app-specific keys
        dictionary.keys.forEach { key in
            if key.hasPrefix("moodae") || 
               key == "hapticEnabled" ||
               key == "reminderEnabled" ||
               key == "appearance_mode" ||
               key == "week_start_day" ||
               key == "userPersonality" ||
               key == "pinEnabled" ||
               key == "pinCode" {
                defaults.removeObject(forKey: key)
            }
        }
        
        defaults.synchronize()
    }
    
    private func resetAppState() {
        // Reset any additional app state here if needed
        // This could include clearing caches, temporary files, etc.
    }
}

#Preview {
    DeleteDataView(viewModel: MoodViewModel())
} 