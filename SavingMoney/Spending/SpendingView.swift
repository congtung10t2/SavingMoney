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
  @State var allTime: Bool = false
  @State var displayDetail: Bool = false
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
            Text("Display all time only")
          }).frame(width: 220)
        }.frame(maxWidth: .infinity)
        SpendingOverviewCircleView(categoryPercents: calculateSpendingPercents(date: Date.startOfMonth(for: selectedMonth, of: selectedYear)))
        
        
      }.frame(maxWidth: .infinity)
      VStack(alignment: .center) {
        
        Toggle(isOn: $displayDetail, label: {
          Text("Display detailed")
        }).frame(width: 220)
        if displayDetail {
          let detailedTransactions = getListOfCalculated(date: Date.startOfMonth(for: selectedMonth, of: selectedYear))
          if !detailedTransactions.isEmpty {
            TransactionDetailTableView(transactions: detailedTransactions)
              .padding(.horizontal, 4)
          }
        } 
      }
    }
    .frame(maxHeight: .infinity)
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
    
    let categoryColors: [String: Color] = [
      "Food": .orange,
      "Transport": .blue,
      "Shopping": .purple,
      "Bills": .gray,
      "Entertainment": .green,
      "Health": .red,
      "Other": .yellow
    ]
    
    return categoryTotals.map { category, amount in
      let percent = amount / totalExpenses
      let color = categoryColors[category] ?? .gray
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
