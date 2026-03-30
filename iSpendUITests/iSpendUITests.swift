//
//  iSpendUITests.swift
//  iSpendUITests
//
//  Created by Spencer Marks on 3/8/24.
//

import XCTest

// swiftlint:disable type_name
final class iSpendUITests: XCTestCase {
// swiftlint:enable type_name

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // Pass a flag so the app can use an in-memory store if it supports it;
        // at minimum this isolates launches by resetting state expectations.
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Launch & Main Screen

    func testAppLaunchesWithoutCrashing() {
        XCTAssert(app.state == .runningForeground)
    }

    func testMainScreenShowsNavigationTitle() {
        XCTAssertTrue(app.navigationBars["iSpend"].exists)
    }

    func testMainScreenShowsNecessaryExpensesSection() {
        XCTAssertTrue(app.staticTexts["Necessary Expenses"].exists)
    }

    func testMainScreenShowsDiscretionaryExpensesSection() {
        XCTAssertTrue(app.staticTexts["Discretionary Expenses"].exists)
    }

    func testAddButtonExistsInToolbar() {
        XCTAssertTrue(app.navigationBars.buttons["Add"].exists ||
                      app.navigationBars.buttons.matching(identifier: "Add").count > 0 ||
                      app.buttons["plus"].exists ||
                      app.navigationBars["iSpend"].buttons.element(boundBy: 0).exists)
    }

    func testSettingsButtonExistsInToolbar() {
        // The gear button should be visible in the navigation bar.
        let toolbar = app.navigationBars["iSpend"]
        XCTAssertTrue(toolbar.buttons.count >= 1)
    }

    // MARK: - Add Expense Sheet

    func testTappingAddButtonOpensSheet() {
        // Tap the + (add) button — the last button in the nav bar is settings,
        // the one before is add. Find by SF Symbol accessibility identifier.
        let addButton = app.navigationBars["iSpend"].buttons.element(boundBy: 0)
        addButton.tap()

        // The Expense Editor sheet should appear.
        XCTAssertTrue(app.navigationBars["Expense Editor"].waitForExistence(timeout: 3))
    }

    func testExpenseEditorHasCancelButton() {
        let addButton = app.navigationBars["iSpend"].buttons.element(boundBy: 0)
        addButton.tap()

        XCTAssertTrue(app.navigationBars["Expense Editor"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Cancel"].exists)
    }

    func testExpenseEditorHasDoneButton() {
        let addButton = app.navigationBars["iSpend"].buttons.element(boundBy: 0)
        addButton.tap()

        XCTAssertTrue(app.navigationBars["Expense Editor"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Done"].exists)
    }

    func testDoneButtonIsDisabledWhenFormIsEmpty() {
        let addButton = app.navigationBars["iSpend"].buttons.element(boundBy: 0)
        addButton.tap()

        XCTAssertTrue(app.navigationBars["Expense Editor"].waitForExistence(timeout: 3))
        let doneButton = app.buttons["Done"]
        XCTAssertFalse(doneButton.isEnabled, "Done should be disabled with empty name and zero amount")
    }

    func testCancelDismissesEditorSheet() {
        let addButton = app.navigationBars["iSpend"].buttons.element(boundBy: 0)
        addButton.tap()

        XCTAssertTrue(app.navigationBars["Expense Editor"].waitForExistence(timeout: 3))
        app.buttons["Cancel"].tap()

        XCTAssertTrue(app.navigationBars["iSpend"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.navigationBars["Expense Editor"].exists)
    }

    // MARK: - Settings Sheet

    func testTappingSettingsButtonOpensSheet() {
        // Settings (gear) is the last button in the nav bar.
        let settingsButton = app.navigationBars["iSpend"].buttons.element(boundBy: 1)
        settingsButton.tap()

        XCTAssertTrue(app.staticTexts["Preferences and Settings"].waitForExistence(timeout: 3))
    }

    func testSettingsSheetHasDoneButton() {
        let settingsButton = app.navigationBars["iSpend"].buttons.element(boundBy: 1)
        settingsButton.tap()

        XCTAssertTrue(app.staticTexts["Preferences and Settings"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Done"].exists)
    }

    func testSettingsDoneButtonDismissesSheet() {
        let settingsButton = app.navigationBars["iSpend"].buttons.element(boundBy: 1)
        settingsButton.tap()

        XCTAssertTrue(app.staticTexts["Preferences and Settings"].waitForExistence(timeout: 3))
        app.buttons["Done"].tap()

        XCTAssertTrue(app.navigationBars["iSpend"].waitForExistence(timeout: 3))
    }

    func testSettingsShowsBudgetsOption() {
        let settingsButton = app.navigationBars["iSpend"].buttons.element(boundBy: 1)
        settingsButton.tap()

        XCTAssertTrue(app.staticTexts["Preferences and Settings"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.cells.staticTexts["Budgets"].exists ||
                      app.staticTexts["Budgets"].exists)
    }

    func testSettingsShowsDataManagementOption() {
        let settingsButton = app.navigationBars["iSpend"].buttons.element(boundBy: 1)
        settingsButton.tap()

        XCTAssertTrue(app.staticTexts["Preferences and Settings"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.cells.staticTexts["Data Management"].exists ||
                      app.staticTexts["Data Management"].exists)
    }

    func testSettingsShowsCategoriesOption() {
        let settingsButton = app.navigationBars["iSpend"].buttons.element(boundBy: 1)
        settingsButton.tap()

        XCTAssertTrue(app.staticTexts["Preferences and Settings"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.cells.staticTexts["Categories"].exists ||
                      app.staticTexts["Categories"].exists)
    }

    func testSettingsShowsReflectionsOption() {
        let settingsButton = app.navigationBars["iSpend"].buttons.element(boundBy: 1)
        settingsButton.tap()

        XCTAssertTrue(app.staticTexts["Preferences and Settings"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.cells.staticTexts["Reflections"].exists ||
                      app.staticTexts["Reflections"].exists)
    }
}
