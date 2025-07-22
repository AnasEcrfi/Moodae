//
//  PrivacyPolicyView.swift
//  Mooday
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
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Privacy Policy")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Last updated: \(formattedDate)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Content sections
                    privacySection(
                        title: "Data Collection",
                        content: """
                        Moodae collects minimal personal information to provide you with mood tracking services:
                        
                        • Mood entries (text and audio recordings)
                        • Usage patterns for app improvement
                        • Device information for technical support
                        
                        All data is stored locally on your device and never shared with third parties.
                        """
                    )
                    
                    privacySection(
                        title: "Data Storage",
                        content: """
                        Your mood data is stored securely on your device using Core Data encryption. We do not store your personal information on external servers.
                        
                        • All mood entries remain on your device
                        • Audio recordings are processed locally
                        • No cloud synchronization without explicit consent
                        """
                    )
                    
                    privacySection(
                        title: "Microphone Usage",
                        content: """
                        Moodae requests microphone access only for audio mood entries:
                        
                        • Used exclusively for recording your mood reflections
                        • Recordings are processed locally on your device
                        • You can revoke microphone permission at any time in Settings
                        """
                    )
                    
                    privacySection(
                        title: "Your Rights",
                        content: """
                        You have full control over your data:
                        
                        • Delete individual mood entries at any time
                        • Export your data in standard formats
                        • Request complete data deletion
                        • Disable specific features (audio recording, etc.)
                        """
                    )
                    
                    privacySection(
                        title: "Contact",
                        content: """
                        For privacy-related questions or requests:
                        
                        Email: privacy@mooday.app
                        
                        We respond to all privacy inquiries within 48 hours.
                        """
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(backgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(.body, design: .default).weight(.medium))
                }
            }
        }
    }
    
    private func privacySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding(.vertical, 8)
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color.white
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
}

#Preview {
    PrivacyPolicyView()
} 