//
//  OnboardingView.swift
//  SavingMoney
//
//  Created by congtungit on 21/11/26.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject private var languageManager = LanguageManager.shared

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text(LocalizationKeys.onboardingTitle.localized)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(LocalizationKeys.onboardingDescription.localized)
                .font(.body)

            Text(LocalizationKeys.onboardingLanguageHint.localized)
                .font(.headline)
                .padding(.top, 4)

            // Language choices presented as selectable cards
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 12
            ) {
                ForEach(languageManager.supportedLanguages, id: \.self) { languageCode in
                    LanguageCard(
                        name: languageManager.supportedLanguageNames[languageCode] ?? languageCode,
                        isSelected: languageCode == languageManager.currentLanguage,
                        onTap: { languageManager.setLanguage(languageCode) }
                    )
                }
            }
            .frame(maxWidth: 420)
            .padding(.top, 4)

            Spacer()

            // Continue stays at the bottom, wider than a default button, centered horizontally
            Button {
                languageManager.hasCompletedOnboarding = true
            } label: {
                Text(LocalizationKeys.onboardingContinue.localized)
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: 300)
            .padding(.bottom, 8)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? .blue : .secondary)

                Text(name)
                    .font(.body)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .lineLimit(1)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
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
