import SwiftUI

// MARK: - Global Text Scaling ViewModifier

struct AppTextScaling: ViewModifier {
    @State private var customTextSizeEnabled = UserDefaults.standard.bool(forKey: "customTextSizeEnabled")
    @State private var customTextSize = UserDefaults.standard.object(forKey: "customTextSize") as? Double ?? 1.0
    
    func body(content: Content) -> some View {
        content
            .environment(\.sizeCategory, customTextSizeEnabled ? 
                         calculateSizeCategory(from: customTextSize) : .large)
            .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
                // Update when UserDefaults change
                customTextSizeEnabled = UserDefaults.standard.bool(forKey: "customTextSizeEnabled")
                customTextSize = UserDefaults.standard.object(forKey: "customTextSize") as? Double ?? 1.0
            }
    }
    
    private func calculateSizeCategory(from scale: Double) -> ContentSizeCategory {
        // Map scale factor to appropriate ContentSizeCategory
        switch scale {
        case ...0.85: return .small
        case 0.85...0.95: return .medium
        case 0.95...1.05: return .large
        case 1.05...1.15: return .extraLarge
        case 1.15...1.25: return .extraExtraLarge
        case 1.25...1.35: return .extraExtraExtraLarge
        case 1.35...1.45: return .accessibilityMedium
        case 1.45...1.55: return .accessibilityLarge
        case 1.55...: return .accessibilityExtraLarge
        default: return .large
        }
    }
}

// MARK: - Convenience Extension

extension View {
    func withAppTextScaling() -> some View {
        self.modifier(AppTextScaling())
    }
}

// MARK: - Notification Helper for Real-time Updates

extension UserDefaults {
    static let textSizeDidChangeNotification = Notification.Name("TextSizeDidChange")
    
    func setTextSize(_ size: Double) {
        set(size, forKey: "customTextSize")
        NotificationCenter.default.post(name: Self.textSizeDidChangeNotification, object: nil)
    }
    
    func setTextSizeEnabled(_ enabled: Bool) {
        set(enabled, forKey: "customTextSizeEnabled")
        NotificationCenter.default.post(name: Self.textSizeDidChangeNotification, object: nil)
    }
} 