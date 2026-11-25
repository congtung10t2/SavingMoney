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
    var onDelete: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Color.gray.opacity(0.65)
                .ignoresSafeArea(.all)
                .onTapGesture {
                    onCancel()
                }

            ScrollView {
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
                        VStack(spacing: 12) {
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
                        }
                    } else if let category = selectedCategory {
                        Text(LocalizationKeys.categoryLabel.localized(arguments: category.localizedName))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Divider()
                        .padding(.vertical, 4)

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

                    if let onDelete {
                        Button(LocalizationKeys.delete.localized) {
                            onDelete()
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)
                    }
                }
                .padding(24)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(radius: 20)
            }
            .frame(maxWidth: 340)
            .padding(.horizontal, 20)
        }
    }
}
