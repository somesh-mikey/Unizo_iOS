//
//  HapticFeedback.swift
//  Unizo_iOS
//
//  Centralized haptic feedback utility. Call the semantic methods
//  (e.g. HapticFeedback.placeOrder()) rather than the primitives so
//  feedback stays consistent if intensities need tuning later.
//

import UIKit

enum HapticFeedback {

    // MARK: - Primitives

    static func light() {
        let g = UIImpactFeedbackGenerator(style: .light)
        g.prepare(); g.impactOccurred()
    }

    static func medium() {
        let g = UIImpactFeedbackGenerator(style: .medium)
        g.prepare(); g.impactOccurred()
    }

    static func heavy() {
        let g = UIImpactFeedbackGenerator(style: .heavy)
        g.prepare(); g.impactOccurred()
    }

    /// iOS 13+
    static func soft() {
        let g = UIImpactFeedbackGenerator(style: .soft)
        g.prepare(); g.impactOccurred()
    }

    /// iOS 13+
    static func rigid() {
        let g = UIImpactFeedbackGenerator(style: .rigid)
        g.prepare(); g.impactOccurred()
    }

    static func success() {
        let g = UINotificationFeedbackGenerator()
        g.prepare(); g.notificationOccurred(.success)
    }

    static func warning() {
        let g = UINotificationFeedbackGenerator()
        g.prepare(); g.notificationOccurred(.warning)
    }

    static func error() {
        let g = UINotificationFeedbackGenerator()
        g.prepare(); g.notificationOccurred(.error)
    }

    static func selection() {
        let g = UISelectionFeedbackGenerator()
        g.prepare(); g.selectionChanged()
    }

    // MARK: - Semantic Actions

    static func addToCart()        { success() }
    static func removeFromCart()   { light() }
    static func addToWishlist()    { success() }
    static func removeFromWishlist() { light() }
    static func placeOrder()       { heavy() }
    static func orderConfirmed()   { success() }
    static func buttonTap()        { light() }
    static func tabSelected()      { selection() }
    static func pullToRefresh()    { medium() }
    static func delete()           { medium() }
    static func send()             { light() }
    static func errorOccurred()    { error() }
    static func warningOccurred()  { warning() }
}
