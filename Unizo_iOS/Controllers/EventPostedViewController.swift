//
//  EventPostedViewController.swift
//  Unizo_iOS
//

import UIKit

class EventPostedViewController: UIViewController {

    // MARK: - UI Elements
    private let iconContainer = UIView()
    private let iconImageView = UIImageView()
    private let dottedLinesView = UIImageView()

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let viewEventsButton = UIButton()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.14, green: 0.42, blue: 0.53, alpha: 1.0)
        navigationItem.hidesBackButton = true

        setupIcon()
        setupText()
        setupButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        (tabBarController as? MainTabBarController)?.hideFloatingTabBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        (tabBarController as? MainTabBarController)?.showFloatingTabBar()
    }

    // MARK: - Icon Setup

    private func setupIcon() {
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iconContainer)

        NSLayoutConstraint.activate([
            iconContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120),
            iconContainer.widthAnchor.constraint(equalToConstant: 180),
            iconContainer.heightAnchor.constraint(equalToConstant: 180)
        ])

        // Dotted lines
        dottedLinesView.image = UIImage(named: "dotted-lines") ?? UIImage()
        dottedLinesView.contentMode = .scaleAspectFit
        dottedLinesView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(dottedLinesView)

        NSLayoutConstraint.activate([
            dottedLinesView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            dottedLinesView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            dottedLinesView.widthAnchor.constraint(equalToConstant: 160),
            dottedLinesView.heightAnchor.constraint(equalToConstant: 160)
        ])

        // Calendar checkmark icon
        iconImageView.image = UIImage(systemName: "calendar.badge.checkmark")
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconImageView)

        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 100),
            iconImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    // MARK: - Text Setup

    private func setupText() {
        titleLabel.text = "Your Event has been posted!".localized
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        subtitleLabel.text = "Users can now discover and register for your event.".localized
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = UIColor(white: 1.0, alpha: 0.8)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
        ])
    }

    // MARK: - Button Setup

    private func setupButton() {
        viewEventsButton.setTitle("View Events".localized, for: .normal)
        viewEventsButton.backgroundColor = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1.0)
        viewEventsButton.layer.cornerRadius = 26
        viewEventsButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        viewEventsButton.translatesAutoresizingMaskIntoConstraints = false
        viewEventsButton.addTarget(self, action: #selector(openEvents), for: .touchUpInside)

        view.addSubview(viewEventsButton)

        NSLayoutConstraint.activate([
            viewEventsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            viewEventsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            viewEventsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -35),
            viewEventsButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }

    // MARK: - Navigation

    @objc private func openEvents() {
        // Navigate to BrowseEventsViewController
        if let navController = navigationController {
            // Pop back to the PostChooser root, then push Browse Events
            let browseVC = BrowseEventsViewController()
            var stack = navController.viewControllers
            // Remove everything after root (PostChooser)
            if let rootIndex = stack.firstIndex(where: { $0 is PostChooserViewController }) {
                stack = Array(stack[...rootIndex])
            }
            stack.append(browseVC)
            navController.setViewControllers(stack, animated: true)
        }
    }
}
