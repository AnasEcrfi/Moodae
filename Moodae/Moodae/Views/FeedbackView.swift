//
//  FeedbackView.swift
//  Moodae
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI
import MessageUI

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var feedbackText = ""
    @State private var feedbackType: FeedbackType = .general
    @State private var includeAppInfo = true
    @State private var showingMailComposer = false
    @State private var showingShareSheet = false
    @State private var canSendMail = MFMailComposeViewController.canSendMail()
    
    enum FeedbackType: String, CaseIterable {
        case general = "General Feedback"
        case bug = "Bug Report"
        case feature = "Feature Request"
        case improvement = "Improvement"
        
        var icon: String {
            switch self {
            case .general: return "bubble.left.and.bubble.right"
            case .bug: return "ant"
            case .feature: return "lightbulb"
            case .improvement: return "arrow.up.circle"
            }
        }
        
        var color: Color {
            switch self {
            case .general: return DesignSystem.Colors.accent
            case .bug: return DesignSystem.Colors.error
            case .feature: return DesignSystem.Colors.success
            case .improvement: return DesignSystem.Colors.info
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.surface
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: DesignSystem.Spacing.xxxl) {
                        // Header
                        headerSection
                        
                        // Feedback Type Selection
                        feedbackTypeSection
                        
                        // Feedback Text Input
                        feedbackInputSection
                        
                        // Include App Info Toggle
                        appInfoSection
                        
                        // Send Button
                        sendButtonSection
                        
                        Spacer(minLength: DesignSystem.Spacing.xl)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.top, DesignSystem.Spacing.lg)
                }
                .onTapGesture {
                    hideKeyboard()
                }
            }
            .navigationTitle("Send Feedback")
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
        .sheet(isPresented: $showingMailComposer) {
            MailComposeView(
                feedbackType: feedbackType,
                feedbackText: feedbackText,
                includeAppInfo: includeAppInfo
            )
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [generateFeedbackText()])
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "envelope.open")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundColor(DesignSystem.Colors.accent)
                .subtleAppearance(delay: 0.1)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("We'd Love Your Feedback")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .subtleAppearance(delay: 0.2)
                
                Text("Help us improve Moodae by sharing your thoughts, reporting bugs, or suggesting new features")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .multilineTextAlignment(.center)
                    .subtleAppearance(delay: 0.3)
            }
        }
    }
    
    // MARK: - Feedback Type Section
    private var feedbackTypeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Feedback Type")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.primary)
                .subtleAppearance(delay: 0.4)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(FeedbackType.allCases, id: \.self) { type in
                    feedbackTypeButton(type: type)
                        .subtleAppearance(delay: 0.5 + Double(FeedbackType.allCases.firstIndex(of: type) ?? 0) * 0.1)
                }
            }
        }
    }
    
    // MARK: - Feedback Input Section
    private var feedbackInputSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Your Message")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.primary)
                .subtleAppearance(delay: 0.8)
            
            CleanCard(padding: DesignSystem.Spacing.lg) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    TextField("Tell us what's on your mind...", text: $feedbackText, axis: .vertical)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.primary)
                        .lineLimit(8...12)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    Text("\(feedbackText.count)/500")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .subtleAppearance(delay: 0.9)
        }
    }
    
    // MARK: - App Info Section
    private var appInfoSection: some View {
        CleanCard(padding: DesignSystem.Spacing.lg) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "info.circle")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.info)
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Include App Information")
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text("Helps us debug issues faster")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $includeAppInfo)
                    .labelsHidden()
                    .tint(DesignSystem.Colors.accent)
            }
        }
        .subtleAppearance(delay: 1.0)
    }
    
    // MARK: - Send Button Section
    private var sendButtonSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Button(action: sendFeedback) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: canSendMail ? "envelope" : "square.and.arrow.up")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text(canSendMail ? "Send via Mail" : "Share Feedback")
                        .font(DesignSystem.Typography.bodyMedium)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .fill(isFormValid ? DesignSystem.Colors.accent : DesignSystem.Colors.secondary.opacity(0.5))
                )
            }
            .disabled(!isFormValid)
            .buttonStyle(PlainButtonStyle())
            
            if !canSendMail {
                Text("Mail app not configured. Feedback will be shared via other apps.")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .subtleAppearance(delay: 1.1)
    }
    
    // MARK: - Feedback Type Button
    private func feedbackTypeButton(type: FeedbackType) -> some View {
        Button(action: {
            HapticFeedback.light.trigger()
            withAnimation(.easeInOut(duration: 0.2)) {
                feedbackType = type
            }
        }) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: type.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isSelected(type) ? .white : type.color)
                    .frame(width: 24)
                
                Text(type.rawValue)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(isSelected(type) ? .white : DesignSystem.Colors.primary)
                
                Spacer()
                
                if isSelected(type) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .padding(DesignSystem.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(isSelected(type) ? type.color : DesignSystem.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .stroke(isSelected(type) ? Color.clear : type.color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected(type) ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected(type))
    }
    
    // MARK: - Helper Methods
    private func isSelected(_ type: FeedbackType) -> Bool {
        feedbackType == type
    }
    
    private var isFormValid: Bool {
        !feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        feedbackText.count <= 500
    }
    
    private func sendFeedback() {
        HapticFeedback.medium.trigger()
        
        if canSendMail {
            showingMailComposer = true
        } else {
            showingShareSheet = true
        }
    }
    
    private func generateFeedbackText() -> String {
        var text = "\(feedbackType.rawValue)\n\n"
        text += feedbackText
        
        if includeAppInfo {
            text += "\n\n---\nApp Information:\n"
            text += "App: Moodae\n"
            text += "Version: 1.0.0\n"
            text += "iOS: \(UIDevice.current.systemVersion)\n"
            text += "Device: \(UIDevice.current.model)\n"
        }
        
        return text
    }
    
    // MARK: - Helper Functions
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Mail Compose View
struct MailComposeView: UIViewControllerRepresentable {
    let feedbackType: FeedbackView.FeedbackType
    let feedbackText: String
    let includeAppInfo: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = context.coordinator
        
        mailComposer.setToRecipients(["feedback@moodae.app"])
        mailComposer.setSubject("Moodae \(feedbackType.rawValue)")
        
        var messageBody = feedbackText
        
        if includeAppInfo {
            messageBody += "\n\n---\nApp Information:\n"
            messageBody += "App: Moodae\n"
            messageBody += "Version: 1.0.0\n"
            messageBody += "iOS: \(UIDevice.current.systemVersion)\n"
            messageBody += "Device: \(UIDevice.current.model)\n"
        }
        
        mailComposer.setMessageBody(messageBody, isHTML: false)
        
        return mailComposer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposeView
        
        init(_ parent: MailComposeView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.dismiss()
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    FeedbackView()
} 