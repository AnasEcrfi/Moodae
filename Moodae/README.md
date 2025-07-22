# 📱 Moodae - Your Personal Mood Tracking Companion

> A beautifully designed, privacy-first mood tracking app built with SwiftUI

![iOS](https://img.shields.io/badge/iOS-18.4+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0+-green.svg)
![License](https://img.shields.io/badge/License-MIT-blue.svg)

## 🌟 Overview

Moodae is a modern, intuitive mood tracking application that helps users understand their emotional patterns while keeping their data completely private. Built with SwiftUI and following Apple's Human Interface Guidelines, it offers a premium user experience without compromising on privacy.

## ✨ Key Features

### 🎯 Core Functionality
- **6-Level Mood Tracking**: From Amazing to Overwhelming
- **Rich Categorization**: Emotions, People, Weather, Activities (50+ categories)
- **Audio Journaling**: Voice recordings with transcription
- **Photo Attachments**: Visual mood documentation
- **Retroactive Entries**: Add entries for any past date

### 📊 Data Visualization
- **Interactive Calendar**: Color-coded mood visualization
- **Timeline View**: Chronological mood history
- **Insights Dashboard**: Patterns, trends, and analytics
- **Year-in-Review**: Comprehensive annual mood overview
- **Category Insights**: Smart pattern recognition

### 🔒 Privacy & Security
- **Local-Only Storage**: All data stays on your device
- **No Cloud Sync**: Complete privacy control
- **PIN/Biometric Protection**: Optional app locking
- **Data Export**: CSV export for external analysis
- **Complete Data Deletion**: Full user control

### 🎨 Modern Design
- **Dark/Light Mode**: Adaptive color schemes
- **Accessibility**: Full VoiceOver and Dynamic Type support
- **Haptic Feedback**: Contextual vibrations
- **Smooth Animations**: Spring-based transitions
- **Premium UI**: Card-based interface with elegant shadows

## 📱 Screenshots

[Add screenshots here when available]

## 🛠️ Technical Stack

- **Framework**: SwiftUI
- **Architecture**: MVVM with Combine
- **Data Storage**: UserDefaults (Core Data ready)
- **Audio**: AVFoundation
- **Health Integration**: HealthKit (optional)
- **Platform**: iOS 18.4+
- **Languages**: Swift 5.9+

## 🏗️ Project Structure

```
Moodae/
├── Models/              # Data models and types
│   ├── MoodEntry.swift
│   ├── CategorySystem.swift
│   └── AIDataModels.swift
├── ViewModels/          # Business logic
│   └── MoodViewModel.swift
├── Views/               # UI components
│   ├── ContentView.swift
│   ├── TimelineView.swift
│   ├── InsightsView.swift
│   └── DesignSystem.swift
├── Services/            # Core services
│   ├── HealthKitManager.swift
│   ├── AudioRecordingManager.swift
│   └── PINManager.swift
└── Utils/               # Helper utilities
    ├── AnimationExtensions.swift
    └── TextScalingModifier.swift
```

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 18.4+ target device/simulator
- Apple Developer Account (for device testing)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/moodae.git
cd moodae
```

2. Open the project in Xcode:
```bash
open Moodae/Moodae.xcodeproj
```

3. Build and run:
- Select your target device/simulator
- Press `Cmd + R` to build and run

### Development Setup

The project uses no external dependencies and relies entirely on native iOS frameworks, making setup straightforward.

## 📋 Features Roadmap

### ✅ Completed
- [x] Core mood tracking
- [x] Rich categorization system
- [x] Audio recording and playback
- [x] Photo attachments
- [x] Calendar visualization
- [x] Insights and analytics
- [x] Privacy-first architecture
- [x] Dark/Light mode support
- [x] Accessibility features

### 🔄 In Progress
- [ ] Core Data migration
- [ ] Advanced analytics
- [ ] Widget support

### 📋 Planned
- [ ] Apple Watch companion app
- [ ] Siri Shortcuts integration
- [ ] Custom category creation
- [ ] Advanced data visualization

## 🔒 Privacy & Security

Moodae is built with privacy as a core principle:

- **No Data Collection**: We don't collect any personal data
- **Local Storage**: All mood entries stay on your device
- **No Analytics**: No tracking or usage analytics
- **Transparent Permissions**: Clear explanations for all permission requests
- **User Control**: Complete data export and deletion capabilities

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## 📞 Support

- **Email**: support@moodae.app
- **Issues**: GitHub Issues page
- **Documentation**: [Wiki](wiki-url)

## 🙏 Acknowledgments

- Apple for the amazing SwiftUI framework
- SF Symbols for beautiful iconography
- The iOS development community for inspiration and best practices

## ⭐ Show Your Support

If you find this project useful, please consider giving it a star on GitHub!

---

**Built with ❤️ using SwiftUI** 