# 📱 Mooday

> Your daily emotional check-in. Quick, beautiful, and honest.

## 🎯 Purpose

Mooday hilft User:innen, täglich kurz und intuitiv zu reflektieren:
- War mein Tag **gut** oder **schlecht**?
- Warum?
- Optional via Text oder Audio.
- Smarte Rückblicke & Mini-Affirmationen helfen beim langfristigen Verständnis des eigenen emotionalen Wohlbefindens.

---

## ✨ Core Features

### 1. Mood Entry
- Zwei Buttons: `Good Day` oder `Bad Day`
- Smoothe Animation mit subtiler Farbveränderung (kein Kitsch, kein Emoji-Overkill)
- Danach: Textfeld **oder Sprachaufnahme**
  - User entscheidet frei
  - Transkript (auto oder manuell aktivierbar)

### 2. Micro-Affirmations
- Nach jedem Eintrag erscheint ein dezenter Satz:
  - *"You made it through. That counts."*
  - *"Bad days don't define you."*
  - *"Noted. Now let it go."*
- Kein Alarmismus – Fokus auf ruhiger, empathischer Tonalität

### 3. Timeline
- Chronologische Liste der Mood-Entries
- Filterbar nach: Mood-Typ, Audio/Text, Keyword
- Light & Dark Mode

### 4. Insights (ab 5 Einträgen)
- Wöchentliche Karten mit Stats:
  - % positive Tage
  - häufigste Begriffe (Text-Cloud)
  - Tonalitätstrends
- Ziel: **Reflexion ohne Bewertung**

---

## 🧠 Erweiterte Features (Phase 2)

- HealthKit-Integration (optional): Schlaf, Schritte vs. Stimmung
- Export as PDF
- Passcode/FaceID-Schutz
- Adaptive Reminder (intelligent, basierend auf Nutzungsmuster)

---

## 🛠️ Tech Stack

| Komponente         | Technologie              |
|--------------------|--------------------------|
| UI                 | SwiftUI                  |
| State Management   | Combine / ObservableObj  |
| Audio Transkription| AVFoundation + SpeechKit |
| Storage            | CoreData (lokal)         |
| Dark/Light Mode    | Native mit `.colorScheme`|
| Reminder           | UNUserNotificationCenter |

---

## 📂 Projektstruktur

```plaintext
Mooday/
├── Models/
│   └── MoodEntry.swift
├── Views/
│   ├── MoodSelectorView.swift
│   ├── TextOrAudioInputView.swift
│   ├── TimelineView.swift
│   ├── InsightsView.swift
│   └── AffirmationView.swift
├── ViewModels/
│   └── MoodViewModel.swift
├── Resources/
│   ├── Assets.xcassets
│   └── Fonts/
└── MoodayApp.swift
```

---

## 🚀 Status

✅ **Implementiert:**
- Grundlegende Projektstruktur
- MoodEntry Model mit Core Data
- MoodViewModel mit Combine
- Alle Hauptviews (MoodSelector, TextOrAudio, Timeline, Insights, Affirmation)
- Dark/Light Mode Support
- Minimalistisches Design nach Apple/Airbnb Prinzipien

🔄 **In Arbeit:**
- Core Data Model Integration
- Audio Recording Implementation
- Speech-to-Text Integration

📋 **Geplant:**
- HealthKit Integration
- Export Funktionen
- Passcode/FaceID Schutz
- Adaptive Notifications 