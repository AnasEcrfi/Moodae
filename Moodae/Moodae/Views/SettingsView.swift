//
//  SettingsView.swift
//  Mooday
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

extension UIContentSizeCategory {
    static var isAccessibilityCategory: Bool {
        let current = UIApplication.shared.preferredContentSizeCategory
        return current >= .accessibilityMedium
    }
}

struct SettingsView: View {
    @ObservedObject var viewModel: MoodViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appearanceManager: AppearanceManager
    @EnvironmentObject var weekStartManager: WeekStartManager
    
    @State private var showingPrivacyPolicy = false
    @State private var showingContentRights = false
    @State private var showingDataExport = false
    @State private var hapticEnabled = UserDefaults.standard.object(forKey: "hapticEnabled") as? Bool ?? true
    @State private var reminderEnabled = UserDefaults.standard.object(forKey: "reminderEnabled") as? Bool ?? false
    @State private var showingAppearancePicker = false
    @State private var showingWeekStartPicker = false
    @State private var showingFeedback = false
    @State private var showingDeleteDataView = false
    @State private var showingPINVerification = false
    @State private var showingAccessibilitySettings = false
    
    // PIN Manager
    @StateObject private var pinManager = PINManager()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Clean Background
                DesignSystem.Colors.surface
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: DesignSystem.Spacing.xxxl) {
                        // App Section
                        appSection
                        
                        // Security Section
                        securitySection
                        
                        // Preferences Section
                        preferencesSection
                        
                        // Accessibility Section
                        accessibilitySection
                        
                        // Data Section
                        dataSection
                        
                        // Support Section
                        supportSection
                        
                        // Health Disclaimer
                        healthDisclaimerSection
                        
                        // Bottom spacing to prevent tab bar overlap
                        Spacer(minLength: 12)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.top, DesignSystem.Spacing.lg)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showingContentRights) {
            ContentRightsView()
        }
        .sheet(isPresented: $showingAppearancePicker) {
            AppearancePickerView(appearanceManager: appearanceManager)
        }
        .sheet(isPresented: $showingWeekStartPicker) {
            WeekStartPickerView(weekStartManager: weekStartManager)
        }
        .sheet(isPresented: $showingFeedback) {
            FeedbackView()
        }
        .sheet(isPresented: $showingDeleteDataView) {
            DeleteDataView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingPINVerification) {
            PINVerificationView(pinManager: pinManager) {
                pinManager.disablePIN()
            }
        }
        .sheet(isPresented: $showingAccessibilitySettings) {
            AccessibilitySettingsView()
        }
        .sheet(isPresented: $pinManager.showingPINSetup) {
            PINSetupView(pinManager: pinManager)
        }
        .alert("Export Data", isPresented: $showingDataExport) {
            Button("Cancel", role: .cancel) { }
            Button("Export") {
                exportData()
            }
        } message: {
            Text("Export your mood data as a CSV file.")
        }
        .onChange(of: hapticEnabled) {
            UserDefaults.standard.set(hapticEnabled, forKey: "hapticEnabled")
        }
        .onChange(of: reminderEnabled) {
            UserDefaults.standard.set(reminderEnabled, forKey: "reminderEnabled")
        }
        .withAppTextScaling()
    }
    
    // MARK: - App Section
    private var appSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            CleanSectionHeader("App")
            
            CleanCard(padding: 0) {
                VStack(spacing: 0) {
                    settingsRow(
                        icon: "heart.fill",
                        iconColor: DesignSystem.Colors.accent,
                        title: "About Moodae",
                        subtitle: "Version 1.0.0",
                        showChevron: false,
                        action: {}
                    )
                }
            }
        }
        .subtleAppearance(delay: 0.1)
    }
    
    // MARK: - Security Section
    private var securitySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            CleanSectionHeader("Security")
            
            CleanCard(padding: 0) {
                VStack(spacing: 0) {
                                         HStack(spacing: DesignSystem.Spacing.md) {
                         // Icon
                         Image(systemName: "lock.fill")
                             .font(.system(size: 16, weight: .medium))
                             .foregroundColor(DesignSystem.Colors.info)
                             .frame(width: 32, height: 32)
                             .background(
                                 RoundedRectangle(cornerRadius: 8)
                                     .fill(DesignSystem.Colors.info.opacity(0.15))
                             )
                         
                         // Content
                         VStack(alignment: .leading, spacing: 2) {
                             Text("PIN Security")
                                 .font(DesignSystem.Typography.bodyMedium)
                                 .foregroundColor(DesignSystem.Colors.primary)
                             
                             Text(pinManager.isPINEnabled ? "PIN is enabled" : "Protect your app with a PIN")
                                 .font(DesignSystem.Typography.caption)
                                 .foregroundColor(DesignSystem.Colors.secondary)
                         }
                         
                         Spacer()
                         
                         // Toggle
                         Toggle("", isOn: Binding(
                             get: { pinManager.isPINEnabled },
                             set: { enabled in
                                 if enabled {
                                     pinManager.showingPINSetup = true
                                 } else {
                                     // Require PIN verification before disabling
                                     showingPINVerification = true
                                 }
                             }
                         ))
                         .toggleStyle(SwitchToggleStyle(tint: DesignSystem.Colors.accent))
                     }
                     .padding(DesignSystem.Spacing.lg)
                    
                    Divider()
                        .background(DesignSystem.Colors.secondary.opacity(0.3))
                        .padding(.leading, 56)
                    
                    settingsRow(
                        icon: "hand.raised.fill",
                        iconColor: DesignSystem.Colors.secondary,
                        title: "Privacy Policy",
                        subtitle: "How we handle your data",
                        showChevron: true,
                        action: { showingPrivacyPolicy = true }
                    )
                    
                    Divider()
                        .background(DesignSystem.Colors.secondary.opacity(0.3))
                        .padding(.leading, 56)
                    
                    settingsRow(
                        icon: "c.circle.fill",
                        iconColor: DesignSystem.Colors.info,
                        title: "Content Rights",
                        subtitle: "Copyright and attribution information",
                        showChevron: true,
                        action: { showingContentRights = true }
                    )
                }
            }
        }
        .subtleAppearance(delay: 0.2)
    }
    
    // MARK: - Preferences Section
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            CleanSectionHeader("Preferences")
            
            CleanCard(padding: 0) {
                VStack(spacing: 0) {
                    // Appearance Setting
                    settingsRow(
                        icon: "circle.lefthalf.filled",
                        iconColor: DesignSystem.Colors.accent,
                        title: "Appearance",
                        subtitle: appearanceManager.selectedMode.rawValue,
                        showChevron: true,
                        action: { showingAppearancePicker = true }
                    )
                    
                    Divider()
                        .background(DesignSystem.Colors.secondary.opacity(0.3))
                        .padding(.leading, 56)
                    
                    // Week Start Setting
                    settingsRow(
                        icon: "calendar",
                        iconColor: DesignSystem.Colors.info,
                        title: "Start of Week",
                        subtitle: weekStartManager.selectedWeekStart.rawValue,
                        showChevron: true,
                        action: { showingWeekStartPicker = true }
                    )
                    
                    Divider()
                        .background(DesignSystem.Colors.secondary.opacity(0.3))
                        .padding(.leading, 56)
                    
                    settingsToggleRow(
                        icon: "hand.tap.fill",
                        iconColor: DesignSystem.Colors.warning,
                        title: "Haptic Feedback",
                        subtitle: "Feel vibrations for interactions",
                        isOn: $hapticEnabled
                    )
                    
                    Divider()
                        .background(DesignSystem.Colors.secondary.opacity(0.3))
                        .padding(.leading, 56)
                    
                    settingsRowWithBadge(
                        icon: "bell.fill",
                        iconColor: DesignSystem.Colors.warning,
                        title: "Smart Notifications",
                        subtitle: "Intelligent daily mood reminders",
                        badge: "Coming Soon",
                        badgeColor: DesignSystem.Colors.accent
                    )
                }
            }
        }
        .subtleAppearance(delay: 0.2)
    }
    
    // MARK: - Accessibility Section
    private var accessibilitySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            CleanSectionHeader("Accessibility")
            
            CleanCard(padding: 0) {
                settingsRow(
                    icon: "accessibility",
                    iconColor: DesignSystem.Colors.accent,
                    title: "Accessibility Settings",
                    subtitle: "Text size, contrast, animations, and accessibility guide",
                    showChevron: true,
                    action: { showingAccessibilitySettings = true }
                )
            }
        }
        .subtleAppearance(delay: 0.25)
    }
    
    // MARK: - Data Section
    private var dataSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            CleanSectionHeader("Data")
            
            CleanCard(padding: 0) {
                VStack(spacing: 0) {
                    settingsRow(
                        icon: "square.and.arrow.up.fill",
                        iconColor: DesignSystem.Colors.success,
                        title: "Export Data",
                        subtitle: "Download your mood data as CSV",
                        showChevron: true,
                        action: { showingDataExport = true }
                    )
                    
                    Divider()
                        .background(DesignSystem.Colors.secondary.opacity(0.3))
                        .padding(.leading, 56)
                    
                    settingsRow(
                        icon: "trash.fill",
                        iconColor: DesignSystem.Colors.error,
                        title: "Delete Data",
                        subtitle: "Remove entries or delete account",
                        showChevron: true,
                        action: { showingDeleteDataView = true }
                    )
                }
            }
        }
        .subtleAppearance(delay: 0.3)
    }
    
    // MARK: - Support Section
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            CleanSectionHeader("Support")
            
            CleanCard(padding: 0) {
                VStack(spacing: 0) {
                    settingsRow(
                        icon: "questionmark.circle.fill",
                        iconColor: DesignSystem.Colors.info,
                        title: "Help & FAQ",
                        subtitle: "Get help with using Moodae",
                        showChevron: true,
                        action: {}
                    )
                    
                    Divider()
                        .background(DesignSystem.Colors.secondary.opacity(0.3))
                        .padding(.leading, 56)
                    
                    settingsRow(
                        icon: "envelope.fill",
                        iconColor: DesignSystem.Colors.accent,
                        title: "Contact Us",
                        subtitle: "Send feedback or report issues",
                        showChevron: true,
                        action: { showingFeedback = true }
                    )
                }
            }
        }
        .subtleAppearance(delay: 0.4)
    }
    
    // MARK: - Health Disclaimer Section
    private var healthDisclaimerSection: some View {
        CleanCard(padding: DesignSystem.Spacing.lg) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    Image(systemName: "cross.circle.fill")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(DesignSystem.Colors.error)
                    
                    Text("Health Disclaimer")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.primary)
                }
                
                Text("Moodae is not a substitute for professional medical advice, diagnosis, or treatment. If you're experiencing persistent mental health concerns, please consult a qualified healthcare provider.")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .lineSpacing(2)
            }
        }
        .subtleAppearance(delay: 0.5)
    }
    
    // MARK: - Helper Views
    private func settingsRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        showChevron: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            HapticFeedback.light.trigger()
            action()
        }) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Icon
                settingsIconView(icon: icon, color: iconColor)
                
                // Content
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(title)
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text(subtitle)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondary)
                }
                
                Spacer()
                
                // Chevron
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(DesignSystem.Colors.secondary)
                }
            }
            .contentShape(Rectangle()) // This ensures the entire area is tappable
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func settingsRowWithBadge(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        badge: String,
        badgeColor: Color
    ) -> some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(iconColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Spacer()
                    
                    // Badge
                    Text(badge)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(badgeColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(badgeColor.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(badgeColor.opacity(0.2), lineWidth: 1)
                                )
                        )
                }
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(DesignSystem.Colors.secondary)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.md)
        .contentShape(Rectangle())
    }
    
    private func settingsToggleRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Icon
            settingsIconView(icon: icon, color: iconColor)
            
            // Content
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text(subtitle)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondary)
            }
            
            Spacer()
            
            // Toggle
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(DesignSystem.Colors.accent)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.md)
    }
    
    private func settingsIconView(icon: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(color)
                .frame(width: 28, height: 28)
            
            Image(systemName: icon)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.white)
        }
    }
    

    
    // MARK: - Actions
    private func exportData() {
        HapticFeedback.medium.trigger()
        
        let csvData = generateCSVData()
        let fileName = "moodae_export_\(dateFormatter.string(from: Date())).csv"
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvData.write(to: tempURL, atomically: true, encoding: .utf8)
            
            let activityController = UIActivityViewController(
                activityItems: [tempURL],
                applicationActivities: nil
            )
            
            // Für iPad - Popover konfigurieren
            if let popover = activityController.popoverPresentationController {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    popover.sourceView = window
                    popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
            }
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                rootViewController.present(activityController, animated: true)
            }
            
        } catch {
            print("Error exporting data: \(error)")
        }
    }
    
    private func generateCSVData() -> String {
        var csvLines = ["Date,Time,Mood,Text,Categories"]
        
        let sortedEntries = viewModel.moodEntries.sorted { $0.date < $1.date }
        
        for entry in sortedEntries {
            let dateString = exportDateFormatter.string(from: entry.date)
            let timeString = exportTimeFormatter.string(from: entry.date)
            let moodString = entry.mood == .good ? "Good" : "Difficult"
            let textString = (entry.textEntry ?? "").replacingOccurrences(of: "\"", with: "\"\"")
            
            // Kategorien zu String konvertieren
            let categoriesString = entry.categories.map { selection in
                "\(selection.categoryName): \(selection.selectedOptions.joined(separator: "; "))"
            }.joined(separator: " | ")
            
            let csvLine = "\"\(dateString)\",\"\(timeString)\",\"\(moodString)\",\"\(textString)\",\"\(categoriesString)\""
            csvLines.append(csvLine)
        }
        
        return csvLines.joined(separator: "\n")
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    private var exportDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    private var exportTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }

}

#Preview {
    SettingsView(viewModel: MoodViewModel())
} 