//
//  AIAdviceView.swift
//  SavingMoney
//
//  Created by congtungit on 28/10/25.
//

import SwiftUI
import FoundationModels
import _SwiftData_SwiftUI

struct AIAdviceView: View {
    @EnvironmentObject var transactionViewModel: TransactionViewModel
    @State private var advice: [FinancialAdvice] = []
    @State private var isLoading = false
  @Query var transactions: [Transaction]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Financial Advisor")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)

                    // Financial Summary Card
                    FinancialSummaryCard(viewModel: transactionViewModel)

                    // Advice Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Personalized Advice")
                                .font(.headline)
                            Spacer()
                            Button("Refresh") {
                                generateAdvice()
                            }
                            .foregroundColor(.blue)
                        }

                        if isLoading {
                            ProgressView("Analyzing your finances...")
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if advice.isEmpty {
                            EmptyAdviceView {
                                generateAdvice()
                            }
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(advice, id: \.id) { adviceItem in
                                    AdviceCard(advice: adviceItem)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.bottom)
            }
            .onAppear {
                if advice.isEmpty {
                    generateAdvice()
                }
            }
        }
    }
    
    private func generateAdvice() {
        guard !isLoading else { return }
        isLoading = true
        
        Task { @MainActor in
            let generated: [FinancialAdvice]
            if transactions.isEmpty {
                generated = AIAdviceEngine.generateAdvice(transactions: transactions, for: transactionViewModel)
            } else if #available(iOS 26.0, *) {
                do {
                    generated = try await FoundationModelsAdvisor.generateAdvice(
                        transactions: transactions,
                        balance: transactionViewModel.balance
                    )
                } catch {
                    generated = AIAdviceEngine.generateAdvice(transactions: transactions, for: transactionViewModel)
                }
            } else {
                generated = AIAdviceEngine.generateAdvice(transactions: transactions, for: transactionViewModel)
            }

            advice = generated
            isLoading = false
        }
    }
}

struct FinancialSummaryCard: View {
    let viewModel: TransactionViewModel
  @Query var transactions: [Transaction]
    private var totalIncome: Double {
       transactions.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpenses: Double {
        transactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    private var savingsRate: Double {
        guard totalIncome > 0 else { return 0 }
        return ((totalIncome - totalExpenses) / totalIncome) * 100
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Financial Overview")
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack {
                    Text("Balance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                  
                  Text(viewModel.balance, format: .number.grouping(.automatic))
                      .font(.title2)
                      .fontWeight(.semibold)
                      .foregroundColor(viewModel.balance >= 0 ? .green : .red)
                }
                
                VStack {
                    Text("Savings Rate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(String(format: "%.1f", savingsRate))%")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(savingsRate >= 20 ? .green : savingsRate >= 10 ? .orange : .red)
                }
                
                VStack {
                    Text("Transactions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(transactions.count)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.gray))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct AdviceCard: View {
    let advice: FinancialAdvice
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: advice.icon)
                .font(.title2)
                .foregroundColor(advice.color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(advice.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(advice.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let action = advice.actionText {
                    Text(action)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.top, 4)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
    }
}

struct EmptyAdviceView: View {
    let onGenerateAdvice: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Get Financial Advice")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add some transactions to receive personalized financial recommendations")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Generate Advice") {
                onGenerateAdvice()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

// MARK: - AI Advice Engine
struct AIAdviceEngine {
  static func generateAdvice(transactions: [Transaction], for viewModel: TransactionViewModel) -> [FinancialAdvice] {
        var advice: [FinancialAdvice] = []
        
        let totalIncome = transactions.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
        let totalExpenses = transactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
        let balance = viewModel.balance
        let transactionCount = transactions.count
        
        // No transactions advice
        if transactionCount == 0 {
            advice.append(FinancialAdvice(
                title: "Start Tracking Your Finances",
                description: "Begin by adding your income and expenses to get personalized advice.",
                icon: "chart.line.uptrend.xyaxis",
                color: .blue,
                actionText: "Add your first transaction in the Add tab"
            ))
            return advice
        }
        
        // Balance-based advice
        if balance < 0 {
            advice.append(FinancialAdvice(
                title: "Negative Balance Alert",
                description: "Your expenses exceed your income. Consider reviewing your spending habits and finding ways to reduce unnecessary expenses.",
                icon: "exclamationmark.triangle",
                color: .red,
                actionText: "Review your spending categories for potential cuts"
            ))
        } else if balance > 0 && totalIncome > 0 {
            let savingsRate = (balance / totalIncome) * 100
            if savingsRate < 10 {
                advice.append(FinancialAdvice(
                    title: "Improve Your Savings Rate",
                    description: "Your savings rate is \(String(format: "%.1f", savingsRate))%. Financial experts recommend saving at least 20% of your income.",
                    icon: "arrow.up.circle",
                    color: .orange,
                    actionText: "Try to reduce spending or increase income"
                ))
            } else if savingsRate >= 20 {
                advice.append(FinancialAdvice(
                    title: "Excellent Savings Rate!",
                    description: "Your savings rate of \(String(format: "%.1f", savingsRate))% is excellent. Consider investing your surplus for long-term growth.",
                    icon: "star.circle",
                    color: .green,
                    actionText: "Look into investment opportunities"
                ))
            }
        }
        
        // Category-based advice
        let expenses = transactions.filter { !$0.isIncome }
        if !expenses.isEmpty {
            var categoryTotals: [String: Double] = [:]
            for expense in expenses {
                categoryTotals[expense.category, default: 0] += expense.amount
            }
            
            // Find highest spending category
            if let highestCategory = categoryTotals.max(by: { $0.value < $1.value }) {
                let percentage = (highestCategory.value / totalExpenses) * 100
                if percentage > 40 {
                    advice.append(FinancialAdvice(
                        title: "High Spending in \(highestCategory.key)",
                        description: "\(String(format: "%.1f", percentage))% of your expenses go to \(highestCategory.key). Consider if this aligns with your financial goals.",
                        icon: "chart.pie",
                        color: .purple,
                        actionText: "Review \(highestCategory.key) expenses for optimization"
                    ))
                }
            }
        }
        
        // Emergency fund advice
        if totalIncome > 0 {
            let monthlyIncome = totalIncome / max(1, Double(transactionCount) / 30) // Rough monthly estimate
            let emergencyFundGoal = monthlyIncome * 3 // 3 months
            
            if balance < emergencyFundGoal {
                advice.append(FinancialAdvice(
                    title: "Build an Emergency Fund",
                    description: "Aim to save 3-6 months of expenses (approximately $\(String(format: "%.0f", emergencyFundGoal))) for unexpected situations.",
                    icon: "shield.checkered",
                    color: .blue,
                    actionText: "Set aside money each month for emergencies"
                ))
            }
        }
        
        // General tips if no specific issues
        if advice.isEmpty || advice.count < 2 {
            advice.append(FinancialAdvice(
                title: "Track Your Progress",
                description: "Continue monitoring your income and expenses to maintain healthy financial habits.",
                icon: "chart.line.uptrend.xyaxis",
                color: .green,
                actionText: "Keep adding transactions regularly"
            ))
        }
        
        return advice
    }
}

enum AIAdviceError: Error {
    case modelUnavailable
}

@available(iOS 26.0, *)
@Generable
struct GeneratedFinancialAdviceSet {
    @Guide(description: "Exactly three distinct pieces of financial advice.", .count(3))
    var items: [GeneratedFinancialAdviceItem]
}

@available(iOS 26.0, *)
@Generable
struct GeneratedFinancialAdviceItem {
    @Guide(description: "A short advice title of at most six words.")
    var title: String
    @Guide(description: "Specific, empathetic advice under 45 words that cites exact figures from the data.")
    var detail: String
    @Guide(description: "One concrete next action in a few words.")
    var action: String
    @Guide(description: "One of: blue, green, orange, red, purple.")
    var colorName: String
    @Guide(description: "One SF Symbol name from: chart.pie, arrow.up.circle, exclamationmark.triangle, star.circle, shield.checkered, chart.line.uptrend.xyaxis.")
    var symbolName: String
}

@available(iOS 26.0, *)
enum FoundationModelsAdvisor {
    private static let allowedSymbols = [
        "chart.pie", "arrow.up.circle", "exclamationmark.triangle",
        "star.circle", "shield.checkered", "chart.line.uptrend.xyaxis"
    ]

    static func generateAdvice(transactions: [Transaction], balance: Double) async throws -> [FinancialAdvice] {
        guard case .available = SystemLanguageModel.default.availability else {
            throw AIAdviceError.modelUnavailable
        }

        let language = LanguageManager.shared.currentLanguage
        let session = LanguageModelSession(instructions: instructions(for: language))
        let response = try await session.respond(
            to: prompt(for: transactions, balance: balance),
            generating: GeneratedFinancialAdviceSet.self
        )
        return response.content.items.map { item in
            FinancialAdvice(
                title: item.title,
                description: item.detail,
                icon: allowedSymbols.contains(item.symbolName) ? item.symbolName : "lightbulb",
                color: color(for: item.colorName),
                actionText: item.action
            )
        }
    }

    private static func instructions(for language: String) -> String {
        let locale: String
        let languageName: String
        switch language {
        case "vi":
            locale = "vi_VN"
            languageName = "Vietnamese"
        case "fr":
            locale = "fr_FR"
            languageName = "French"
        case "zh-Hans":
            locale = "zh_CN"
            languageName = "Simplified Chinese"
        default:
            locale = "en_US"
            languageName = "English"
        }

        return """
        You are a careful personal-finance coach inside a budgeting app.
        The person's locale is \(locale).
        You MUST respond in \(languageName).
        Use only the financial data in the prompt; never invent numbers, income, debts, or goals.
        Do not claim to be a licensed advisor or promise returns.
        Cite exact amounts or percentages from the data in every item and keep each item under 45 words.
        Choose colorName only from: blue, green, orange, red, purple.
        Choose symbolName only from: chart.pie, arrow.up.circle, exclamationmark.triangle, star.circle, shield.checkered, chart.line.uptrend.xyaxis.
        """
    }

    private static func prompt(for transactions: [Transaction], balance: Double) -> String {
        let sorted = transactions.sorted { $0.date < $1.date }
        let totalIncome = transactions.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
        let totalExpenses = transactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
        let savingsRate = totalIncome > 0 ? ((totalIncome - totalExpenses) / totalIncome) * 100 : 0

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        var period = "No dated transactions"
        if let first = sorted.first, let last = sorted.last {
            let days = Calendar.current.dateComponents([.day], from: first.date, to: last.date).day ?? 0
            period = "\(dateFormatter.string(from: first.date)) to \(dateFormatter.string(from: last.date)) (\(days + 1) days)"
        }

        let incomeByCategory = totals(by: \.category, in: transactions.filter { $0.isIncome })
        let expenseByCategory = totals(by: \.category, in: transactions.filter { !$0.isIncome })

        let incomeLines = incomeByCategory.prefix(6).map { name, amount in
            "- \(name): \(money(amount)) (\(percent(totalIncome > 0 ? amount / totalIncome * 100 : 0)) of income)"
        }
        let expenseLines = expenseByCategory.prefix(8).map { name, amount in
            "- \(name): \(money(amount)) (\(percent(totalExpenses > 0 ? amount / totalExpenses * 100 : 0)) of expenses)"
        }
        let recentLines = sorted.suffix(20).map { transaction in
            let prefix = transaction.isIncome ? "+" : "-"
            let note = transaction.descriptionText.isEmpty ? "" : " — \(transaction.descriptionText)"
            return "- \(dateFormatter.string(from: transaction.date)): \(prefix)\(money(transaction.amount)) \(transaction.category)\(note)"
        }

        return """
        Analyze the following personal finance data and give exactly three specific, realistic pieces of advice.
        Period: \(period)
        Current balance: \(money(balance))
        Total income: \(money(totalIncome))
        Total expenses: \(money(totalExpenses))
        Savings rate: \(percent(savingsRate))
        Transaction count: \(transactions.count)

        Income by category:
        \(incomeLines.isEmpty ? "- none" : incomeLines.joined(separator: "\n"))

        Expenses by category:
        \(expenseLines.isEmpty ? "- none" : expenseLines.joined(separator: "\n"))

        Most recent transactions:
        \(recentLines.isEmpty ? "- none" : recentLines.joined(separator: "\n"))

        Prioritize the biggest measurable issues in this data and mention the exact figures that support each recommendation.
        """
    }

    private static func totals(by keyPath: KeyPath<Transaction, String>, in transactions: [Transaction]) -> [(String, Double)] {
        var totals: [String: Double] = [:]
        for transaction in transactions {
            totals[transaction[keyPath: keyPath], default: 0] += transaction.amount
        }
        return totals.sorted { $0.value > $1.value }
    }

    private static func money(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...2)))
    }

    private static func percent(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...1))) + "%"
    }

    private static func color(for name: String) -> Color {
        switch name.lowercased() {
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "purple": return .purple
        default: return .blue
        }
    }
}

// MARK: - Models
struct FinancialAdvice {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
    let actionText: String?
}

struct AIAdviceView_Previews: PreviewProvider {
    static var previews: some View {
        AIAdviceView()
            .environmentObject(TransactionViewModel())
    }
}
