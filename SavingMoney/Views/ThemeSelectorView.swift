//
//  ThemeSelectorView.swift
//  SavingMoney
//
//  Created by congtungit on 28/10/25.
//

import SwiftUI

struct ThemeSelectorView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    HStack {
                        Image(systemName: theme.icon)
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(theme.displayName)
                                .font(.headline)
                            Text(theme.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if theme == themeManager.currentTheme {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                                .font(.caption.weight(.semibold))
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        themeManager.setTheme(theme)
                    }
                }
            }
            .navigationTitle(LocalizationKeys.settingsSelectTheme.localized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button(LocalizationKeys.uiDone.localized) {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

extension AppTheme {
//    var displayName: String {
//        switch self {
//        case .system:
//            return LocalizationKeys.themeSystem.localized
//        case .light:
//            return LocalizationKeys.themeLight.localized
//        case .dark:
//            return LocalizationKeys.themeDark.localized
//        }
//    }
    
    var description: String {
        switch self {
        case .system:
            return LocalizationKeys.themeSystemDescription.localized
        case .light:
            return LocalizationKeys.themeLightDescription.localized
        case .dark:
            return LocalizationKeys.themeDarkDescription.localized
        }
    }
    
//    var icon: String {
//        switch self {
//        case .system:
//            return "gearshape"
//        case .light:
//            return "sun.max"
//        case .dark:
//            return "moon"
//        }
//    }
}

struct ThemeSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeSelectorView()
    }
}
