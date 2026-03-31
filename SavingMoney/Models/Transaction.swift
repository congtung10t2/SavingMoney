import Foundation
import SwiftData
@Model
class Transaction: Identifiable {
  init(id: UUID, amount: Double, date: Date, descriptionText: String, isIncome: Bool, category: String) {
    self.id = id
    self.amount = amount
    self.date = date
    self.descriptionText = descriptionText
    self.isIncome = isIncome
    self.category = category
  }
  var id: UUID
  var amount: Double
  var date: Date
  var descriptionText: String
  var isIncome: Bool
  var category: String
}


@Model
class PassiveTransaction: Identifiable {
  init(id: UUID, amount: Double, date: Date, descriptionText: String, isIncome: Bool, category: String) {
    self.id = id
    self.amount = amount
    self.date = date
    self.descriptionText = descriptionText
    self.isIncome = isIncome
    self.category = category
  }
  var id: UUID
  var amount: Double
  var date: Date
  var descriptionText: String
  var isIncome: Bool
  var category: String
}
