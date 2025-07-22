import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var showMainApp = false
    @State private var showOnboarding = false
    @EnvironmentObject var pinManager: PINManager
    @Environment(\.colorScheme) var colorScheme
    
    private var hasCompletedOnboarding: Bool {
        UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView {
                    // Onboarding completed
                    withAnimation(.easeInOut(duration: 0.8)) {
                        showOnboarding = false
                        showMainApp = true
                    }
                }
                .transition(.opacity)
            } else if showMainApp {
                if pinManager.isPINEnabled && !pinManager.isUnlocked {
                    PINUnlockView(pinManager: pinManager)
                        .transition(.opacity)
                } else {
                    CustomTabBarView()
                        .transition(.opacity)
                }
            } else {
                splashContent
            }
        }
        .animation(.easeInOut(duration: 0.8), value: showMainApp)
        .animation(.easeInOut(duration: 0.8), value: showOnboarding)
    }
    
    private var splashContent: some View {
        ZStack {
            DesignSystem.Colors.surface.ignoresSafeArea()
            
            VStack(spacing: DesignSystem.Spacing.xl) {
                Spacer()
                
                // Content centered
                VStack(spacing: DesignSystem.Spacing.xl) {
                // Moodae Logo
                ZStack {
                    // Subtiler Background Circle - optional
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    DesignSystem.Colors.accent.opacity(0.05),
                                    DesignSystem.Colors.accent.opacity(0.02)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 2)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    
                    // Echtes Moodae Logo aus Assets
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 70)
                        .scaleEffect(isAnimating ? 1.0 : 0.95)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .delay(0.3),
                            value: isAnimating
                        )
                }
                
                // App Name
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text("Moodae")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(DesignSystem.Colors.secondary.opacity(0.9))
                    
                    Text("calm. honest. modern.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.secondary.opacity(0.9))
                        .tracking(0.8)
                }
                .opacity(isAnimating ? 1.0 : 0.6)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .delay(0.5),
                    value: isAnimating
                )
                }
                
                Spacer()
                
                // Loading indicator
                VStack(spacing: DesignSystem.Spacing.md) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.accent))
                        .scaleEffect(0.8)
                    
                    Text("Loading...")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(DesignSystem.Colors.secondary.opacity(0.7))
                }
                .opacity(isAnimating ? 1.0 : 0.0)
                .animation(
                    Animation.easeInOut(duration: 1.0)
                        .delay(1.0),
                    value: isAnimating
                )
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
            
            // Check if onboarding is needed and show appropriate screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    if hasCompletedOnboarding {
                        showMainApp = true
                    } else {
                        showOnboarding = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
} 