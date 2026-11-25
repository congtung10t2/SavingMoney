import SwiftUI
import _SwiftData_SwiftUI

struct MainActionView: View {
  @State private var selectedType: ActionType? = nil
  @State private var selectedCategory: TransactionCategory? = nil
  @State private var showAmountPopup = false
  @State private var amountText = ""
  @State private var descriptionText = ""
  @EnvironmentObject var viewModel: TransactionViewModel
  @Environment(\.modelContext) var modelContext
  @Query var transactions: [Transaction]
  
  var body: some View {
    ScrollView {
      VStack(spacing: 32) {
        Text(LocalizationKeys.balanceLabel.localized(arguments: viewModel.balance.formatted(
          .number
            .grouping(.automatic)
            .precision(.fractionLength(0)))))
        .font(.title)
        .bold()
        .padding(.top, 16)
        
        if LanguageManager.shared.initialMoney > 0 {
          Text(LanguageManager.formatInitialMoneyNote(
            amount: LanguageManager.shared.initialMoney,
            on: LanguageManager.shared.initialMoneyDate ?? Date()))
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.top, 4)
        }
        
        Text(LocalizationKeys.whatDoYouWant.localized)
          .font(.title2)
          .bold()
          .padding(.top, 8)
        
        HStack(spacing: 40) {
          ActionButton(type: .spending, selected: selectedType == .spending) {
            selectedType = .spending
            selectedCategory = nil
          }
          ActionButton(type: .saving, selected: selectedType == .saving) {
            selectedType = .saving
            selectedCategory = nil
          }
        }
        
        if let type = selectedType {
          Text(LocalizationKeys.selectCategory.localized)
            .font(.headline)
          CategoryGridView(
            isIncome: type == .saving, 
            selectedCategory: $selectedCategory,
            onCategorySelected: { category in
              selectedCategory = category
              showAmountPopup = true
            }
          )
        }
        
        Spacer()
      }
      .padding()
      .frame(maxWidth: .infinity)
    }
    .overlay(
      Group {
        if showAmountPopup, let type = selectedType {
          TransactionEntryPopupView(
            title: type == .saving ? LocalizationKeys.addDeposit.localized : LocalizationKeys.addExpense.localized,
            amountText: $amountText,
            descriptionText: $descriptionText,
            selectedCategory: $selectedCategory,
            isIncome: type == .saving,
            allowsCategorySelection: false,
            onSave: {
              if let amount = Double(amountText.replacingOccurrences(of: ",", with: "")), let category = selectedCategory {
                modelContext.insert(viewModel.addTransaction(amount: amount, description: descriptionText, isIncome: type == .saving, category: category.name))
                amountText = ""
                descriptionText = ""
                showAmountPopup = false
                selectedType = nil
                selectedCategory = nil
              }
            },
            onCancel: {
              showAmountPopup = false
              amountText = ""
              descriptionText = ""
            }
          )
        }
      }
    )
    .onAppear() {
      viewModel.balance = totalIncome - totalExpenses + LanguageManager.shared.initialMoney
    }
    
  }
  private var totalIncome: Double {
    transactions.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
  }
  
  private var totalExpenses: Double {
    transactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
  }
  
}

enum ActionType {
  case spending, saving
  case expenses
  case passiveIncome
  var icon: String {
    switch self {
    case .spending: return "minus.circle.fill"
    case .saving: return "plus.circle.fill"
    case .expenses: return "divide.circle"
    case .passiveIncome: return "multiply.circle"
    }
  }
  var color: Color {
    switch self {
    case .spending: return .red
    case .saving: return .green
    case .expenses: return .orange
    case .passiveIncome: return .blue
    }
  }
  
  var localizedTitle: String {
    switch self {
    case .spending: return LocalizationKeys.spendingAction.localized
    case .saving: return LocalizationKeys.savingAction.localized
    case .expenses: return "Expenses"
    case .passiveIncome: return "Passive Income"
    }
  }
  var accessibilityIdentifier: String {
    switch self {
    case .spending: return "SpendingAction"
    case .saving: return "SavingAction"
    case .expenses: return "ExpensesAction"
    case .passiveIncome: return "PassiveIncomeAction"
    }
  }
}

struct ActionButton: View {
  let type: ActionType
  let selected: Bool
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      VStack {
        Image(systemName: type.icon)
          .resizable()
          .frame(width: 48, height: 48)
          .foregroundColor(type.color)
        Text(type.localizedTitle)
          .font(.headline)
      }
      .padding()
      .background(selected ? Color(.systemGray5) : Color.clear)
      .cornerRadius(12)
    }
    .accessibilityIdentifier(type.accessibilityIdentifier)
  }
}

struct CategoryGridView: View {
  let isIncome: Bool
  @Binding var selectedCategory: TransactionCategory?
  let onCategorySelected: (TransactionCategory) -> Void
  @ObservedObject private var categoryModel = CategoryModel.shared
  @State private var showingManager = false

  var categories: [TransactionCategory] {
    isIncome ? categoryModel.getLocalizedIncomeCategories() : categoryModel.getLocalizedExpenseCategories()
  }
  
  let columns = [GridItem(.adaptive(minimum: 80))]
  
  var body: some View {
    LazyVGrid(columns: columns, spacing: 20) {
      ForEach(categories) { category in
        CategoryItemView(category: category, selected: selectedCategory?.name == category.name) {
          onCategorySelected(category)
        }
      }

      Button {
        showingManager = true
      } label: {
        VStack(spacing: 6) {
          Image(systemName: "plus")
            .font(.title)
            .foregroundColor(.gray)
          Text(LocalizationKeys.manageCategories.localized)
            .font(.caption)
            .foregroundColor(.secondary)
            .lineLimit(2)
            .multilineTextAlignment(.center)
        }
        .frame(width: 80, height: 80)
        .background(Color(.systemGray6))
        .cornerRadius(12)
      }
      .buttonStyle(.plain)
      .accessibilityIdentifier("ManageCategoriesButton")
    }
    .sheet(isPresented: $showingManager) {
      CategoryManagerView(isIncome: isIncome, selectedCategory: $selectedCategory)
    }
  }
}

struct CategoryItemView: View {
  let category: TransactionCategory
  let selected: Bool
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      VStack(spacing: 6) {
        Image(systemName: category.icon)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 28, height: 28)
          .foregroundColor(category.swiftUIColor)
        Text(category.localizedName)
          .font(.caption)
          .lineLimit(2)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)
      }
      .frame(width: 80, height: 80)
      .background(selected ? Color(.systemGray4) : Color(.systemGray6))
      .cornerRadius(12)
    }
  }
}

struct CategoryManagerView: View {
  let isIncome: Bool
  @Binding var selectedCategory: TransactionCategory?
  @ObservedObject private var categoryModel = CategoryModel.shared
  @Environment(\.dismiss) private var dismiss
  @State private var newCategoryName = ""
  @State private var errorMessage: String?

  private var categories: [TransactionCategory] {
    isIncome ? categoryModel.getLocalizedIncomeCategories() : categoryModel.getLocalizedExpenseCategories()
  }

  var body: some View {
    NavigationStack {
      Form {
        Section(LocalizationKeys.addCategory.localized) {
          TextField(LocalizationKeys.categoryNamePlaceholder.localized, text: $newCategoryName)
            .textInputAutocapitalization(.words)
          Button {
            addCategory()
          } label: {
            Label(LocalizationKeys.addCategory.localized, systemImage: "plus.circle.fill")
          }
          .disabled(newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
          if let message = errorMessage {
            Text(message)
              .font(.caption)
              .foregroundColor(.red)
          }
        }

        Section(LocalizationKeys.categories.localized) {
          ForEach(categories) { category in
            HStack {
              Image(systemName: category.icon)
                .foregroundColor(category.swiftUIColor)
                .frame(width: 24)
              Text(category.localizedName)
              Spacer()
              Button {
                removeCategory(category)
              } label: {
                Image(systemName: "minus.circle.fill")
                  .foregroundColor(.red)
              }
              .buttonStyle(.borderless)
              .accessibilityLabel(LocalizationKeys.removeCategory.localized(arguments: category.localizedName))
            }
          }
        }
      }
      .navigationTitle(LocalizationKeys.manageCategories.localized)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button(LocalizationKeys.done.localized) {
            dismiss()
          }
        }
      }
    }
  }

  private func addCategory() {
    let name = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !name.isEmpty else { return }
    if categoryModel.addCategory(name: name, isIncome: isIncome) != nil {
      newCategoryName = ""
      errorMessage = nil
    } else {
      errorMessage = LocalizationKeys.categoryAlreadyExists.localized(arguments: name)
    }
  }

  private func removeCategory(_ category: TransactionCategory) {
    categoryModel.removeCategory(named: category.name, isIncome: isIncome)
    if selectedCategory?.name == category.name {
      selectedCategory = nil
    }
    if errorMessage != nil {
      errorMessage = nil
    }
  }
}

struct MainActionView_Previews: PreviewProvider {
  static var previews: some View {
    MainActionView()
      .environmentObject(TransactionViewModel())
  }
}
