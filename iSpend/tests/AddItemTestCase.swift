//
//  AddItemTestCase.swift
//  iSpendTests
//
//  SwiftData integration tests — all operations use an in-memory store so
//  they are fast, isolated, and leave no on-disk state behind.
//

import Testing
import SwiftData
import Foundation
@testable import iSpend

// MARK: - Helpers

private func makeContainer() throws -> ModelContainer {
    let schema = Schema([ExpenseModel.self, BudgetModel.self, EditableListItem.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    return try ModelContainer(for: schema, configurations: [config])
}

// MARK: - Expense CRUD

@Suite("Expense CRUD")
struct ExpenseCRUDTests {

    @Test("Insert expense and fetch it back")
    func insertAndFetch() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let expense = ExpenseModel(name: "Coffee", type: NECESSARY, amount: 3.50, category: "Food")
        context.insert(expense)
        try context.save()

        let all = try context.fetch(FetchDescriptor<ExpenseModel>())
        #expect(all.count == 1)
        #expect(all[0].name == "Coffee")
        #expect(all[0].amount == 3.50)
        #expect(all[0].category == "Food")
        #expect(all[0].typeMap == NECESSARY)
    }

    @Test("Inserted expense retains its UUID after save")
    func uuidPersistedAfterSave() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let expense = ExpenseModel(name: "Test", amount: 1.0)
        let originalId = expense.id
        context.insert(expense)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<ExpenseModel>())
        #expect(fetched[0].id == originalId)
    }

    @Test("Delete expense removes it from the store")
    func deleteExpense() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let expense = ExpenseModel(name: "Lunch", amount: 12.00)
        context.insert(expense)
        try context.save()

        context.delete(expense)
        try context.save()

        #expect(try context.fetch(FetchDescriptor<ExpenseModel>()).isEmpty)
    }

    @Test("Update expense fields persist across save")
    func updateExpense() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let expense = ExpenseModel(name: "Coffee", amount: 3.00)
        context.insert(expense)
        try context.save()

        expense.name = "Latte"
        expense.amount = 5.50
        expense.category = "Café"
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<ExpenseModel>())
        #expect(fetched[0].name == "Latte")
        #expect(fetched[0].amount == 5.50)
        #expect(fetched[0].category == "Café")
    }

    @Test("Multiple expenses are all stored")
    func insertMultiple() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let names = ["Coffee", "Lunch", "Transport", "Groceries", "Netflix"]
        for name in names {
            context.insert(ExpenseModel(name: name, amount: 10.0))
        }
        try context.save()

        #expect(try context.fetch(FetchDescriptor<ExpenseModel>()).count == 5)
    }

    @Test("Delete all expenses via model delete")
    func deleteAllExpenses() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        for i in 1...5 {
            context.insert(ExpenseModel(name: "Expense \(i)", amount: Double(i) * 10))
        }
        try context.save()
        try context.delete(model: ExpenseModel.self)
        try context.save()

        #expect(try context.fetch(FetchDescriptor<ExpenseModel>()).isEmpty)
    }

    @Test("Rollback discards unsaved expense changes")
    func rollbackDiscardsChanges() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let expense = ExpenseModel(name: "Coffee", amount: 3.00)
        context.insert(expense)
        try context.save()

        expense.name = "Changed"
        expense.amount = 99.99
        context.rollback()

        let fetched = try context.fetch(FetchDescriptor<ExpenseModel>())
        #expect(fetched[0].name == "Coffee")
        #expect(fetched[0].amount == 3.00)
    }

    @Test("Rollback before save prevents a new expense from being stored")
    func rollbackBeforeSavePreventsInsert() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let expense = ExpenseModel(name: "Never Saved", amount: 1.0)
        context.insert(expense)
        context.rollback()

        #expect(try context.fetch(FetchDescriptor<ExpenseModel>()).isEmpty)
    }
}

// MARK: - Expense Queries

@Suite("Expense Queries")
struct ExpenseQueryTests {

    @Test("Predicate for NECESSARY returns only necessary expenses")
    func necessaryPredicate() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        context.insert(ExpenseModel(name: "Rent", type: NECESSARY, amount: 1000))
        context.insert(ExpenseModel(name: "Netflix", type: DISCRETIONARY, amount: 15))
        context.insert(ExpenseModel(name: "Groceries", type: NECESSARY, amount: 150))
        try context.save()

        let descriptor = FetchDescriptor<ExpenseModel>(predicate: #Predicate { $0.typeMap == NECESSARY })
        let necessary = try context.fetch(descriptor)
        #expect(necessary.count == 2)
        #expect(necessary.allSatisfy { $0.typeMap == NECESSARY })
    }

    @Test("Predicate for DISCRETIONARY returns only discretionary expenses")
    func discretionaryPredicate() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        context.insert(ExpenseModel(name: "Rent", type: NECESSARY, amount: 1000))
        context.insert(ExpenseModel(name: "Netflix", type: DISCRETIONARY, amount: 15))
        context.insert(ExpenseModel(name: "Games", type: DISCRETIONARY, amount: 60))
        try context.save()

        let descriptor = FetchDescriptor<ExpenseModel>(predicate: #Predicate { $0.typeMap == DISCRETIONARY })
        let discretionary = try context.fetch(descriptor)
        #expect(discretionary.count == 2)
        #expect(discretionary.allSatisfy { $0.typeMap == DISCRETIONARY })
    }

    @Test("No expenses match when store is empty")
    func emptyStoreReturnsEmpty() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let descriptor = FetchDescriptor<ExpenseModel>(predicate: #Predicate { $0.typeMap == NECESSARY })
        #expect(try context.fetch(descriptor).isEmpty)
    }

    @Test("Sort by date returns expenses in ascending order")
    func sortByDate() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let dates = [
            Date(timeIntervalSinceReferenceDate: 300),
            Date(timeIntervalSinceReferenceDate: 100),
            Date(timeIntervalSinceReferenceDate: 200)
        ]
        for (index, date) in dates.enumerated() {
            context.insert(ExpenseModel(name: "E\(index)", amount: 1.0, date: date))
        }
        try context.save()

        let descriptor = FetchDescriptor<ExpenseModel>(sortBy: [SortDescriptor(\ExpenseModel.date)])
        let sorted = try context.fetch(descriptor)
        #expect(sorted[0].date < sorted[1].date)
        #expect(sorted[1].date < sorted[2].date)
    }

    @Test("Total amount calculation sums all fetched expenses")
    func totalAmountCalculation() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        context.insert(ExpenseModel(name: "A", type: NECESSARY, amount: 100.0))
        context.insert(ExpenseModel(name: "B", type: NECESSARY, amount: 50.0))
        context.insert(ExpenseModel(name: "C", type: NECESSARY, amount: 25.0))
        context.insert(ExpenseModel(name: "D", type: DISCRETIONARY, amount: 999.0)) // excluded
        try context.save()

        let descriptor = FetchDescriptor<ExpenseModel>(predicate: #Predicate { $0.typeMap == NECESSARY })
        let expenses = try context.fetch(descriptor)
        let total = expenses.reduce(0.0) { $0 + $1.amount }
        #expect(total == 175.0)
    }
}

// MARK: - ExpenseType Persistence

@Suite("ExpenseType Persistence")
struct ExpenseTypePersistenceTests {

    @Test("expenseType is .necessary when typeMap is NECESSARY after fetch")
    func necessaryTypePersistedViaTypeMap() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        context.insert(ExpenseModel(name: "Rent", type: NECESSARY, amount: 1000))
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<ExpenseModel>())
        #expect(fetched[0].typeMap == NECESSARY)
        #expect(fetched[0].expenseType == .necessary)
    }

    @Test("expenseType is .discretionary when typeMap is DISCRETIONARY after fetch")
    func discretionaryTypePersistedViaTypeMap() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        context.insert(ExpenseModel(name: "Games", type: DISCRETIONARY, amount: 60))
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<ExpenseModel>())
        #expect(fetched[0].typeMap == DISCRETIONARY)
        #expect(fetched[0].expenseType == .discretionary)
    }

    @Test("Setting expenseType via setter persists the correct typeMap value")
    func expenseTypeSetterPersists() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let expense = ExpenseModel(name: "Coffee", type: NECESSARY, amount: 4.0)
        context.insert(expense)
        try context.save()

        expense.expenseType = .discretionary
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<ExpenseModel>())
        #expect(fetched[0].typeMap == DISCRETIONARY)
        #expect(fetched[0].expenseType == .discretionary)
    }

    @Test("Changing typeMap directly updates expenseType getter after re-fetch")
    func typeMapDirectChangeReflectedInGetter() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let expense = ExpenseModel(name: "Test", type: NECESSARY, amount: 5.0)
        context.insert(expense)
        try context.save()

        expense.typeMap = DISCRETIONARY
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<ExpenseModel>())
        #expect(fetched[0].expenseType == .discretionary)
    }
}

// MARK: - Budget CRUD

@Suite("Budget CRUD")
struct BudgetCRUDTests {

    @Test("Insert necessary budget and fetch it back")
    func insertNecessaryBudget() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        context.insert(BudgetModel(type: NECESSARY, amount: 500.0))
        try context.save()

        let descriptor = FetchDescriptor<BudgetModel>(predicate: #Predicate { $0.type == NECESSARY })
        let budgets = try context.fetch(descriptor)
        #expect(budgets.count == 1)
        #expect(budgets[0].amount == 500.0)
    }

    @Test("Update budget amount persists across save")
    func updateBudgetAmount() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let budget = BudgetModel(type: NECESSARY, amount: 500.0)
        context.insert(budget)
        try context.save()

        budget.amount = 750.0
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<BudgetModel>())
        #expect(fetched[0].amount == 750.0)
    }

    @Test("Necessary and discretionary budgets coexist in the store")
    func bothBudgetTypesCoexist() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        context.insert(BudgetModel(type: NECESSARY, amount: 500.0))
        context.insert(BudgetModel(type: DISCRETIONARY, amount: 200.0))
        try context.save()

        #expect(try context.fetch(FetchDescriptor<BudgetModel>()).count == 2)

        let necessaryDescriptor = FetchDescriptor<BudgetModel>(predicate: #Predicate { $0.type == NECESSARY })
        let necessary = try context.fetch(necessaryDescriptor)
        #expect(necessary.count == 1)
        #expect(necessary[0].amount == 500.0)

        let discretionaryDescriptor = FetchDescriptor<BudgetModel>(predicate: #Predicate { $0.type == DISCRETIONARY })
        let discretionary = try context.fetch(discretionaryDescriptor)
        #expect(discretionary.count == 1)
        #expect(discretionary[0].amount == 200.0)
    }

    @Test("Rollback discards unsaved budget amount change")
    func rollbackDiscardsBudgetChange() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let budget = BudgetModel(type: NECESSARY, amount: 500.0)
        context.insert(budget)
        try context.save()

        budget.amount = 999.0
        context.rollback()

        let fetched = try context.fetch(FetchDescriptor<BudgetModel>())
        #expect(fetched[0].amount == 500.0)
    }

    @Test("Delete all budget data clears the store")
    func deleteAllBudgets() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        context.insert(BudgetModel(type: NECESSARY, amount: 500.0))
        context.insert(BudgetModel(type: DISCRETIONARY, amount: 200.0))
        try context.save()

        try context.delete(model: BudgetModel.self)
        try context.save()

        #expect(try context.fetch(FetchDescriptor<BudgetModel>()).isEmpty)
    }
}

// MARK: - EditableListItem CRUD

@Suite("EditableListItem CRUD")
struct EditableListItemCRUDTests {

    @Test("Insert category and fetch by CATEGORY type")
    func insertAndFetchCategory() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        context.insert(EditableListItem(text: "Food", type: CATEGORY))
        context.insert(EditableListItem(text: "Transport", type: CATEGORY))
        context.insert(EditableListItem(text: "Is this necessary?", type: MEDIATION))
        try context.save()

        let descriptor = FetchDescriptor<EditableListItem>(predicate: #Predicate { $0.type == CATEGORY })
        let categories = try context.fetch(descriptor)
        #expect(categories.count == 2)
        #expect(categories.allSatisfy { $0.type == CATEGORY })
    }

    @Test("Insert mediation and fetch by MEDIATION type")
    func insertAndFetchMediation() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        context.insert(EditableListItem(text: "Food", type: CATEGORY))
        context.insert(EditableListItem(text: "Is this necessary?", type: MEDIATION))
        context.insert(EditableListItem(text: "Will it last?", type: MEDIATION))
        try context.save()

        let descriptor = FetchDescriptor<EditableListItem>(predicate: #Predicate { $0.type == MEDIATION })
        let mediations = try context.fetch(descriptor)
        #expect(mediations.count == 2)
        #expect(mediations.allSatisfy { $0.type == MEDIATION })
    }

    @Test("Update item text persists across save")
    func updateItemText() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let item = EditableListItem(text: "Old Category", type: CATEGORY)
        context.insert(item)
        try context.save()

        item.text = "New Category"
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<EditableListItem>())
        #expect(fetched[0].text == "New Category")
    }

    @Test("Delete item removes it from the store")
    func deleteItem() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let item = EditableListItem(text: "Food", type: CATEGORY)
        context.insert(item)
        try context.save()

        context.delete(item)
        try context.save()

        #expect(try context.fetch(FetchDescriptor<EditableListItem>()).isEmpty)
    }

    @Test("Delete all items via model delete")
    func deleteAllItems() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        for text in ["Food", "Transport", "Entertainment"] {
            context.insert(EditableListItem(text: text, type: CATEGORY))
        }
        context.insert(EditableListItem(text: "Reflect", type: MEDIATION))
        try context.save()

        try context.delete(model: EditableListItem.self)
        try context.save()

        #expect(try context.fetch(FetchDescriptor<EditableListItem>()).isEmpty)
    }

    @Test("CATEGORY and MEDIATION items are independent of each other")
    func categoryAndMediationIndependent() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        context.insert(EditableListItem(text: "Food", type: CATEGORY))
        context.insert(EditableListItem(text: "Is this needed?", type: MEDIATION))
        try context.save()

        try context.delete(model: EditableListItem.self, where: #Predicate { $0.type == CATEGORY })
        try context.save()

        let remaining = try context.fetch(FetchDescriptor<EditableListItem>())
        #expect(remaining.count == 1)
        #expect(remaining[0].type == MEDIATION)
    }
}

// MARK: - Default Data Initialization (mirrors iSpendApp.initializeDefaultDataIfNeeded)

@Suite("Default Data Initialization")
struct DefaultDataInitTests {

    /// Runs the same seeding logic that iSpendApp performs on first launch.
    private func seedDefaultData(into context: ModelContext) throws {
        let categoryDescriptor = FetchDescriptor<EditableListItem>(
            predicate: #Predicate { $0.type == CATEGORY }
        )
        if (try context.fetch(categoryDescriptor)).isEmpty {
            let defaults = ["Food", "Transport", "Shopping", "Entertainment", "Bills", "Other"]
            for name in defaults {
                context.insert(EditableListItem(text: name, type: CATEGORY))
            }
        }

        let mediationDescriptor = FetchDescriptor<EditableListItem>(
            predicate: #Predicate { $0.type == MEDIATION }
        )
        if (try context.fetch(mediationDescriptor)).isEmpty {
            let defaults = [
                "Take a moment to reflect on this purchase.",
                "Will this bring lasting value?",
                "Is this aligned with your goals?"
            ]
            for text in defaults {
                context.insert(EditableListItem(text: text, type: MEDIATION))
            }
        }

        let necessaryBudgetDescriptor = FetchDescriptor<BudgetModel>(
            predicate: #Predicate { $0.type == NECESSARY }
        )
        if (try context.fetch(necessaryBudgetDescriptor)).isEmpty {
            context.insert(BudgetModel(type: NECESSARY, amount: 0))
        }

        let discretionaryBudgetDescriptor = FetchDescriptor<BudgetModel>(
            predicate: #Predicate { $0.type == DISCRETIONARY }
        )
        if (try context.fetch(discretionaryBudgetDescriptor)).isEmpty {
            context.insert(BudgetModel(type: DISCRETIONARY, amount: 0))
        }

        try context.save()
    }

    @Test("Six default categories are seeded on first run")
    func defaultCategoriesSeeded() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        try seedDefaultData(into: context)

        let descriptor = FetchDescriptor<EditableListItem>(predicate: #Predicate { $0.type == CATEGORY })
        let categories = try context.fetch(descriptor)
        #expect(categories.count == 6)
    }

    @Test("Three default reflections are seeded on first run")
    func defaultMediationsSeeded() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        try seedDefaultData(into: context)

        let descriptor = FetchDescriptor<EditableListItem>(predicate: #Predicate { $0.type == MEDIATION })
        let mediations = try context.fetch(descriptor)
        #expect(mediations.count == 3)
    }

    @Test("One necessary budget is seeded on first run")
    func defaultNecessaryBudgetSeeded() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        try seedDefaultData(into: context)

        let descriptor = FetchDescriptor<BudgetModel>(predicate: #Predicate { $0.type == NECESSARY })
        let budgets = try context.fetch(descriptor)
        #expect(budgets.count == 1)
        #expect(budgets[0].amount == 0)
    }

    @Test("One discretionary budget is seeded on first run")
    func defaultDiscretionaryBudgetSeeded() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        try seedDefaultData(into: context)

        let descriptor = FetchDescriptor<BudgetModel>(predicate: #Predicate { $0.type == DISCRETIONARY })
        let budgets = try context.fetch(descriptor)
        #expect(budgets.count == 1)
        #expect(budgets[0].amount == 0)
    }

    @Test("Seeding is idempotent: running it twice does not duplicate data")
    func seedingIsIdempotent() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        try seedDefaultData(into: context)
        try seedDefaultData(into: context) // second call

        let categoryDescriptor = FetchDescriptor<EditableListItem>(predicate: #Predicate { $0.type == CATEGORY })
        let categories = try context.fetch(categoryDescriptor)
        #expect(categories.count == 6, "Categories should not be duplicated by a second seed")

        let budgetDescriptor = FetchDescriptor<BudgetModel>()
        let budgets = try context.fetch(budgetDescriptor)
        #expect(budgets.count == 2, "Budgets should not be duplicated by a second seed")
    }

    @Test("Default category names include expected entries")
    func defaultCategoryNames() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        try seedDefaultData(into: context)

        let descriptor = FetchDescriptor<EditableListItem>(predicate: #Predicate { $0.type == CATEGORY })
        let names = try context.fetch(descriptor).map { $0.text }
        #expect(names.contains("Food"))
        #expect(names.contains("Transport"))
        #expect(names.contains("Bills"))
    }
}
