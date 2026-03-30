//
//  Spacing.swift
//  Unizo_iOS
//
//  Layout constants for the 8pt grid. Import this enum anywhere you
//  need consistent padding, sizing, or corner radii instead of
//  hardcoding magic numbers.
//

import UIKit

// MARK: - Spacing Scale

/// 8pt-grid spacing values. Use the T-shirt aliases (xs/sm/md/lg…) for
/// generic layout gaps and the named component constants for specific contexts.
enum Spacing {

    // Base unit
    static let base: CGFloat = 8

    // Scale (multiples/fractions of base)
    static let xxs:  CGFloat = 2
    static let xs:   CGFloat = 4
    static let sm:   CGFloat = 8
    static let md:   CGFloat = 12
    static let lg:   CGFloat = 16
    static let xl:   CGFloat = 20
    static let xxl:  CGFloat = 24
    static let xxxl: CGFloat = 32

    // MARK: - Component Constants

    static let cellPadding:    CGFloat = 16
    static let sectionSpacing: CGFloat = 24
    static let contentMargin:  CGFloat = 16   // horizontal page margin
    static let cardPadding:    CGFloat = 12
    static let buttonPadding:  CGFloat = 16

    static let iconSmall:  CGFloat = 16
    static let iconMedium: CGFloat = 24
    static let iconLarge:  CGFloat = 32

    // MARK: - Touch Targets

    /// 44 pt minimum per Apple HIG
    static let minTouchTarget: CGFloat = 44
    static let buttonHeight:    CGFloat = 50
    static let textFieldHeight: CGFloat = 44

    // MARK: - Corner Radii

    static let cornerRadiusSmall:  CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge:  CGFloat = 16
    static let cornerRadiusXL:     CGFloat = 20

    // MARK: - Grid / Collection View

    static let gridItemSpacing:   CGFloat = 12
    static let gridLineSpacing:   CGFloat = 16
    static let gridSectionInset:  CGFloat = 16
}

// MARK: - UIEdgeInsets Presets

extension UIEdgeInsets {

    static var contentInsets: UIEdgeInsets {
        UIEdgeInsets(top: Spacing.lg, left: Spacing.contentMargin,
                     bottom: Spacing.lg, right: Spacing.contentMargin)
    }

    static var cardInsets: UIEdgeInsets {
        UIEdgeInsets(top: Spacing.cardPadding, left: Spacing.cardPadding,
                     bottom: Spacing.cardPadding, right: Spacing.cardPadding)
    }

    static var cellInsets: UIEdgeInsets {
        UIEdgeInsets(top: Spacing.cellPadding, left: Spacing.cellPadding,
                     bottom: Spacing.cellPadding, right: Spacing.cellPadding)
    }
}
