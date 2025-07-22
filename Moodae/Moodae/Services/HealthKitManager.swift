//
//  HealthKitManager.swift
//  Mooday
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import Foundation
import HealthKit
import Combine

@MainActor
class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var isHealthKitAvailable = false
    @Published var authorizationStatus: HKAuthorizationStatus = .notDetermined
    @Published var stepCount: Int = 0
    @Published var sleepHours: Double = 0.0
    @Published var heartRate: Double = 0.0
    @Published var isAuthorized = false
    
    // Health data for correlation with mood
    @Published var dailyHealthData: [Date: HealthData] = [:]
    
    init() {
        checkHealthKitAvailability()
    }
    
    // MARK: - HealthKit Availability & Authorization
    
    private func checkHealthKitAvailability() {
        isHealthKitAvailable = HKHealthStore.isHealthDataAvailable()
    }
    
    func requestAuthorization() async {
        guard isHealthKitAvailable else {
            print("HealthKit is not available on this device")
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            
            // Check authorization status for key types
            let stepCountStatus = healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .stepCount)!)
            let sleepStatus = healthStore.authorizationStatus(for: HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!)
            
            isAuthorized = stepCountStatus == .sharingAuthorized || sleepStatus == .sharingAuthorized
            authorizationStatus = stepCountStatus
            
            if isAuthorized {
                await loadTodaysHealthData()
            }
        } catch {
            print("HealthKit authorization failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Data Fetching
    
    func loadTodaysHealthData() async {
        await loadHealthData(for: Date())
    }
    
    func loadHealthData(for date: Date) async {
        guard isAuthorized else { return }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        async let steps = fetchStepCount(from: startOfDay, to: endOfDay)
        async let sleep = fetchSleepHours(from: startOfDay, to: endOfDay)
        async let heartRate = fetchAverageHeartRate(from: startOfDay, to: endOfDay)
        
        let healthData = HealthData(
            date: date,
            stepCount: await steps,
            sleepHours: await sleep,
            averageHeartRate: await heartRate
        )
        
        dailyHealthData[startOfDay] = healthData
        
        // Update published properties for today
        if calendar.isDate(date, inSameDayAs: Date()) {
            self.stepCount = healthData.stepCount
            self.sleepHours = healthData.sleepHours
            self.heartRate = healthData.averageHeartRate
        }
    }
    
    private func fetchStepCount(from startDate: Date, to endDate: Date) async -> Int {
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return 0
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepCountType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    print("Error fetching step count: \(error.localizedDescription)")
                    continuation.resume(returning: 0)
                    return
                }
                
                let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                continuation.resume(returning: Int(steps))
            }
            
            healthStore.execute(query)
        }
    }
    
    private func fetchSleepHours(from startDate: Date, to endDate: Date) async -> Double {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            return 0.0
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, error in
                if let error = error {
                    print("Error fetching sleep data: \(error.localizedDescription)")
                    continuation.resume(returning: 0.0)
                    return
                }
                
                guard let sleepSamples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: 0.0)
                    return
                }
                
                var totalSleepTime: TimeInterval = 0
                
                for sample in sleepSamples {
                    // Use compatibility check for iOS 16.0+ sleep analysis values
                    let isValidSleepValue: Bool
                    if #available(iOS 16.0, *) {
                        isValidSleepValue = sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue ||
                                           sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                                           sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                                           sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                                           sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue
                    } else {
                        // Fallback for iOS 15.0 - only check basic values
                        isValidSleepValue = sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue ||
                                           sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue
                    }
                    
                    if isValidSleepValue {
                        totalSleepTime += sample.endDate.timeIntervalSince(sample.startDate)
                    }
                }
                
                let sleepHours = totalSleepTime / 3600.0 // Convert seconds to hours
                continuation.resume(returning: sleepHours)
            }
            
            healthStore.execute(query)
        }
    }
    
    private func fetchAverageHeartRate(from startDate: Date, to endDate: Date) async -> Double {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return 0.0
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: heartRateType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, error in
                if let error = error {
                    print("Error fetching heart rate: \(error.localizedDescription)")
                    continuation.resume(returning: 0.0)
                    return
                }
                
                let heartRate = result?.averageQuantity()?.doubleValue(for: HKUnit(from: "count/min")) ?? 0.0
                continuation.resume(returning: heartRate)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Correlation Analysis
    
    func getHealthDataForDate(_ date: Date) -> HealthData? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        return dailyHealthData[startOfDay]
    }
    
    func loadHealthDataForDateRange(from startDate: Date, to endDate: Date) async {
        let calendar = Calendar.current
        var currentDate = startDate
        
        while currentDate <= endDate {
            await loadHealthData(for: currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? endDate
        }
    }
    
    // MARK: - Helper Methods
    
    func getHealthSummaryForToday() -> String {
        if !isAuthorized {
            return "Health data not available"
        }
        
        var summary: [String] = []
        
        if stepCount > 0 {
            summary.append("\(stepCount) steps")
        }
        
        if sleepHours > 0 {
            summary.append(String(format: "%.1fh sleep", sleepHours))
        }
        
        if heartRate > 0 {
            summary.append(String(format: "%.0f bpm", heartRate))
        }
        
        return summary.isEmpty ? "No health data" : summary.joined(separator: " • ")
    }
    
    func getHealthStatusColor() -> String {
        if !isAuthorized { return "gray" }
        
        // Simple health status based on steps and sleep
        let goodSteps = stepCount >= 8000
        let goodSleep = sleepHours >= 7.0
        
        if goodSteps && goodSleep {
            return "green"
        } else if goodSteps || goodSleep {
            return "orange"
        } else {
            return "red"
        }
    }
}

// MARK: - Health Data Model

struct HealthData: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let stepCount: Int
    let sleepHours: Double
    let averageHeartRate: Double
    
    enum CodingKeys: String, CodingKey {
        case date, stepCount, sleepHours, averageHeartRate
    }
    
    var formattedSteps: String {
        return "\(stepCount) steps"
    }
    
    var formattedSleep: String {
        return String(format: "%.1fh sleep", sleepHours)
    }
    
    var formattedHeartRate: String {
        return String(format: "%.0f bpm", averageHeartRate)
    }
    
    var healthScore: Double {
        // Simple health score calculation (0-100)
        let stepScore = min(Double(stepCount) / 10000.0, 1.0) * 40 // Max 40 points
        let sleepScore = min(sleepHours / 8.0, 1.0) * 40 // Max 40 points
        let heartRateScore = averageHeartRate > 0 ? 20.0 : 0.0 // 20 points if heart rate data exists
        
        return stepScore + sleepScore + heartRateScore
    }
}

// MARK: - AI Service Support Extension

extension HealthKitManager {
    
    func getRecentSleepData() async -> Double? {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return nil }
        
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: endDate) ?? endDate
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                guard let sleepSamples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let sleepDurations = sleepSamples.compactMap { sample -> Double? in
                    if sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue {
                        return sample.endDate.timeIntervalSince(sample.startDate) / 3600 // Convert to hours
                    }
                    return nil
                }
                
                let averageSleep = sleepDurations.isEmpty ? nil : sleepDurations.reduce(0, +) / Double(sleepDurations.count)
                continuation.resume(returning: averageSleep)
            }
            
            healthStore.execute(query)
        }
    }
    
    func getRecentActivityData() async -> Double? {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return nil }
        
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: endDate) ?? endDate
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, statistics, _ in
                guard let sum = statistics?.sumQuantity() else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let steps = sum.doubleValue(for: HKUnit.count())
                let averageSteps = steps / 7.0 // Average per day
                continuation.resume(returning: averageSteps)
            }
            
            healthStore.execute(query)
        }
    }
    
    func getHRVData() async -> Double? {
        guard let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else { return nil }
        
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: endDate) ?? endDate
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: hrvType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                guard let hrvSamples = samples as? [HKQuantitySample] else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let hrvValues = hrvSamples.map { $0.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli)) }
                let averageHRV = hrvValues.isEmpty ? nil : hrvValues.reduce(0, +) / Double(hrvValues.count)
                continuation.resume(returning: averageHRV)
            }
            
            healthStore.execute(query)
        }
    }
} 