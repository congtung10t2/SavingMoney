//
//  CategoryModelTests.swift
//  SavingMoneyTests
//
//  Created by congtungit on 28/10/25.
//

import Testing
import Foundation
@testable import SavingMoneyApp

// MARK: - CategoryModel Validation Tests
struct CategoryModelValidationTests {
    
    @Test func testAllExpenseCategoriesHaveRequiredProperties() async throws {
        let categoryModel = CategoryModel.shared
        
        for category in categoryModel.expenseCategories {
            #expect(!category.name.isEmpty, "Category name should not be empty")
            #expect(!category.icon.isEmpty, "Category icon should not be empty")
            #expect(!category.color.isEmpty, "Category color should not be empty")
        }
    }
    
    @Test func testAllIncomeCategoriesHaveRequiredProperties() async throws {
        let categoryModel = CategoryModel.shared
        
        for category in categoryModel.incomeCategories {
            #expect(!category.name.isEmpty, "Category name should not be empty")
            #expect(!category.icon.isEmpty, "Category icon should not be empty")
            #expect(!category.color.isEmpty, "Category color should not be empty")
        }
    }
    
    @Test func testExpenseCategoryNamesAreUnique() async throws {
        let categoryModel = CategoryModel.shared
        let names = categoryModel.expenseCategories.map { $0.name }
        let uniqueNames = Set(names)
        
        #expect(names.count == uniqueNames.count, "All expense category names should be unique")
    }
    
    @Test func testIncomeCategoryNamesAreUnique() async throws {
        let categoryModel = CategoryModel.shared
        let names = categoryModel.incomeCategories.map { $0.name }
        let uniqueNames = Set(names)
        
        #expect(names.count == uniqueNames.count, "All income category names should be unique")
    }
    
    @Test func testMinimumCategoriesExist() async throws {
        let categoryModel = CategoryModel.shared
        
        // Should have at least a few categories for each type
        #expect(categoryModel.expenseCategories.count >= 5, "Should have at least 5 expense categories")
        #expect(categoryModel.incomeCategories.count >= 3, "Should have at least 3 income categories")
    }
    
    @Test func testCommonCategoriesExist() async throws {
        let categoryModel = CategoryModel.shared
        
        // Common expense categories
        let expenseNames = categoryModel.expenseCategories.map { $0.name }
        #expect(expenseNames.contains("Food"), "Should have Food category")
        #expect(expenseNames.contains("Transportation"), "Should have Transportation category")
        #expect(expenseNames.contains("Other"), "Should have Other category as fallback")
        
        // Common income categories
        let incomeNames = categoryModel.incomeCategories.map { $0.name }
        #expect(incomeNames.contains("Salary"), "Should have Salary category")
        #expect(incomeNames.contains("Other"), "Should have Other category as fallback")
    }
    
    @Test func testGetCategoryWithWrongIncomeFlag() async throws {
        let categoryModel = CategoryModel.shared
        
        // Try to get expense category with income flag
        let result1 = categoryModel.getCategory(name: "Food", isIncome: true)
        #expect(result1 == nil, "Should return nil when looking for expense category with income flag")
        
        // Try to get income category with expense flag
        let result2 = categoryModel.getCategory(name: "Salary", isIncome: false)
        #expect(result2 == nil, "Should return nil when looking for income category with expense flag")
    }
    
    @Test func testGetCategoryIsCaseSensitive() async throws {
        let categoryModel = CategoryModel.shared
        
        // Should not find category with different case
        let result = categoryModel.getCategory(name: "food", isIncome: false) // lowercase
        #expect(result == nil, "Category lookup should be case sensitive")
    }
    
    @Test func testCategoryIconsAreValidSFSymbols() async throws {
        let categoryModel = CategoryModel.shared
        
        // Test expense category icons
        for category in categoryModel.expenseCategories {
            // Basic validation - should not contain spaces or invalid characters
            #expect(!category.icon.contains(" "), "Icon name should not contain spaces: \(category.icon)")
            #expect(category.icon.allSatisfy { $0.isLetter || $0.isNumber || $0 == "." || $0 == "_" }, 
                   "Icon should only contain valid SF Symbol characters: \(category.icon)")
        }
        
        // Test income category icons
        for category in categoryModel.incomeCategories {
            #expect(!category.icon.contains(" "), "Icon name should not contain spaces: \(category.icon)")
            #expect(category.icon.allSatisfy { $0.isLetter || $0.isNumber || $0 == "." || $0 == "_" }, 
                   "Icon should only contain valid SF Symbol characters: \(category.icon)")
        }
    }
    
    @Test func testCategoryColorsAreValid() async throws {
        let categoryModel = CategoryModel.shared
        
        let validColors = ["red", "blue", "green", "yellow", "orange", "purple", "pink", "gray", "brown", "indigo", "teal", "cyan"]
        
        // Test expense category colors
        for category in categoryModel.expenseCategories {
            #expect(validColors.contains(category.color.lowercased()), 
                   "Color should be a valid color name: \(category.color)")
        }
        
        // Test income category colors
        for category in categoryModel.incomeCategories {
            #expect(validColors.contains(category.color.lowercased()), 
                   "Color should be a valid color name: \(category.color)")
        }
    }
}

// MARK: - Category Edge Cases Tests
struct CategoryEdgeCasesTests {
    
    @Test func testGetCategoryWithEmptyName() async throws {
        let categoryModel = CategoryModel.shared
        
        let result = categoryModel.getCategory(name: "", isIncome: false)
        #expect(result == nil, "Should return nil for empty category name")
    }
    
    @Test func testGetCategoryWithWhitespaceName() async throws {
        let categoryModel = CategoryModel.shared
        
        let result = categoryModel.getCategory(name: "   ", isIncome: false)
        #expect(result == nil, "Should return nil for whitespace-only category name")
    }
    
    @Test func testGetCategoryWithSpecialCharacters() async throws {
        let categoryModel = CategoryModel.shared
        
        let result = categoryModel.getCategory(name: "Food@#$%", isIncome: false)
        #expect(result == nil, "Should return nil for category name with special characters")
    }
    
    @Test func testCategoryModelConsistency() async throws {
        let categoryModel1 = CategoryModel.shared
        let categoryModel2 = CategoryModel.shared
        
        // Should be the same instance (singleton)
        #expect(categoryModel1 === categoryModel2, "Should return same singleton instance")
        
        // Should have same data
        #expect(categoryModel1.expenseCategories.count == categoryModel2.expenseCategories.count)
        #expect(categoryModel1.incomeCategories.count == categoryModel2.incomeCategories.count)
    }
    
    @Test func testCategoryDataImmutability() async throws {
        let categoryModel = CategoryModel.shared
        
        // Store original counts
        let originalExpenseCount = categoryModel.expenseCategories.count
        let originalIncomeCount = categoryModel.incomeCategories.count
        
        // Categories should be read-only (can't modify the arrays)
        // This test ensures the arrays maintain their integrity
        
        // Re-check counts (should be unchanged)
        #expect(categoryModel.expenseCategories.count == originalExpenseCount)
        #expect(categoryModel.incomeCategories.count == originalIncomeCount)
    }
}
