import Foundation
import SwiftUI

struct TransactionCategory: Codable, Equatable, Identifiable {
    let name: String
    let localizedName: String
    let icon: String
    let color: String
    var localizationKey: String? = nil

    var id: String { name }

    /// Returns a copy with the localized name refreshed for the current language.
    func localized() -> TransactionCategory {
        guard let key = localizationKey else { return self }
        return TransactionCategory(
            name: name,
            localizedName: key.localized,
            icon: icon,
            color: color,
            localizationKey: key
        )
    }
}

class CategoryModel: ObservableObject {
    static let shared = CategoryModel()

    private static let customExpenseKey = "custom_expense_categories"
    private static let customIncomeKey = "custom_income_categories"
    private static let hiddenExpenseKey = "hidden_expense_categories"
    private static let hiddenIncomeKey = "hidden_income_categories"

    private let defaultExpenseCategories: [TransactionCategory] = [
        TransactionCategory(name: "Food", localizedName: LocalizationKeys.categoryFood.localized, icon: "fork.knife", color: "orange", localizationKey: LocalizationKeys.categoryFood),
        TransactionCategory(name: "Transportation", localizedName: LocalizationKeys.categoryTransportation.localized, icon: "car.fill", color: "blue", localizationKey: LocalizationKeys.categoryTransportation),
        TransactionCategory(name: "Shopping", localizedName: LocalizationKeys.categoryShopping.localized, icon: "bag.fill", color: "purple", localizationKey: LocalizationKeys.categoryShopping),
        TransactionCategory(name: "Entertainment", localizedName: LocalizationKeys.categoryEntertainment.localized, icon: "tv.fill", color: "red", localizationKey: LocalizationKeys.categoryEntertainment),
        TransactionCategory(name: "Bills", localizedName: LocalizationKeys.categoryBills.localized, icon: "doc.text.fill", color: "gray", localizationKey: LocalizationKeys.categoryBills),
        TransactionCategory(name: "Healthcare", localizedName: LocalizationKeys.categoryHealthcare.localized, icon: "cross.fill", color: "green", localizationKey: LocalizationKeys.categoryHealthcare),
        TransactionCategory(name: "Education", localizedName: LocalizationKeys.categoryEducation.localized, icon: "book.fill", color: "indigo", localizationKey: LocalizationKeys.categoryEducation),
        TransactionCategory(name: "Cafe", localizedName: LocalizationKeys.categoryEntertainment.localized, icon: "cup.and.heat.waves.fill", color: "red", localizationKey: LocalizationKeys.categoryEntertainment),
        TransactionCategory(name: "Cash Widrawal", localizedName: LocalizationKeys.categoryEntertainment.localized, icon: "creditcard.fill", color: "red", localizationKey: LocalizationKeys.categoryEntertainment),
        TransactionCategory(name: "Credit card", localizedName: LocalizationKeys.categoryEntertainment.localized, icon: "creditcard.arrow.trianglehead.2.clockwise.rotate.90", color: "red", localizationKey: LocalizationKeys.categoryEntertainment),
        TransactionCategory(name: "Other", localizedName: LocalizationKeys.categoryOther.localized, icon: "ellipsis.circle.fill", color: "brown", localizationKey: LocalizationKeys.categoryOther)
    ]

    private let defaultIncomeCategories: [TransactionCategory] = [
        TransactionCategory(name: "Salary", localizedName: LocalizationKeys.categorySalary.localized, icon: "dollarsign.circle.fill", color: "green", localizationKey: LocalizationKeys.categorySalary),
        TransactionCategory(name: "Freelance", localizedName: LocalizationKeys.categoryFreelance.localized, icon: "laptopcomputer", color: "blue", localizationKey: LocalizationKeys.categoryFreelance),
        TransactionCategory(name: "Investment", localizedName: LocalizationKeys.categoryInvestment.localized, icon: "chart.line.uptrend.xyaxis", color: "purple", localizationKey: LocalizationKeys.categoryInvestment),
        TransactionCategory(name: "Gift", localizedName: LocalizationKeys.categoryGift.localized, icon: "gift.fill", color: "pink", localizationKey: LocalizationKeys.categoryGift),
        TransactionCategory(name: "Other", localizedName: LocalizationKeys.categoryOther.localized, icon: "ellipsis.circle.fill", color: "brown", localizationKey: LocalizationKeys.categoryOther)
    ]

    @Published private(set) var customExpenseCategories: [TransactionCategory]
    @Published private(set) var customIncomeCategories: [TransactionCategory]
    @Published private(set) var hiddenExpenseCategoryNames: Set<String>
    @Published private(set) var hiddenIncomeCategoryNames: Set<String>

    /// All categories, including hidden ones, so existing transactions can still be resolved.
    var expenseCategories: [TransactionCategory] {
        defaultExpenseCategories + customExpenseCategories
    }

    var incomeCategories: [TransactionCategory] {
        defaultIncomeCategories + customIncomeCategories
    }

    private init() {
        customExpenseCategories = Self.load([TransactionCategory].self, forKey: Self.customExpenseKey) ?? []
        customIncomeCategories = Self.load([TransactionCategory].self, forKey: Self.customIncomeKey) ?? []
        hiddenExpenseCategoryNames = Self.load(Set<String>.self, forKey: Self.hiddenExpenseKey) ?? []
        hiddenIncomeCategoryNames = Self.load(Set<String>.self, forKey: Self.hiddenIncomeKey) ?? []
    }

    func getCategory(name: String, isIncome: Bool) -> TransactionCategory? {
        let categories = isIncome ? incomeCategories : expenseCategories
        return categories.first { $0.name == name }?.localized()
    }

    /// Visible categories with names refreshed for the current app language.
    func getLocalizedExpenseCategories() -> [TransactionCategory] {
        visibleCategories(
            defaults: defaultExpenseCategories,
            hidden: hiddenExpenseCategoryNames,
            custom: customExpenseCategories
        )
    }

    func getLocalizedIncomeCategories() -> [TransactionCategory] {
        visibleCategories(
            defaults: defaultIncomeCategories,
            hidden: hiddenIncomeCategoryNames,
            custom: customIncomeCategories
        )
    }

    @discardableResult
    func addCategory(name: String, isIncome: Bool) -> TransactionCategory? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return nil }

        let allCategories = isIncome ? incomeCategories : expenseCategories

        // Adding back a removed built-in category restores it instead of creating a custom one.
        if let restored = allCategories.first(where: { $0.name == trimmedName }) {
            if isIncome {
                hiddenIncomeCategoryNames.remove(trimmedName)
            } else {
                hiddenExpenseCategoryNames.remove(trimmedName)
            }
            save()
            return restored.localized()
        }

        guard !allCategories.contains(where: { $0.name.caseInsensitiveCompare(trimmedName) == .orderedSame }) else {
            return nil
        }

        let category = TransactionCategory(name: trimmedName, localizedName: trimmedName, icon: "tag.fill", color: "blue")
        if isIncome {
            customIncomeCategories.append(category)
        } else {
            customExpenseCategories.append(category)
        }
        save()
        return category
    }

    func removeCategory(named name: String, isIncome: Bool) {
        let isDefault = (isIncome ? defaultIncomeCategories : defaultExpenseCategories)
            .contains { $0.name == name }

        if isDefault {
            if isIncome {
                hiddenIncomeCategoryNames.insert(name)
            } else {
                hiddenExpenseCategoryNames.insert(name)
            }
        } else if isIncome {
            customIncomeCategories.removeAll { $0.name == name }
        } else {
            customExpenseCategories.removeAll { $0.name == name }
        }
        save()
    }

    func hasCategory(named name: String, isIncome: Bool) -> Bool {
        let categories = isIncome ? incomeCategories : expenseCategories
        return categories.contains { $0.name.caseInsensitiveCompare(name) == .orderedSame }
    }

    private func visibleCategories(
        defaults: [TransactionCategory],
        hidden: Set<String>,
        custom: [TransactionCategory]
    ) -> [TransactionCategory] {
        defaults.filter { !hidden.contains($0.name) }.map { $0.localized() } + custom
    }

    private func save() {
        Self.save(customExpenseCategories, forKey: Self.customExpenseKey)
        Self.save(customIncomeCategories, forKey: Self.customIncomeKey)
        Self.save(hiddenExpenseCategoryNames, forKey: Self.hiddenExpenseKey)
        Self.save(hiddenIncomeCategoryNames, forKey: Self.hiddenIncomeKey)
    }

    private static func save<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private static func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
