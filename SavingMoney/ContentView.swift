import SwiftUI
import _SwiftData_SwiftUI

struct ContentView: View {
  @StateObject private var transactionViewModel = TransactionViewModel()
  @StateObject private var languageManager = LanguageManager.shared
  @StateObject private var themeManager = ThemeManager.shared
  @State private var refreshID = UUID()
  
  var body: some View {
    TabView {
      MainActionView()
        .tabItem {
          Image(systemName: "plus.circle")
          Text(LocalizationKeys.tabAdd.localized)
        }
        .accessibilityIdentifier("AddTab")
      
      SpendingView()
        .tabItem {
          Image(systemName: "chart.pie")
          Text(LocalizationKeys.tabSpending.localized)
        }
        .accessibilityIdentifier("SpendingTab")
      
      DepositView()
        .tabItem {
          Image(systemName: "chart.bar.fill")
          Text(LocalizationKeys.tabDeposits.localized)
        }
        .accessibilityIdentifier("DepositsTab")
      
      AIAdviceView()
        .tabItem {
          Image(systemName: "brain.head.profile")
          Text(LocalizationKeys.tabAIAdvice.localized)
        }
        .accessibilityIdentifier("AIAdviceTab")
      
      SettingsView()
        .tabItem {
          Image(systemName: "gear")
          Text(LocalizationKeys.tabSettings.localized)
        }
        .accessibilityIdentifier("SettingsTab")
    }
    .environmentObject(transactionViewModel)
    .environmentObject(languageManager)
    .environmentObject(themeManager)
    .preferredColorScheme(themeManager.currentTheme.colorScheme)
    .id(refreshID)
    .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
      refreshID = UUID()
    }
    .onReceive(NotificationCenter.default.publisher(for: .themeChanged)) { _ in
      refreshID = UUID()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
