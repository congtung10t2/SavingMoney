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
    .overlay(
      // Custom popup overlay that dims entire screen
      Group {
        if showAmountPopup {
          ZStack {
            // Full screen dark overlay
            Color.black.opacity(0.4)
              .ignoresSafeArea(.all)
              .onTapGesture {
                showAmountPopup = false
              }
            
            // Popup content
            VStack(spacing: 20) {
              HStack {
                Text(selectedType == .saving ? LocalizationKeys.addDeposit.localized : LocalizationKeys.addExpense.localized)
                  .font(.headline)
                Spacer()
                Button("✕") {
                  showAmountPopup = false
                }
                .foregroundColor(.gray)
              }
              
              if let category = selectedCategory {
                Text(LocalizationKeys.categoryLabel.localized(arguments: category.localizedName))
                  .font(.subheadline)
                  .foregroundColor(.secondary)
              }
              
              TextField(LocalizationKeys.amountPlaceholder.localized, text: $amountText)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
              
              TextField(LocalizationKeys.descriptionPlaceholder.localized, text: $descriptionText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
              
              HStack(spacing: 32) {
                Button(LocalizationKeys.cancel.localized) {
                  showAmountPopup = false
                  amountText = ""
                  descriptionText = ""
                }
                .foregroundColor(.red)
                .frame(minWidth: 80)
                
                Button(LocalizationKeys.save.localized) {
                  if let amount = Double(amountText), let category = selectedCategory {
                    modelContext.insert( viewModel.addTransaction(amount: amount, description: descriptionText, isIncome: selectedType == .saving, category: category.name))
                    amountText = ""
                    descriptionText = ""
                    showAmountPopup = false
                    selectedType = nil
                    selectedCategory = nil
                  }
                }
                .disabled(Double(amountText) == nil)
                .foregroundColor(Double(amountText) == nil ? .gray : .blue)
                .frame(minWidth: 80)
              }
            }
            .padding(24)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(radius: 20)
            .frame(maxWidth: 320)
            .padding(.horizontal, 20)
          }
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
  
  var categories: [TransactionCategory] {
    isIncome ? CategoryModel.shared.getLocalizedIncomeCategories() : CategoryModel.shared.getLocalizedExpenseCategories()
  }
  
  let columns = [GridItem(.adaptive(minimum: 80))]
  
  var body: some View {
    LazyVGrid(columns: columns, spacing: 20) {
      ForEach(categories, id: \.name) { category in
        CategoryItemView(category: category, selected: selectedCategory?.name == category.name) {
          onCategorySelected(category)
        }
      }
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
          .foregroundColor(selected ? .blue : .gray)
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

struct MainActionView_Previews: PreviewProvider {
  static var previews: some View {
    MainActionView()
      .environmentObject(TransactionViewModel())
  }
}
