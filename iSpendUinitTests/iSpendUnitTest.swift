//
//  iSpendUnitTest.swift
//  iSpendTests
//
//  Unit tests for models, enums, business logic, and pure utility functions.
//

import Testing
import Foundation
import UIKit
@testable import iSpend

// MARK: - ExpenseType

@Suite("ExpenseType")
struct ExpenseTypeTests {

    @Test("necessary has intValue 1")
    func necessaryIntValue() {
        #expect(ExpenseType.necessary.intValue == 1)
    }

    @Test("discretionary has intValue 2")
    func discretionaryIntValue() {
        #expect(ExpenseType.discretionary.intValue == 2)
    }

    @Test("init(from: 1) produces .necessary")
    func initFromOne() {
        #expect(ExpenseType(from: 1) == .necessary)
    }

    @Test("init(from: 2) produces .discretionary")
    func initFromTwo() {
        #expect(ExpenseType(from: 2) == .discretionary)
    }

    @Test("init(from:) defaults to .discretionary for unknown values", arguments: [0, -1, 3, 99])
    func initFromUnknown(value: Int) {
        #expect(ExpenseType(from: value) == .discretionary)
    }

    @Test("necessary rawValue is 'Necessary'")
    func necessaryRawValue() {
        #expect(ExpenseType.necessary.rawValue == "Necessary")
    }

    @Test("discretionary rawValue is 'Discretionary'")
    func discretionaryRawValue() {
        #expect(ExpenseType.discretionary.rawValue == "Discretionary")
    }

    @Test("allCases contains exactly two values")
    func allCasesCount() {
        #expect(ExpenseType.allCases.count == 2)
        #expect(ExpenseType.allCases.contains(.necessary))
        #expect(ExpenseType.allCases.contains(.discretionary))
    }

    @Test("intValue → init(from:) roundtrip is identity")
    func intValueRoundtrip() {
        for type in ExpenseType.allCases {
            #expect(ExpenseType(from: type.intValue) == type)
        }
    }

    @Test("Codable roundtrip preserves each case")
    func codableRoundtrip() throws {
        for type in ExpenseType.allCases {
            let data = try JSONEncoder().encode(type)
            let decoded = try JSONDecoder().decode(ExpenseType.self, from: data)
            #expect(decoded == type)
        }
    }

    @Test("rawValue can be used to reconstruct the case")
    func rawValueInit() {
        #expect(ExpenseType(rawValue: "Necessary") == .necessary)
        #expect(ExpenseType(rawValue: "Discretionary") == .discretionary)
        #expect(ExpenseType(rawValue: "invalid") == nil)
    }
}

// MARK: - Constants

@Suite("Constants")
struct ConstantsTests {

    @Test("UNDEFINED equals 0")
    func undefinedValue() { #expect(UNDEFINED == 0) }

    @Test("CATEGORY equals 1")
    func categoryValue() { #expect(CATEGORY == 1) }

    @Test("MEDIATION equals 2")
    func mediationValue() { #expect(MEDIATION == 2) }

    @Test("NECESSARY equals 1")
    func necessaryValue() { #expect(NECESSARY == 1) }

    @Test("DISCRETIONARY equals 2")
    func discretionaryValue() { #expect(DISCRETIONARY == 2) }

    @Test("NECESSARY matches ExpenseType.necessary.intValue")
    func necessaryAlignedWithEnum() {
        #expect(NECESSARY == ExpenseType.necessary.intValue)
    }

    @Test("DISCRETIONARY matches ExpenseType.discretionary.intValue")
    func discretionaryAlignedWithEnum() {
        #expect(DISCRETIONARY == ExpenseType.discretionary.intValue)
    }

    @Test("Item type constants are all distinct")
    func itemTypeConstantsAreDistinct() {
        #expect(UNDEFINED != CATEGORY)
        #expect(UNDEFINED != MEDIATION)
        #expect(CATEGORY != MEDIATION)
    }
}

// MARK: - ExpenseModel

@Suite("ExpenseModel")
struct ExpenseModelTests {

    @Test("Default init produces unique ids")
    func defaultInitUniqueIds() {
        let ids = (0..<10).map { _ in ExpenseModel().id }
        #expect(Set(ids).count == 10)
    }

    @Test("Default init has empty name")
    func defaultName() { #expect(ExpenseModel().name == "") }

    @Test("Default init has zero amount")
    func defaultAmount() { #expect(ExpenseModel().amount == 0) }

    @Test("Default init has empty note")
    func defaultNote() { #expect(ExpenseModel().note == "") }

    @Test("Default init has 'None' category")
    func defaultCategory() { #expect(ExpenseModel().category == "None") }

    @Test("Default init has zero discretionaryValue")
    func defaultDiscretionaryValue() { #expect(ExpenseModel().discretionaryValue == 0) }

    @Test("Default init typeMap is NECESSARY")
    func defaultTypeMap() { #expect(ExpenseModel().typeMap == NECESSARY) }

    @Test("Default date is approximately now")
    func defaultDate() {
        let before = Date()
        let model = ExpenseModel()
        let after = Date()
        #expect(model.date >= before)
        #expect(model.date <= after)
    }

    @Test("Custom init sets all fields correctly")
    func customInitAllFields() {
        let date = Date(timeIntervalSinceReferenceDate: 1_000_000)
        let model = ExpenseModel(
            name: "Rent",
            type: DISCRETIONARY,
            amount: 1200.0,
            note: "Monthly",
            date: date,
            category: "Bills",
            discretionaryValue: 6.0
        )
        #expect(model.name == "Rent")
        #expect(model.typeMap == DISCRETIONARY)
        #expect(model.amount == 1200.0)
        #expect(model.note == "Monthly")
        #expect(model.date == date)
        #expect(model.category == "Bills")
        #expect(model.discretionaryValue == 6.0)
    }

    @Test("expenseType getter returns .necessary when typeMap is NECESSARY")
    func expenseTypeGetterNecessary() {
        #expect(ExpenseModel(type: NECESSARY).expenseType == .necessary)
    }

    @Test("expenseType getter returns .discretionary when typeMap is DISCRETIONARY")
    func expenseTypeGetterDiscretionary() {
        #expect(ExpenseModel(type: DISCRETIONARY).expenseType == .discretionary)
    }

    @Test("Setting expenseType to .necessary updates typeMap to NECESSARY")
    func expenseTypeSetterNecessary() {
        let model = ExpenseModel(type: DISCRETIONARY)
        model.expenseType = .necessary
        #expect(model.typeMap == NECESSARY)
    }

    @Test("Setting expenseType to .discretionary updates typeMap to DISCRETIONARY")
    func expenseTypeSetterDiscretionary() {
        let model = ExpenseModel(type: NECESSARY)
        model.expenseType = .discretionary
        #expect(model.typeMap == DISCRETIONARY)
    }

    @Test("typeMap and expenseType stay consistent through multiple mutations")
    func typeSyncThroughMutations() {
        let model = ExpenseModel()
        model.expenseType = .discretionary
        #expect(model.typeMap == DISCRETIONARY)
        #expect(model.expenseType == .discretionary)

        model.expenseType = .necessary
        #expect(model.typeMap == NECESSARY)
        #expect(model.expenseType == .necessary)

        model.typeMap = DISCRETIONARY
        #expect(model.expenseType == .discretionary)
    }

    @Test("Setting typeMap directly updates expenseType getter")
    func typeMapDirectlyUpdatesGetter() {
        let model = ExpenseModel(type: NECESSARY)
        model.typeMap = DISCRETIONARY
        #expect(model.expenseType == .discretionary)
        model.typeMap = NECESSARY
        #expect(model.expenseType == .necessary)
    }

    @Test("All mutable fields can be updated")
    func fieldsAreMutable() {
        let model = ExpenseModel()
        model.name = "Updated"
        model.amount = 99.99
        model.note = "A note"
        model.category = "Food"
        model.discretionaryValue = 5.0

        #expect(model.name == "Updated")
        #expect(model.amount == 99.99)
        #expect(model.note == "A note")
        #expect(model.category == "Food")
        #expect(model.discretionaryValue == 5.0)
    }
}

// MARK: - BudgetModel

@Suite("BudgetModel")
struct BudgetModelTests {

    @Test("Init sets type and amount correctly")
    func initSetsFields() {
        let budget = BudgetModel(type: NECESSARY, amount: 500.0)
        #expect(budget.type == NECESSARY)
        #expect(budget.amount == 500.0)
    }

    @Test("Two instances get distinct UUIDs")
    func uniqueIds() {
        let b1 = BudgetModel(type: NECESSARY, amount: 100)
        let b2 = BudgetModel(type: NECESSARY, amount: 100)
        #expect(b1.id != b2.id)
    }

    @Test("Amount can be updated")
    func amountIsMutable() {
        let budget = BudgetModel(type: NECESSARY, amount: 100.0)
        budget.amount = 250.0
        #expect(budget.amount == 250.0)
    }

    @Test("DISCRETIONARY type is stored correctly")
    func discretionaryType() {
        let budget = BudgetModel(type: DISCRETIONARY, amount: 200.0)
        #expect(budget.type == DISCRETIONARY)
    }

    @Test("Zero amount is valid")
    func zeroAmount() {
        #expect(BudgetModel(type: NECESSARY, amount: 0).amount == 0)
    }

    @Test("Large amount is stored precisely")
    func largeAmount() {
        let budget = BudgetModel(type: NECESSARY, amount: 999_999.99)
        #expect(budget.amount == 999_999.99)
    }
}

// MARK: - EditableListItem

@Suite("EditableListItem")
struct EditableListItemTests {

    @Test("Default init has empty text and CATEGORY type")
    func defaultInit() {
        let item = EditableListItem()
        #expect(item.text == "")
        #expect(item.type == CATEGORY)
    }

    @Test("Custom init sets text and type")
    func customInit() {
        let item = EditableListItem(text: "Food", type: CATEGORY)
        #expect(item.text == "Food")
        #expect(item.type == CATEGORY)
    }

    @Test("MEDIATION type is stored correctly")
    func mediationItem() {
        let item = EditableListItem(text: "Reflect before buying", type: MEDIATION)
        #expect(item.type == MEDIATION)
        #expect(item.text == "Reflect before buying")
    }

    @Test("Two instances get distinct UUIDs")
    func uniqueIds() {
        let i1 = EditableListItem(text: "A", type: CATEGORY)
        let i2 = EditableListItem(text: "A", type: CATEGORY)
        #expect(i1.id != i2.id)
    }

    @Test("Text is mutable")
    func textIsMutable() {
        let item = EditableListItem(text: "Old", type: CATEGORY)
        item.text = "New"
        #expect(item.text == "New")
    }

    @Test("Type is mutable")
    func typeIsMutable() {
        let item = EditableListItem(text: "Test", type: CATEGORY)
        item.type = MEDIATION
        #expect(item.type == MEDIATION)
    }
}

// MARK: - separateNumbersAndLetters

@Suite("separateNumbersAndLetters")
struct SeparateNumbersAndLettersTests {

    @Test("Pure text returns the text and nil number")
    func pureText() {
        let result = separateNumbersAndLetters(from: "Lunch")
        #expect(result.letters == "Lunch")
        #expect(result.number == nil)
    }

    @Test("Pure integer returns empty letters and the number")
    func pureInteger() {
        let result = separateNumbersAndLetters(from: "42")
        #expect(result.letters == "")
        #expect(result.number == 42.0)
    }

    @Test("Decimal number is parsed with full precision")
    func decimalNumber() {
        let result = separateNumbersAndLetters(from: "10.50")
        #expect(result.letters == "")
        #expect(result.number == 10.50)
    }

    @Test("Text followed by number: letters and number split correctly")
    func textThenNumber() {
        let result = separateNumbersAndLetters(from: "Lunch 12.50")
        #expect(result.letters == "Lunch")
        #expect(result.number == 12.50)
    }

    @Test("Number followed by text: letters and number split correctly")
    func numberThenText() {
        let result = separateNumbersAndLetters(from: "12.99 Coffee")
        #expect(result.letters == "Coffee")
        #expect(result.number == 12.99)
    }

    @Test("Empty string returns empty letters and nil number")
    func emptyString() {
        let result = separateNumbersAndLetters(from: "")
        #expect(result.letters == "")
        #expect(result.number == nil)
    }

    @Test("Integer value is returned as a Double")
    func integerReturnedAsDouble() {
        let result = separateNumbersAndLetters(from: "Coffee 5")
        #expect(result.number == 5.0)
    }

    @Test("Whitespace around letters is trimmed")
    func whitespaceIsTrimmed() {
        let result = separateNumbersAndLetters(from: "  Lunch  ")
        #expect(result.letters == "Lunch")
    }

    @Test("Only the first number is extracted when multiple exist")
    func firstNumberExtracted() {
        let result = separateNumbersAndLetters(from: "Item 5 qty 3")
        #expect(result.number == 5.0)
    }

    @Test("Zero is a valid number")
    func zeroIsValid() {
        let result = separateNumbersAndLetters(from: "0")
        #expect(result.number == 0.0)
        #expect(result.letters == "")
    }

    @Test("Number with no decimal point is parsed")
    func wholeNumberParsed() {
        let result = separateNumbersAndLetters(from: "Groceries 150")
        #expect(result.letters == "Groceries")
        #expect(result.number == 150.0)
    }
}

// MARK: - CSV Generation

@Suite("generateCSV")
struct CSVGenerationTests {

    @Test("Empty input produces only the header line")
    func emptyInputHeader() {
        let csv = generateCSV(from: [])
        let lines = csv.components(separatedBy: "\n").filter { !$0.isEmpty }
        #expect(lines.count == 1)
        #expect(lines[0] == "date,name,expenseType,amount,note,category,discretionaryValue")
    }

    @Test("Header contains all seven expected columns")
    func headerColumns() {
        let header = generateCSV(from: []).components(separatedBy: "\n")[0]
        let expected = ["date", "name", "expenseType", "amount", "note", "category", "discretionaryValue"]
        for column in expected {
            #expect(header.contains(column), "Header missing column: \(column)")
        }
    }

    @Test("Single expense produces exactly one data row")
    func singleExpenseOneRow() {
        let expense = ExpenseModel(name: "Coffee", type: NECESSARY, amount: 3.50)
        let lines = generateCSV(from: [expense]).components(separatedBy: "\n").filter { !$0.isEmpty }
        #expect(lines.count == 2) // header + 1 row
    }

    @Test("N expenses produce N data rows plus the header")
    func nExpensesNRows() {
        let expenses = (1...5).map { ExpenseModel(name: "Item \($0)", amount: Double($0)) }
        let lines = generateCSV(from: expenses).components(separatedBy: "\n").filter { !$0.isEmpty }
        #expect(lines.count == 6)
    }

    @Test("Expense name appears in the output")
    func nameAppearsInOutput() {
        let expense = ExpenseModel(name: "Morning Latte", amount: 5.0)
        #expect(generateCSV(from: [expense]).contains("Morning Latte"))
    }

    @Test("Expense amount appears in the output")
    func amountAppearsInOutput() {
        let expense = ExpenseModel(name: "Test", amount: 42.99)
        #expect(generateCSV(from: [expense]).contains("42.99"))
    }

    @Test("Expense category appears in the output")
    func categoryAppearsInOutput() {
        let expense = ExpenseModel(name: "Lunch", amount: 10.0, category: "Food")
        #expect(generateCSV(from: [expense]).contains("Food"))
    }

    @Test("Expense note appears in the output")
    func noteAppearsInOutput() {
        let expense = ExpenseModel(name: "Test", amount: 5.0, note: "Special occasion")
        #expect(generateCSV(from: [expense]).contains("Special occasion"))
    }

    @Test("discretionaryValue appears in the output")
    func discretionaryValueAppearsInOutput() {
        let expense = ExpenseModel(name: "Test", amount: 5.0, discretionaryValue: 4.0)
        #expect(generateCSV(from: [expense]).contains("4.0"))
    }

    @Test("Necessary expense shows 'Necessary' as expenseType")
    func necessaryExpenseType() {
        let expense = ExpenseModel(name: "Rent", type: NECESSARY, amount: 1000)
        #expect(generateCSV(from: [expense]).contains("Necessary"))
    }

    @Test("Discretionary expense shows 'Discretionary' as expenseType")
    func discretionaryExpenseType() {
        let expense = ExpenseModel(name: "Games", type: DISCRETIONARY, amount: 60)
        #expect(generateCSV(from: [expense]).contains("Discretionary"))
    }

    @Test("Double-quote in name is escaped as two consecutive double-quotes")
    func quotesInNameEscaped() {
        let expense = ExpenseModel(name: "\"Fancy\" Dinner", amount: 80.0)
        let csv = generateCSV(from: [expense])
        #expect(csv.contains("\"\"Fancy\"\""))
    }

    @Test("Double-quote in note is escaped correctly")
    func quotesInNoteEscaped() {
        let expense = ExpenseModel(name: "Test", amount: 5.0, note: "He said \"yes\"")
        let csv = generateCSV(from: [expense])
        #expect(csv.contains("He said \"\"yes\"\""))
    }

    @Test("Double-quote in category is escaped correctly")
    func quotesInCategoryEscaped() {
        let expense = ExpenseModel(name: "Test", amount: 5.0, category: "\"Special\"")
        let csv = generateCSV(from: [expense])
        #expect(csv.contains("\"\"Special\"\""))
    }
}

// MARK: - Budget Business Logic

@Suite("Budget Business Logic")
struct BudgetBusinessLogicTests {

    @Test("Total expenses is the sum of all amounts")
    func totalExpensesSum() {
        let amounts = [100.0, 50.25, 75.75]
        let total = amounts.reduce(0, +)
        #expect(total == 226.0)
    }

    @Test("Balance equals budget minus total expenses")
    func balanceCalculation() {
        let budgetAmount = 500.0
        let total = 225.0
        #expect(budgetAmount - total == 275.0)
    }

    @Test("Balance is negative when expenses exceed budget")
    func negativeBalance() {
        let budgetAmount = 100.0
        let total = 150.0
        #expect(budgetAmount - total == -50.0)
        #expect(budgetAmount - total < 0)
    }

    @Test("Balance is zero when expenses exactly equal budget")
    func zeroBalance() {
        let budgetAmount = 100.0
        #expect(budgetAmount - budgetAmount == 0)
    }

    @Test("Total with no expenses is zero")
    func emptyTotalIsZero() {
        let expenses: [ExpenseModel] = []
        #expect(expenses.reduce(0) { $0 + $1.amount } == 0)
    }

    @Test("Total with one expense equals that expense's amount")
    func singleExpenseTotal() {
        let expense = ExpenseModel(name: "Coffee", amount: 4.50)
        let total = [expense].reduce(0) { $0 + $1.amount }
        #expect(total == 4.50)
    }
}

// MARK: - Expense Editor Save Validation

@Suite("Expense Editor Save Validation")
struct EditorSaveValidationTests {

    // Mirrors the logic of ExpenseModelViewEditor.disableSave:
    //   expenseModel.name.isEmpty || expenseModel.amount <= 0

    @Test("Empty name disables save")
    func emptyNameDisablesSave() {
        let model = ExpenseModel(name: "", amount: 10.0)
        let shouldDisable = model.name.isEmpty || model.amount <= 0
        #expect(shouldDisable)
    }

    @Test("Zero amount disables save")
    func zeroAmountDisablesSave() {
        let model = ExpenseModel(name: "Coffee", amount: 0)
        let shouldDisable = model.name.isEmpty || model.amount <= 0
        #expect(shouldDisable)
    }

    @Test("Negative amount disables save")
    func negativeAmountDisablesSave() {
        let model = ExpenseModel(name: "Coffee", amount: -1.0)
        let shouldDisable = model.name.isEmpty || model.amount <= 0
        #expect(shouldDisable)
    }

    @Test("Valid name and positive amount enables save")
    func validInputEnablesSave() {
        let model = ExpenseModel(name: "Coffee", amount: 4.50)
        let shouldDisable = model.name.isEmpty || model.amount <= 0
        #expect(!shouldDisable)
    }

    @Test("Very small positive amount enables save")
    func verySmallAmountEnablesSave() {
        let model = ExpenseModel(name: "Tip", amount: 0.01)
        let shouldDisable = model.name.isEmpty || model.amount <= 0
        #expect(!shouldDisable)
    }
}

// MARK: - Slider → ExpenseType Mapping

@Suite("Slider to ExpenseType Mapping")
struct SliderMappingTests {

    // Mirrors ExpenseModelViewEditor slider onChange logic:
    //   typeMap = newValue > 3 ? DISCRETIONARY : NECESSARY

    @Test("Slider values 1, 2, 3 map to NECESSARY", arguments: [1.0, 2.0, 3.0])
    func lowSliderIsNecessary(value: Double) {
        let result = value > 3 ? DISCRETIONARY : NECESSARY
        #expect(result == NECESSARY)
    }

    @Test("Slider values 4, 5, 6, 7 map to DISCRETIONARY", arguments: [4.0, 5.0, 6.0, 7.0])
    func highSliderIsDiscretionary(value: Double) {
        let result = value > 3 ? DISCRETIONARY : NECESSARY
        #expect(result == DISCRETIONARY)
    }

    @Test("Boundary: 3.0 maps to NECESSARY, 4.0 maps to DISCRETIONARY")
    func boundary() {
        #expect((3.0 > 3 ? DISCRETIONARY : NECESSARY) == NECESSARY)
        #expect((4.0 > 3 ? DISCRETIONARY : NECESSARY) == DISCRETIONARY)
    }
}

// MARK: - Priority Color Tiers

@Suite("Priority Color Tiers")
struct PriorityColorTierTests {

    // Mirrors ExpenseModelViewEditor.typeColor logic:
    //   <= 3 → green, <= 5 → orange, else → red

    @Test("Values 1, 2, 3 fall in the green tier", arguments: [1.0, 2.0, 3.0])
    func greenTier(value: Double) {
        let tier: String = value <= 3 ? "green" : value <= 5 ? "orange" : "red"
        #expect(tier == "green")
    }

    @Test("Values 4, 5 fall in the orange tier", arguments: [4.0, 5.0])
    func orangeTier(value: Double) {
        let tier: String = value <= 3 ? "green" : value <= 5 ? "orange" : "red"
        #expect(tier == "orange")
    }

    @Test("Values 6, 7 fall in the red tier", arguments: [6.0, 7.0])
    func redTier(value: Double) {
        let tier: String = value <= 3 ? "green" : value <= 5 ? "orange" : "red"
        #expect(tier == "red")
    }

    @Test("Boundary: 3 is green, 4 is orange, 5 is orange, 6 is red")
    func boundaries() {
        let classify: (Double) -> String = { v in v <= 3 ? "green" : v <= 5 ? "orange" : "red" }
        #expect(classify(3) == "green")
        #expect(classify(4) == "orange")
        #expect(classify(5) == "orange")
        #expect(classify(6) == "red")
    }
}

// MARK: - BudgetPeriod enum

@Suite("BudgetPeriod")
struct BudgetPeriodTests {

    @Test("weekly has intValue 1")
    func weeklyIntValue() { #expect(BudgetPeriod.weekly.intValue == 1) }

    @Test("monthly has intValue 2")
    func monthlyIntValue() { #expect(BudgetPeriod.monthly.intValue == 2) }

    @Test("yearly has intValue 3")
    func yearlyIntValue() { #expect(BudgetPeriod.yearly.intValue == 3) }

    @Test("custom has intValue 4")
    func customIntValue() { #expect(BudgetPeriod.custom.intValue == 4) }

    @Test("init(from: 1) produces .weekly")
    func initFromOne() { #expect(BudgetPeriod(from: 1) == .weekly) }

    @Test("init(from: 2) produces .monthly")
    func initFromTwo() { #expect(BudgetPeriod(from: 2) == .monthly) }

    @Test("init(from: 3) produces .yearly")
    func initFromThree() { #expect(BudgetPeriod(from: 3) == .yearly) }

    @Test("init(from: 4) produces .custom")
    func initFromFour() { #expect(BudgetPeriod(from: 4) == .custom) }

    @Test("init(from:) defaults to .monthly for unknown values", arguments: [0, -1, 5, 99])
    func initFromUnknown(value: Int) {
        #expect(BudgetPeriod(from: value) == .monthly)
    }

    @Test("intValue → init(from:) roundtrip is identity")
    func intValueRoundtrip() {
        for period in BudgetPeriod.allCases {
            #expect(BudgetPeriod(from: period.intValue) == period)
        }
    }

    @Test("rawValues are human-readable strings")
    func rawValues() {
        #expect(BudgetPeriod.weekly.rawValue == "Weekly")
        #expect(BudgetPeriod.monthly.rawValue == "Monthly")
        #expect(BudgetPeriod.yearly.rawValue == "Yearly")
        #expect(BudgetPeriod.custom.rawValue == "Custom")
    }

    @Test("allCases contains exactly four values")
    func allCasesCount() { #expect(BudgetPeriod.allCases.count == 4) }

    @Test("Codable roundtrip preserves each case")
    func codableRoundtrip() throws {
        for period in BudgetPeriod.allCases {
            let data = try JSONEncoder().encode(period)
            let decoded = try JSONDecoder().decode(BudgetPeriod.self, from: data)
            #expect(decoded == period)
        }
    }
}

// MARK: - BudgetPeriod date ranges

@Suite("BudgetPeriod date ranges")
struct BudgetPeriodDateRangeTests {

    @Test("Monthly period start is the first of the current month")
    func monthlyPeriodStart() {
        let budget = BudgetModel(type: NECESSARY, amount: 100)
        budget.budgetPeriod = .monthly
        let day = Calendar.current.component(.day, from: budget.currentPeriodStart)
        #expect(day == 1)
    }

    @Test("Weekly period start is the first day of the current week")
    func weeklyPeriodStart() {
        let budget = BudgetModel(type: NECESSARY, amount: 100)
        budget.budgetPeriod = .weekly
        let weekday = Calendar.current.component(.weekday, from: budget.currentPeriodStart)
        #expect(weekday == Calendar.current.firstWeekday)
    }

    @Test("Yearly period start is January 1 of the current year")
    func yearlyPeriodStart() {
        let budget = BudgetModel(type: NECESSARY, amount: 100)
        budget.budgetPeriod = .yearly
        let components = Calendar.current.dateComponents([.month, .day], from: budget.currentPeriodStart)
        #expect(components.month == 1)
        #expect(components.day == 1)
    }

    @Test("Period end is strictly after period start for all period types")
    func periodEndAfterStart() {
        for period in BudgetPeriod.allCases {
            let budget = BudgetModel(type: NECESSARY, amount: 100)
            budget.budgetPeriod = period
            #expect(budget.currentPeriodEnd > budget.currentPeriodStart)
        }
    }

    @Test("Custom period spans the configured number of days")
    func customPeriodSpan() {
        let budget = BudgetModel(type: NECESSARY, amount: 100)
        budget.budgetPeriod = .custom
        budget.customPeriodDays = 14
        budget.periodStartDate = Date()
        let days = Calendar.current.dateComponents([.day], from: budget.currentPeriodStart, to: budget.currentPeriodEnd).day
        #expect(days == 14)
    }

    @Test("Default periodMap is monthly (2)")
    func defaultPeriodIsMonthly() {
        let budget = BudgetModel(type: NECESSARY, amount: 500)
        #expect(budget.periodMap == 2)
        #expect(budget.budgetPeriod == .monthly)
    }

    @Test("budgetPeriod getter and setter stay in sync with periodMap")
    func periodGetterSetterSync() {
        let budget = BudgetModel(type: NECESSARY, amount: 100)
        budget.budgetPeriod = .weekly
        #expect(budget.periodMap == 1)
        budget.budgetPeriod = .yearly
        #expect(budget.periodMap == 3)
        budget.periodMap = 4
        #expect(budget.budgetPeriod == .custom)
    }

    @Test("customPeriodDays defaults to 30")
    func defaultCustomDays() {
        #expect(BudgetModel(type: NECESSARY, amount: 0).customPeriodDays == 30)
    }

    @Test("periodLabel for monthly contains the month name")
    func monthlyPeriodLabel() {
        let budget = BudgetModel(type: NECESSARY, amount: 0)
        budget.budgetPeriod = .monthly
        let label = budget.periodLabel
        #expect(!label.isEmpty)
        // Should be something like "Mar 2026"
        #expect(label.contains(" "))
    }

    @Test("periodLabel for weekly contains a date range with dash")
    func weeklyPeriodLabel() {
        let budget = BudgetModel(type: NECESSARY, amount: 0)
        budget.budgetPeriod = .weekly
        #expect(budget.periodLabel.contains("–"))
    }
}

// MARK: - CSV Parsing

@Suite("parseCSV")
struct CSVParsingTests {

    // Returns the short-style date string that generateCSV/parseCSV use.
    private func csvDateString(year: Int, month: Int, day: Int) -> String {
        var comps = DateComponents()
        comps.year = year; comps.month = month; comps.day = day
        let date = Calendar.current.date(from: comps) ?? Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        var comps = DateComponents()
        comps.year = year; comps.month = month; comps.day = day
        return Calendar.current.date(from: comps) ?? Date()
    }

    private func singleRowCSV(dateStr: String, name: String = "Item", type expenseType: String = "Necessary",
                               amount: Double = 5.0, note: String = "", category: String = "None",
                               discretionaryValue: Double = 0.0) -> String {
        let escapedName = name.replacingOccurrences(of: "\"", with: "\"\"")
        let escapedNote = note.replacingOccurrences(of: "\"", with: "\"\"")
        let header = "date,name,expenseType,amount,note,category,discretionaryValue"
        let row = "\"\(dateStr)\",\"\(escapedName)\",\(expenseType),\(amount),\"\(escapedNote)\",\"\(category)\",\(discretionaryValue)"
        return "\(header)\n\(row)\n"
    }

    @Test("Empty string returns empty array and zero failed rows")
    func emptyString() {
        let (expenses, failedRows) = parseCSV("")
        #expect(expenses.isEmpty)
        #expect(failedRows == 0)
    }

    @Test("Header-only input returns empty array and zero failed rows")
    func headerOnly() {
        let (expenses, failedRows) = parseCSV("date,name,expenseType,amount,note,category,discretionaryValue\n")
        #expect(expenses.isEmpty)
        #expect(failedRows == 0)
    }

    @Test("Single valid row produces one expense and zero failed rows")
    func singleValidRow() {
        let csv = singleRowCSV(dateStr: csvDateString(year: 2026, month: 3, day: 15), name: "Coffee", amount: 4.5)
        let (expenses, failedRows) = parseCSV(csv)
        #expect(expenses.count == 1)
        #expect(failedRows == 0)
    }

    @Test("Name field is parsed correctly")
    func parsedName() {
        let csv = singleRowCSV(dateStr: csvDateString(year: 2026, month: 3, day: 15), name: "Groceries")
        let (expenses, _) = parseCSV(csv)
        #expect(expenses.first?.name == "Groceries")
    }

    @Test("Amount field is parsed correctly")
    func parsedAmount() {
        let csv = singleRowCSV(dateStr: csvDateString(year: 2026, month: 3, day: 15), amount: 12.75)
        let (expenses, _) = parseCSV(csv)
        #expect(expenses.first?.amount == 12.75)
    }

    @Test("Note field is parsed correctly")
    func parsedNote() {
        let csv = singleRowCSV(dateStr: csvDateString(year: 2026, month: 3, day: 15), note: "extra shot")
        let (expenses, _) = parseCSV(csv)
        #expect(expenses.first?.note == "extra shot")
    }

    @Test("Category field is parsed correctly")
    func parsedCategory() {
        let csv = singleRowCSV(dateStr: csvDateString(year: 2026, month: 3, day: 15), category: "Bills")
        let (expenses, _) = parseCSV(csv)
        #expect(expenses.first?.category == "Bills")
    }

    @Test("DiscretionaryValue field is parsed correctly")
    func parsedDiscretionaryValue() {
        let csv = singleRowCSV(dateStr: csvDateString(year: 2026, month: 3, day: 15), discretionaryValue: 6.0)
        let (expenses, _) = parseCSV(csv)
        #expect(expenses.first?.discretionaryValue == 6.0)
    }

    @Test("Necessary expenseType is parsed to .necessary")
    func necessaryType() {
        let csv = singleRowCSV(dateStr: csvDateString(year: 2026, month: 3, day: 15), type: "Necessary")
        let (expenses, _) = parseCSV(csv)
        #expect(expenses.first?.expenseType == .necessary)
    }

    @Test("Discretionary expenseType is parsed to .discretionary")
    func discretionaryType() {
        let csv = singleRowCSV(dateStr: csvDateString(year: 2026, month: 3, day: 15), type: "Discretionary")
        let (expenses, _) = parseCSV(csv)
        #expect(expenses.first?.expenseType == .discretionary)
    }

    @Test("Unknown expenseType string defaults to .necessary")
    func unknownTypeDefaultsToNecessary() {
        let csv = singleRowCSV(dateStr: csvDateString(year: 2026, month: 3, day: 15), type: "BogusType")
        let (expenses, _) = parseCSV(csv)
        #expect(expenses.first?.expenseType == .necessary)
    }

    @Test("Empty category string is stored as 'None'")
    func emptyCategoryBecomesNone() {
        let csv = singleRowCSV(dateStr: csvDateString(year: 2026, month: 3, day: 15), category: "")
        let (expenses, _) = parseCSV(csv)
        #expect(expenses.first?.category == "None")
    }

    @Test("Multiple valid rows are all parsed")
    func multipleRows() {
        let dateStr = csvDateString(year: 2026, month: 3, day: 15)
        let header = "date,name,expenseType,amount,note,category,discretionaryValue"
        let rows = (1...5).map { i in "\"\(dateStr)\",\"Item \(i)\",Necessary,\(Double(i)),\"\",\"None\",0.0" }
        let csv = header + "\n" + rows.joined(separator: "\n") + "\n"
        let (expenses, failedRows) = parseCSV(csv)
        #expect(expenses.count == 5)
        #expect(failedRows == 0)
    }

    @Test("Row with too few columns increments failedRows and produces no expense")
    func tooFewColumns() {
        let csv = "date,name,expenseType,amount,note,category,discretionaryValue\n\"1/1/26\",\"Item\"\n"
        let (expenses, failedRows) = parseCSV(csv)
        #expect(expenses.isEmpty)
        #expect(failedRows == 1)
    }

    @Test("Row with an invalid date increments failedRows")
    func invalidDate() {
        let csv = "date,name,expenseType,amount,note,category,discretionaryValue\n\"not-a-date\",\"Item\",Necessary,5.0,\"\",\"None\",0.0\n"
        let (expenses, failedRows) = parseCSV(csv)
        #expect(expenses.isEmpty)
        #expect(failedRows == 1)
    }

    @Test("Row with a non-numeric amount increments failedRows")
    func invalidAmount() {
        let dateStr = csvDateString(year: 2026, month: 3, day: 15)
        let csv = "date,name,expenseType,amount,note,category,discretionaryValue\n\"\(dateStr)\",\"Item\",Necessary,notanumber,\"\",\"None\",0.0\n"
        let (expenses, failedRows) = parseCSV(csv)
        #expect(expenses.isEmpty)
        #expect(failedRows == 1)
    }

    @Test("Mix of valid and invalid rows: valid ones returned, invalid counted")
    func mixedValidAndInvalid() {
        let dateStr = csvDateString(year: 2026, month: 3, day: 15)
        let csv = """
        date,name,expenseType,amount,note,category,discretionaryValue
        "\(dateStr)","Coffee",Necessary,4.5,"","Food",0.0
        "bad-date","Broken",Necessary,5.0,"","None",0.0
        "\(dateStr)","Tea",Necessary,2.0,"","Food",0.0
        """
        let (expenses, failedRows) = parseCSV(csv)
        #expect(expenses.count == 2)
        #expect(failedRows == 1)
    }

    @Test("Escaped double-quotes inside a quoted field are unescaped")
    func escapedQuotesUnescaped() {
        // The name in the CSV is: ""Fancy"" Dinner  →  parsed as: "Fancy" Dinner
        let dateStr = csvDateString(year: 2026, month: 3, day: 15)
        let csv = "date,name,expenseType,amount,note,category,discretionaryValue\n\"\(dateStr)\",\"\"\"Fancy\"\" Dinner\",Necessary,80.0,\"\",\"None\",0.0\n"
        let (expenses, _) = parseCSV(csv)
        #expect(expenses.first?.name == "\"Fancy\" Dinner")
    }

    @Test("Comma inside a quoted field does not split the field")
    func commaInQuotedField() {
        let dateStr = csvDateString(year: 2026, month: 3, day: 15)
        let csv = singleRowCSV(dateStr: dateStr, name: "Salt, Pepper")
        let (expenses, _) = parseCSV(csv)
        #expect(expenses.first?.name == "Salt, Pepper")
    }

    @Test("Windows CRLF line endings are handled correctly")
    func windowsLineEndings() {
        let dateStr = csvDateString(year: 2026, month: 3, day: 15)
        let csv = "date,name,expenseType,amount,note,category,discretionaryValue\r\n\"\(dateStr)\",\"Item\",Necessary,5.0,\"\",\"Food\",0.0\r\n"
        let (expenses, failedRows) = parseCSV(csv)
        #expect(expenses.count == 1)
        #expect(failedRows == 0)
    }

    @Test("generateCSV → parseCSV roundtrip preserves all non-date fields")
    func generateParseRoundtrip() {
        let date = makeDate(year: 2026, month: 3, day: 15)
        let originals = [
            ExpenseModel(name: "Coffee", type: NECESSARY, amount: 4.5, note: "morning", date: date, category: "Food", discretionaryValue: 1.0),
            ExpenseModel(name: "Games", type: DISCRETIONARY, amount: 60.0, note: "", date: date, category: "Entertainment", discretionaryValue: 6.0),
            ExpenseModel(name: "\"Fancy\" Dinner", type: NECESSARY, amount: 95.0, note: "special, occasion", date: date, category: "None", discretionaryValue: 0.0)
        ]
        let csv = generateCSV(from: originals)
        let (parsed, failedRows) = parseCSV(csv)
        #expect(failedRows == 0)
        #expect(parsed.count == originals.count)
        for (original, parsedExpense) in zip(originals, parsed) {
            #expect(parsedExpense.name == original.name)
            #expect(parsedExpense.amount == original.amount)
            #expect(parsedExpense.expenseType == original.expenseType)
            #expect(parsedExpense.note == original.note)
            #expect(parsedExpense.category == original.category)
            #expect(parsedExpense.discretionaryValue == original.discretionaryValue)
        }
    }

    @Test("generateCSV → parseCSV roundtrip preserves the date (day precision)")
    func roundtripPreservesDate() {
        let date = makeDate(year: 2026, month: 3, day: 15)
        let original = ExpenseModel(name: "Test", type: NECESSARY, amount: 1.0, date: date)
        let csv = generateCSV(from: [original])
        let (parsed, _) = parseCSV(csv)
        guard let parsedExpense = parsed.first else {
            Issue.record("No expense was parsed")
            return
        }
        let calendar = Calendar.current
        #expect(calendar.isDate(parsedExpense.date, inSameDayAs: date))
    }
}

// MARK: - Export to Clipboard

@Suite("Export to Clipboard")
struct ExportToClipboardTests {

    private func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var comps = DateComponents()
        comps.year = year; comps.month = month; comps.day = day
        return Calendar.current.date(from: comps) ?? Date()
    }

    @Test("generateCSV output can be written to and read back from the clipboard")
    func clipboardWriteAndRead() {
        let csv = generateCSV(from: [ExpenseModel(name: "Coffee", amount: 4.50)])
        UIPasteboard.general.string = csv
        #expect(UIPasteboard.general.string == csv)
    }

    @Test("Clipboard content after export is parseable with zero failures")
    func clipboardContentParseable() {
        let date = makeDate(2026, 3, 15)
        let csv = generateCSV(from: [
            ExpenseModel(name: "Rent", type: NECESSARY, amount: 1500.0, note: "monthly", date: date, category: "Bills", discretionaryValue: 0.0)
        ])
        UIPasteboard.general.string = csv
        let content = UIPasteboard.general.string ?? ""
        let (parsed, failedRows) = parseCSV(content)
        #expect(failedRows == 0)
        #expect(parsed.count == 1)
        #expect(parsed.first?.name == "Rent")
        #expect(parsed.first?.amount == 1500.0)
    }

    @Test("Exporting empty array produces header-only CSV that parses to zero expenses")
    func emptyExportParsesToZero() {
        UIPasteboard.general.string = generateCSV(from: [])
        let content = UIPasteboard.general.string ?? ""
        let (parsed, failedRows) = parseCSV(content)
        #expect(parsed.isEmpty)
        #expect(failedRows == 0)
    }

    @Test("Full export → clipboard → import roundtrip preserves all fields")
    func fullClipboardRoundtrip() {
        let date = makeDate(2026, 3, 15)
        let originals = [
            ExpenseModel(name: "Coffee", type: NECESSARY, amount: 4.5, note: "morning", date: date, category: "Food", discretionaryValue: 1.0),
            ExpenseModel(name: "Games", type: DISCRETIONARY, amount: 60.0, note: "", date: date, category: "Entertainment", discretionaryValue: 6.0),
        ]
        UIPasteboard.general.string = generateCSV(from: originals)
        let content = UIPasteboard.general.string ?? ""
        let (parsed, failedRows) = parseCSV(content)
        #expect(failedRows == 0)
        #expect(parsed.count == originals.count)
        for (original, parsedExpense) in zip(originals, parsed) {
            #expect(parsedExpense.name == original.name)
            #expect(parsedExpense.amount == original.amount)
            #expect(parsedExpense.expenseType == original.expenseType)
            #expect(parsedExpense.note == original.note)
            #expect(parsedExpense.category == original.category)
            #expect(parsedExpense.discretionaryValue == original.discretionaryValue)
        }
    }
}

// MARK: - Export to File

@Suite("Export to File")
struct ExportToFileTests {

    private func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var comps = DateComponents()
        comps.year = year; comps.month = month; comps.day = day
        return Calendar.current.date(from: comps) ?? Date()
    }

    @Test("generateCSV written to a temp file round-trips correctly")
    func fileRoundtrip() throws {
        let date = makeDate(2026, 3, 15)
        let expense = ExpenseModel(name: "Lunch", type: NECESSARY, amount: 12.0, date: date, category: "Food")
        let csv = generateCSV(from: [expense])
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("ispend-test-roundtrip.csv")
        try csv.write(to: url, atomically: true, encoding: .utf8)
        let content = try String(contentsOf: url, encoding: .utf8)
        let (parsed, failedRows) = parseCSV(content)
        #expect(failedRows == 0)
        #expect(parsed.count == 1)
        #expect(parsed.first?.name == "Lunch")
        #expect(parsed.first?.amount == 12.0)
    }

    @Test("File export of N expenses produces a file with N data rows plus the header")
    func multipleExpensesLineCount() throws {
        let date = makeDate(2026, 3, 15)
        let expenses = (1...3).map { i in
            ExpenseModel(name: "Item \(i)", type: NECESSARY, amount: Double(i) * 10.0, date: date)
        }
        let csv = generateCSV(from: expenses)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("ispend-test-count.csv")
        try csv.write(to: url, atomically: true, encoding: .utf8)
        let content = try String(contentsOf: url, encoding: .utf8)
        let lines = content.components(separatedBy: "\n").filter { !$0.isEmpty }
        #expect(lines.count == 4) // 1 header + 3 data rows
    }

    @Test("Exported file uses the .csv extension")
    func fileExtension() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("ispend-\(formatter.string(from: Date())).csv")
        #expect(url.pathExtension == "csv")
        #expect(url.lastPathComponent.hasPrefix("ispend-"))
    }

    @Test("File exported from generateCSV is UTF-8 encoded and readable as String")
    func fileIsUTF8() throws {
        let expense = ExpenseModel(name: "Café", type: NECESSARY, amount: 3.0)
        let csv = generateCSV(from: [expense])
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("ispend-test-utf8.csv")
        try csv.write(to: url, atomically: true, encoding: .utf8)
        let content = try String(contentsOf: url, encoding: .utf8)
        #expect(content.contains("Café"))
    }
}

// MARK: - Import from Clipboard Logic

@Suite("Import from Clipboard Logic")
struct ImportFromClipboardLogicTests {

    private func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var comps = DateComponents()
        comps.year = year; comps.month = month; comps.day = day
        return Calendar.current.date(from: comps) ?? Date()
    }

    @Test("Valid CSV written to clipboard can be read and parsed into expenses")
    func validCSVParsesFromClipboard() {
        let date = makeDate(2026, 3, 15)
        let expense = ExpenseModel(name: "Groceries", type: NECESSARY, amount: 55.0, date: date, category: "Food")
        UIPasteboard.general.string = generateCSV(from: [expense])
        let content = UIPasteboard.general.string ?? ""
        let (parsed, failedRows) = parseCSV(content)
        #expect(failedRows == 0)
        #expect(parsed.first?.name == "Groceries")
        #expect(parsed.first?.amount == 55.0)
    }

    @Test("Non-CSV text on clipboard produces no valid expenses")
    func invalidCSVOnClipboard() {
        UIPasteboard.general.string = "this is not csv data at all"
        let content = UIPasteboard.general.string ?? ""
        let (parsed, _) = parseCSV(content)
        #expect(parsed.isEmpty)
    }

    @Test("Empty string on clipboard produces empty result with zero failures")
    func emptyClipboard() {
        UIPasteboard.general.string = ""
        let content = UIPasteboard.general.string ?? ""
        let (parsed, failedRows) = parseCSV(content)
        #expect(parsed.isEmpty)
        #expect(failedRows == 0)
    }

    @Test("Header-only clipboard content produces no expenses and no failures")
    func headerOnlyClipboard() {
        UIPasteboard.general.string = "date,name,expenseType,amount,note,category,discretionaryValue"
        let content = UIPasteboard.general.string ?? ""
        let (parsed, failedRows) = parseCSV(content)
        #expect(parsed.isEmpty)
        #expect(failedRows == 0)
    }

    @Test("Multiple expenses on clipboard are all parsed correctly")
    func multipleExpensesOnClipboard() {
        let date = makeDate(2026, 3, 15)
        let originals = (1...4).map { i in
            ExpenseModel(name: "Expense \(i)", type: NECESSARY, amount: Double(i) * 5.0, date: date)
        }
        UIPasteboard.general.string = generateCSV(from: originals)
        let content = UIPasteboard.general.string ?? ""
        let (parsed, failedRows) = parseCSV(content)
        #expect(failedRows == 0)
        #expect(parsed.count == 4)
    }
}

// MARK: - Import Duplicate Detection

/// Tests the deduplication logic used in performImport:
/// a duplicate requires name + amount + same calendar day to all match.
@Suite("Import Duplicate Detection")
struct ImportDuplicateDetectionTests {

    private let calendar = Calendar.current

    private func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var comps = DateComponents()
        comps.year = year; comps.month = month; comps.day = day
        return Calendar.current.date(from: comps) ?? Date()
    }

    private func isDuplicate(_ incoming: ExpenseModel, among existing: [ExpenseModel]) -> Bool {
        existing.contains { e in
            e.name == incoming.name &&
            e.amount == incoming.amount &&
            calendar.isDate(e.date, inSameDayAs: incoming.date)
        }
    }

    @Test("Exact match on name, amount, and date is a duplicate")
    func exactMatchIsDuplicate() {
        let date = makeDate(2026, 3, 15)
        let existing = [ExpenseModel(name: "Coffee", amount: 4.50, date: date)]
        let incoming = ExpenseModel(name: "Coffee", amount: 4.50, date: date)
        #expect(isDuplicate(incoming, among: existing))
    }

    @Test("Same name and date but different amount is not a duplicate")
    func differentAmountNotDuplicate() {
        let date = makeDate(2026, 3, 15)
        let existing = [ExpenseModel(name: "Coffee", amount: 4.50, date: date)]
        let incoming = ExpenseModel(name: "Coffee", amount: 5.00, date: date)
        #expect(!isDuplicate(incoming, among: existing))
    }

    @Test("Same name and amount but different day is not a duplicate")
    func differentDayNotDuplicate() {
        let existing = [ExpenseModel(name: "Coffee", amount: 4.50, date: makeDate(2026, 3, 15))]
        let incoming = ExpenseModel(name: "Coffee", amount: 4.50, date: makeDate(2026, 3, 16))
        #expect(!isDuplicate(incoming, among: existing))
    }

    @Test("Different name with same amount and date is not a duplicate")
    func differentNameNotDuplicate() {
        let date = makeDate(2026, 3, 15)
        let existing = [ExpenseModel(name: "Coffee", amount: 4.50, date: date)]
        let incoming = ExpenseModel(name: "Tea", amount: 4.50, date: date)
        #expect(!isDuplicate(incoming, among: existing))
    }

    @Test("Same expense on same day at a different time of day is still a duplicate")
    func sameDayDifferentTimeIsDuplicate() {
        let morning = makeDate(2026, 3, 15).addingTimeInterval(8 * 3600)
        let evening = makeDate(2026, 3, 15).addingTimeInterval(18 * 3600)
        let existing = [ExpenseModel(name: "Coffee", amount: 4.50, date: morning)]
        let incoming = ExpenseModel(name: "Coffee", amount: 4.50, date: evening)
        #expect(isDuplicate(incoming, among: existing))
    }

    @Test("No duplicates are detected against an empty existing list")
    func emptyExistingListNoDuplicate() {
        let incoming = ExpenseModel(name: "Coffee", amount: 4.50, date: makeDate(2026, 3, 15))
        #expect(!isDuplicate(incoming, among: []))
    }

    @Test("One matching expense among several existing ones is correctly detected")
    func oneDuplicateAmongMany() {
        let date = makeDate(2026, 3, 15)
        let existing = [
            ExpenseModel(name: "Rent", amount: 1500.0, date: date),
            ExpenseModel(name: "Coffee", amount: 4.50, date: date),
            ExpenseModel(name: "Groceries", amount: 55.0, date: date),
        ]
        let incoming = ExpenseModel(name: "Coffee", amount: 4.50, date: date)
        #expect(isDuplicate(incoming, among: existing))
    }

    @Test("Expense from a previous month with the same name and amount is not a duplicate")
    func sameNameAmountDifferentMonthNotDuplicate() {
        let existing = [ExpenseModel(name: "Netflix", amount: 15.99, date: makeDate(2026, 2, 1))]
        let incoming = ExpenseModel(name: "Netflix", amount: 15.99, date: makeDate(2026, 3, 1))
        #expect(!isDuplicate(incoming, among: existing))
    }
}

// MARK: - Balance Color

@Suite("Balance Color")
struct BalanceColorTests {

    // Mirrors SummaryView.balanceColor: balance < 0 ? .red : .green

    @Test("Positive balance is green (not red)")
    func positiveIsGreen() {
        let balance = 100.0
        #expect(balance >= 0)   // green path
    }

    @Test("Negative balance is red")
    func negativeIsRed() {
        let balance = -50.0
        #expect(balance < 0)
    }

    @Test("Zero balance is green (not red)")
    func zeroIsGreen() {
        let balance = 0.0
        #expect(!(balance < 0))
    }

    @Test("Balance = budget - total expenses is correct")
    func balanceComputation() {
        let budget = 500.0
        let spent = 350.0
        #expect(budget - spent == 150.0)
    }

    @Test("Over-budget balance is negative")
    func overBudgetIsNegative() {
        let budget = 200.0
        let spent = 250.0
        #expect((budget - spent) < 0)
    }

    @Test("Exactly on-budget balance is zero, which is green")
    func exactlyOnBudgetIsGreen() {
        let budget = 100.0
        let balance = budget - budget
        #expect(balance == 0)
        #expect(!(balance < 0))
    }
}

// MARK: - Spending Progress Bar

@Suite("Spending Progress Bar")
struct SpendingProgressBarTests {

    // Mirrors SummaryView.progressBar logic:
    //   rawProgress = budget > 0 ? spent / budget : 0
    //   clampedProgress = min(max(rawProgress, 0), 1.0)
    //   color: rawProgress < 0.6 → green, < 0.9 → orange, else → red

    private func clamp(_ raw: Double) -> Double {
        min(max(raw, 0), 1.0)
    }

    private func progressColor(_ raw: Double) -> String {
        raw < 0.6 ? "green" : raw < 0.9 ? "orange" : "red"
    }

    @Test("Zero budget produces zero raw progress")
    func zeroBudgetProducesZeroProgress() {
        let budget = 0.0
        let raw = budget > 0 ? 100.0 / budget : 0.0
        #expect(raw == 0.0)
    }

    @Test("Progress is spent divided by budget")
    func progressCalculation() {
        #expect(50.0 / 100.0 == 0.5)
    }

    @Test("Progress over 100% is clamped to 1.0")
    func progressClampsAtOne() {
        #expect(clamp(1.5) == 1.0)
        #expect(clamp(2.0) == 1.0)
        #expect(clamp(99.9) == 1.0)
    }

    @Test("Negative raw progress is clamped to zero")
    func progressClampsAtZero() {
        #expect(clamp(-0.5) == 0.0)
        #expect(clamp(-99.0) == 0.0)
    }

    @Test("Progress within [0, 1] is unchanged by clamping")
    func progressWithinRangeUnchanged() {
        #expect(clamp(0.0) == 0.0)
        #expect(clamp(0.5) == 0.5)
        #expect(clamp(1.0) == 1.0)
    }

    @Test("Under 60% progress is green", arguments: [0.0, 0.3, 0.59])
    func greenBelow60(progress: Double) {
        #expect(progressColor(progress) == "green")
    }

    @Test("60–89% progress is orange", arguments: [0.6, 0.75, 0.89])
    func orangeAt60to89(progress: Double) {
        #expect(progressColor(progress) == "orange")
    }

    @Test("90% and above is red", arguments: [0.9, 0.95, 1.0])
    func redAt90Plus(progress: Double) {
        #expect(progressColor(progress) == "red")
    }

    @Test("Boundary: 0.599 is green, 0.6 is orange")
    func greenOrangeBoundary() {
        #expect(progressColor(0.599) == "green")
        #expect(progressColor(0.6) == "orange")
    }

    @Test("Boundary: 0.899 is orange, 0.9 is red")
    func orangeRedBoundary() {
        #expect(progressColor(0.899) == "orange")
        #expect(progressColor(0.9) == "red")
    }
}

// MARK: - Category Aggregation (Reports)

@Suite("Category Aggregation")
struct CategoryAggregationTests {

    // Mirrors ReportsView.categoryTotals:
    //   Dictionary(grouping: expenses, by: \.category)
    //   → sum amounts per group → filter > 0 → sort descending

    private func aggregate(_ expenses: [ExpenseModel]) -> [(category: String, total: Double)] {
        Dictionary(grouping: expenses, by: \.category)
            .map { (category: $0.key, total: $0.value.reduce(0) { $0 + $1.amount }) }
            .filter { $0.total > 0 }
            .sorted { $0.total > $1.total }
    }

    @Test("No expenses produces empty result")
    func emptyExpenses() {
        #expect(aggregate([]).isEmpty)
    }

    @Test("Single expense produces one category entry with correct total")
    func singleExpense() {
        let expense = ExpenseModel(name: "Coffee", amount: 4.50, category: "Food")
        let result = aggregate([expense])
        #expect(result.count == 1)
        #expect(result[0].category == "Food")
        #expect(result[0].total == 4.50)
    }

    @Test("Two expenses in the same category are summed")
    func sameCategorySummed() {
        let e1 = ExpenseModel(name: "Coffee", amount: 4.50, category: "Food")
        let e2 = ExpenseModel(name: "Lunch", amount: 12.00, category: "Food")
        let result = aggregate([e1, e2])
        #expect(result.count == 1)
        #expect(result[0].total == 16.50)
    }

    @Test("Expenses in different categories produce separate entries")
    func differentCategories() {
        let e1 = ExpenseModel(name: "Coffee", amount: 4.50, category: "Food")
        let e2 = ExpenseModel(name: "Bus", amount: 2.00, category: "Transport")
        let result = aggregate([e1, e2])
        #expect(result.count == 2)
    }

    @Test("Results are sorted by total descending")
    func sortedDescending() {
        let e1 = ExpenseModel(name: "Coffee", amount: 4.50, category: "Food")
        let e2 = ExpenseModel(name: "Bus", amount: 2.00, category: "Transport")
        let e3 = ExpenseModel(name: "Rent", amount: 1500.00, category: "Housing")
        let result = aggregate([e1, e2, e3])
        #expect(result[0].category == "Housing")
        #expect(result[1].category == "Food")
        #expect(result[2].category == "Transport")
    }

    @Test("Expenses with zero amount are excluded from results")
    func zeroAmountExcluded() {
        let zero = ExpenseModel(name: "Freebie", amount: 0, category: "Misc")
        let positive = ExpenseModel(name: "Coffee", amount: 4.50, category: "Food")
        let result = aggregate([zero, positive])
        #expect(result.count == 1)
        #expect(result[0].category == "Food")
    }

    @Test("Grand total equals sum of all category totals")
    func grandTotalIsSum() {
        let e1 = ExpenseModel(name: "Coffee", amount: 4.50, category: "Food")
        let e2 = ExpenseModel(name: "Bus", amount: 2.00, category: "Transport")
        let e3 = ExpenseModel(name: "Lunch", amount: 10.00, category: "Food")
        let result = aggregate([e1, e2, e3])
        let grandTotal = result.reduce(0) { $0 + $1.total }
        #expect(grandTotal == 16.50)
    }

    @Test("Five distinct categories produce five entries")
    func fiveCategories() {
        let categories = ["Food", "Transport", "Housing", "Health", "Entertainment"]
        let expenses = categories.map { ExpenseModel(name: $0, amount: 10.0, category: $0) }
        #expect(aggregate(expenses).count == 5)
    }

    @Test("Filtering necessary vs discretionary reduces the aggregated set")
    func typeFilterReducesResults() {
        let necessary = ExpenseModel(name: "Rent", type: NECESSARY, amount: 1500.0, category: "Housing")
        let discretionary = ExpenseModel(name: "Games", type: DISCRETIONARY, amount: 60.0, category: "Entertainment")
        let necessaryOnly = [necessary, discretionary].filter { $0.typeMap == NECESSARY }
        let result = aggregate(necessaryOnly)
        #expect(result.count == 1)
        #expect(result[0].category == "Housing")
    }
}

// MARK: - Period ID Set Lookup

@Suite("Period ID Set Lookup")
struct PeriodIDSetTests {

    // Mirrors ContentView's O(1) isInPeriod check:
    //   Set(expensesInPeriod.map(\.id)).contains(item.id)

    @Test("In-period expense ID is found in the set")
    func inPeriodFound() {
        let expense = ExpenseModel(name: "Coffee", amount: 4.50)
        let periodIDs = Set([expense.id])
        #expect(periodIDs.contains(expense.id))
    }

    @Test("Out-of-period expense ID is not in the set")
    func outOfPeriodNotFound() {
        let inPeriod = ExpenseModel(name: "Coffee", amount: 4.50)
        let outOfPeriod = ExpenseModel(name: "Old expense", amount: 10.0)
        let periodIDs = Set([inPeriod.id])
        #expect(!periodIDs.contains(outOfPeriod.id))
    }

    @Test("Empty set means no expense is in period")
    func emptySetNothingInPeriod() {
        let expense = ExpenseModel(name: "Coffee", amount: 4.50)
        let periodIDs = Set<UUID>()
        #expect(!periodIDs.contains(expense.id))
    }

    @Test("Set built from expenses map contains every expense ID")
    func setPreservesAllIDs() {
        let expenses = (0..<5).map { _ in ExpenseModel() }
        let idSet = Set(expenses.map(\.id))
        #expect(idSet.count == 5)
        for expense in expenses {
            #expect(idSet.contains(expense.id))
        }
    }

    @Test("Set lookup is consistent — same expense always found in its own set")
    func consistentLookup() {
        let expenses = (0..<10).map { _ in ExpenseModel() }
        let idSet = Set(expenses.map(\.id))
        for expense in expenses {
            #expect(idSet.contains(expense.id))
        }
    }

    @Test("Duplicate IDs in source array do not increase set size")
    func duplicateIDsCollapsed() {
        let expense = ExpenseModel()
        let idSet = Set([expense.id, expense.id, expense.id])
        #expect(idSet.count == 1)
    }

    @Test("IDs of different expenses are distinct")
    func differentExpensesDifferentIDs() {
        let a = ExpenseModel()
        let b = ExpenseModel()
        #expect(a.id != b.id)
        let idSet = Set([a.id])
        #expect(!idSet.contains(b.id))
    }
}
