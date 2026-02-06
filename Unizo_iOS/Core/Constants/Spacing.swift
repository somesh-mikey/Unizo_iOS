//
//  Spacing.swift
//  Unizo_iOS
//
//  Consistent spacing constants following Apple HIG 8pt grid system
//  Ensures visual rhythm and proper hierarchy across the app
//

import UIKit

/// Standard spacing constants based on 8pt grid system
/// Apple HIG recommends consistent spacing for visual harmony
enum Spacing {

    // MARK: - Base Unit
    /// Base spacing unit (8pt)
    static let base: CGFloat = 8

    // MARK: - Standard Spacing
    /// Extra extra small spacing (2pt)
    static let xxs: CGFloat = 2

    /// Extra small spacing (4pt)
    static let xs: CGFloat = 4

    /// Small spacing (8pt)
    static let sm: CGFloat = 8

    /// Medium spacing (12pt)
    static let md: CGFloat = 12

    /// Large spacing (16pt)
    static let lg: CGFloat = 16

    /// Extra large spacing (20pt)
    static let xl: CGFloat = 20

    /// Extra extra large spacing (24pt)
    static let xxl: CGFloat = 24

    /// Triple extra large spacing (32pt)
    static let xxxl: CGFloat = 32

    // MARK: - Component Spacing
    /// Standard cell padding
    static let cellPadding: CGFloat = 16

    /// Standard section spacing
    static let sectionSpacing: CGFloat = 24

    /// Standard content margin (horizontal)
    static let contentMargin: CGFloat = 16

    /// Standard card padding
    static let cardPadding: CGFloat = 12

    /// Standard button padding
    static let buttonPadding: CGFloat = 16

    /// Standard icon size (small)
    static let iconSmall: CGFloat = 16

    /// Standard icon size (medium)
    static let iconMedium: CGFloat = 24

    /// Standard icon size (large)
    static let iconLarge: CGFloat = 32

    // MARK: - Touch Targets
    /// Minimum touch target size (Apple HIG requirement)
    static let minTouchTarget: CGFloat = 44

    /// Standard button height
    static let buttonHeight: CGFloat = 50

    /// Standard text field height
    static let textFieldHeight: CGFloat = 44

    // MARK: - Corner Radius
    /// Small corner radius (buttons, small cards)
    static let cornerRadiusSmall: CGFloat = 8

    /// Medium corner radius (cards, containers)
    static let cornerRadiusMedium: CGFloat = 12

    /// Large corner radius (modals, large cards)
    static let cornerRadiusLarge: CGFloat = 16

    /// Extra large corner radius (sheets)
    static let cornerRadiusXL: CGFloat = 20

    // MARK: - Grid
    /// Standard collection view item spacing
    static let gridItemSpacing: CGFloat = 12

    /// Standard collection view line spacing
    static let gridLineSpacing: CGFloat = 16

    /// Standard collection view section inset
    static let gridSectionInset: CGFloat = 16
}

// MARK: - UIEdgeInsets Extension
extension UIEdgeInsets {

    /// Standard content insets
    static var contentInsets: UIEdgeInsets {
        UIEdgeInsets(
            top: Spacing.lg,
            left: Spacing.contentMargin,
            bottom: Spacing.lg,
            right: Spacing.contentMargin
        )
    }

    /// Standard card insets
    static var cardInsets: UIEdgeInsets {
        UIEdgeInsets(
            top: Spacing.cardPadding,
            left: Spacing.cardPadding,
            bottom: Spacing.cardPadding,
            right: Spacing.cardPadding
        )
    }

    /// Standard cell insets
    static var cellInsets: UIEdgeInsets {
        UIEdgeInsets(
            top: Spacing.cellPadding,
            left: Spacing.cellPadding,
            bottom: Spacing.cellPadding,
            right: Spacing.cellPadding
        )
    }
}
