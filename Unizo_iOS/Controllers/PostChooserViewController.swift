//
//  PostChooserViewController.swift
//  Unizo_iOS
//

import UIKit

final class PostChooserViewController: UIViewController {

    // MARK: - UI Components

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Post".localized
        l.font = .systemFont(ofSize: 35, weight: .bold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Choose an option below to get started.".localized
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var itemCard: UIView = makeCard(
        icon: "tag.fill",
        title: "Post an Item".localized,
        subtitle: "List a product for sale on the marketplace.".localized
    )

    private lazy var eventCard: UIView = makeCard(
        icon: "calendar.badge.plus",
        title: "Post an Event".localized,
        subtitle: "Create a campus event for others to discover.".localized
    )

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavBar()
        setupLayout()
        addCardActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        (tabBarController as? MainTabBarController)?.showFloatingTabBar()
        tabBarController?.tabBar.isHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Navigation Bar

    private func setupNavBar() {
        navigationItem.title = "Post".localized
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(itemCard)
        view.addSubview(eventCard)

        itemCard.translatesAutoresizingMaskIntoConstraints = false
        eventCard.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 75),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            // Item Card
            itemCard.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
            itemCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            itemCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            itemCard.heightAnchor.constraint(equalToConstant: 120),

            // Event Card
            eventCard.topAnchor.constraint(equalTo: itemCard.bottomAnchor, constant: 16),
            eventCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            eventCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            eventCard.heightAnchor.constraint(equalToConstant: 120),
        ])

        // Accessibility
        titleLabel.accessibilityTraits = .header
        subtitleLabel.accessibilityTraits = .staticText
        itemCard.isAccessibilityElement = true
        itemCard.accessibilityLabel = "Post an Item".localized
        itemCard.accessibilityHint = "List a product for sale on the marketplace".localized
        itemCard.accessibilityTraits = .button
        eventCard.isAccessibilityElement = true
        eventCard.accessibilityLabel = "Post an Event".localized
        eventCard.accessibilityHint = "Create a campus event for others to discover".localized
        eventCard.accessibilityTraits = .button
    }

    // MARK: - Card Builder

    private func makeCard(icon: String, title: String, subtitle: String) -> UIView {

        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 8

        let iconBg = UIView()
        iconBg.backgroundColor = UIColor.brandPrimary.withAlphaComponent(0.12)
        iconBg.layer.cornerRadius = 24
        iconBg.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .brandPrimary
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLbl.textColor = .label
        titleLbl.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLbl = UILabel()
        subtitleLbl.text = subtitle
        subtitleLbl.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLbl.textColor = .secondaryLabel
        subtitleLbl.numberOfLines = 2
        subtitleLbl.translatesAutoresizingMaskIntoConstraints = false

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .tertiaryLabel
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(iconBg)
        iconBg.addSubview(iconView)
        card.addSubview(titleLbl)
        card.addSubview(subtitleLbl)
        card.addSubview(chevron)

        NSLayoutConstraint.activate([
            // Icon background circle
            iconBg.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            iconBg.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconBg.widthAnchor.constraint(equalToConstant: 48),
            iconBg.heightAnchor.constraint(equalToConstant: 48),

            // SF Symbol inside circle
            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            // Title
            titleLbl.topAnchor.constraint(equalTo: card.topAnchor, constant: 30),
            titleLbl.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 16),
            titleLbl.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),

            // Subtitle
            subtitleLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 4),
            subtitleLbl.leadingAnchor.constraint(equalTo: titleLbl.leadingAnchor),
            subtitleLbl.trailingAnchor.constraint(equalTo: titleLbl.trailingAnchor),

            // Chevron
            chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            chevron.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 14),
            chevron.heightAnchor.constraint(equalToConstant: 14),
        ])

        return card
    }

    // MARK: - Actions

    private func addCardActions() {
        let itemTap = UITapGestureRecognizer(target: self, action: #selector(itemCardTapped))
        itemCard.addGestureRecognizer(itemTap)
        itemCard.isUserInteractionEnabled = true

        let eventTap = UITapGestureRecognizer(target: self, action: #selector(eventCardTapped))
        eventCard.addGestureRecognizer(eventTap)
        eventCard.isUserInteractionEnabled = true
    }

    @objc private func itemCardTapped() {
        HapticFeedback.tabSelected()
        animateCardPress(itemCard) { [weak self] in
            let vc = PostItemViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc private func eventCardTapped() {
        HapticFeedback.tabSelected()
        animateCardPress(eventCard) { [weak self] in
            let vc = PostEventViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - Card Press Animation

    private func animateCardPress(_ card: UIView, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.08, animations: {
            card.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            card.alpha = 0.85
        }) { _ in
            UIView.animate(withDuration: 0.08, animations: {
                card.transform = .identity
                card.alpha = 1.0
            }) { _ in
                completion()
            }
        }
    }
}
