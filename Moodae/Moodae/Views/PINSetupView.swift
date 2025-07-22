//
//  PINSetupView.swift
//  Moodae
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import SwiftUI

struct PINSetupView: View {
    @ObservedObject var pinManager: PINManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var enteredPIN = ""
    @State private var confirmPIN = ""
    @State private var isConfirming = false
    @State private var showError = false
    @State private var errorMessage = ""
    
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
                    
                    // Error Message
                    if showError {
                        errorSection
                    }
                    
                    Spacer()
                    
                    // Continue Button
                    continueButton
                    
                    Spacer()
                }
                .padding(.horizontal, 32)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.secondary)
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundColor(DesignSystem.Colors.accent)
            
            VStack(spacing: 8) {
                Text(isConfirming ? "Confirm PIN" : "Set PIN")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text(isConfirming ? "Enter your PIN again" : "Create a 4-digit PIN")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(DesignSystem.Colors.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - PIN Input Section
    
    private var pinInputSection: some View {
        VStack(spacing: 24) {
            // PIN Dots
            HStack(spacing: 16) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(currentPIN.count > index ? DesignSystem.Colors.accent : DesignSystem.Colors.secondary.opacity(0.3))
                        .frame(width: 16, height: 16)
                        .scaleEffect(currentPIN.count == index ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPIN.count)
                }
            }
            
            // Number Pad
            numberPad
        }
    }
    
    private var numberPad: some View {
        VStack(spacing: 16) {
            // Numbers 1-3
            HStack(spacing: 20) {
                ForEach(1...3, id: \.self) { number in
                    numberButton(number)
                }
            }
            
            // Numbers 4-6
            HStack(spacing: 20) {
                ForEach(4...6, id: \.self) { number in
                    numberButton(number)
                }
            }
            
            // Numbers 7-9
            HStack(spacing: 20) {
                ForEach(7...9, id: \.self) { number in
                    numberButton(number)
                }
            }
            
            // 0 and Delete
            HStack(spacing: 20) {
                Spacer()
                    .frame(width: 60, height: 60)
                
                numberButton(0)
                
                Button(action: deleteDigit) {
                    Image(systemName: "delete.left")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(DesignSystem.Colors.secondary)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(DesignSystem.Colors.cardBackground)
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
                .font(.system(size: 24, weight: .light))
                .foregroundColor(DesignSystem.Colors.primary)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(DesignSystem.Colors.cardBackground)
                        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 4, x: 0, y: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Error Section
    
    private var errorSection: some View {
        Text(errorMessage)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
            .opacity(showError ? 1 : 0)
            .animation(.easeInOut(duration: 0.3), value: showError)
    }
    
    // MARK: - Continue Button
    
    private var continueButton: some View {
        Button(action: handleContinue) {
            Text(isConfirming ? "Confirm" : "Continue")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(currentPIN.count == 4 ? DesignSystem.Colors.accent : DesignSystem.Colors.secondary.opacity(0.3))
                )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(currentPIN.count != 4)
        .animation(.easeInOut(duration: 0.2), value: currentPIN.count)
    }
    
    // MARK: - Computed Properties
    
    private var currentPIN: String {
        return isConfirming ? confirmPIN : enteredPIN
    }
    
    // MARK: - Actions
    
    private func addDigit(_ digit: Int) {
        HapticFeedback.light.trigger()
        
        if isConfirming {
            if confirmPIN.count < 4 {
                confirmPIN += "\(digit)"
            }
        } else {
            if enteredPIN.count < 4 {
                enteredPIN += "\(digit)"
            }
        }
        
        hideError()
    }
    
    private func deleteDigit() {
        HapticFeedback.light.trigger()
        
        if isConfirming {
            if !confirmPIN.isEmpty {
                confirmPIN.removeLast()
            }
        } else {
            if !enteredPIN.isEmpty {
                enteredPIN.removeLast()
            }
        }
        
        hideError()
    }
    
    private func handleContinue() {
        HapticFeedback.medium.trigger()
        
        if isConfirming {
            // Confirm PIN
            if confirmPIN == enteredPIN {
                pinManager.enablePIN(enteredPIN)
                dismiss()
            } else {
                showErrorMessage("PINs do not match")
                resetConfirmation()
            }
        } else {
            // Move to confirmation
            isConfirming = true
        }
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
        
        // Hide error after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            hideError()
        }
    }
    
    private func hideError() {
        if showError {
            showError = false
        }
    }
    
    private func resetConfirmation() {
        isConfirming = false
        confirmPIN = ""
    }
}

#Preview {
    PINSetupView(pinManager: PINManager())
} 