//
//  SpendingView.swift
//  SavingMoney
//
//  Created by congtungit on 21/2/26.
//

import SwiftUI
import SwiftData

struct SpendingView: View {
  @State var selectedMonth = Calendar.current.component(.month, from: Date())
  @State var selectedYear = Calendar.current.component(.year, from: Date())
  @State var selectedDate = Date()
  @EnvironmentObject var transactionViewModel: TransactionViewModel
  @Environment(\.modelContext) private var modelContext
  @State var allTime: Bool = false
  @State var displayDetail: Bool = false
  @State private var editingTransaction: Transaction?
  @State private var editingAmount = ""
  @State private var editingDescription = ""
  @State private var editingCategory: TransactionCategory?
  @Query var transactions: [Transaction]
  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        Text(LocalizationKeys.spendingOverview.localized)
          .font(.largeTitle)
          .fontWeight(.bold)
          .padding(.top)
        if !allTime {
          Text(LocalizationKeys.totalSpentPermonth.localized(arguments: totalSpending.formatted(
            .number
              .grouping(.automatic)
              .precision(.fractionLength(0)))))
          .font(.title2)
          .fontWeight(.semibold)
          .foregroundColor(.red)
        } else {
          Text(LocalizationKeys.totalSpent.localized(arguments: totalSpending.formatted(
            .number
              .grouping(.automatic)
              .precision(.fractionLength(0)))))
          .font(.title2)
          .fontWeight(.semibold)
          .foregroundColor(.green)
          
        }
        VStack(alignment: .center) {
          if !allTime {
            MonthYearPickerView(selectedMonth: $selectedMonth, selectedYear: $selectedYear)
          }
          Toggle(isOn: $allTime, label: {
            Text(LocalizationKeys.displayAllTimeOnly.localized)
          }).frame(width: 220)
        }.frame(maxWidth: .infinity)
        SpendingOverviewCircleView(categoryPercents: calculateSpendingPercents(date: Date.startOfMonth(for: selectedMonth, of: selectedYear)))
        
        
      }.frame(maxWidth: .infinity)
      VStack(alignment: .center) {
        
        Toggle(isOn: $displayDetail, label: {
          Text(LocalizationKeys.displayDetailed.localized)
        }).frame(width: 220)
        if displayDetail {
          let detailedTransactions = getListOfCalculated(date: Date.startOfMonth(for: selectedMonth, of: selectedYear))
          if !detailedTransactions.isEmpty {
            TransactionDetailTableView(transactions: detailedTransactions) { transaction in
              beginEditing(transaction)
            }
              .padding(.horizontal, 4)
          }
        } 
      }
    }
    .frame(maxHeight: .infinity)
    .overlay {
      if let editingTransaction {
        TransactionEntryPopupView(
          title: LocalizationKeys.editExpense.localized,
          amountText: $editingAmount,
          descriptionText: $editingDescription,
          selectedCategory: $editingCategory,
          isIncome: editingTransaction.isIncome,
          allowsCategorySelection: true,
          onSave: { commitEdit(for: editingTransaction) },
          onCancel: { clearEditingState() },
          onDelete: { deleteTransaction(for: editingTransaction) }
        )
      }
    }
  }

  private func beginEditing(_ transaction: Transaction) {
    editingTransaction = transaction
    editingAmount = transaction.amount.formatted(.number.precision(.fractionLength(0)).grouping(.never))
    editingDescription = transaction.descriptionText
    editingCategory = CategoryModel.shared.getCategory(name: transaction.category, isIncome: transaction.isIncome)
  }

  private func commitEdit(for transaction: Transaction) {
    let normalized = editingAmount.replacingOccurrences(of: ",", with: "")
    guard let newAmount = Double(normalized), newAmount >= 0, let category = editingCategory else { return }
    let delta = newAmount - transaction.amount
    if delta != 0 {
      transactionViewModel.balance -= delta
    }
    transaction.amount = newAmount
    transaction.descriptionText = editingDescription
    transaction.category = category.name
    try? modelContext.save()
    clearEditingState()
  }

  private func deleteTransaction(for transaction: Transaction) {
    if transaction.isIncome {
      transactionViewModel.balance -= transaction.amount
    } else {
      transactionViewModel.balance += transaction.amount
    }
    modelContext.delete(transaction)
    try? modelContext.save()
    clearEditingState()
  }

  private func clearEditingState() {
    editingTransaction = nil
    editingAmount = ""
    editingDescription = ""
    editingCategory = nil
  }
  private func getListOfCalculated(date: Date?) -> [Transaction] {
    if allTime {
      return transactions.filter { !$0.isIncome } 
    }
    return transactionByMonth(date: date ?? Date()).filter { !$0.isIncome } 
  }
  
  private func transactionByMonth(date: Date) -> [Transaction] {
    let month = Calendar.current.component(.month, from: date)
    let year = Calendar.current.component(.year, from: date)
    let allTransactionByMonth = transactions.filter { transaction -> Bool in {
      let monthOfTransaction = Calendar.current.component(.month, from: transaction.date)
      let yearOfTransaction = Calendar.current.component(.year, from: transaction.date)
      return monthOfTransaction == month && yearOfTransaction == year
    }()
    }
    return allTransactionByMonth
  }
  
  private func calculateSpendingPercents(date: Date?) -> [(category: String, percent: Double, color: Color)] {
    let expenses = getListOfCalculated(date: date)
    let totalExpenses = expenses.reduce(0) { $0 + $1.amount }
    
    guard totalExpenses > 0 else {
      return []
    }
    
    var categoryTotals: [String: Double] = [:]
    for expense in expenses {
      categoryTotals[expense.category, default: 0] += expense.amount
    }
    

    
    return categoryTotals.map { category, amount in
      let percent = amount / totalExpenses
      let color = CategoryModel.shared.getCategory(name: category, isIncome: false)?.swiftUIColor ?? .gray
      return (category: category, percent: percent, color: color)
    }.sorted { $0.percent > $1.percent }
  }
  
  private var totalSpending: Double { transactions.filter { !$0.isIncome }
      .reduce(0) { $0 + $1.amount }
  }
  private var totalSpendingByMonth: Double { transactionByMonth(date: Date.startOfMonth(for: selectedMonth, of: selectedYear) ?? Date())
      .filter { !$0.isIncome }
      .reduce(0) { $0 + $1.amount }
  }
}

#Preview {
  SpendingView() 
}
extension Date {
  /**
   Creates a Date object for the start of a specific month and year.
   - Parameters:
   - month: The desired month (1-12).
   - year: The desired year.
   - calendar: The calendar to use (defaults to the current calendar).
   - Returns: The Date object for the first day of the specified month and year, or nil if the components are invalid.
   */
  static func startOfMonth(for month: Int, of year: Int, using calendar: Calendar = .current) -> Date? {
    // Create DateComponents with the specified year and month, and implicitly sets the day to 1
    let components = DateComponents(calendar: calendar, year: year, month: month)
    // Returns the Date from the components
    return calendar.date(from: components)
  }
}
