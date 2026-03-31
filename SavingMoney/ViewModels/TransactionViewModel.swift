import Foundation
import SwiftUI
import SwiftData
class TransactionViewModel: ObservableObject {
  @Published var balance: Double = 0

  func addTransaction(amount: Double, description: String, isIncome: Bool, category: String) -> Transaction {
        let transaction = Transaction(id: UUID(), amount: amount, date: Date(), descriptionText: description, isIncome: isIncome, category: category)
        if isIncome {
            balance += amount
        } else {
            balance -= amount
        }
      return transaction
    }
}
