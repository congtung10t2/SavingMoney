//
//  OnboardingView.swift
//  SavingMoney
//
//  Created by congtungit on 21/11/26.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    @State private var showInitialMoneyPopup = false

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
                Text(LocalizationKeys.onboardingTitle.localized)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(LocalizationKeys.onboardingDescription.localized)
                    .font(.body)

                Text(LocalizationKeys.onboardingLanguageHint.localized)
                    .font(.headline)
                    .padding(.top, 4)

                // Language choices presented as selectable cards stacked vertically
                VStack(spacing: 10) {
                    ForEach(languageManager.supportedLanguages, id: \.self) { languageCode in
                        LanguageCard(
                            name: languageManager.supportedLanguageNames[languageCode] ?? languageCode,
                            isSelected: languageCode == languageManager.currentLanguage,
                            onTap: { languageManager.setLanguage(languageCode) }
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 4)

                // Initial money entry — tap to open the entry popup, same as saving/spending entry
                Button {
                    showInitialMoneyPopup = true
                } label: {
                    HStack(spacing: 10) {
                        Text(LocalizationKeys.onboardingInitialMoneyTitle.localized)
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding(.vertical, 10)
                }
                .frame(maxWidth: 340)
                .padding(.top, 8)

                Spacer()

                // Continue stays at the bottom, wider than a default button, centered horizontally
                Button {
                    languageManager.hasCompletedOnboarding = true
                } label: {
                    HStack {
                        Text(LocalizationKeys.onboardingContinue.localized)
                            .font(.headline)
                            .fontWeight(.semibold)
                    }.frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .padding(.bottom, 8)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(
            Group {
                if showInitialMoneyPopup {
                    InitialMoneyPopupView(isPresented: $showInitialMoneyPopup)
                }
            }
        )
    }
}

private struct LanguageCard: View {
    let name: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "globe")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(isSelected ? .blue : .secondary)

                Text(name)
                    .font(.body)
                    .lineLimit(1)

                Spacer()

                // Fixed-width trailing slot: the checkmark always occupies the same space,
                // so the layout never shifts when selection changes
                HStack {
                    if isSelected {
                        Image(systemName: "checkmark")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
                .frame(width: 28, alignment: .trailing)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color(.systemBlue).opacity(0.12) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
