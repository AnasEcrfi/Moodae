//
//  SmartPredictionView.swift
//  Mooday
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

struct SmartPredictionView: View {
    let prediction: MoodPrediction
    @State private var showDetails = false
    @State private var animateConfidence = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            // Compact header
            compactHeaderView
            
            // Subtle prediction content
            compactPredictionView
            
            // Expandable details (optional)
            if showDetails {
                detailsView
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(cardBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.quaternary, lineWidth: 0.5)
                )
        )
        .padding(.horizontal, 20)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).delay(0.2)) {
                animateConfidence = true
            }
        }
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray6) : Color.white
    }
    
    private var compactHeaderView: some View {
        HStack {
            // Subtle AI indicator
            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .foregroundColor(.secondary)
                    .font(.caption2)
                
                Text("KI Tipp")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Compact confidence
            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(index < Int(prediction.confidence * 3) ? DesignSystem.weatherIconColor(isGood: true).opacity(0.7) : .gray.opacity(0.3))
                        .frame(width: 4, height: 4)
                        .scaleEffect(animateConfidence ? 1.0 : 0.5)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.05), value: animateConfidence)
                }
            }
        }
    }
    
    private var compactPredictionView: some View {
        HStack(spacing: 12) {
            // Small mood icon
            Image(systemName: prediction.predictedMood == .good ? "sun.max.fill" : "cloud.rain.fill")
                .font(.title3)
                .foregroundColor(DesignSystem.weatherIconColor(isGood: prediction.predictedMood == .good))
                .scaleEffect(animateConfidence ? 1.0 : 0.8)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: animateConfidence)
            
            // Compact text
            VStack(alignment: .leading, spacing: 2) {
                Text("Heute wahrscheinlich \(prediction.predictedMood.displayName.lowercased())")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                if !prediction.mainReason.isEmpty {
                    Text(prediction.mainReason)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Optional expand button
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showDetails.toggle()
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .rotationEffect(.degrees(showDetails ? 90 : 0))
            }
        }
        .opacity(animateConfidence ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 0.5).delay(0.3), value: animateConfidence)
    }
    
    private var mainPredictionView: some View {
        VStack(spacing: 16) {
            // Predicted mood with icon
            VStack(spacing: 8) {
                // Mood icon with animation
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: prediction.predictedMood == .good ? 
                                    [DesignSystem.weatherIconColor(isGood: true).opacity(0.3), DesignSystem.weatherIconColor(isGood: true).opacity(0.2)] :
                                    [DesignSystem.weatherIconColor(isGood: false).opacity(0.3), DesignSystem.weatherIconColor(isGood: false).opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: DesignSystem.moodIconName(for: prediction.predictedMood, filled: true))
                        .font(.system(size: 32))
                        .foregroundColor(DesignSystem.moodIconColor(for: prediction.predictedMood))
                        .scaleEffect(animateConfidence ? 1.0 : 0.8)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: animateConfidence)
                }
                
                // Predicted mood text
                VStack(spacing: 4) {
                    Text("Du wirst dich wahrscheinlich")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(prediction.predictedMood.displayName.lowercased())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.moodColor(for: prediction.predictedMood))
                    
                                            Text("feel")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Main reason
            if !prediction.mainReason.isEmpty {
                Text(prediction.mainReason)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .opacity(animateConfidence ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(0.5), value: animateConfidence)
            }
            
            // Expand button
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showDetails.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Text(showDetails ? "Weniger anzeigen" : "Mehr Details")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .rotationEffect(.degrees(showDetails ? 180 : 0))
                }
                .foregroundColor(.purple)
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }
    
    private var detailsView: some View {
        VStack(spacing: 16) {
            Divider()
                .padding(.horizontal, 20)
            
            // Additional reasons
            if prediction.reasons.count > 1 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Additional reasons:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    ForEach(Array(prediction.reasons.dropFirst().enumerated()), id: \.offset) { index, reason in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(DesignSystem.weatherIconColor(isGood: true))
                                .font(.caption)
                                .padding(.top, 2)
                            
                            Text(reason)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .opacity(showDetails ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.5).delay(Double(index) * 0.1), value: showDetails)
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Suggested categories
            if !prediction.suggestedCategories.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Common activities at this time:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(Array(prediction.suggestedCategories.prefix(4).enumerated()), id: \.offset) { index, category in
                            HStack {
                                Text(getCategoryIcon(category))
                                    .font(.caption)
                                
                                Text(category)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                            )
                            .opacity(showDetails ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 0.4).delay(Double(index) * 0.05), value: showDetails)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Time info
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                Text("Vorhersage von \(prediction.timeOfPrediction.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 16)
        }
    }
    
    private func getCategoryIcon(_ category: String) -> String {
        switch category.lowercased() {
        case "arbeit", "work": return "💼"
        case "sport", "fitness": return "🏃‍♂️"
        case "essen", "food": return "🍽️"
        case "schlafen", "sleep": return "😴"
        case "freunde", "friends": return "👥"
        case "familie", "family": return "👨‍👩‍👧‍👦"
        case "entspannung", "relax": return "🧘‍♀️"
        case "lernen", "study": return "📚"
        case "musik", "music": return "🎵"
        case "natur", "nature": return "🌳"
        default: return "✨"
        }
    }
}

// MARK: - Loading State

struct SmartPredictionLoadingView: View {
    @State private var opacity: Double = 0.3
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Subtle loading indicator
            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .foregroundColor(.secondary)
                    .font(.caption2)
                
                Text("KI analysiert...")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Simple animated dots
            HStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(.secondary)
                        .frame(width: 3, height: 3)
                        .opacity(opacity)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                            value: opacity
                        )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(cardBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.quaternary, lineWidth: 0.5)
                )
        )
        .padding(.horizontal, 20)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                opacity = 1.0
            }
        }
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray6) : Color.white
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        SmartPredictionLoadingView()
        
        SmartPredictionView(
            prediction: MoodPrediction(
                predictedMood: .good,
                confidence: 0.85,
                score: 4.2,
                reasons: [
                    "You usually feel energized in the mornings",
                    "Deine Stimmung hat sich in den letzten Tagen verbessert",
                    "Sonniges Wetter wirkt sich positiv auf dich aus"
                ],
                suggestedCategories: ["Sport", "Arbeit", "Kaffee", "Musik"],
                timeOfPrediction: Date()
            )
        )
    }
    .background(Color(.systemGroupedBackground))
} 