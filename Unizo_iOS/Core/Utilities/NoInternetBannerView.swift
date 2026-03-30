//
//  NoInternetBannerView.swift
//  Unizo_iOS
//
//  Displays a banner indicating no internet connectivity
//

import UIKit

final class NoInternetBannerView: UIView {

    private static let bannerTag = 99999

    // MARK: - Subviews

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "wifi.slash")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "No Internet Connection"
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup

    private func setupView() {
        tag = NoInternetBannerView.bannerTag
        backgroundColor = .systemOrange
        layer.cornerRadius = 12
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(iconImageView)
        addSubview(messageLabel)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),

            messageLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // MARK: - Show

    static func show(in window: UIWindow) {
        DispatchQueue.main.async {
            // Avoid adding duplicate banners
            if window.viewWithTag(bannerTag) != nil { return }

            let banner = NoInternetBannerView()
            window.addSubview(banner)

            let topInset = window.safeAreaInsets.top

            NSLayoutConstraint.activate([
                banner.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 16),
                banner.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -16),
                banner.topAnchor.constraint(equalTo: window.topAnchor, constant: topInset + 8),
                banner.heightAnchor.constraint(equalToConstant: 50)
            ])

            // Start off-screen above the top edge
            banner.transform = CGAffineTransform(translationX: 0, y: -(topInset + 70))
            banner.alpha = 0

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
        }
    }

    // MARK: - Hide

    static func hide(from window: UIWindow) {
        DispatchQueue.main.async {
            guard let banner = window.viewWithTag(bannerTag) as? NoInternetBannerView else { return }

            let topInset = window.safeAreaInsets.top

            UIView.animate(
                withDuration: 0.4,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0.5,
                options: [.curveEaseIn],
                animations: {
                    banner.transform = CGAffineTransform(translationX: 0, y: -(topInset + 70))
                    banner.alpha = 0
                },
                completion: { _ in
                    banner.removeFromSuperview()
                }
            )
        }
    }
}
