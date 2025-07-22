//
//  PINVerificationView.swift
//  Moodae
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

struct PINVerificationView: View {
    @ObservedObject var pinManager: PINManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    let onSuccess: () -> Void
    
    @State private var enteredPIN = ""
    @State private var isShaking = false
    @State private var showError = false
    @State private var attemptCount = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.surface
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Header
                    headerSection
                    
                    // PIN Input
                    pinInputSection
                    
                    Spacer()
                }
                .padding(.horizontal, 32)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        HapticFeedback.light.trigger()
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.secondary)
                }
            }
        }
        .onAppear {
            enteredPIN = ""
            attemptCount = 0
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.open.fill")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundColor(DesignSystem.Colors.warning)
                .scaleEffect(isShaking ? 0.9 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isShaking)
            
            VStack(spacing: 8) {
                Text("Verify PIN")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text("Enter your current PIN to disable PIN security")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - PIN Input Section
    
    private var pinInputSection: some View {
        VStack(spacing: 30) {
            // PIN Dots
            HStack(spacing: 16) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(enteredPIN.count > index ? DesignSystem.Colors.warning : DesignSystem.Colors.secondary.opacity(0.3))
                        .frame(width: 18, height: 18)
                        .scaleEffect(enteredPIN.count == index ? 1.3 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: enteredPIN.count)
                }
            }
            .offset(x: isShaking ? -10 : 0)
            .animation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true), value: isShaking)
            
            // Error Message
            if showError {
                Text("Incorrect PIN. Try again.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
            }
            
            // Number Pad
            numberPad
        }
    }
    
    private var numberPad: some View {
        VStack(spacing: 20) {
            // Numbers 1-3
            HStack(spacing: 25) {
                ForEach(1...3, id: \.self) { number in
                    numberButton(number)
                }
            }
            
            // Numbers 4-6
            HStack(spacing: 25) {
                ForEach(4...6, id: \.self) { number in
                    numberButton(number)
                }
            }
            
            // Numbers 7-9
            HStack(spacing: 25) {
                ForEach(7...9, id: \.self) { number in
                    numberButton(number)
                }
            }
            
            // 0 and Delete
            HStack(spacing: 25) {
                Spacer()
                    .frame(width: 70, height: 70)
                
                numberButton(0)
                
                Button(action: deleteDigit) {
                    Image(systemName: "delete.left")
                        .font(.system(size: 22, weight: .light))
                        .foregroundColor(DesignSystem.Colors.secondary)
                        .frame(width: 70, height: 70)
                        .background(
                            Circle()
                                .fill(DesignSystem.Colors.cardBackground)
                                .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 6, x: 0, y: 3)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private func numberButton(_ number: Int) -> some View {
        Button(action: {
            addDigit(number)
        }) {
            Text("\(number)")
                .font(.system(size: 28, weight: .light))
                .foregroundColor(DesignSystem.Colors.primary)
                .frame(width: 70, height: 70)
                .background(
                    Circle()
                        .fill(DesignSystem.Colors.cardBackground)
                        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 6, x: 0, y: 3)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isShaking ? 0.95 : 1.0)
    }
    
    // MARK: - Actions
    
    private func addDigit(_ digit: Int) {
        HapticFeedback.light.trigger()
        
        guard enteredPIN.count < 4 else { return }
        
        enteredPIN += "\(digit)"
        hideError()
        
        // Check PIN when 4 digits entered
        if enteredPIN.count == 4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                verifyPIN()
            }
        }
    }
    
    private func deleteDigit() {
        HapticFeedback.light.trigger()
        
        if !enteredPIN.isEmpty {
            enteredPIN.removeLast()
        }
        
        hideError()
    }
    
    private func verifyPIN() {
        if pinManager.verifyPIN(enteredPIN) {
            // Correct PIN - allow disabling
                            HapticFeedback.medium.trigger()
            
            // Call success callback and dismiss
            onSuccess()
            dismiss()
        } else {
            // Incorrect PIN
                            HapticFeedback.heavy.trigger()
            attemptCount += 1
            
            withAnimation(.easeInOut(duration: 0.5)) {
                showError = true
                isShaking = true
            }
            
            // Reset PIN input
            enteredPIN = ""
            
            // Stop shaking after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isShaking = false
            }
            
            // Hide error after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                hideError()
            }
        }
    }
    
    private func hideError() {
        withAnimation(.easeOut(duration: 0.3)) {
            showError = false
        }
    }
}

#Preview {
    PINVerificationView(pinManager: PINManager()) {
        print("PIN verified successfully")
    }
} 