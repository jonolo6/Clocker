// Copyright © 2015 Abhishek Banthia

import XCTest

class AboutUsTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()

        if app.tables["FloatingTableView"].exists {
            app.tapMenubarIcon()
            app.buttons["FloatingPin"].click()
        }
    }

    private func tapAboutTab() {
        let aboutTab = app.toolbars.buttons.element(boundBy: 4)
        aboutTab.click()
    }

    func testMockingFeedback() {
        app.tapMenubarIcon()
        app.buttons["Preferences"].click()

        tapAboutTab()

        let expectedVersion = "Clocker 1.6.15 (70)"
        guard let presentVersion = app.windows["Clocker"].staticTexts["ClockerVersion"].value as? String else {
            XCTFail("Present version not present")
            return
        }

        XCTAssertEqual(expectedVersion, presentVersion)

        app.checkBoxes["ClockerPrivateFeedback"].click()
        app.buttons["Send Feedback"].click()

        let expectedInformativeText = "Please enter some feedback."
        XCTAssertTrue(app.staticTexts["InformativeText"].exists)

        guard let infoText = app.staticTexts["InformativeText"].value as? String else {
            XCTFail("InformativeText label was unexpectedly absent")
            return
        }

        XCTAssertEqual(infoText, expectedInformativeText)

        sleep(5)

        guard let newInfoText = app.staticTexts["InformativeText"].value as? String else {
            XCTFail("InformativeText label was unexpectedly absent")
            return
        }

        XCTAssertTrue(newInfoText.isEmpty)

        // Close window
        app.windows["Clocker Feedback"].buttons["Cancel"].click()
    }

    func testSendingDataToFirebase() {
        app.tapMenubarIcon()
        app.buttons["Preferences"].click()
        tapAboutTab()
        app.checkBoxes["ClockerPrivateFeedback"].click()

        let textView = app.textViews["FeedbackTextView"]
        textView.click()
        textView.typeText("This feedback was generated by UI Tests")

        let nameField = app.textFields["NameField"]
        nameField.click()
        nameField.typeText("Random Name")

        let emailField = app.textFields["EmailField"]
        emailField.click()
        emailField.typeText("randomemail@uitests.com")

        app.buttons["Send Feedback"].click()

        inverseWaiterFor(element: app.progressIndicators["ProgressIndicator"])

        XCTAssertTrue(app.sheets.staticTexts["Thank you for helping make Clocker even better!"].exists)
        XCTAssertTrue(app.sheets.staticTexts["We owe you a candy. 😇"].exists)

        app.windows["Clocker Feedback"].sheets.buttons["Close"].click()
    }
}
