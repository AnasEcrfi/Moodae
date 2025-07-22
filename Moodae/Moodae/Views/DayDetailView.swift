//
//  DayDetailView.swift
//  Mooday
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

struct DayDetailView: View {
    @ObservedObject var viewModel: MoodViewModel
    let selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedEntry: MoodEntryData?
    @State private var showingEditEntry = false
    
    private var dayEntries: [MoodEntryData] {
        viewModel.moodEntries.filter { entry in
            Calendar.current.isDate(entry.date, inSameDayAs: selectedDate)
        }.sorted { $0.date > $1.date }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.surface.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Content
                        if dayEntries.isEmpty {
                            emptyStateSection
                        } else {
                            entriesSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Day Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        HapticFeedback.light.trigger()
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.accent)
                }
            }
        }
        .sheet(isPresented: $showingEditEntry) {
            if let entry = selectedEntry {
                EditEntryView(
                    entry: entry,
                    viewModel: viewModel,
                    isPresented: $showingEditEntry
                )
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text(dateFormatter.string(from: selectedDate))
                .font(.system(size: 28, weight: .light))
                .foregroundColor(DesignSystem.Colors.primary)
                .multilineTextAlignment(.center)
            
            if !dayEntries.isEmpty {
                Text("\(dayEntries.count) \(dayEntries.count == 1 ? "Entry" : "Entries")")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(DesignSystem.Colors.secondary)
            }
        }
    }
    
    // MARK: - Empty State Section
    private var emptyStateSection: some View {
        VStack(spacing: 24) {
            Image(systemName: "calendar")
                .font(.system(size: 64, weight: .ultraLight))
                .foregroundColor(DesignSystem.Colors.secondary.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No entries for this day")
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text("Add your first mood entry to get started")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                dismiss()
            }) {
                Text("Add Entry")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(DesignSystem.Colors.accent)
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.top, 40)
    }
    
    // MARK: - Entries Section
    private var entriesSection: some View {
        VStack(spacing: 16) {
            ForEach(dayEntries, id: \.id) { entry in
                entryCard(entry)
            }
        }
    }
    
    // MARK: - Entry Card
    private func entryCard(_ entry: MoodEntryData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header Row
            HStack {
                // Mood Icon & Type
                HStack(spacing: 12) {
                    Image(systemName: entry.mood.icon)
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(DesignSystem.moodColor(for: entry.mood))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.mood.displayName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.primary)
                        
                        Text(timeFormatter.string(from: entry.date))
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(DesignSystem.Colors.secondary)
                    }
                }
                
                Spacer()
                
                // Entry Indicators
                HStack(spacing: 8) {
                    if entry.textEntry != nil && !entry.textEntry!.isEmpty {
                        Image(systemName: "text.alignleft")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(DesignSystem.Colors.secondary)
                    }
                    
                    if entry.photoURL != nil {
                        Image(systemName: "photo")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(DesignSystem.Colors.secondary)
                    }
                    
                    if entry.audioURL != nil {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(DesignSystem.Colors.secondary)
                    }
                    
                    if !entry.categories.isEmpty {
                        Image(systemName: "tag.fill")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(DesignSystem.Colors.secondary)
                    }
                }
            }
            
            // Content Preview
            if let text = entry.textEntry, !text.isEmpty {
                Text(text)
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .lineLimit(10)
                    .multilineTextAlignment(.leading)
            }
            
            // Categories
            if !entry.categories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(entry.categories, id: \.id) { category in
                            Text(category.categoryName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(DesignSystem.Colors.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(DesignSystem.Colors.secondary.opacity(0.1))
                                )
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(DesignSystem.Colors.cardBackground)
                .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 8, x: 0, y: 2)
        )
        .contextMenu {
            Button(action: {
                selectedEntry = entry
                showingEditEntry = true
            }) {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                                    HapticFeedback.medium.trigger()
                viewModel.moodEntries.removeAll { $0.id == entry.id }
                viewModel.saveMoodEntriesToUserDefaults()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
} 