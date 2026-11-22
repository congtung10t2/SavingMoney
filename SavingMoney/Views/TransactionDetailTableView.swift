//
//  TransactionDetailTableView.swift
//  SavingMoney
//
//  Created by congtungit on 21/11/26.
//

import SwiftUI

/// Table-like view that shows the detailed transaction list.
/// Amounts are displayed as whole numbers (no decimal places).
/// The table scrolls horizontally when it is wider than the screen.
struct TransactionDetailTableView: View {
    let transactions: [Transaction]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 0) {
                // Header row
                HStack(spacing: 14) {
                    Text(LocalizationKeys.detailNumber.localized)
                        .font(.caption.weight(.semibold))
                        .frame(width: 36, alignment: .leading)

                    Text(LocalizationKeys.detailAmount.localized)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                        .frame(width: 120, alignment: .trailing)

                    Text(LocalizationKeys.detailCategory.localized)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                        .frame(width: 150, alignment: .leading)

                    Text(LocalizationKeys.detailDescription.localized)
                        .font(.caption.weight(.semibold))
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)

                Divider()
                    .padding(.vertical, 4)

                // Data rows
                ForEach(transactions.enumerated(), id: \.offset) { index, transaction in
                    HStack(spacing: 14) {
                        Text("\(index + 1)")
                            .font(.body)
                            .frame(width: 36, alignment: .leading)

                        Text(transaction.amount.formatted(.number.precision(.fractionLength(0))))
                            .font(.body)
                            .lineLimit(1)
                            .frame(width: 120, alignment: .trailing)

                        Text(transaction.category)
                            .font(.body)
                            .lineLimit(1)
                            .frame(width: 150, alignment: .leading)

                        Text(transaction.descriptionText)
                            .font(.body)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)  // more space between cells
                    .background(index % 2 == 0 ? Color(.systemGray5) : Color.clear)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemGray6))
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
            )
        }
        .frame(maxWidth: .infinity)
    }
}

struct TransactionDetailTableView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionDetailTableView(transactions: [
            Transaction(id: UUID(), amount: 50, date: Date(), descriptionText: "Groceries with a fairly long description that should be scrollable horizontally", isIncome: false, category: "Food"),
            Transaction(id: UUID(), amount: 30, date: Date(), descriptionText: "", isIncome: true, category: "Salary")
        ])
    }
}
