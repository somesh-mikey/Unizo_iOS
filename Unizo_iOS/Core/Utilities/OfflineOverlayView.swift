//
//  OfflineOverlayView.swift
//  Unizo_iOS
//
//  Full-screen offline state overlay (Zepto-style).
//  Added to a VC's view, NOT the window, so users can still switch tabs.
//

import UIKit

final class OfflineOverlayView: UIView {

    // MARK: - Callback

    var onRetry: (() -> Void)?

    // MARK: - Subviews

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(
            systemName: "wifi.slash",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 80, weight: .thin)
        )
        iv.tintColor = .systemGray3
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isAccessibilityElement = false // decorative
        return iv
    }()

    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.text = "No Internet Connection".localized
        label.font = UIFont.preferredFont(forTextStyle: .title2).withBoldTrait()
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityTraits = .header
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Please check your connection and try again.".localized
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let retryButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Try Again".localized, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        btn.titleLabel?.adjustsFontForContentSizeCategory = true
        btn.backgroundColor = UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1)
        btn.layer.cornerRadius = 25
        btn.translatesAutoresizingMaskIntoConstraints = false

        // Accessibility
        btn.accessibilityLabel = "Try Again".localized
        btn.accessibilityHint = "Checks for internet connection and reloads content".localized
        btn.accessibilityTraits = .button
        return btn
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupView() {
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [iconImageView, headlineLabel, subtitleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        addSubview(retryButton)
        addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            // Center the content stack vertically, slightly above true center
            stack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),

            // Icon size
            iconImageView.widthAnchor.constraint(equalToConstant: 100),
            iconImageView.heightAnchor.constraint(equalToConstant: 100),

            // Retry button below the stack
            retryButton.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 32),
            retryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            retryButton.widthAnchor.constraint(equalToConstant: 200),
            retryButton.heightAnchor.constraint(equalToConstant: 50),

            // Activity indicator centered below retry
            activityIndicator.topAnchor.constraint(equalTo: retryButton.bottomAnchor, constant: 16),
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)

        // Tap animation
        retryButton.addTarget(self, action: #selector(retryTouchDown), for: .touchDown)
        retryButton.addTarget(self, action: #selector(retryTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    // MARK: - Retry Actions

    @objc private func retryTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        // Check if still offline before calling retry
        if !NetworkMonitor.shared.isReachable() {
            // Shake animation to indicate still offline
            shakeRetryButton()
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return
        }

        onRetry?()
    }

    @objc private func retryTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.retryButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc private func retryTouchUp() {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.8,
            options: [],
            animations: {
                self.retryButton.transform = .identity
            }
        )
    }

    private func shakeRetryButton() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.duration = 0.4
        animation.values = [-8, 8, -6, 6, -3, 3, 0]
        retryButton.layer.add(animation, forKey: "shake")
    }

    // MARK: - Show / Dismiss

    /// Shows the overlay in a view controller's view.
    func show(in parentView: UIView, animated: Bool = true) {
        guard superview == nil else { return } // already shown

        parentView.addSubview(self)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parentView.topAnchor),
            bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor)
        ])

        if animated {
            alpha = 0
            UIView.animate(withDuration: 0.25) {
                self.alpha = 1
            }
        }

        // VoiceOver: announce the offline state
        UIAccessibility.post(notification: .screenChanged, argument: headlineLabel)
    }

    /// Dismisses the overlay with optional animation.
    func dismiss(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 0
            }, completion: { _ in
                self.removeFromSuperview()
            })
        } else {
            removeFromSuperview()
        }
    }

    /// Shows a loading state on the retry button.
    func showLoading() {
        retryButton.isEnabled = false
        retryButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
    }

    /// Hides the loading state.
    func hideLoading() {
        retryButton.isEnabled = true
        retryButton.setTitle("Try Again".localized, for: .normal)
        activityIndicator.stopAnimating()
    }
}

// MARK: - UIFont Helper

private extension UIFont {
    func withBoldTrait() -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(.traitBold) else { return self }
        return UIFont(descriptor: descriptor, size: 0)
    }
}
