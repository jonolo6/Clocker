// Copyright © 2015 Abhishek Banthia

import XCTest

class NetworkDisconnectionTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }

    func precondition() {
        app.launch()

        if !app.tables["FloatingTableView"].exists {
            app.tapMenubarIcon()
            app.buttons["Pin"].click()
        }
    }

    func testAddingACity() {
        app.launchArguments.append("mockNetworkDown")
        precondition()
        app.buttons["FloatingPreferences"].click()

        if app.sheets.count == 0 {
            app.windows["Clocker"].checkBoxes["AddTimezone"].click()
        }

        XCTAssertFalse(app.sheets.staticTexts["ErrorPlaceholder"].exists)

        let searchField = app.searchFields["AvailableSearchField"]
        searchField.reset(text: "Uganda")
        sleep(1)
        XCTAssertTrue(app.sheets.staticTexts["ErrorPlaceholder"].exists)

        app.sheets.buttons["Close Button Title".localizedString()].click()
    }

    func testFetchingATimezone() {
        app.launchArguments.append("mockTimezoneDown")
        precondition()
        app.buttons["FloatingPreferences"].click()

        if app.sheets.count == 0 {
            app.windows["Clocker"].checkBoxes["AddTimezone"].click()
        }

        XCTAssertFalse(app.sheets.staticTexts["ErrorPlaceholder"].exists)

        let searchField = app.searchFields["AvailableSearchField"]
        searchField.reset(text: "Uganda")

        let firstResult = app.tables["AvailableTimezoneTableView"].tableRows.firstMatch

        let waiter = XCTWaiter()
        let isHittable = NSPredicate(format: "exists == true", "")
        let addExpectation = expectation(for: isHittable,
                                         evaluatedWith: firstResult,
                                         handler: nil)
        waiter.wait(for: [addExpectation], timeout: 5)
        app.tables["AvailableTimezoneTableView"].click()
        app.buttons["AddAvailableTimezone"].click()

        sleep(1)
        XCTAssertTrue(app.sheets.staticTexts["ErrorPlaceholder"].exists)
        app.sheets.buttons["Close Button Title".localizedString()].click()
    }
}
