import XCTest

final class HomeSecurityCodeLogUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testAddItemFlow() {
        app.buttons["addButton"].tap()
        let field1 = app.textFields["fieldCodeName"]
        XCTAssertTrue(field1.waitForExistence(timeout: 2))
        field1.tap()
        field1.typeText("Test Code Name")
        app.buttons["saveButton"].tap()
        XCTAssertTrue(app.staticTexts["Test Code Name"].waitForExistence(timeout: 2))
    }

    func testFreeLimitTriggersPaywall() {
        for i in 0..<(60) {
            app.buttons["addButton"].tap()
            let field1 = app.textFields["fieldCodeName"]
            if field1.waitForExistence(timeout: 1) {
                field1.tap()
                field1.typeText("Item \(i)")
                app.buttons["saveButton"].tap()
            } else {
                break
            }
        }
        XCTAssertTrue(app.staticTexts["Unlock Pro"].waitForExistence(timeout: 3) || app.buttons["paywallPurchaseButton"].waitForExistence(timeout: 1))
    }

    func testKeyboardDismissOnTapOutside() {
        app.buttons["addButton"].tap()
        let field1 = app.textFields["fieldCodeName"]
        XCTAssertTrue(field1.waitForExistence(timeout: 2))
        field1.tap()
        field1.typeText("Dismiss me")
        app.navigationBars.staticTexts.firstMatch.tap()
        XCTAssertFalse(app.keyboards.element.exists)
    }

    func testSettingsOpens() {
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 2))
        app.buttons["settingsDoneButton"].tap()
    }
}
