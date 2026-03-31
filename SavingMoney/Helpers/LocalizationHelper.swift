//
//  LocalizationHelper.swift
//  SavingMoney
//
//  Created by congtungit on 28/10/25.
//

import Foundation

// MARK: - Localization Helper
extension String {
    /// Returns the localized string for this key using current language
    var localized: String {
        return LanguageManager.shared.getLocalizedString(self)
    }
    
    /// Returns a localized string with formatted arguments
    func localized(arguments: CVarArg...) -> String {
        return LanguageManager.shared.getLocalizedString(self, arguments: arguments)
    }
}

// MARK: - Localization Keys
struct LocalizationKeys {
    
    // MARK: - Tab Bar
    static let tabAdd = "tab_add"
    static let tabSpending = "tab_spending"
    static let tabDeposits = "tab_deposits"
    static let tabAIAdvice = "tab_ai_advice"
    static let tabSettings = "tab_settings"
    
    // MARK: - Settings
    static let settingsTitle = "settings_title"
    static let settingsLanguage = "settings_language"
    static let settingsAppLanguage = "settings_app_language"
    static let settingsAppearance = "settings_appearance"
    static let settingsTheme = "settings_theme"
    static let settingsSelectTheme = "settings_select_theme"
    static let settingsAbout = "settings_about"
    static let settingsVersion = "settings_version"
    static let selectLanguage = "select_language"
    static let selectTheme = "select_theme"
    static let done = "done"
    
    // MARK: - Theme
    static let themeSystem = "theme_system"
    static let themeLight = "theme_light"
    static let themeDark = "theme_dark"
    static let themeSystemDescription = "theme_system_description"
    static let themeLightDescription = "theme_light_description"
    static let themeDarkDescription = "theme_dark_description"
    
    // MARK: - Common UI
    static let uiDone = "ui_done"
    static let uiCancel = "ui_cancel"
    static let uiClose = "ui_close"
    
    // MARK: - Main Action View
    static let balanceLabel = "balance_label"
    static let whatDoYouWant = "what_do_you_want"
    static let spendingAction = "spending_action"
    static let savingAction = "saving_action"
    static let selectCategory = "select_category"
    static let enterAmount = "enter_amount"
    
    // MARK: - Transaction Form
    static let addExpense = "add_expense"
    static let addDeposit = "add_deposit"
    static let categoryLabel = "category_label"
    static let amountPlaceholder = "amount_placeholder"
    static let descriptionPlaceholder = "description_placeholder"
    static let cancel = "cancel"
    static let save = "save"
    
    // MARK: - Overview Views
    static let spendingOverview = "spending_overview"
    static let depositOverview = "deposit_overview"
    static let totalSpent = "total_spent"
    static let totalSpentPermonth = "total_spent_per_month"
    static let totalDeposits = "total_deposits"
    static let totalDepositsPermonth = "total_deposits_per_month"
    static let spendingBreakdown = "spending_breakdown"
    static let depositBreakdown = "deposit_breakdown"
    static let addSpendingMessage = "add_spending_message"
    static let addDepositMessage = "add_deposit_message"
    static let noDepositsYet = "no_deposits_yet"
    
    // MARK: - Categories
    static let categoryFood = "category_food"
    static let categoryTransportation = "category_transportation"
    static let categoryShopping = "category_shopping"
    static let categoryEntertainment = "category_entertainment"
    static let categoryBills = "category_bills"
    static let categoryHealthcare = "category_healthcare"
    static let categoryEducation = "category_education"
    static let categoryOther = "category_other"
    static let categorySalary = "category_salary"
    static let categoryFreelance = "category_freelance"
    static let categoryInvestment = "category_investment"
    static let categoryGift = "category_gift"
    
    // MARK: - AI Advice
    static let aiFinancialAdvisor = "ai_financial_advisor"
    static let financialOverview = "financial_overview"
    static let personalizedAdvice = "personalized_advice"
    static let refresh = "refresh"
    static let analyzingFinances = "analyzing_finances"
    static let getAIAdvice = "get_ai_advice"
    static let addTransactionsAdvice = "add_transactions_advice"
    static let generateAdvice = "generate_advice"
    
    // MARK: - Financial Summary
    static let balance = "balance"
    static let savingsRate = "savings_rate"
    static let transactions = "transactions"
    
    // MARK: - AI Advice Messages
    static let startTrackingTitle = "start_tracking_title"
    static let startTrackingDesc = "start_tracking_desc"
    static let startTrackingAction = "start_tracking_action"
    
    static let negativeBalanceTitle = "negative_balance_title"
    static let negativeBalanceDesc = "negative_balance_desc"
    static let negativeBalanceAction = "negative_balance_action"
    
    static let improveSavingsTitle = "improve_savings_title"
    static let improveSavingsDesc = "improve_savings_desc"
    static let improveSavingsAction = "improve_savings_action"
    
    static let excellentSavingsTitle = "excellent_savings_title"
    static let excellentSavingsDesc = "excellent_savings_desc"
    static let excellentSavingsAction = "excellent_savings_action"
    
    static let highSpendingTitle = "high_spending_title"
    static let highSpendingDesc = "high_spending_desc"
    static let highSpendingAction = "high_spending_action"
    
    static let emergencyFundTitle = "emergency_fund_title"
    static let emergencyFundDesc = "emergency_fund_desc"
    static let emergencyFundAction = "emergency_fund_action"
    
    static let trackProgressTitle = "track_progress_title"
    static let trackProgressDesc = "track_progress_desc"
    static let trackProgressAction = "track_progress_action"
}

// MARK: - Language Manager
class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: String = "en" {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "app_language")
            updateBundle()
            NotificationCenter.default.post(name: .languageChanged, object: nil)
        }
    }
    
    private var currentBundle: Bundle = Bundle.main
    
    private init() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "app_language") {
            currentLanguage = savedLanguage
        } else {
            // Default to device language if supported, otherwise English
            let deviceLanguage = Locale.current.languageCode ?? "en"
            currentLanguage = supportedLanguages.contains(deviceLanguage) ? deviceLanguage : "en"
        }
        updateBundle()
    }
    
    let supportedLanguages = ["en", "vi", "fr", "zh-Hans"]
    
    var supportedLanguageNames: [String: String] {
        [
            "en": "English",
            "vi": "Tiếng Việt",
            "fr": "Français",
            "zh-Hans": "简体中文"
        ]
    }
    
    func setLanguage(_ languageCode: String) {
        guard supportedLanguages.contains(languageCode) else { return }
        currentLanguage = languageCode
    }
    
    private func updateBundle() {
        if let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            currentBundle = bundle
        } else {
            currentBundle = Bundle.main
        }
    }
    
    func getLocalizedString(_ key: String, arguments: CVarArg...) -> String {
        let localizedString = NSLocalizedString(key, bundle: currentBundle, comment: "")
        if arguments.isEmpty {
            return localizedString
        } else {
            return String(format: localizedString, arguments: arguments)
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
    static let themeChanged = Notification.Name("themeChanged")
}
