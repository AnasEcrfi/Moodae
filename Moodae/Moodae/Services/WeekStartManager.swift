//
//  WeekStartManager.swift
//  Moodae
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI
import Foundation

enum WeekStartDay: String, CaseIterable {
    case sunday = "Sunday"
    case monday = "Monday"
    
    var calendarWeekday: Int {
        switch self {
        case .sunday: return 1 // Calendar.Weekday.sunday
        case .monday: return 2 // Calendar.Weekday.monday
        }
    }
    
    var icon: String {
        switch self {
        case .sunday: return "sun.max"
        case .monday: return "calendar"
        }
    }
    
    var description: String {
        switch self {
        case .sunday: return "Week starts on Sunday"
        case .monday: return "Week starts on Monday"
        }
    }
    
    var shortName: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        }
    }
}

@MainActor
class WeekStartManager: ObservableObject {
    @Published var selectedWeekStart: WeekStartDay = .monday
    
    private let userDefaultsKey = "week_start_day"
    
    init() {
        loadWeekStartSetting()
    }
    
    func setWeekStart(_ weekStart: WeekStartDay) {
        selectedWeekStart = weekStart
        saveWeekStartSetting()
        updateSystemCalendar()
    }
    
    private func loadWeekStartSetting() {
        if let savedWeekStart = UserDefaults.standard.string(forKey: userDefaultsKey),
           let weekStart = WeekStartDay(rawValue: savedWeekStart) {
            selectedWeekStart = weekStart
        } else {
            // Default to system locale preference
            let calendar = Calendar.current
            selectedWeekStart = calendar.firstWeekday == 1 ? .sunday : .monday
        }
        updateSystemCalendar()
    }
    
    private func saveWeekStartSetting() {
        UserDefaults.standard.set(selectedWeekStart.rawValue, forKey: userDefaultsKey)
    }
    
    private func updateSystemCalendar() {
        // This will be used by calendar views
        NotificationCenter.default.post(
            name: NSNotification.Name("WeekStartChanged"),
            object: selectedWeekStart
        )
    }
    
    // MARK: - Calendar Helper Methods
    
    /// Returns a calendar configured with the user's preferred week start
    var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = selectedWeekStart.calendarWeekday
        return calendar
    }
    
    /// Returns the start of the week for a given date
    func startOfWeek(for date: Date) -> Date {
        return calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
    }
    
    /// Returns the end of the week for a given date
    func endOfWeek(for date: Date) -> Date {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return date
        }
        return calendar.date(byAdding: .second, value: -1, to: weekInterval.end) ?? date
    }
    
    /// Returns all days in the week for a given date
    func daysInWeek(for date: Date) -> [Date] {
        let startOfWeek = startOfWeek(for: date)
        var days: [Date] = []
        
        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                days.append(day)
            }
        }
        
        return days
    }
    
    /// Returns weekday names starting from the preferred first day
    var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        let startIndex = selectedWeekStart.calendarWeekday - 1
        
        // Reorder to start from preferred day
        return Array(symbols[startIndex...]) + Array(symbols[..<startIndex])
    }
    
    /// Returns very short weekday symbols (S, M, T, W, T, F, S)
    var veryShortWeekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let startIndex = selectedWeekStart.calendarWeekday - 1
        
        // Reorder to start from preferred day
        return Array(symbols[startIndex...]) + Array(symbols[..<startIndex])
    }
} 