//
//  PrivacyPolicyView.swift
//  Moodae
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                    // Header
                    headerSection
                    
                    // Content sections
                    Group {
                        // Effective Date & Overview
                        privacySection(
                            title: "Effective Date & Overview",
                            content: """
                            Last updated: January 27, 2025

                            Moodae is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and protect your information when you use our mood tracking application.

                            Key principles:
                            • All data stays on your device
                            • No cloud storage or data transmission
                            • No third-party analytics or tracking
                            • Complete user control over data
                            • No advertising or marketing use of personal data
                            """
                        )
                        
                        // Data We Collect
                        privacySection(
                            title: "Information We Collect",
                            content: """
                            Moodae collects and stores the following information locally on your device:

                            Personal Data:
                            • Mood entries (text reflections and mood ratings)
                            • Audio recordings (if you choose to record voice memos)
                            • Photos (if you attach them to mood entries)
                            • Categories and tags you select
                            • Timestamps of mood entries

                            Technical Data:
                            • App preferences and settings
                            • Local usage patterns for app improvement

                            What We DON'T Collect:
                            • Personal identifiers (name, email, phone number)
                            • Location data
                            • Device identifiers for tracking
                            • Web browsing history
                            • Data from other apps
                            """
                        )
                        
                        // How We Use Information
                        privacySection(
                            title: "How We Use Your Information",
                            content: """
                            Your information is used exclusively for:

                            Core App Functionality:
                            • Displaying your mood history and patterns
                            • Generating insights and analytics
                            • Providing mood tracking features
                            • Creating visualizations of your data

                            App Improvement:
                            • Optimizing app performance
                            • Fixing bugs and technical issues
                            • Enhancing user experience

                            We DO NOT use your data for:
                            • Advertising or marketing
                            • Selling to third parties
                            • Profiling or tracking
                            • AI training (without explicit consent)
                            • Cross-app tracking
                            """
                        )
                        
                        // Data Storage & Security
                        privacySection(
                            title: "Data Storage & Security",
                            content: """
                            Local-Only Storage:
                            • All data is stored locally using Core Data encryption
                            • No cloud synchronization unless explicitly enabled
                            • No data transmission to external servers
                            • Data remains on your device at all times

                            Security Measures:
                            • iOS Keychain for sensitive settings
                            • App Transport Security (ATS) compliance
                            • Optional PIN/biometric protection
                            • Automatic data encryption at rest

                            Data Retention:
                            • Data is retained until you delete it
                            • No automatic deletion policies
                            • Complete user control over retention periods
                            """
                        )
                    }
                    
                    Group {
                        // Third-Party Services
                        privacySection(
                            title: "Third-Party Services",
                            content: """
                            Moodae does NOT integrate with:
                            • Analytics services (Google Analytics, Firebase, etc.)
                            • Advertising networks
                            • Social media platforms
                            • Cloud storage services (unless user-initiated)
                            • Marketing or tracking services

                            Optional Integrations:
                            • HealthKit (with explicit permission)
                            • iCloud (for device synchronization only)
                            • Siri Shortcuts (for voice commands)

                            These integrations require your explicit consent and can be disabled at any time.
                            """
                        )
                        
                        // Your Rights & Controls
                        privacySection(
                            title: "Your Privacy Rights & Controls",
                            content: """
                            Complete Data Control:
                            • Export all data in CSV format
                            • Delete individual mood entries
                            • Delete all data permanently
                            • Disable specific features

                            Privacy Controls:
                            • Revoke microphone permissions
                            • Disable photo access
                            • Turn off HealthKit integration
                            • Control iCloud synchronization

                            Legal Rights (where applicable):
                            • Right to access your data
                            • Right to data portability
                            • Right to rectification
                            • Right to erasure ("right to be forgotten")
                            • Right to restrict processing
                            • Right to object to processing
                            """
                        )
                        
                        // Children's Privacy
                        privacySection(
                            title: "Children's Privacy (COPPA Compliance)",
                            content: """
                            Age Requirements:
                            • Moodae is designed for users 13 years and older
                            • We do not knowingly collect data from children under 13
                            • No targeted advertising to minors

                            If you are under 13:
                            • Please do not use this app without parental consent
                            • Parents can contact us to remove any data
                            • We will delete accounts if notified of underage use

                            Parental Rights:
                            • Request access to child's data
                            • Request deletion of child's data
                            • Disable data collection features
                            """
                        )
                        
                        // International Privacy Laws
                        privacySection(
                            title: "International Privacy Compliance",
                            content: """
                            GDPR (European Union):
                            • Lawful basis: Legitimate interest for core functionality
                            • Data minimization principle followed
                            • Privacy by design implementation
                            • No cross-border data transfers

                            CCPA (California):
                            • No sale of personal information
                            • Right to opt-out (not applicable - no data sharing)
                            • Right to delete personal information
                            • Non-discrimination for privacy requests

                            Other Jurisdictions:
                            • PIPEDA (Canada) compliance
                            • LGPD (Brazil) compliance
                            • PDPA (Singapore) compliance
                            • Local privacy laws respected
                            """
                        )
                    }
                    
                    Group {
                        // Data Breach Notification
                        privacySection(
                            title: "Data Breach Notification",
                            content: """
                            Security Incident Response:
                            • Immediate investigation of any potential breach
                            • User notification within 72 hours
                            • Regulatory notification as required by law
                            • Remediation steps and recommendations

                            Since data is stored locally:
                            • Risk of data breach is minimal
                            • No external server vulnerabilities
                            • Device security is primary protection
                            """
                        )
                        
                        // Health Information
                        privacySection(
                            title: "Health Information & Medical Disclaimer",
                            content: """
                            Health Data Handling:
                            • Mood data may be considered health information
                            • Extra security measures for sensitive data
                            • No sharing with healthcare providers without consent
                            • HealthKit integration is optional and user-controlled

                            Medical Disclaimer:
                            • Moodae is not a medical device
                            • Not intended for medical diagnosis or treatment
                            • Consult healthcare professionals for medical concerns
                            • App does not replace professional medical advice
                            """
                        )
                        
                        // Changes to Privacy Policy
                        privacySection(
                            title: "Changes to This Privacy Policy",
                            content: """
                            Policy Updates:
                            • Notification of material changes via app update
                            • Continued use implies acceptance of changes
                            • Previous versions available upon request
                            • Users can delete data if they disagree with changes

                            We will notify you of changes by:
                            • App Store update notes
                            • In-app notification
                            • Updated "Last modified" date
                            """
                        )
                        
                        // Contact Information
                        privacySection(
                            title: "Contact Us",
                            content: """
                            Privacy Questions & Requests:
                            Email: privacy@moodae.app
                            Response time: Within 48 hours

                            Data Protection Officer:
                            Email: dpo@moodae.app
                            For GDPR-related inquiries

                            General Support:
                            Email: support@moodae.app
                            App Store: Developer Response Section

                            Mailing Address:
                            Moodae Privacy Team
                            [Your Address]
                            [City, State, Zip Code]
                            """
                        )
                    }
                    
                    // Footer
                    footerSection
                    
                    // Bottom spacing
                    Spacer(minLength: 30)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.top, DesignSystem.Spacing.lg)
            }
            .background(DesignSystem.Colors.surface)
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        HapticFeedback.light.trigger()
                        dismiss()
                    }
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.accent)
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Privacy Policy")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(DesignSystem.Colors.primary)
            
            Text("Your privacy is our priority. This policy explains how we protect your personal information.")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.secondary)
                .lineSpacing(4)
        }
        .subtleAppearance(delay: 0.1)
    }
    
    // MARK: - Privacy Section
    private func privacySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text(title)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(DesignSystem.Colors.primary)
            
            Text(content)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.secondary)
                .lineSpacing(6)
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .fill(DesignSystem.Colors.cardBackground)
        )
        .subtleAppearance(delay: 0.2)
    }
    
    // MARK: - Footer Section
    private var footerSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Document Version")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(DesignSystem.Colors.primary)
            
            Text("Version 1.0 - Effective January 27, 2025")
                .font(.system(size: 12))
                .foregroundColor(DesignSystem.Colors.secondary)
            
            Text("This privacy policy complies with GDPR, CCPA, COPPA, and other applicable privacy laws.")
                .font(.system(size: 12))
                .foregroundColor(DesignSystem.Colors.secondary)
                .italic()
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(DesignSystem.Colors.accent.opacity(0.1))
        )
        .subtleAppearance(delay: 0.3)
    }
}

#Preview {
    PrivacyPolicyView()
}