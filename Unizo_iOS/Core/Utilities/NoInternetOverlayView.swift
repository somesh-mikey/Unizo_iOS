//
//  NoInternetOverlayView.swift
//  Unizo_iOS
//
//  Full-screen overlay that blocks the app when there is no internet.
//  Displays a centered "No Internet Connection" message with a "Try Again"
//  button that makes a real network request to verify connectivity.
//

import UIKit

final class NoInternetOverlayView: UIView {

    // MARK: - Constants

    private static let overlayTag = 99997

    /// App teal colour used throughout the app
    private static let tealColor = UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1)

    // MARK: - Notification posted when internet is restored so screens can refresh
    static let internetRestoredNotification = Notification.Name("NoInternetOverlay_InternetRestored")

    // MARK: - Subviews

    private let wifiIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 48, weight: .medium)
        let iv = UIImageView(image: UIImage(systemName: "wifi.slash", withConfiguration: config))
        iv.tintColor = .secondaryLabel
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "No Internet Connection"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Your device is not connected to the internet. Please check your Wi-Fi or mobile data and try again."
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tryAgainButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Try Again", for: .normal)
        btn.setTitleColor(
            UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1),
            for: .normal
        )
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .medium)
        s.hidesWhenStopped = true
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    // MARK: - Init

    private override init(frame: CGRect) {
        super.init(frame: frame)
        tag = NoInternetOverlayView.overlayTag
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private func setupSubviews() {
        let stack = UIStackView(arrangedSubviews: [wifiIcon, titleLabel, descriptionLabel, tryAgainButton, spinner])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.setCustomSpacing(24, after: wifiIcon)
        stack.setCustomSpacing(12, after: descriptionLabel)

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),

            wifiIcon.widthAnchor.constraint(equalToConstant: 56),
            wifiIcon.heightAnchor.constraint(equalToConstant: 56),
        ])

        tryAgainButton.addTarget(self, action: #selector(tryAgainTapped), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func tryAgainTapped() {
        tryAgainButton.isHidden = true
        spinner.startAnimating()

        Task {
            let isOnline = await NoInternetOverlayView.pingNetwork()

            await MainActor.run { [weak self] in
                self?.spinner.stopAnimating()
                self?.tryAgainButton.isHidden = false

                if isOnline {
                    NoInternetOverlayView.hide(from: self?.window)
                } else {
                    let haptic = UINotificationFeedbackGenerator()
                    haptic.notificationOccurred(.error)
                    self?.titleLabel.shake()
                }
            }
        }
    }

    /// Makes a lightweight HEAD request to Apple's captive portal endpoint
    /// to verify actual internet connectivity.
    private static func pingNetwork() async -> Bool {
        guard let url = URL(string: "https://captive.apple.com/hotspot-detect.html") else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 5
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse {
                return http.statusCode == 200
            }
            return false
        } catch {
            return false
        }
    }

    // MARK: - Find MainTabBarController

    /// Recursively searches the VC hierarchy for MainTabBarController.
    /// Handles all cases: rootVC, children, presented VCs.
    private static func findTabBarController(from window: UIWindow) -> MainTabBarController? {
        return findTabBar(from: window.rootViewController)
    }

    private static func findTabBar(from vc: UIViewController?) -> MainTabBarController? {
        guard let vc = vc else { return nil }

        // Direct match
        if let tabBar = vc as? MainTabBarController {
            return tabBar
        }

        // Check children (e.g. container VCs)
        for child in vc.children {
            if let found = findTabBar(from: child) {
                return found
            }
        }

        // Check presented VCs
        if let presented = vc.presentedViewController {
            if let found = findTabBar(from: presented) {
                return found
            }
        }

        return nil
    }

    // MARK: - Show / Hide

    static func show(in window: UIWindow) {
        dispatchPrecondition(condition: .onQueue(.main))

        // Already showing — but ensure it's on top
        if let existing = window.viewWithTag(overlayTag) {
            window.bringSubviewToFront(existing)
            return
        }

        // Hide the tab bar (walk the full VC tree to find it)
        if let tabVC = findTabBarController(from: window) {
            tabVC.tabBar.isHidden = true
        }

        let overlay = NoInternetOverlayView(frame: .zero)
        window.addSubview(overlay)

        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: window.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: window.bottomAnchor),
        ])

        // Force it above everything (tab bar, banners, etc.)
        overlay.layer.zPosition = 9999
        window.bringSubviewToFront(overlay)

        // Fade in
        overlay.alpha = 0
        UIView.animate(withDuration: 0.25) {
            overlay.alpha = 1
        }

        let haptic = UINotificationFeedbackGenerator()
        haptic.notificationOccurred(.warning)
    }

    static func hide(from window: UIWindow?) {
        guard let window = window else { return }
        dispatchPrecondition(condition: .onQueue(.main))

        guard let overlay = window.viewWithTag(overlayTag) else { return }

        // Restore the tab bar
        if let tabVC = findTabBarController(from: window) {
            tabVC.tabBar.isHidden = false
        }

        UIView.animate(withDuration: 0.25, animations: {
            overlay.alpha = 0
        }, completion: { _ in
            overlay.removeFromSuperview()

            // Notify the app that internet is back so screens can refresh their data
            NotificationCenter.default.post(
                name: NoInternetOverlayView.internetRestoredNotification,
                object: nil
            )
        })
    }
}

// MARK: - Shake Animation Helper

private extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.5
        animation.values = [-8, 8, -6, 6, -4, 4, -2, 2, 0]
        layer.add(animation, forKey: "shake")
    }
}
