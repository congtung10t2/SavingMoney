//
//  SavingMoneyApp.swift
//  SavingMoney
//
//  Created by congtungit on 28/10/25.
//

import SwiftUI
import SwiftData

@main
struct SavingMoneyApp: App {
    @StateObject private var languageManager = LanguageManager.shared

    var body: some Scene {
        WindowGroup {
            if languageManager.hasCompletedOnboarding {
                ContentView()
                    .modelContainer(for: Transaction.self)
            } else {
                OnboardingView()
            }
        }
    }
}
