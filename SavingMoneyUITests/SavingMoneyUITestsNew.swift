//
//  SavingMoneyUITestsNew.swift
//  SavingMoneyUITests
//
//  Created by congtungit on 28/10/25.
//

import XCTest

final class SavingMoneyUITestsNew: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Tab Bar Tests
    
    @MainActor
    func testTabBarExists() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "Tab bar should exist")
        
        // Check all three tabs exist
        XCTAssertTrue(app.buttons["AddTab"].exists, "Add tab should exist")
        XCTAssertTrue(app.buttons["SpendingTab"].exists, "Spending tab should exist") 
        XCTAssertTrue(app.buttons["DepositsTab"].exists, "Deposits tab should exist")
    }
    
    @MainActor
    func testTabNavigation() throws {
        // Test navigation to Spending tab
        app.buttons["SpendingTab"].tap()
        XCTAssertTrue(app.staticTexts["Spending Overview"].exists, "Should navigate to spending view")
        
        // Test navigation to Deposits tab
        app.buttons["DepositsTab"].tap()
        XCTAssertTrue(app.staticTexts["Deposit Overview"].exists, "Should navigate to deposit view")
        
        // Test navigation back to Add tab
        app.buttons["AddTab"].tap()
        XCTAssertTrue(app.staticTexts["What do you want to do?"].exists, "Should navigate to add view")
    }

    // MARK: - Add Transaction Flow Tests
    
    @MainActor
    func testAddTransactionInitialState() throws {
        // Should be on Add tab by default
        XCTAssertTrue(app.staticTexts["What do you want to do?"].exists, "Should show main question")
        XCTAssertTrue(app.buttons["SpendingActionButton"].exists, "Spending button should exist")
        XCTAssertTrue(app.buttons["SavingActionButton"].exists, "Saving button should exist")
        
        // Balance should be displayed
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Balance:'")).firstMatch.exists, "Balance should be displayed")
    }
    
    @MainActor
    func testSelectSpendingAction() throws {
        app.buttons["SpendingActionButton"].tap()
        
        // Should show category selection
        XCTAssertTrue(app.staticTexts["Select a category"].exists, "Should show category selection text")
        
        // Should show expense categories
        XCTAssertTrue(app.buttons["Food"].exists, "Food category should exist")
        XCTAssertTrue(app.buttons["Transportation"].exists, "Transportation category should exist")
        XCTAssertTrue(app.buttons["Shopping"].exists, "Shopping category should exist")
    }
    
    @MainActor
    func testSelectSavingAction() throws {
        app.buttons["SavingActionButton"].tap()
        
        // Should show category selection
        XCTAssertTrue(app.staticTexts["Select a category"].exists, "Should show category selection text")
        
        // Should show income categories
        XCTAssertTrue(app.buttons["Salary"].exists, "Salary category should exist")
        XCTAssertTrue(app.buttons["Freelance"].exists, "Freelance category should exist")
        XCTAssertTrue(app.buttons["Investment"].exists, "Investment category should exist")
    }
    
    @MainActor
    func testAddExpenseTransaction() throws {
        // Select spending action
        app.buttons["SpendingActionButton"].tap()
        
        // Select Food category - this should trigger popup immediately
        app.buttons["Food"].tap()
        
        // Popup should appear
        XCTAssertTrue(app.staticTexts["Add Expense"].exists, "Expense popup should appear")
        XCTAssertTrue(app.staticTexts["Category: Food"].exists, "Should show selected category")
        
        // Enter amount
        let amountField = app.textFields["Amount"]
        XCTAssertTrue(amountField.exists, "Amount field should exist")
        amountField.tap()
        amountField.typeText("25.50")
        
        // Enter description
        let descriptionField = app.textFields["Description (optional)"]
        XCTAssertTrue(descriptionField.exists, "Description field should exist")
        descriptionField.tap()
        descriptionField.typeText("Lunch")
        
        // Save transaction
        app.buttons["Save"].tap()
        
        // Popup should dismiss and balance should update
        XCTAssertFalse(app.staticTexts["Add Expense"].exists, "Popup should be dismissed")
        
        // Check balance updated (should be negative)
        let balanceText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Balance: $-25.50'")).firstMatch
        XCTAssertTrue(balanceText.exists, "Balance should be updated to -$25.50")
    }
    
    @MainActor
    func testAddIncomeTransaction() throws {
        // Select saving action
        app.buttons["SavingActionButton"].tap()
        
        // Select Salary category
        app.buttons["Salary"].tap()
        
        // Popup should appear
        XCTAssertTrue(app.staticTexts["Add Deposit"].exists, "Deposit popup should appear")
        XCTAssertTrue(app.staticTexts["Category: Salary"].exists, "Should show selected category")
        
        // Enter amount
        let amountField = app.textFields["Amount"]
        amountField.tap()
        amountField.typeText("2000")
        
        // Save transaction
        app.buttons["Save"].tap()
        
        // Check balance updated (should be positive)
        let balanceText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Balance: $2000.00'")).firstMatch
        XCTAssertTrue(balanceText.exists, "Balance should be updated to $2000.00")
    }
    
    @MainActor
    func testCancelTransaction() throws {
        // Select spending and category
        app.buttons["SpendingActionButton"].tap()
        app.buttons["Food"].tap()
        
        // Cancel the popup
        app.buttons["Cancel"].tap()
        
        // Popup should be dismissed
        XCTAssertFalse(app.staticTexts["Add Expense"].exists, "Popup should be dismissed")
        
        // Should return to category selection
        XCTAssertTrue(app.staticTexts["Select a category"].exists, "Should return to category selection")
    }
    
    @MainActor
    func testDismissPopupByTappingBackground() throws {
        // Select spending and category to show popup
        app.buttons["SpendingActionButton"].tap()
        app.buttons["Food"].tap()
        
        // Tap outside the popup to dismiss
        let coordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1))
        coordinate.tap()
        
        // Popup should be dismissed
        XCTAssertFalse(app.staticTexts["Add Expense"].exists, "Popup should be dismissed by background tap")
    }

    // MARK: - Spending Overview Tests
    
    @MainActor
    func testSpendingOverviewEmpty() throws {
        app.buttons["SpendingTab"].tap()
        
        XCTAssertTrue(app.staticTexts["Spending Overview"].exists, "Should show spending overview title")
        XCTAssertTrue(app.staticTexts["Total Spent: $0.00"].exists, "Should show zero spending initially")
        XCTAssertTrue(app.staticTexts["Add spending transactions to see your breakdown"].exists, "Should show empty state message")
    }
    
    @MainActor
    func testSpendingOverviewWithData() throws {
        // Add a spending transaction first
        addTestExpenseTransaction(amount: "50", description: "Test", category: "Food")
        
        // Navigate to spending tab
        app.buttons["SpendingTab"].tap()
        
        // Should show updated total
        XCTAssertTrue(app.staticTexts["Total Spent: $50.00"].exists, "Should show correct spending total")
        
        // Should show pie chart components
        XCTAssertTrue(app.staticTexts["Spending Breakdown"].exists, "Should show breakdown title")
    }

    // MARK: - Deposit Overview Tests
    
    @MainActor
    func testDepositOverviewEmpty() throws {
        app.buttons["DepositsTab"].tap()
        
        XCTAssertTrue(app.staticTexts["Deposit Overview"].exists, "Should show deposit overview title")
        XCTAssertTrue(app.staticTexts["Total Deposits: $0.00"].exists, "Should show zero deposits initially")
        XCTAssertTrue(app.staticTexts["Add deposit transactions to see your breakdown"].exists, "Should show empty state message")
    }
    
    @MainActor
    func testDepositOverviewWithData() throws {
        // Add a deposit transaction first
        addTestIncomeTransaction(amount: "1000", description: "Test", category: "Salary")
        
        // Navigate to deposits tab
        app.buttons["DepositsTab"].tap()
        
        // Should show updated total
        XCTAssertTrue(app.staticTexts["Total Deposits: $1000.00"].exists, "Should show correct deposit total")
        
        // Should show bar chart components
        XCTAssertTrue(app.staticTexts["Deposit Breakdown"].exists, "Should show breakdown title")
    }

    // MARK: - Input Validation Tests
    
    @MainActor
    func testSaveButtonDisabledWithoutAmount() throws {
        // Open popup
        app.buttons["SpendingActionButton"].tap()
        app.buttons["Food"].tap()
        
        // Save button should be disabled without amount
        let saveButton = app.buttons["Save"]
        XCTAssertFalse(saveButton.isEnabled, "Save button should be disabled without amount")
    }
    
    @MainActor
    func testSaveButtonEnabledWithValidAmount() throws {
        // Open popup
        app.buttons["SpendingActionButton"].tap()
        app.buttons["Food"].tap()
        
        // Enter valid amount
        app.textFields["Amount"].tap()
        app.textFields["Amount"].typeText("10")
        
        // Save button should be enabled
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.isEnabled, "Save button should be enabled with valid amount")
    }

    // MARK: - Performance Tests
    
    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    @MainActor
    func testTabSwitchingPerformance() throws {
        measure {
            app.buttons["SpendingTab"].tap()
            app.buttons["DepositsTab"].tap()
            app.buttons["AddTab"].tap()
        }
    }

    // MARK: - Helper Methods
    
    private func addTestExpenseTransaction(amount: String, description: String, category: String) {
        app.buttons["AddTab"].tap()
        app.buttons["SpendingActionButton"].tap()
        app.buttons[category].tap()
        
        app.textFields["Amount"].tap()
        app.textFields["Amount"].typeText(amount)
        
        if !description.isEmpty {
            app.textFields["Description (optional)"].tap()
            app.textFields["Description (optional)"].typeText(description)
        }
        
        app.buttons["Save"].tap()
    }
    
    private func addTestIncomeTransaction(amount: String, description: String, category: String) {
        app.buttons["AddTab"].tap()
        app.buttons["SavingActionButton"].tap()
        app.buttons[category].tap()
        
        app.textFields["Amount"].tap()
        app.textFields["Amount"].typeText(amount)
        
        if !description.isEmpty {
            app.textFields["Description (optional)"].tap()
            app.textFields["Description (optional)"].typeText(description)
        }
        
        app.buttons["Save"].tap()
    }
}
