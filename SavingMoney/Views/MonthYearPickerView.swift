//
//  MonthYearPickerView.swift
//  SavingMoney
//
//  Created by congtungit on 21/2/26.
//


import SwiftUI

struct MonthYearPickerView: View {
  @Binding var selectedMonth: Int
  @Binding var selectedYear: Int 
    private let months = DateFormatter().monthSymbols
    private let years: [Int] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array(2025...currentYear)
    }()

    var body: some View {
        HStack(spacing: 16) {

            // Month
            Picker("Month", selection: $selectedMonth) {
              ForEach(0..<months!.count, id: \.self) { index in
                    Text(months![index])
                        .tag(index + 1)
                }
            }
            .pickerStyle(.menu)

            // Year
            Picker("Year", selection: $selectedYear) {
                ForEach(years, id: \.self) { year in
                  Text(String(format: "%d", year))
                        .tag(year)
                }
            }
            .pickerStyle(.menu)
        }
    }
}
#Preview {
  MonthYearPickerView(selectedMonth: .constant(1), selectedYear: .constant(2025))
}
