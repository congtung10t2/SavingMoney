import SwiftUI

struct TransactionEntryPopupView: View {
    let title: String
    @Binding var amountText: String
    @Binding var descriptionText: String
    @Binding var selectedCategory: TransactionCategory?
    let isIncome: Bool
    let allowsCategorySelection: Bool
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea(.all)
                .onTapGesture {
                    onCancel()
                }

            VStack(spacing: 20) {
                HStack {
                    Text(title)
                        .font(.headline)
                    Spacer()
                    Button("✕") {
                        onCancel()
                    }
                    .foregroundColor(.gray)
                }

                if allowsCategorySelection {
                    Text(LocalizationKeys.selectCategory.localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    CategoryGridView(
                        isIncome: isIncome,
                        selectedCategory: $selectedCategory,
                        onCategorySelected: { category in
                            selectedCategory = category
                        }
                    )
                    .frame(maxHeight: 180)
                } else if let category = selectedCategory {
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
                        onCancel()
                    }
                    .foregroundColor(.red)
                    .frame(minWidth: 80)

                    Button(LocalizationKeys.save.localized) {
                        onSave()
                    }
                    .disabled(Double(amountText.replacingOccurrences(of: ",", with: "")) == nil || selectedCategory == nil)
                    .foregroundColor((Double(amountText.replacingOccurrences(of: ",", with: "")) == nil || selectedCategory == nil) ? .gray : .blue)
                    .frame(minWidth: 80)
                }
            }
            .padding(24)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(radius: 20)
            .frame(maxWidth: 340)
            .padding(.horizontal, 20)
        }
    }
}
