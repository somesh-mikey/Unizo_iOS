//
//  UnizoBannerView.swift
//  Unizo_iOS
//
//  iOS-native pill banner for connectivity status.
//  Replaces NoInternetBannerView with Swiggy-style pill design.
//

import UIKit

final class UnizoBannerView: UIView {

    // MARK: - State

    enum State {
        case offline
        case online
    }

    // MARK: - Constants

    private static let bannerTag = 99998
    private static var dismissWorkItem: DispatchWorkItem?

    // MARK: - Subviews

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote).withTraits(.traitBold)
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    private init(state: State) {
        super.init(frame: .zero)
        tag = UnizoBannerView.bannerTag
        translatesAutoresizingMaskIntoConstraints = false

        configure(for: state)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    private func configure(for state: State) {
        switch state {
        case .offline:
            backgroundColor = .systemGray5
            iconImageView.image = UIImage(
                systemName: "wifi.slash",
                withConfiguration: UIImage.SymbolConfiguration(weight: .medium)
            )
            iconImageView.tintColor = .secondaryLabel
            messageLabel.text = "No Internet Connection".localized
            messageLabel.textColor = .label
            isAccessibilityElement = true
            accessibilityLabel = "No internet connection".localized
            accessibilityTraits = .staticText

        case .online:
            backgroundColor = UIColor.systemGreen.withAlphaComponent(0.9)
            iconImageView.image = UIImage(
                systemName: "wifi",
                withConfiguration: UIImage.SymbolConfiguration(weight: .medium)
            )
            iconImageView.tintColor = .white
            messageLabel.text = "Back Online".localized
            messageLabel.textColor = .white
            isAccessibilityElement = true
            accessibilityLabel = "Back online".localized
            accessibilityTraits = .staticText
        }
    }

    private func setupSubviews() {
        // Pill shape
        layer.cornerRadius = 20 // height/2 for 40pt pill
        layer.masksToBounds = true

        // Shadow for depth (iOS-native floating pill look)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        layer.masksToBounds = false

        addSubview(iconImageView)
        addSubview(messageLabel)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18),

            messageLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // MARK: - Show

    static func show(in window: UIWindow, state: State) {
        dispatchPrecondition(condition: .onQueue(.main))

        // Cancel any pending dismiss timer
        dismissWorkItem?.cancel()
        dismissWorkItem = nil

        // Remove any existing banner (handles offline→online transitions & race conditions)
        if let existing = window.viewWithTag(bannerTag) {
            existing.removeFromSuperview()
        }

        let banner = UnizoBannerView(state: state)
        window.addSubview(banner)

        // Safe area top offset with fallback for early-layout scenarios
        let safeTop = window.safeAreaInsets.top > 0
            ? window.safeAreaInsets.top
            : (window.windowScene?.statusBarManager?.statusBarFrame.height ?? 44)

        NSLayoutConstraint.activate([
            banner.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            banner.topAnchor.constraint(equalTo: window.topAnchor, constant: safeTop + 8),
            banner.heightAnchor.constraint(equalToConstant: 40),
            // Intrinsic width with max 80% of screen
            banner.widthAnchor.constraint(lessThanOrEqualTo: window.widthAnchor, multiplier: 0.8)
        ])

        // Start off-screen above the top edge
        banner.transform = CGAffineTransform(translationX: 0, y: -(safeTop + 60))
        banner.alpha = 0

        // Spring animation in (iOS-native)
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.8,
            options: [.curveEaseOut],
            animations: {
                banner.transform = .identity
                banner.alpha = 1
            }
        )

        // Haptic feedback
        let haptic = UINotificationFeedbackGenerator()
        haptic.notificationOccurred(state == .offline ? .warning : .success)

        // Auto-dismiss for online state
        if state == .online {
            let workItem = DispatchWorkItem { [weak window] in
                guard let window = window else { return }
                UnizoBannerView.hide(from: window)
            }
            dismissWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: workItem)
        }
    }

    // MARK: - Hide

    static func hide(from window: UIWindow) {
        dispatchPrecondition(condition: .onQueue(.main))

        dismissWorkItem?.cancel()
        dismissWorkItem = nil

        guard let banner = window.viewWithTag(bannerTag) else { return }

        let safeTop = window.safeAreaInsets.top > 0
            ? window.safeAreaInsets.top
            : (window.windowScene?.statusBarManager?.statusBarFrame.height ?? 44)

        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.5,
            options: [.curveEaseIn],
            animations: {
                banner.transform = CGAffineTransform(translationX: 0, y: -(safeTop + 60))
                banner.alpha = 0
            },
            completion: { _ in
                banner.removeFromSuperview()
            }
        )
    }
}

// MARK: - UIFont Helper

private extension UIFont {
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else { return self }
        return UIFont(descriptor: descriptor, size: 0)
    }
}
