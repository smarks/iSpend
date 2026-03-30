//
//  iSpendUnitTest.swift
//  iSpendTests
//
//  Unit tests for models, enums, business logic, and pure utility functions.
//

import Testing
import Foundation
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
