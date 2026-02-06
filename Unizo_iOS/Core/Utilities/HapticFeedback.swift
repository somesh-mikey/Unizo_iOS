//
//  HapticFeedback.swift
//  Unizo_iOS
//
//  Centralized haptic feedback utility for iOS native experience
//  Apple HIG: Use haptics to provide tactile feedback for meaningful events
//

import UIKit

/// Centralized haptic feedback manager for consistent tactile feedback
/// across the app following Apple Human Interface Guidelines
enum HapticFeedback {

    // MARK: - Impact Feedback
    /// Use for UI element impacts (button taps, toggles)

    /// Light impact - subtle feedback for small UI elements
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Medium impact - standard feedback for most interactions
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Heavy impact - strong feedback for significant actions
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Soft impact - gentle feedback (iOS 13+)
    static func soft() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Rigid impact - sharp feedback (iOS 13+)
    static func rigid() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred()
    }

    // MARK: - Notification Feedback
    /// Use for task completion, errors, or warnings

    /// Success notification - task completed successfully
    /// Use for: Order placed, Item added to cart, Wishlist added
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    /// Warning notification - attention needed
    /// Use for: Low stock, Validation warnings
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    /// Error notification - task failed
    /// Use for: Network errors, Validation failures
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }

    // MARK: - Selection Feedback
    /// Use for selection changes (picker, segment control)

    /// Selection changed - use for picker/segment changes
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    // MARK: - Contextual Haptics
    /// Pre-configured haptics for common app actions

    /// Add to cart action
    static func addToCart() {
        success()
    }

    /// Remove from cart action
    static func removeFromCart() {
        light()
    }

    /// Add to wishlist action
    static func addToWishlist() {
        success()
    }

    /// Remove from wishlist action
    static func removeFromWishlist() {
        light()
    }

    /// Buy now / Place order action
    static func placeOrder() {
        heavy()
    }

    /// Order confirmed successfully
    static func orderConfirmed() {
        success()
    }

    /// Button tap feedback
    static func buttonTap() {
        light()
    }

    /// Tab bar selection
    static func tabSelected() {
        selection()
    }

    /// Pull to refresh triggered
    static func pullToRefresh() {
        medium()
    }

    /// Delete action
    static func delete() {
        medium()
    }

    /// Error occurred
    static func errorOccurred() {
        error()
    }

    /// Warning notification
    static func warningOccurred() {
        warning()
    }
}
