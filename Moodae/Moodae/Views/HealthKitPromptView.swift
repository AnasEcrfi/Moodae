//
//  HealthKitPromptView.swift
//  Mooday
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

struct HealthKitPromptView: View {
    @ObservedObject var viewModel: MoodViewModel
    @Binding var isPresented: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var showingDetails = false
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        headerView
                        
                        // Benefits
                        benefitsView
                        
                        // Data Types
                        dataTypesView
                        
                        // Privacy Notice
                        privacyView
                        
                        // Action Buttons
                        actionButtonsView
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        viewModel.declineHealthKitAccess()
                        isPresented = false
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color(.systemBackground)
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Health Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [DesignSystem.Colors.accent, DesignSystem.Colors.accent.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(.white)
            }
            .scaleIn(delay: 0.2)
            
            VStack(spacing: 8) {
                Text("Sync Health Data")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .animatedAppearance(delay: 0.3)
                
                Text("Connect your health data to discover patterns between your physical wellbeing and mood")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .animatedAppearance(delay: 0.4)
            }
        }
    }
    
    private var benefitsView: some View {
        VStack(spacing: 20) {
            Text("Why Connect Health Data?")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .animatedAppearance(delay: 0.5)
            
            VStack(spacing: 16) {
                benefitRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Discover Patterns",
                    description: "See how sleep and activity affect your mood",
                    delay: 0.6
                )
                
                benefitRow(
                    icon: "lightbulb.fill",
                    title: "Personal Insights",
                    description: "Get personalized recommendations based on your data",
                    delay: 0.7
                )
                
                benefitRow(
                    icon: "shield.fill",
                    title: "Private & Secure",
                    description: "All data stays on your device and is never shared",
                    delay: 0.8
                )
            }
        }
    }
    
    private func benefitRow(icon: String, title: String, description: String, delay: Double) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                                            .fill(DesignSystem.Colors.accent.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.accent)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .animatedAppearance(delay: delay)
    }
    
    private var dataTypesView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Data We'll Access")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: { showingDetails.toggle() }) {
                    Text(showingDetails ? "Hide Details" : "Show Details")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.accent)
                }
            }
            .animatedAppearance(delay: 0.9)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                dataTypeCard(icon: "figure.walk", title: "Steps", description: "Daily step count")
                dataTypeCard(icon: "bed.double.fill", title: "Sleep", description: "Sleep duration")
                dataTypeCard(icon: "heart.fill", title: "Heart Rate", description: "Average heart rate")
                dataTypeCard(icon: "flame.fill", title: "Activity", description: "Active calories")
            }
            .scaleIn(delay: 1.0)
            
            if showingDetails {
                detailsView
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showingDetails)
    }
    
    private func dataTypeCard(icon: String, title: String, description: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.orange)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text(description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.5))
        )
    }
    
    private var detailsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Privacy Details")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                privacyPoint("• Data is read-only and never modified")
                privacyPoint("• Information stays on your device")
                privacyPoint("• You can revoke access anytime in Settings")
                privacyPoint("• We only access data from the last 30 days")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.3))
        )
    }
    
    private func privacyPoint(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    private var privacyView: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.title3)
                                    .foregroundColor(DesignSystem.weatherIconColor(isGood: true))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Privacy is Protected")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("Health data is processed locally and never leaves your device")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                                    .fill(DesignSystem.weatherIconColor(isGood: true).opacity(0.1))
        )
        .scaleIn(delay: 1.1)
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 16) {
            // Connect Button
            Button(action: {
                Task {
                    await viewModel.requestHealthKitAccess()
                    isPresented = false
                }
            }) {
                HStack {
                    Image(systemName: "heart.fill")
                        .font(.title3)
                    
                    Text("Connect Health Data")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [DesignSystem.Colors.accent, DesignSystem.Colors.accent.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .scaleIn(delay: 1.2)
            
            // Skip Button
            Button("Maybe Later") {
                viewModel.declineHealthKitAccess()
                isPresented = false
            }
            .foregroundColor(.secondary)
            .scaleIn(delay: 1.3)
        }
    }
}

#Preview {
    HealthKitPromptView(
        viewModel: MoodViewModel(),
        isPresented: .constant(true)
    )
} 