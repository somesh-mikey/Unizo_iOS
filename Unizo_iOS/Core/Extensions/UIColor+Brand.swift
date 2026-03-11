//
//  UIColor+Brand.swift
//  Unizo_iOS
//
//  Brand and semantic color palette. Semantic wrappers (textPrimary,
//  backgroundPrimary, etc.) use iOS system colors so dark mode is handled
//  automatically. Brand colors are fixed and do not adapt.
//

import UIKit

// MARK: - Brand Colors

extension UIColor {

    /// #3D7C98 — primary buttons, navigation tint, key highlights
    static let brandPrimary   = UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1.0)

    /// #5DADBC — secondary buttons, less prominent accents
    static let brandSecondary = UIColor(red: 0.365, green: 0.678, blue: 0.737, alpha: 1.0)

    /// #E67E22 — call-to-action badges, important notifications
    static let brandAccent    = UIColor(red: 0.902, green: 0.494, blue: 0.133, alpha: 1.0)

    /// #E9F2F5 — light backgrounds, subtle highlights
    static let brandLight     = UIColor(red: 0.914, green: 0.949, blue: 0.961, alpha: 1.0)
}

// MARK: - Semantic Text & Background Colors

extension UIColor {
    static var textPrimary:       UIColor { .label }
    static var textSecondary:     UIColor { .secondaryLabel }
    static var textTertiary:      UIColor { .tertiaryLabel }
    static var textPlaceholder:   UIColor { .placeholderText }

    static var backgroundPrimary:   UIColor { .systemBackground }
    static var backgroundSecondary: UIColor { .secondarySystemBackground }
    static var backgroundTertiary:  UIColor { .tertiarySystemBackground }
    static var backgroundGrouped:   UIColor { .systemGroupedBackground }

    static var separatorColor: UIColor { .separator }
    static var borderColor:    UIColor { .systemGray4 }
}

// MARK: - Status Colors

extension UIColor {
    static var statusSuccess:   UIColor { .systemGreen }
    static var statusWarning:   UIColor { .systemOrange }
    static var statusError:     UIColor { .systemRed }
    static var statusInfo:      UIColor { .systemBlue }

    /// Product in-stock indicator
    static var statusAvailable: UIColor { .systemGreen }
    /// Order awaiting action
    static var statusPending:   UIColor { .systemOrange }
    /// Product sold out
    static var statusSold:      UIColor { .systemRed }
}

// MARK: - UI Element Colors

extension UIColor {
    static var cardBackground:   UIColor { .white }
    static var cardShadow:       UIColor { .black.withAlphaComponent(0.08) }

    static var navigationBackground: UIColor { .systemBackground }
    static var tabBarBackground:     UIColor { .systemBackground }

    static var buttonPrimaryBackground:     UIColor { brandPrimary }
    static var buttonPrimaryText:           UIColor { .white }
    static var buttonSecondaryBackground:   UIColor { brandLight }
    static var buttonSecondaryText:         UIColor { brandPrimary }
    static var buttonDestructiveBackground: UIColor { .systemRed }
    static var buttonDestructiveText:       UIColor { .white }

    static var negotiableBadge:    UIColor { .systemGreen }
    static var nonNegotiableBadge: UIColor { .systemRed }
    static var ratingStar:         UIColor { .systemYellow }
    static var priceText:          UIColor { .label }
    static var discountPrice:      UIColor { .systemRed }
    static var linkColor:          UIColor { brandPrimary }
}

// MARK: - Gradient Colors

extension UIColor {
    static var gradientStart: UIColor { brandPrimary }
    static var gradientEnd:   UIColor { brandSecondary }
}

extension CAGradientLayer {

    /// Creates a diagonal brand gradient (top-left → bottom-right).
    static func brandGradient(frame: CGRect) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = [UIColor.gradientStart.cgColor, UIColor.gradientEnd.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint   = CGPoint(x: 1, y: 1)
        return gradient
    }
}
