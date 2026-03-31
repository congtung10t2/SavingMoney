import Foundation

struct TransactionCategory {
    let name: String
    let localizedName: String
    let icon: String
    let color: String
}

class CategoryModel: ObservableObject {
    static let shared = CategoryModel()
    
    let expenseCategories = [
        TransactionCategory(name: "Food", localizedName: LocalizationKeys.categoryFood.localized, icon: "fork.knife", color: "orange"),
        TransactionCategory(name: "Transportation", localizedName: LocalizationKeys.categoryTransportation.localized, icon: "car.fill", color: "blue"),
        TransactionCategory(name: "Shopping", localizedName: LocalizationKeys.categoryShopping.localized, icon: "bag.fill", color: "purple"),
        TransactionCategory(name: "Entertainment", localizedName: LocalizationKeys.categoryEntertainment.localized, icon: "tv.fill", color: "red"),
        TransactionCategory(name: "Bills", localizedName: LocalizationKeys.categoryBills.localized, icon: "doc.text.fill", color: "gray"),
        TransactionCategory(name: "Healthcare", localizedName: LocalizationKeys.categoryHealthcare.localized, icon: "cross.fill", color: "green"),
        TransactionCategory(name: "Education", localizedName: LocalizationKeys.categoryEducation.localized, icon: "book.fill", color: "indigo"),
        TransactionCategory(name: "Cafe", localizedName: LocalizationKeys.categoryEntertainment.localized, icon: "cup.and.heat.waves.fill", color: "red"),
        TransactionCategory(name: "Cash Widrawal", localizedName: LocalizationKeys.categoryEntertainment.localized, icon: "creditcard.fill", color: "red"),
        TransactionCategory(name: "Credit card", localizedName: LocalizationKeys.categoryEntertainment.localized, icon: "creditcard.arrow.trianglehead.2.clockwise.rotate.90", color: "red"),
        TransactionCategory(name: "Other", localizedName: LocalizationKeys.categoryOther.localized, icon: "ellipsis.circle.fill", color: "brown")
    ]
    
    let incomeCategories = [
        TransactionCategory(name: "Salary", localizedName: LocalizationKeys.categorySalary.localized, icon: "dollarsign.circle.fill", color: "green"),
        TransactionCategory(name: "Freelance", localizedName: LocalizationKeys.categoryFreelance.localized, icon: "laptopcomputer", color: "blue"),
        TransactionCategory(name: "Investment", localizedName: LocalizationKeys.categoryInvestment.localized, icon: "chart.line.uptrend.xyaxis", color: "purple"),
        TransactionCategory(name: "Gift", localizedName: LocalizationKeys.categoryGift.localized, icon: "gift.fill", color: "pink"),
        TransactionCategory(name: "Other", localizedName: LocalizationKeys.categoryOther.localized, icon: "ellipsis.circle.fill", color: "brown")
    ]
    
    private init() {}
    
    func getCategory(name: String, isIncome: Bool) -> TransactionCategory? {
        let categories = isIncome ? incomeCategories : expenseCategories
        return categories.first { $0.name == name }
    }
    
    // Get updated categories with current localization
    func getLocalizedExpenseCategories() -> [TransactionCategory] {
        return [
            TransactionCategory(name: "Food", localizedName: LocalizationKeys.categoryFood.localized, icon: "fork.knife", color: "orange"),
            TransactionCategory(name: "Transportation", localizedName: LocalizationKeys.categoryTransportation.localized, icon: "car.fill", color: "blue"),
            TransactionCategory(name: "Shopping", localizedName: LocalizationKeys.categoryShopping.localized, icon: "bag.fill", color: "purple"),
            TransactionCategory(name: "Entertainment", localizedName: LocalizationKeys.categoryEntertainment.localized, icon: "tv.fill", color: "red"),
            TransactionCategory(name: "Bills", localizedName: LocalizationKeys.categoryBills.localized, icon: "doc.text.fill", color: "gray"),
            TransactionCategory(name: "Healthcare", localizedName: LocalizationKeys.categoryHealthcare.localized, icon: "cross.fill", color: "green"),
            TransactionCategory(name: "Education", localizedName: LocalizationKeys.categoryEducation.localized, icon: "book.fill", color: "indigo"),
            TransactionCategory(name: "Other", localizedName: LocalizationKeys.categoryOther.localized, icon: "ellipsis.circle.fill", color: "brown")
        ]
    }
    
    func getLocalizedIncomeCategories() -> [TransactionCategory] {
        return [
            TransactionCategory(name: "Salary", localizedName: LocalizationKeys.categorySalary.localized, icon: "dollarsign.circle.fill", color: "green"),
            TransactionCategory(name: "Freelance", localizedName: LocalizationKeys.categoryFreelance.localized, icon: "play.laptopcomputer", color: "blue"),
            TransactionCategory(name: "Investment", localizedName: LocalizationKeys.categoryInvestment.localized, icon: "chart.line.uptrend.xyaxis", color: "purple"),
            TransactionCategory(name: "Gift", localizedName: LocalizationKeys.categoryGift.localized, icon: "gift.fill", color: "pink"),
            TransactionCategory(name: "Other", localizedName: LocalizationKeys.categoryOther.localized, icon: "ellipsis.circle.fill", color: "brown")
        ]
    }
}
