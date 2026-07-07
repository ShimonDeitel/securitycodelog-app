import XCTest
@testable import HomeSecurityCodeLog

@MainActor
final class StoreTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
        store.items = []
        store.isPro = false
    }

    func testAddItem() {
        let item = HomeSecurityCodeLogItem(codeName: "A", codeValue: "B", notes: "C")
        let added = store.add(item)
        XCTAssertTrue(added)
        XCTAssertEqual(store.items.count, 1)
    }

    func testFreeLimitBlocksAdd() {
        for i in 0..<Store.freeLimit {
            store.add(HomeSecurityCodeLogItem(codeName: "\(i)", codeValue: "B", notes: "C"))
        }
        XCTAssertEqual(store.items.count, Store.freeLimit)
        let blocked = store.add(HomeSecurityCodeLogItem(codeName: "over", codeValue: "B", notes: "C"))
        XCTAssertFalse(blocked)
        XCTAssertEqual(store.items.count, Store.freeLimit)
    }

    func testProBypassesLimit() {
        store.isPro = true
        for i in 0..<(Store.freeLimit + 5) {
            store.add(HomeSecurityCodeLogItem(codeName: "\(i)", codeValue: "B", notes: "C"))
        }
        XCTAssertEqual(store.items.count, Store.freeLimit + 5)
    }

    func testDeleteItem() {
        let item = HomeSecurityCodeLogItem(codeName: "A", codeValue: "B", notes: "C")
        store.add(item)
        store.delete(item)
        XCTAssertTrue(store.items.isEmpty)
    }

    func testUpdateItem() {
        var item = HomeSecurityCodeLogItem(codeName: "A", codeValue: "B", notes: "C")
        store.add(item)
        item.codeName = "Updated"
        store.update(item)
        XCTAssertEqual(store.items.first?.codeName, "Updated")
    }

    func testCanAddMoreTrueInitially() {
        XCTAssertTrue(store.canAddMore)
    }

    func testDeleteAtOffsets() {
        store.add(HomeSecurityCodeLogItem(codeName: "A", codeValue: "B", notes: "C"))
        store.add(HomeSecurityCodeLogItem(codeName: "D", codeValue: "E", notes: "F"))
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.items.count, 1)
    }

    func testPersistenceRoundTrip() {
        store.add(HomeSecurityCodeLogItem(codeName: "Persist", codeValue: "B", notes: "C"))
        let reloaded = Store()
        XCTAssertTrue(reloaded.items.contains(where: { $0.codeName == "Persist" }))
    }
}
