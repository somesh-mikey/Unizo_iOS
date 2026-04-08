//
//  UnizoIntegrationTests.swift
//  Unizo_iOS
//
//  DEBUG-only runtime validation suite. Call UnizoIntegrationTests.runAll()
//  from the hidden debug button in SettingsViewController to confirm every
//  data layer is working correctly. This is NOT an XCTest target.
//
//  Output appears in the Xcode console (print statements).
//

#if DEBUG

import Foundation
import FirebaseFirestore

final class UnizoIntegrationTests {

    private static let db = Firestore.firestore()

    // MARK: - Run All Tests

    static func runAll() {
        Task {
            print("\n🧪 ========= UNIZO INTEGRATION TESTS START =========\n")

            await testFirestoreConnection()
            await testAuthSession()
            await testProductLoad()
            await testNotificationFetch()
            await testOrderFetch()
            await testEventFetch()

            print("\n🧪 ========= UNIZO INTEGRATION TESTS END =========\n")
        }
    }

    // MARK: - Test 1: Firestore Connection

    private static func testFirestoreConnection() async {
        print("🧪 TEST 1: Firestore Connection")
        do {
            let snapshot = try await db.collection("products")
                .limit(to: 1)
                .getDocuments()
            print("  ✅ PASS: Firestore connection OK (returned \(snapshot.documents.count) doc(s))")
        } catch {
            print("  ❌ FAIL: Firestore connection failed: \(error)")
            print("  ⚠️  CHECK: GoogleService-Info.plist, Firebase project status, network")
        }
    }

    // MARK: - Test 2: Auth Session

    private static func testAuthSession() async {
        print("🧪 TEST 2: Auth Session")
        let valid = await AuthManager.shared.validateSession()
        if valid {
            if let userId = await AuthManager.shared.currentUserId {
                print("  ✅ PASS: Session valid for user \(userId)")
            } else {
                print("  ⚠️  WARN: validateSession() returned true but currentUserId is nil")
            }
        } else {
            print("  ❌ FAIL: No valid session — user must re-authenticate")
            print("  ⚠️  CHECK: Was the Firebase project or auth config changed?")
        }
    }

    // MARK: - Test 3: Product Load

    private static func testProductLoad() async {
        print("🧪 TEST 3: Product Loading")
        let repo = ProductRepository()
        do {
            let products = try await repo.fetchAllProducts(page: 1)
            if products.isEmpty {
                print("  ⚠️  WARN: Product query succeeded but returned 0 results")
                print("  ⚠️  CHECK: is_active field, status != sold, quantity > 0, Firestore composite indexes")
            } else {
                let first = products[0]
                let idText = first.id ?? "nil"
                print("  ✅ PASS: Loaded \(products.count) products. First: \"\(first.title)\" (id: \(idText))")
            }
        } catch {
            print("  ❌ FAIL: Product fetch failed: \(error)")
            print("  ⚠️  CHECK: products collection, composite indexes, Firestore rules")
        }
    }

    // MARK: - Test 4: Notification Fetch

    private static func testNotificationFetch() async {
        print("🧪 TEST 4: Notification Fetch")
        let repo = NotificationRepository()
        do {
            let notifications = try await repo.fetchNotifications()
            print("  ✅ PASS: Fetched \(notifications.count) notifications")

            let unread = try await repo.fetchUnreadCount()
            print("  ✅ PASS: Unread count: \(unread)")
        } catch {
            print("  ❌ FAIL: Notification fetch failed: \(error)")
            print("  ⚠️  CHECK: notifications collection, recipient_id field, Firestore rules")
        }
    }

    // MARK: - Test 5: Order Fetch

    private static func testOrderFetch() async {
        print("🧪 TEST 5: Order Fetch")
        let repo = OrderRepository()
        do {
            let orders = try await repo.fetchUserOrdersWithItems()
            print("  ✅ PASS: Fetched \(orders.count) orders")
        } catch {
            print("  ❌ FAIL: Order fetch failed: \(error)")
            print("  ⚠️  CHECK: orders collection, user_id field, Firestore rules")
        }
    }

    // MARK: - Test 6: Event Fetch

    private static func testEventFetch() async {
        print("🧪 TEST 6: Event Fetch")
        let repo = EventRepository()
        do {
            let events = try await repo.fetchFeaturedEvents()
            if events.isEmpty {
                print("  ⚠️  WARN: Event query returned 0 results (collection may be empty)")
            } else {
                print("  ✅ PASS: Fetched \(events.count) events")
            }
        } catch {
            print("  ❌ FAIL: Event fetch failed: \(error)")
            print("  ⚠️  CHECK: events collection, is_active field, Firestore composite indexes")
        }
    }
}

#endif
