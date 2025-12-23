//
//  UISegmentedControl.swift
//  Unizo_iOS
//
//  Created by Somesh on 24/12/25.
//

import UIKit

extension UISegmentedControl {

    func applyPrimarySegmentStyle() {
        // Default selected index
        selectedSegmentIndex = 0

        // Selected segment background
        selectedSegmentTintColor = UIColor(
            red: 0.239, green: 0.486, blue: 0.596, alpha: 1
        ) // #3D7C98

        // Unselected text style
        setTitleTextAttributes([
            .foregroundColor: UIColor(
                red: 0.239, green: 0.486, blue: 0.596, alpha: 1
            ),
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)

        // Selected text style
        setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)
    }
}

