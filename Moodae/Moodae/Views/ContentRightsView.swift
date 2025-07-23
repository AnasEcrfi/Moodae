//
//  ContentRightsView.swift
//  Moodae
//
//  Created by Anas Ech-Cherfi on 27/01/2025.
//

import SwiftUI

struct ContentRightsView: View {
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
                        // Copyright Notice
                        rightsSection(
                            title: "Copyright Notice",
                            content: """
                            © 2025 Moodae. All rights reserved.

                            Moodae and the Moodae logo are trademarks of Moodae.

                            App Content Ownership:
                            • All original app design, interface, and code
                            • Mood tracking algorithms and analytics
                            • Custom graphics and visual elements
                            • App Store screenshots and marketing materials
                            • User interface layouts and navigation design

                            Protected under international copyright law and applicable trademark legislation.
                            """
                        )
                        
                        // Third-Party Attributions
                        rightsSection(
                            title: "Third-Party Content & Attributions",
                            content: """
                            Apple Technologies:
                            • SF Symbols (System icons) - Apple Inc.
                            • SwiftUI Framework - Apple Inc.
                            • Core Data Framework - Apple Inc.
                            • AVFoundation for audio recording - Apple Inc.

                            Used under Apple's standard licensing terms for iOS developers.

                            Design Inspiration:
                            • Human Interface Guidelines - Apple Inc.
                            • iOS design patterns and conventions
                            • Accessibility standards and implementations

                            All third-party content is used in compliance with respective licenses and terms of service.
                            """
                        )
                        
                        // User-Generated Content
                        rightsSection(
                            title: "User-Generated Content Rights",
                            content: """
                            Your Content Ownership:
                            • You retain full ownership of your mood entries
                            • Your audio recordings remain your property
                            • Photos you attach maintain your copyright
                            • All personal reflections and notes are yours

                            Limited License to Moodae:
                            • Permission to store content locally on your device
                            • Right to display content within the app interface
                            • Ability to process content for app functionality
                            • No rights to distribute, share, or monetize your content

                            Content Deletion:
                            • Complete removal possible at any time
                            • No retention after user deletion
                            • Export available before deletion
                            """
                        )
                        
                        // DMCA Compliance
                        rightsSection(
                            title: "Digital Millennium Copyright Act (DMCA)",
                            content: """
                            Copyright Infringement Policy:
                            Moodae respects intellectual property rights and expects users to do the same.

                            Prohibited Activities:
                            • Uploading copyrighted material without permission
                            • Sharing protected audio or video content
                            • Using copyrighted images in mood entries
                            • Distributing proprietary content of others

                            DMCA Notice Procedure:
                            If you believe your copyrighted work has been infringed:

                            1. Send written notice to: dmca@moodae.app
                            2. Include identification of copyrighted work
                            3. Specify location of infringing material
                            4. Provide your contact information
                            5. Include good faith statement
                            6. Verify accuracy under penalty of perjury
                            """
                        )
                    }
                    
                    Group {
                        // Content Guidelines
                        rightsSection(
                            title: "Content Guidelines & Acceptable Use",
                            content: """
                            Acceptable Content:
                            • Personal mood reflections and experiences
                            • Original thoughts and feelings
                            • Personal photos you have rights to use
                            • Self-recorded audio content

                            Prohibited Content:
                            • Copyrighted material without permission
                            • Content that infringes others' rights
                            • Malicious or harmful content
                            • Content violating applicable laws

                            Content Moderation:
                            • Automated scanning for inappropriate content
                            • User reporting mechanisms
                            • Prompt response to legitimate complaints
                            • Content removal when necessary
                            """
                        )
                        
                        // International Copyright
                        rightsSection(
                            title: "International Copyright Compliance",
                            content: """
                            Global Copyright Protection:
                            • Berne Convention compliance
                            • WIPO Copyright Treaty adherence
                            • Respect for local copyright laws
                            • Recognition of international copyrights

                            Territorial Considerations:
                            • Copyright laws vary by jurisdiction
                            • Fair use/fair dealing differences
                            • Local licensing requirements
                            • Cultural content sensitivities

                            Multi-Jurisdictional Approach:
                            • Compliance with strictest applicable standards
                            • Regular review of international obligations
                            • Adaptation to changing legal landscapes
                            """
                        )
                        
                        // Creative Commons & Open Source
                        rightsSection(
                            title: "Creative Commons & Open Source",
                            content: """
                            Open Source Components:
                            Currently, Moodae does not include open source components requiring attribution. This section will be updated if any are added.

                            Creative Commons Content:
                            No Creative Commons content is currently used in the app.

                            Future Considerations:
                            • Any open source usage will be properly attributed
                            • Creative Commons licenses will be respected
                            • Full compliance with attribution requirements
                            • Transparent disclosure of all dependencies
                            """
                        )
                        
                        // Data Rights & Export
                        rightsSection(
                            title: "Data Portability & Export Rights",
                            content: """
                            Your Data Rights:
                            • Export all mood data in CSV format
                            • Portable format for use in other applications
                            • No restrictions on personal data usage
                            • Standard format for maximum compatibility

                            Export Features:
                            • Complete mood entry history
                            • Category and tag information
                            • Timestamps and metadata
                            • Personal analytics and insights

                            Post-Export Rights:
                            • Use exported data as you see fit
                            • Import into other applications
                            • Create personal backups
                            • Share with healthcare providers (your choice)
                            """
                        )
                    }
                    
                    Group {
                        // Content Reporting
                        rightsSection(
                            title: "Content Reporting & Enforcement",
                            content: """
                            Report Copyright Infringement:
                            Email: dmca@moodae.app
                            Response time: Within 48 hours

                            Information Required:
                            • Your contact information
                            • Description of copyrighted work
                            • Location of infringing content
                            • Good faith belief statement
                            • Accuracy verification statement
                            • Physical or electronic signature

                            Investigation Process:
                            • Immediate review of all reports
                            • Content removal if infringement confirmed
                            • User notification of violations
                            • Account suspension for repeat offenders
                            """
                        )
                        
                        // Legal Framework
                        rightsSection(
                            title: "Legal Framework & Jurisdiction",
                            content: """
                            Governing Law:
                            These content rights are governed by applicable copyright laws and international treaties.

                            Dispute Resolution:
                            • Good faith negotiation preferred
                            • Mediation for complex disputes
                            • Arbitration when appropriate
                            • Court proceedings as last resort

                            Limitation of Liability:
                            • User responsibility for uploaded content
                            • Moodae not liable for user copyright violations
                            • Safe harbor provisions where applicable
                            • Prompt response to legitimate complaints
                            """
                        )
                        
                        // Contact Information
                        rightsSection(
                            title: "Contact for Content Rights Issues",
                            content: """
                            Copyright Questions:
                            Email: apps@mpagency.ae
                            
                            DMCA Notices:
                            Email: apps@mpagency.ae
                            
                            Legal Department:
                            Email: apps@mpagency.ae
                            
                            General Support:
                            Email: apps@mpagency.ae
                            
                            Company Information:
                            MPAGENCY MARKETING - FZCO
                            Building A1, Dubai Digital Park
                            Dubai, United Arab Emirates
                            
                            Response Time:
                            • DMCA notices: Within 24 hours
                            • Copyright questions: Within 48 hours
                            • General inquiries: Within 72 hours
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
            .navigationTitle("Content Rights")
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
            Text("Content Rights Information")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(DesignSystem.Colors.primary)
            
            Text("Information about copyright, content ownership, and your rights when using Moodae.")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.secondary)
                .lineSpacing(4)
        }
        .subtleAppearance(delay: 0.1)
    }
    
    // MARK: - Rights Section
    private func rightsSection(title: String, content: String) -> some View {
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
            Text("Document Information")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(DesignSystem.Colors.primary)
            
            Text("Version 1.0 - Effective January 27, 2025")
                .font(.system(size: 12))
                .foregroundColor(DesignSystem.Colors.secondary)
            
            Text("This document complies with DMCA requirements and international copyright law.")
                .font(.system(size: 12))
                .foregroundColor(DesignSystem.Colors.secondary)
                .italic()
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(DesignSystem.Colors.secondary.opacity(0.1))
        )
        .subtleAppearance(delay: 0.3)
    }
}

#Preview {
    ContentRightsView()
} 