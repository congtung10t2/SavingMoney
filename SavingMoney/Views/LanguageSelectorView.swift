//
//  LanguageSelectorView.swift
//  SavingMoney
//
//  Created by congtungit on 28/10/25.
//

import SwiftUI

struct LanguageSelectorView: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(languageManager.supportedLanguages, id: \.self) { languageCode in
                    HStack {
                        Text(languageManager.supportedLanguageNames[languageCode] ?? languageCode)
                            .font(.body)
                        
                        Spacer()
                        
                        if languageCode == languageManager.currentLanguage {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        languageManager.setLanguage(languageCode)
                    }
                }
            }
            .navigationTitle(LocalizationKeys.selectLanguage.localized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button(LocalizationKeys.done.localized) {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct LanguageSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageSelectorView()
    }
}