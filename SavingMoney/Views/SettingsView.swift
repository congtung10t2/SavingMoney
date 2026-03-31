//
//  SettingsView.swift
//  SavingMoney
//
//  Created by congtungit on 28/10/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var showLanguageSelector = false
    @State private var showThemeSelector = false
    @State private var refreshID = UUID()
    
    var body: some View {
        NavigationView {
            List {
                // Language Section
                Section(LocalizationKeys.settingsLanguage.localized) {
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        
                        Text(LocalizationKeys.settingsAppLanguage.localized)
                        
                        Spacer()
                        
                        Text(languageManager.supportedLanguageNames[languageManager.currentLanguage] ?? "English")
                            .foregroundColor(.secondary)
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showLanguageSelector = true
                    }
                }
                
                // Appearance Section
                Section(LocalizationKeys.settingsAppearance.localized) {
                    HStack {
                        Image(systemName: themeManager.currentTheme.icon)
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        
                        Text(LocalizationKeys.settingsTheme.localized)
                        
                        Spacer()
                        
                        Text(themeManager.currentTheme.displayName)
                            .foregroundColor(.secondary)
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showThemeSelector = true
                    }
                }
                
                // About Section
                Section(LocalizationKeys.settingsAbout.localized) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        
                        Text(LocalizationKeys.settingsVersion.localized)
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "person.circle")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        
                        Text("Developer")
                        
                        Spacer()
                        
                        Text("congtungit")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "star.circle")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        
                        Text("Rate App")
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Handle app rating
                    }
                }
            }
            .navigationTitle(LocalizationKeys.settingsTitle.localized)
        }
        .id(refreshID)
        .sheet(isPresented: $showLanguageSelector) {
            LanguageSelectorView()
        }
        .sheet(isPresented: $showThemeSelector) {
            ThemeSelectorView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
            refreshID = UUID()
        }
        .onReceive(NotificationCenter.default.publisher(for: .themeChanged)) { _ in
            refreshID = UUID()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}