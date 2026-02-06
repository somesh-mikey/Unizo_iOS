//
//  UIColor+Brand.swift
//  Unizo_iOS
//
//  Brand colors and semantic color extensions
//  Uses iOS semantic colors for automatic dark mode support when needed
//

import UIKit

// MARK: - Brand Colors
extension UIColor {

    /// Primary brand color - Main accent color
    /// Used for: Primary buttons, key highlights, navigation tint
    static let brandPrimary = UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1.0)  // #3D7C98

    /// Secondary brand color - Supporting accent
    /// Used for: Secondary buttons, less prominent elements
    static let brandSecondary = UIColor(red: 0.365, green: 0.678, blue: 0.737, alpha: 1.0)  // #5DADBC

    /// Accent color - Call to action
    /// Used for: Important buttons, notifications
    static let brandAccent = UIColor(red: 0.902, green: 0.494, blue: 0.133, alpha: 1.0)  // #E67E22

    /// Light brand color - Backgrounds
    /// Used for: Light backgrounds, subtle highlights
    static let brandLight = UIColor(red: 0.914, green: 0.949, blue: 0.961, alpha: 1.0)  // #E9F2F5
}

// MARK: - Semantic Colors (iOS Native)
extension UIColor {

    /// Primary text color - Main content
    static var textPrimary: UIColor { .label }

    /// Secondary text color - Less prominent text
    static var textSecondary: UIColor { .secondaryLabel }

    /// Tertiary text color - Subtle text
    static var textTertiary: UIColor { .tertiaryLabel }

    /// Placeholder text color
    static var textPlaceholder: UIColor { .placeholderText }

    /// Primary background
    static var backgroundPrimary: UIColor { .systemBackground }

    /// Secondary background (grouped sections)
    static var backgroundSecondary: UIColor { .secondarySystemBackground }

    /// Tertiary background (nested sections)
    static var backgroundTertiary: UIColor { .tertiarySystemBackground }

    /// Grouped background (table view background)
    static var backgroundGrouped: UIColor { .systemGroupedBackground }

    /// Separator color
    static var separatorColor: UIColor { .separator }

    /// Border color for inputs
    static var borderColor: UIColor { .systemGray4 }
}

// MARK: - Status Colors (iOS Semantic)
extension UIColor {

    /// Success color - Positive outcomes
    static var statusSuccess: UIColor { .systemGreen }

    /// Warning color - Caution states
    static var statusWarning: UIColor { .systemOrange }

    /// Error color - Errors and destructive actions
    static var statusError: UIColor { .systemRed }

    /// Info color - Informational states
    static var statusInfo: UIColor { .systemBlue }

    /// Available status (product in stock)
    static var statusAvailable: UIColor { .systemGreen }

    /// Pending status (order pending)
    static var statusPending: UIColor { .systemOrange }

    /// Sold status (product sold out)
    static var statusSold: UIColor { .systemRed }
}

// MARK: - UI Element Colors
extension UIColor {

    /// Card background color
    static var cardBackground: UIColor { .white }

    /// Card shadow color
    static var cardShadow: UIColor { .black.withAlphaComponent(0.08) }

    /// Navigation bar background
    static var navigationBackground: UIColor { .systemBackground }

    /// Tab bar background
    static var tabBarBackground: UIColor { .systemBackground }

    /// Button primary background
    static var buttonPrimaryBackground: UIColor { brandPrimary }

    /// Button primary text
    static var buttonPrimaryText: UIColor { .white }

    /// Button secondary background
    static var buttonSecondaryBackground: UIColor { brandLight }

    /// Button secondary text
    static var buttonSecondaryText: UIColor { brandPrimary }

    /// Button destructive background
    static var buttonDestructiveBackground: UIColor { .systemRed }

    /// Button destructive text
    static var buttonDestructiveText: UIColor { .white }

    /// Negotiable badge color
    static var negotiableBadge: UIColor { .systemGreen }

    /// Non-negotiable badge color
    static var nonNegotiableBadge: UIColor { .systemRed }

    /// Rating star color
    static var ratingStar: UIColor { .systemYellow }

    /// Price text color
    static var priceText: UIColor { .label }

    /// Discount price color
    static var discountPrice: UIColor { .systemRed }

    /// Link color
    static var linkColor: UIColor { brandPrimary }
}

// MARK: - Gradient Colors
extension UIColor {

    /// Primary gradient start color
    static var gradientStart: UIColor { brandPrimary }

    /// Primary gradient end color
    static var gradientEnd: UIColor { brandSecondary }
}

// MARK: - CAGradientLayer Extension
extension CAGradientLayer {

    /// Creates a brand gradient layer
    static func brandGradient(frame: CGRect) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = [UIColor.gradientStart.cgColor, UIColor.gradientEnd.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        return gradient
    }
}
