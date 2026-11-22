//
//  InitialMoneyPopupView.swift
//  SavingMoney
//
//  Created by congtungit on 21/11/26.
//

import SwiftUI

/// Popup used to enter the initial money — same style as the saving/spending entry popup in MainActionView.
struct InitialMoneyPopupView: View {
    @Binding var isPresented: Bool
    @State private var amountText = ""

    var body: some View {
        ZStack {
            // Full screen dark overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }

            // Popup content
            VStack(spacing: 20) {
                Text(LocalizationKeys.onboardingInitialMoneyTitle.localized)
                    .font(.headline)

                // Small note with the amount being entered and the date it's entered (current date for existing users)
                Text(LanguageManager.formatInitialMoneyNote(
                    amount: Double(amountText) ?? LanguageManager.shared.initialMoney,
                    on: LanguageManager.shared.initialMoneyDate ?? Date()))
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextField(LocalizationKeys.onboardingInitialMoneyPlaceholder.localized, text: $amountText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                HStack(spacing: 32) {
                    Button(LocalizationKeys.cancel.localized) {
                        isPresented = false
                        amountText = ""
                    }
                    .foregroundColor(.red)
                    .frame(minWidth: 80)

                    Button(LocalizationKeys.save.localized) {
                        if let amount = Double(amountText) {
                            LanguageManager.shared.initialMoney = amount
                        }
                        if LanguageManager.shared.initialMoneyDate == nil {
                            LanguageManager.shared.initialMoneyDate = Date()
                        }
                        isPresented = false
                        amountText = ""
                    }
                    .disabled(Double(amountText) == nil)
                    .foregroundColor(Double(amountText) == nil ? .gray : .blue)
                    .frame(minWidth: 80)
                }
            }
            .padding(24)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(radius: 20)
            .frame(maxWidth: 320)
            .padding(.horizontal, 20)
        }
    }
}

struct InitialMoneyPopupView_Previews: PreviewProvider {
    static var previews: some View {
        InitialMoneyPopupView(isPresented: .constant(true))
    }
}
