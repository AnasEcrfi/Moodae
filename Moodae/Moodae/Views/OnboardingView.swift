//
//  OnboardingView.swift
//  Moodae
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

// HapticFeedback Helper für Onboarding
enum OnboardingHapticFeedback {
    case light, medium, success
    
    func trigger() {
        switch self {
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var isAnimating = false
    let onComplete: () -> Void
    
    private let totalPages = 4
    
    var body: some View {
        ZStack {
            // Modern Background mit Gradient
            modernBackground
            
            VStack(spacing: 0) {
                // Skip Button (nur bei ersten Slides)
                if currentPage < totalPages - 1 {
                    topNavigationBar
                }
                
                // Page Content
                TabView(selection: $currentPage) {
                    // Slide 1: Welcome
                    welcomeSlide.tag(0)
                    
                    // Slide 2: Privacy First  
                    privacySlide.tag(1)
                    
                    // Slide 3: Features
                    featuresSlide.tag(2)
                    
                    // Slide 4: Get Started
                    getStartedSlide.tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.moodayEase, value: currentPage)
                
                // Bottom Navigation
                bottomNavigationBar
            }
        }
        .onAppear {
            withAnimation(.moodayEase.delay(0.3)) {
                isAnimating = true
            }
        }
    }
    
    // MARK: - Background
    private var modernBackground: some View {
        ZStack {
            DesignSystem.Colors.surface
                .ignoresSafeArea()
            
            // Subtile Gradient Overlay basierend auf aktuellem Slide
            LinearGradient(
                colors: backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(0.1)
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.8), value: currentPage)
        }
    }
    
    private var backgroundColors: [Color] {
        switch currentPage {
        case 0: return [DesignSystem.Colors.accent, DesignSystem.Colors.secondary]
        case 1: return [DesignSystem.Colors.success, DesignSystem.Colors.accent]
        case 2: return [DesignSystem.Colors.info, DesignSystem.Colors.accent]
        default: return [DesignSystem.Colors.accent, DesignSystem.Colors.success]
        }
    }
    
    // MARK: - Top Navigation
    private var topNavigationBar: some View {
        HStack {
            Spacer()
            
                         Button("Skip") {
                 OnboardingHapticFeedback.light.trigger()
                 completeOnboarding()
             }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(DesignSystem.Colors.secondary)
        }
        .padding(.horizontal, DesignSystem.Spacing.xl)
        .padding(.top, DesignSystem.Spacing.lg)
    }
    
    // MARK: - Slide 1: Welcome
    private var welcomeSlide: some View {
        ZStack {
            OnboardingSlideView(
                icon: "heart.fill",
                iconColor: DesignSystem.Colors.accent,
                title: "Welcome to Moodae",
                subtitle: "Your personal sanctuary for emotional wellness",
                description: "Track your daily moods with beautiful insights while keeping your data completely private on your device.",
                animation: .spring(response: 0.8, dampingFraction: 0.8),
                delay: isAnimating ? 0.2 : 0
            )
            
            // Schriftzug unten - wie im originalen Design
            VStack {
                Spacer()
                
                Text("calm. honest. modern.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.secondary.opacity(0.9))
                    .tracking(0.8)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 20)
                    .animation(.spring(response: 1.2, dampingFraction: 0.8).delay(1.5), value: isAnimating)
                    .padding(.bottom, 120) // Über den Navigations-Buttons
            }
        }
    }
    
    // MARK: - Slide 2: Privacy First
    private var privacySlide: some View {
        OnboardingSlideView(
            icon: "lock.shield.fill",
            iconColor: DesignSystem.Colors.success,
            title: "Privacy First",
            subtitle: "Your data stays with you",
            description: "No accounts, no cloud storage, no tracking. Everything stays secure on your device.",
            features: [
                "🔒 Local-only storage",
                "🚫 No data collection", 
                "📱 Complete user control"
            ],
            animation: .spring(response: 0.8, dampingFraction: 0.8),
            delay: isAnimating ? 0.2 : 0
        )
    }
    
    // MARK: - Slide 3: Features
    private var featuresSlide: some View {
        OnboardingSlideView(
            icon: "chart.line.uptrend.xyaxis",
            iconColor: DesignSystem.Colors.info,
            title: "Discover Patterns",
            subtitle: "Beautiful insights into your emotional journey",
            description: "Track moods with rich categories and view trends in stunning visualizations.",
            features: [
                "📝 Rich mood categories",
                "📊 Beautiful visualizations",
                "📅 Interactive calendar",
                "🎯 Personal insights"
            ],
            animation: .spring(response: 0.8, dampingFraction: 0.8),
            delay: isAnimating ? 0.2 : 0
        )
    }
    
    // MARK: - Slide 4: Get Started
    private var getStartedSlide: some View {
        OnboardingSlideView(
            icon: "sun.max.fill",
            iconColor: DesignSystem.Colors.accent,
            title: "Ready to Begin?",
            subtitle: "Start your wellness journey today",
            description: "Take a moment each day to check in with yourself. Small steps lead to profound insights.",
            animation: .spring(response: 0.8, dampingFraction: 0.8),
            delay: isAnimating ? 0.2 : 0,
            showGetStartedButton: true,
            onGetStarted: completeOnboarding
        )
    }
    
    // MARK: - Bottom Navigation
    private var bottomNavigationBar: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            // Page Indicators
            pageIndicators
            
            // Navigation Buttons (nicht bei letzter Slide)
            if currentPage < totalPages - 1 {
                navigationButtons
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.xl)
        .padding(.bottom, DesignSystem.Spacing.xxxl)
    }
    
    private var pageIndicators: some View {
        HStack(spacing: 12) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? DesignSystem.Colors.accent : DesignSystem.Colors.secondary.opacity(0.3))
                    .frame(width: index == currentPage ? 12 : 8, height: index == currentPage ? 12 : 8)
                    .animation(.moodayEase, value: currentPage)
            }
        }
    }
    
    private var navigationButtons: some View {
        HStack {
            // Back Button (ab Slide 2)
            if currentPage > 0 {
                                 Button("Back") {
                     OnboardingHapticFeedback.light.trigger()
                     withAnimation(.moodayEase) {
                         currentPage = max(0, currentPage - 1)
                     }
                 }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DesignSystem.Colors.secondary)
            }
            
            Spacer()
            
            // Next Button
                         Button("Next") {
                 OnboardingHapticFeedback.medium.trigger()
                 withAnimation(.moodayEase) {
                     if currentPage < totalPages - 1 {
                         currentPage += 1
                     }
                 }
             }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(DesignSystem.Colors.accent)
            )
            .buttonStyle(CleanButtonStyle())
        }
    }
    
    // MARK: - Actions
    private func completeOnboarding() {
        OnboardingHapticFeedback.success.trigger()
        
        // Mark onboarding as completed
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Call completion handler
        onComplete()
    }
}

// MARK: - Individual Slide Component

struct OnboardingSlideView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let description: String
    let features: [String]?
    let animation: Animation
    let delay: Double
    let showGetStartedButton: Bool
    let onGetStarted: (() -> Void)?
    
    @State private var isVisible = false
    
    init(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        description: String,
        features: [String]? = nil,
        animation: Animation = .spring(),
        delay: Double = 0,
        showGetStartedButton: Bool = false,
        onGetStarted: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.features = features
        self.animation = animation
        self.delay = delay
        self.showGetStartedButton = showGetStartedButton
        self.onGetStarted = onGetStarted
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Icon - zentriert
                    iconView
                    
                    Spacer(minLength: DesignSystem.Spacing.xl)
                    
                    // Content - zentriert
                    contentView
                    
                    // Features List (wenn vorhanden) - zentriert
                    if let features = features {
                        Spacer(minLength: DesignSystem.Spacing.lg)
                        compactFeaturesView(features)
                    }
                    
                    Spacer()
                    
                    // Get Started Button (nur auf letzter Slide) - zentriert
                    if showGetStartedButton {
                        getStartedButtonView
                            .padding(.bottom, DesignSystem.Spacing.xl)
                    }
                    
                    Spacer(minLength: showGetStartedButton ? DesignSystem.Spacing.sm : DesignSystem.Spacing.xl)
                }
                .frame(maxWidth: geometry.size.width - (DesignSystem.Spacing.xl * 2))
                
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .onAppear {
            // Gestaffelte Animation für besseren Effekt
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    isVisible = true
                }
            }
        }
    }
    
    private var iconView: some View {
        ZStack {
            // Äußerer Kreis mit sanfter Pulse-Animation
            Circle()
                .fill(iconColor.opacity(0.08))
                .frame(width: 100, height: 100)
                .scaleEffect(isVisible ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isVisible)
            
            // Mittlerer Kreis - statisch für bessere Performance
            Circle()
                .fill(iconColor.opacity(0.12))
                .frame(width: 70, height: 70)
            
            // Icon - vereinfachte Animation, aber sichtbar
            Image(systemName: icon)
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(iconColor)
                .scaleEffect(isVisible ? 1.0 : 0.5)
                .opacity(isVisible ? 1.0 : 0.0)
                .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2), value: isVisible)
        }
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .opacity(isVisible ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: isVisible)
    }
    
    private var contentView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Minimalistischer Titel mit Typewriter-Effekt
            Text(title)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .opacity(isVisible ? 1.0 : 0.0)
                .offset(y: isVisible ? 0 : 50)
                .scaleEffect(isVisible ? 1.0 : 0.8)
                .animation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.5), value: isVisible)
            
            // Dezenter Subtitle mit Slide-in von links
            Text(subtitle)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(iconColor)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .opacity(isVisible ? 1.0 : 0.0)
                .offset(x: isVisible ? 0 : -100, y: isVisible ? 0 : 10)
                .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.7), value: isVisible)
            
            // Kompakte Beschreibung mit Fade-in von rechts
            Text(description)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(DesignSystem.Colors.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(isVisible ? 1.0 : 0.0)
                .offset(x: isVisible ? 0 : 100)
                .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.9), value: isVisible)
        }
    }
    
    private func compactFeaturesView(_ features: [String]) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(features.indices, id: \.self) { index in
                HStack(spacing: DesignSystem.Spacing.sm) {
                    // Animierter Punkt mit Bounce
                    Circle()
                        .fill(iconColor)
                        .frame(width: 6, height: 6)
                        .scaleEffect(isVisible ? 1.2 : 0.0)
                        .opacity(isVisible ? 1.0 : 0.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.3).delay(1.1 + Double(index) * 0.15), value: isVisible)
                    
                    Text(features[index].dropFirst(2)) // Entfernt Emoji
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.primary)
                        .multilineTextAlignment(.center)
                        .opacity(isVisible ? 1.0 : 0.0)
                        .offset(x: isVisible ? 0 : -50)
                        .scaleEffect(isVisible ? 1.0 : 0.5)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(1.2 + Double(index) * 0.15), value: isVisible)
                }
                .frame(maxWidth: 200) // Begrenzte Breite für bessere Zentrierung
                .contentShape(Rectangle())
                .onTapGesture {
                    // Kleine Tap-Animation für Interaktivität
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        // Kurze Scale-Animation
                    }
                    OnboardingHapticFeedback.light.trigger()
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
        private var getStartedButtonView: some View {
        Button(action: {
            OnboardingHapticFeedback.success.trigger()
            // Kleine Button-Animation beim Tap
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                // Scale-Effekt wird automatisch durch CleanButtonStyle behandelt
            }
            
            // Delayed action für bessere UX
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                onGetStarted?()
            }
        }) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Text("Get Started for Free")
                    .font(.system(size: 16, weight: .semibold))
                    .opacity(isVisible ? 1.0 : 0.0)
                    .offset(x: isVisible ? 0 : -20)
                    .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(1.5), value: isVisible)
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                    .offset(x: isVisible ? 0 : -30)
                    .rotationEffect(.degrees(isVisible ? 0 : -180))
                    .animation(.spring(response: 1.0, dampingFraction: 0.6).delay(1.7), value: isVisible)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(
                        LinearGradient(
                            colors: [iconColor, iconColor.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .scaleEffect(isVisible ? 1.0 : 0.1)
                    .animation(.spring(response: 1.2, dampingFraction: 0.5).delay(1.3), value: isVisible)
            )
        }
        .buttonStyle(CleanButtonStyle())
        .scaleEffect(isVisible ? 1.0 : 0.0)
        .opacity(isVisible ? 1.0 : 0.0)
        .animation(.spring(response: 1.0, dampingFraction: 0.6).delay(1.3), value: isVisible)
        .shadow(color: iconColor.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    OnboardingView {
        print("Onboarding completed")
    }
} 