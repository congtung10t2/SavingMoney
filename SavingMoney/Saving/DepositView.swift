//
//  DepositView.swift
//  SavingMoney
//
//  Created by congtungit on 16/2/26.
//

import Foundation
import SwiftUI
import SwiftData

struct DepositView: View {
  @State var selectedMonth = Calendar.current.component(.month, from: Date())
  @State var selectedYear = Calendar.current.component(.year, from: Date())
  @State var allTime: Bool = false
  @State var displayDetail: Bool = false
  @EnvironmentObject var transactionViewModel: TransactionViewModel
  @Environment(\.modelContext) private var modelContext
  @State private var editingTransaction: Transaction?
  @State private var editingAmount = ""
  @State private var editingDescription = ""
  @State private var editingCategory: TransactionCategory?
  @Query var transactions: [Transaction]
  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        Text(LocalizationKeys.depositOverview.localized)
          .font(.largeTitle)
          .fontWeight(.bold)
          .padding(.top)
        if allTime {
          Text(LocalizationKeys.totalDeposits.localized(arguments: totalDeposits.formatted(
            .number
              .grouping(.automatic)
              .precision(.fractionLength(0)))))
          .font(.title2)
          .fontWeight(.semibold)
          .foregroundColor(.green)
        } else {
          Text(LocalizationKeys.totalDepositsPermonth.localized(arguments: totalDeposits.formatted(
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
            Text("Display All Time")
          }).frame(width: 220)
        }.frame(maxWidth: .infinity)
        
        
      }.frame(maxWidth: .infinity)
      DepositOverviewBarView(categoryPercents: calculateDepositPercents(date: Date.startOfMonth(for: selectedMonth, of: selectedYear) ?? Date()))
      VStack(alignment: .center) {
        Toggle(isOn: $displayDetail, label: {
          Text("Display detailed")
        }).frame(width: 220)
        if displayDetail {
          let detailedTransactions = getListOfCalculated(date: Date.startOfMonth(for: selectedMonth, of: selectedYear) ?? Date())
          if !detailedTransactions.isEmpty {
            TransactionDetailTableView(transactions: detailedTransactions) { transaction in
              beginEditing(transaction)
            }
              .padding(.horizontal, 4)
          }
        } 
        Spacer()
      }
    }.frame(maxHeight: .infinity)
    .overlay {
      if let editingTransaction {
        TransactionEntryPopupView(
          title: LocalizationKeys.addDeposit.localized,
          amountText: $editingAmount,
          descriptionText: $editingDescription,
          selectedCategory: $editingCategory,
          isIncome: editingTransaction.isIncome,
          allowsCategorySelection: true,
          onSave: { commitEdit(for: editingTransaction) },
          onCancel: { clearEditingState() }
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
      transactionViewModel.balance += delta
    }
    transaction.amount = newAmount
    transaction.descriptionText = editingDescription
    transaction.category = category.name
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
      return transactions.filter { $0.isIncome }
    }
    return transactionByMonth(date: date ?? Date()).filter { $0.isIncome }
  }
  
  private func calculateDepositPercents(date: Date?) -> [(category: String, percent: Double, color: Color)] {
 
    let deposits = getListOfCalculated(date: date).filter { $0.isIncome }
    let totalDeposits = deposits.reduce(0) { $0 + $1.amount }
    
    guard totalDeposits > 0 else {
      return []
    }
    
    var categoryTotals: [String: Double] = [:]
    for deposit in deposits {
      categoryTotals[deposit.category, default: 0] += deposit.amount
    }
    
    let categoryColors: [String: Color] = [
      "Salary": .green,
      "Freelance": .blue,
      "Investment": .purple,
      "Gift": .pink,
      "Bonus": .orange,
      "Other": .yellow
    ]
    
    return categoryTotals.map { category, amount in
      let percent = amount / totalDeposits
      let color = categoryColors[category] ?? .green
      return (category: category, percent: percent, color: color)
    }.sorted { $0.percent > $1.percent }
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
  
  private var totalDeposits: Double { transactionByMonth(date: Date.startOfMonth(for: selectedMonth, of: selectedYear) ?? Date())
    .filter { $0.isIncome }
    .reduce(0) { $0 + $1.amount }
  }
  
  private var totalDepositsAllTime: Double { transactions
    .filter { $0.isIncome }
    .reduce(0) { $0 + $1.amount }
  }
}

struct DepositOverviewBarView: View {
  let categoryPercents: [(category: String, percent: Double, color: Color)]
  
  var body: some View {
    VStack {
      Text(LocalizationKeys.depositBreakdown.localized)
        .font(.headline)
        .padding(.bottom, 8)
      
      VStack(spacing: 12) {
        ForEach(categoryPercents, id: \.category) { item in
          HStack {
            Text(item.category)
              .font(.caption)
              .frame(width: 80, alignment: .leading)
            
            GeometryReader { geometry in
              HStack {
                Rectangle()
                  .fill(item.color)
                  .frame(width: geometry.size.width * CGFloat(item.percent))
                  .frame(height: 20)
                  .cornerRadius(4)
                Spacer()
              }
            }
            .frame(height: 20)
            
            Text("\(Int(item.percent * 100))%")
              .font(.caption)
              .frame(width: 35, alignment: .trailing)
          }
        }
      }
      .frame(width: 280, height: categoryPercents.isEmpty ? 40 : CGFloat(categoryPercents.count * 32))
      .padding()
      .background(Color(.systemGray6))
      .cornerRadius(12)
      
      if categoryPercents.isEmpty {
        Text(LocalizationKeys.noDepositsYet.localized)
          .font(.caption)
          .foregroundColor(.secondary)
          .padding(.top, 8)
      }
    }
  }
}

#Preview {
  DepositView()
}
