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
    var body: some Scene {
        WindowGroup {
            ContentView()
            .modelContainer(for: Transaction.self)
        }
    }
}
