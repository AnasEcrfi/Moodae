//
//  AffirmationView.swift
//  Mooday
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

struct AffirmationView: View {
    let moodType: MoodType
    @Binding var isPresented: Bool
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    @State private var currentAffirmationIndex = 0
    @Environment(\.colorScheme) var colorScheme
    
    private let affirmations: [MoodType: [String]] = [
        .good: [
            "Your positive energy is contagious ✨",
            "You're creating beautiful moments",
            "Keep shining, you're doing amazing",
            "Your joy lights up the world",
            "Today's victories, big and small, matter"
        ],
        .challenging: [
            "This feeling is temporary, you are resilient 💙",
            "It's okay to have difficult days",
            "You're stronger than you know",
            "Tomorrow brings new possibilities",
            "Your feelings are valid, and you're not alone"
        ]
    ]
    
    private var currentAffirmation: String {
        affirmations[moodType]?[currentAffirmationIndex] ?? "You matter."
    }
    
    var body: some View {
        ZStack {
            // Background blur
            backgroundBlur
            
            // Main content
            VStack(spacing: 0) {
                Spacer()
                
                // Card content
                VStack(spacing: 32) {
                    // Success indicator
                    successIndicator
                    
                    // Affirmation content
                    affirmationContent
                    
                    // Action button
                    actionButton
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(cardBackgroundColor)
                        .shadow(color: shadowColor, radius: 20, x: 0, y: 10)
                )
                .padding(.horizontal, 24)
                .scaleEffect(isVisible ? 1.0 : 0.8)
                .opacity(isVisible ? 1.0 : 0.0)
                
                Spacer()
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isVisible)
        .onAppear {
            currentAffirmationIndex = Int.random(in: 0..<(affirmations[moodType]?.count ?? 1))
            withAnimation {
                isVisible = true
            }
        }
    }
    
    private var backgroundBlur: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .ignoresSafeArea()
            .onTapGesture {
                dismissView()
            }
    }
    
    private var successIndicator: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: moodColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: moodColors.first?.opacity(0.3) ?? .clear, radius: 12, x: 0, y: 6)
                
                Image(systemName: "checkmark")
                    .font(.title)
                    .font(.system(.body, design: .default).weight(.bold))
                    .foregroundColor(.white)
            }
            .scaleEffect(isVisible ? 1.0 : 0.3)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: isVisible)
            
            Text("Entry Saved!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .opacity(isVisible ? 1.0 : 0.0)
                .offset(y: isVisible ? 0 : 10)
                .animation(.easeOut(duration: 0.6).delay(0.3), value: isVisible)
        }
    }
    
    private var affirmationContent: some View {
        VStack(spacing: 16) {
            Text(currentAffirmation)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(isVisible ? 1.0 : 0.0)
                .offset(y: isVisible ? 0 : 20)
                .animation(.easeOut(duration: 0.8).delay(0.5), value: isVisible)
            
            Text("Take a moment to appreciate this step")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .opacity(isVisible ? 1.0 : 0.0)
                .offset(y: isVisible ? 0 : 15)
                .animation(.easeOut(duration: 0.6).delay(0.7), value: isVisible)
        }
    }
    
    private var actionButton: some View {
        Button(action: dismissView) {
            HStack {
                Image(systemName: "arrow.right")
                    .font(.system(.body, design: .default).weight(.semibold))
                
                Text("Continue")
                    .font(.system(.body, design: .default).weight(.semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: moodColors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: moodColors.first?.opacity(0.3) ?? .clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(y: isVisible ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(0.9), value: isVisible)
    }
    
    private var moodColors: [Color] {
        moodType == .good ? 
                            [DesignSystem.weatherIconColor(for: .good), DesignSystem.weatherIconColor(for: .good).opacity(0.8)] :
                            [DesignSystem.weatherIconColor(for: .challenging), DesignSystem.weatherIconColor(for: .challenging).opacity(0.8)]
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray6) : Color.white
    }
    
    private var shadowColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.15)
    }
    
    private func dismissView() {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            isVisible = false
        }
        
        // Call onDismiss immediately
        onDismiss()
    }
}

#Preview {
    AffirmationView(
        moodType: .good,
        isPresented: .constant(true)
    ) {
        // Preview dismiss action
    }
} 