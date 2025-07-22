//
//  AnimationExtensions.swift
//  Mooday
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

// MARK: - Accessible Animation Extensions

extension View {
    
    /// Applies subtle appearance animation with reduced motion support
    func subtleAppearance(delay: Double = 0) -> some View {
        modifier(SubtleAppearance(delay: delay))
    }
    
    /// Applies scale-in animation with reduced motion support
    @ViewBuilder
    func scaleIn(delay: Double = 0) -> some View {
        if UIAccessibility.isReduceMotionEnabled {
            self
        } else {
            self
                .modifier(ScaleInAnimation(delay: delay))
        }
    }
    
    /// Applies animated appearance with reduced motion support
    @ViewBuilder
    func animatedAppearance(delay: Double = 0) -> some View {
        if UIAccessibility.isReduceMotionEnabled {
            self
        } else {
            self
                .modifier(AnimatedAppearance(delay: delay))
        }
    }
}

// MARK: - Animation Presets with Accessibility

extension Animation {
    static var moodayEase: Animation {
        if UIAccessibility.isReduceMotionEnabled {
            return .easeInOut(duration: 0.2)
        } else {
            return .spring(response: 0.4, dampingFraction: 0.8)
        }
    }
    
    static var smoothSpring: Animation {
        if UIAccessibility.isReduceMotionEnabled {
            return .easeInOut(duration: 0.15)
        } else {
            return .spring(response: 0.3, dampingFraction: 0.7)
        }
    }
}

// MARK: - Haptic Feedback with Accessibility

struct HapticFeedback {
    static let light = UIImpactFeedbackGenerator(style: .light)
    static let medium = UIImpactFeedbackGenerator(style: .medium)
    static let heavy = UIImpactFeedbackGenerator(style: .heavy)
    
    static func trigger(_ generator: UIImpactFeedbackGenerator) {
        // Only trigger haptics if not disabled in accessibility settings
        if !UIAccessibility.isReduceMotionEnabled {
            generator.impactOccurred()
        }
    }
}

extension UIImpactFeedbackGenerator {
    func trigger() {
        HapticFeedback.trigger(self)
    }
}

// MARK: - Clean Button Styles
struct CleanButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.95 : 1.0)
            .animation(.smoothSpring, value: configuration.isPressed)
    }
}

struct SmoothButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.smoothSpring, value: configuration.isPressed)
    }
}

struct CardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
            .animation(.smoothSpring, value: configuration.isPressed)
    }
}

// MARK: - Accessible Subtle Entrance Animations
struct SubtleAppearance: ViewModifier {
    @State private var isVisible = false
    let delay: Double
    let duration: Double
    
    init(delay: Double = 0, duration: Double = 0.4) {
        self.delay = delay
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        let shouldReduceAnimations = UIAccessibility.isReduceMotionEnabled || 
                                   UserDefaults.standard.bool(forKey: "reduceAnimationsEnabled")
        
        if shouldReduceAnimations {
            // Show immediately for accessibility
            content
                .onAppear {
                    isVisible = true
                }
        } else {
            content
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 8) // Very subtle offset
                .animation(.easeOut(duration: duration), value: isVisible)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        isVisible = true
                    }
                }
        }
    }
}

extension View {
    func modernAppearance(delay: Double = 0, duration: Double = 0.4) -> some View {
        modifier(SubtleAppearance(delay: delay, duration: duration))
    }
    
    // Legacy support
    func animatedAppearance(delay: Double = 0, duration: Double = 0.6) -> some View {
        modernAppearance(delay: delay, duration: min(duration, 0.4)) // Cap at 0.4s for subtlety
    }
}

// MARK: - Modern Slide Animation
struct ModernSlideIn: ViewModifier {
    @State private var isVisible = false
    let direction: Edge
    let delay: Double
    
    init(from direction: Edge = .bottom, delay: Double = 0) {
        self.direction = direction
        self.delay = delay
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(
                x: isVisible ? 0 : (direction == .leading ? -12 : direction == .trailing ? 12 : 0),
                y: isVisible ? 0 : (direction == .top ? -12 : direction == .bottom ? 12 : 0)
            )
            .animation(.smoothSpring, value: isVisible)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func modernSlideIn(from direction: Edge = .bottom, delay: Double = 0) -> some View {
        modifier(ModernSlideIn(from: direction, delay: delay))
    }
    
    // Legacy support
    func slideIn(from direction: Edge = .bottom, delay: Double = 0) -> some View {
        modernSlideIn(from: direction, delay: delay)
    }
}

// MARK: - Gentle Scale Animation
struct GentleScale: ViewModifier {
    @State private var isVisible = false
    let delay: Double
    
    init(delay: Double = 0) {
        self.delay = delay
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isVisible ? 1 : 0.95) // Very subtle scale
            .opacity(isVisible ? 1 : 0)
            .animation(.smoothSpring, value: isVisible)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func gentleScale(delay: Double = 0) -> some View {
        modifier(GentleScale(delay: delay))
    }
    
    func modernScaleIn(delay: Double = 0) -> some View {
        gentleScale(delay: delay)
    }
    
    // Legacy support - replaced with accessible version above
}

// MARK: - Staggered Animation (Clean)
struct CleanStaggered: ViewModifier {
    let index: Int
    let total: Int
    let baseDelay: Double
    
    init(index: Int, total: Int, baseDelay: Double = 0.05) {
        self.index = index
        self.total = total
        self.baseDelay = baseDelay
    }
    
    func body(content: Content) -> some View {
        content
            .subtleAppearance(delay: Double(index) * baseDelay)
    }
}

extension View {
    func cleanStaggered(index: Int, total: Int, baseDelay: Double = 0.05) -> some View {
        modifier(CleanStaggered(index: index, total: total, baseDelay: baseDelay))
    }
    
    // Legacy support
    func staggered(index: Int, total: Int) -> some View {
        cleanStaggered(index: index, total: total)
    }
}

// MARK: - Fade Transition (Subtle)
struct SubtleFade: ViewModifier {
    let isVisible: Bool
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .animation(.moodayEase, value: isVisible)
    }
}

extension View {
    func subtleFade(isVisible: Bool) -> some View {
        modifier(SubtleFade(isVisible: isVisible))
    }
}

// MARK: - Interactive Feedback (Minimal)
struct InteractiveFeedback: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.99 : 1.0)
            .opacity(isPressed ? 0.98 : 1.0)
            .animation(.smoothSpring, value: isPressed)
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
    }
}

extension View {
    func interactiveFeedback() -> some View {
        modifier(InteractiveFeedback())
    }
}

// MARK: - Loading Animation (Minimal)
struct MinimalLoading: View {
    @State private var isAnimating = false
    let size: CGFloat
    let color: Color
    
    init(size: CGFloat = 20, color: Color = .secondary) {
        self.size = size
        self.color = color
    }
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(color, lineWidth: 2)
            .frame(width: size, height: size)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}

// MARK: - Breathing Animation (Very Subtle)
struct BreathingEffect: ViewModifier {
    @State private var isBreathing = false
    let intensity: Double
    
    init(intensity: Double = 0.02) { // Very subtle
        self.intensity = intensity
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isBreathing ? 1 + intensity : 1)
            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isBreathing)
            .onAppear {
                isBreathing = true
            }
    }
}

extension View {
    func breathingEffect(intensity: Double = 0.02) -> some View {
        modifier(BreathingEffect(intensity: intensity))
    }
} 

// MARK: - Animated Weather Icons for Mood Cards
struct AnimatedWeatherMoodIcon: View {
    let mood: MoodType
    let size: CGFloat
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            switch mood.mainCategory {
            case .positive:
                sunIcon
            case .difficult:
                rainCloudIcon
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    // MARK: - Sun Icon with Rotation
    private var sunIcon: some View {
        ZStack {
            Image(systemName: "sun.max.fill")
                .foregroundColor(.yellow)
                .font(.system(size: size, weight: .medium))
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 8)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
            
            // Subtle glow effect
            Image(systemName: "sun.max.fill")
                .foregroundColor(.yellow.opacity(0.3))
                .font(.system(size: size, weight: .medium))
                .scaleEffect(1.2)
                .opacity(isAnimating ? 0.6 : 0.3)
                .animation(
                    Animation.easeInOut(duration: 2)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
    }
    
    // MARK: - Rain Cloud with Animated Drops
    private var rainCloudIcon: some View {
        ZStack {
            Image(systemName: "cloud.rain.fill")
                .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
                .font(.system(size: size, weight: .medium))
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 3)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            // Animated rain drops
            VStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color(red: 0.3, green: 0.4, blue: 0.5).opacity(0.7))
                        .frame(width: 2.5, height: 2.5)
                        .offset(y: isAnimating ? 15 : -8)
                        .animation(
                            Animation.linear(duration: 1.5)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index) * 0.3),
                            value: isAnimating
                        )
                }
            }
            .offset(y: size * 0.25)
        }
    }
    
    // MARK: - Animation Control
    private func startAnimation() {
        withAnimation(.easeInOut(duration: 0.5)) {
            isAnimating = true
        }
    }
}

// MARK: - Animated Mood Icons for Graphs
struct AnimatedMoodIcon: View {
    let mood: MoodType
    let size: CGFloat
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Base mood icon
            Image(systemName: mood.icon)
                .foregroundColor(DesignSystem.moodIconColor(for: mood))
                .font(.system(size: size, weight: .medium))
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            // Subtle glow effect for positive moods
            if mood.mainCategory == .positive {
                Image(systemName: mood.icon)
                    .foregroundColor(DesignSystem.moodIconColor(for: mood).opacity(0.3))
                    .font(.system(size: size, weight: .medium))
                    .scaleEffect(1.2)
                    .opacity(isAnimating ? 0.7 : 0.4)
                    .animation(
                        Animation.easeInOut(duration: 3.0)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
            
            // Pulse effect for difficult moods
            if mood.mainCategory == .difficult {
                Image(systemName: mood.icon)
                    .foregroundColor(DesignSystem.moodIconColor(for: mood).opacity(0.2))
                    .font(.system(size: size, weight: .medium))
                    .scaleEffect(isAnimating ? 1.3 : 1.0)
                    .opacity(isAnimating ? 0.5 : 0.0)
                    .animation(
                        Animation.easeOut(duration: 1.5)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        withAnimation(.easeInOut(duration: 0.5)) {
            isAnimating = true
        }
    }
}

// MARK: - Animation Modifiers

struct ScaleInAnimation: ViewModifier {
    let delay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isVisible ? 1.0 : 0.8)
            .opacity(isVisible ? 1.0 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

struct AnimatedAppearance: ViewModifier {
    let delay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isVisible ? 1.0 : 0.9)
            .opacity(isVisible ? 1.0 : 0)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Mood Icon Extensions for easy use
extension View {
    func animatedMoodIcon(_ mood: MoodType, size: CGFloat = 24) -> some View {
        AnimatedMoodIcon(mood: mood, size: size)
    }
    
    func animatedWeatherMoodIcon(_ mood: MoodType, size: CGFloat = 24) -> some View {
        AnimatedWeatherMoodIcon(mood: mood, size: size)
    }
} 