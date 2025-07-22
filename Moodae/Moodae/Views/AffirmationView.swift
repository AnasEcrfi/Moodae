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
        .amazing: [
            "You're radiating pure magic today ✨",
            "This energy is incredible - keep it flowing!",
            "You're unstoppable right now",
            "Amazing things happen to amazing people",
            "Your light is shining so bright today",
            "This is your moment to soar",
            "You're living your best life",
            "Your positive energy is transforming everything",
            "Today is proof of your incredible power",
            "You're creating miracles just by being you",
            "The universe is conspiring in your favor",
            "Your joy is magnetic and inspiring",
            "You're in perfect alignment with your purpose",
            "This feeling is your natural state",
            "You're a walking example of possibility",
            "Your enthusiasm is changing lives",
            "You're writing the best chapter yet",
            "Everything is working out beautifully",
            "You're attracting abundance effortlessly",
            "This energy will ripple into tomorrow"
        ],
        .good: [
            "Your positive energy is contagious ✨",
            "You're creating beautiful moments",
            "Keep shining, you're doing amazing",
            "Your joy lights up the world",
            "Today's victories, big and small, matter",
            "You're exactly where you need to be",
            "Your smile changes everything",
            "Good things flow to you naturally",
            "You're making a difference today",
            "This feeling suits you perfectly",
            "You're building momentum with every step",
            "Your optimism is your superpower",
            "Life is responding to your positive vibes",
            "You're cultivating happiness from within",
            "Your gratitude is multiplying your blessings",
            "You're becoming the person you're meant to be",
            "Small joys create lasting happiness",
            "You're proof that good things happen",
            "Your presence brings light to others",
            "This is what contentment feels like"
        ],
        .okay: [
            "Okay days are still worthy days 🌱",
            "You're doing better than you think",
            "Small steps count too",
            "Balance is beautiful",
            "You're allowed to just be today",
            "Steady progress is still progress",
            "You're holding space for yourself",
            "Even neutral days have value",
            "You're exactly enough right now",
            "Tomorrow holds new possibilities",
            "Being average is perfectly acceptable",
            "You're in a season of gentle growth",
            "Stability has its own kind of strength",
            "You're honoring your natural rhythms",
            "Not every day needs to be extraordinary",
            "You're building resilience in quiet ways",
            "Consistency is more valuable than intensity",
            "You're learning to be present",
            "This calm energy serves you well",
            "You're exactly where you're supposed to be"
        ],
        .challenging: [
            "This feeling is temporary, you are resilient 🤍",
            "It's okay to have difficult days",
            "You're stronger than you know",
            "Tomorrow brings new possibilities",
            "Your feelings are valid, and you're not alone",
            "Every storm passes eventually",
            "You've overcome challenges before",
            "Rest is part of the healing process",
            "You're allowed to feel this way",
            "Your courage shows even in hard times",
            "You're doing the best you can right now",
            "Healing isn't linear, and that's okay",
            "This chapter doesn't define your story",
            "Your sensitivity is a strength, not weakness",
            "You're learning something important today"
        ],
        .tough: [
            "You're braver than you believe 💪",
            "This pain won't last forever",
            "One breath at a time is enough",
            "You're not walking this path alone",
            "Your strength runs deeper than this moment",
            "It's okay to ask for support",
            "You matter, especially on hard days",
            "This is temporary, you are permanent",
            "Your resilience is remarkable",
            "Better days are coming, trust the process",
            "You've survived every hard day so far",
            "Your scars tell a story of survival",
            "Difficult roads often lead to beautiful places",
            "You're stronger in the broken places",
            "This struggle is shaping your wisdom",
            "You're allowed to rest when you're tired",
            "Progress includes the messy middle",
            "Your pain has purpose, even if hidden",
            "You're writing a comeback story",
            "The mountain teaches you to climb"
        ],
        .overwhelming: [
            "You will get through this 🫂",
            "Take it one moment at a time",
            "You're stronger than this feeling",
            "Reach out - you don't have to face this alone",
            "This intensity will pass",
            "You deserve support and care",
            "Your feelings are completely valid",
            "You've survived 100% of your hardest days",
            "Healing takes time, be patient with yourself",
            "You are loved, even when it's hard to feel",
            "This storm is temporary, you are not",
            "You don't have to carry this alone",
            "Professional help is a sign of strength",
            "Your mental health matters deeply",
            "It's okay to not be okay right now",
            "You're worthy of compassion and care",
            "This feeling will not consume you",
            "You have people who want to help",
            "Crisis hotlines are there for you",
            "Tomorrow can look different than today"
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
                            colors: [DesignSystem.Colors.success, DesignSystem.Colors.success.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: DesignSystem.Colors.success.opacity(0.3), radius: 12, x: 0, y: 6)
                
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
                    colors: [DesignSystem.Colors.accent, DesignSystem.Colors.accent.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: DesignSystem.Colors.accent.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(y: isVisible ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(0.9), value: isVisible)
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