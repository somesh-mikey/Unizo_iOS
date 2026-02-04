//
//  OrderAcceptedViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 21/11/25.
//

import UIKit

class OrderAcceptedViewController: UIViewController {

    // MARK: - Data passed from ConfirmOrderSellerVC
    var orderId: UUID?
    var buyerName: String?

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let backButton = UIButton(type: .system)
    private let iconCircle = UIView()
    private let bagImage = UIImageView()

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let viewOrderButton = UIButton(type: .system)
    private let viewListingsButton = UIButton(type: .system)

    private let primaryTeal = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1.0)
    private let borderTeal = UIColor(red: 0.00, green: 0.62, blue: 0.71, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 1.0, alpha: 1.0)

        setupScroll()
        setupBackButton()
        setupIllustration()
        setupLabels()
        setupButtons()

        // 👉 Add button targets
        viewOrderButton.addTarget(self, action: #selector(openOrderDetails), for: .touchUpInside)
        viewListingsButton.addTarget(self, action: #selector(goToListings), for: .touchUpInside)

        // Update subtitle with real buyer name if available
        if let name = buyerName, !name.isEmpty {
            subtitleLabel.text = "\(name)'s order has been successfully\naccepted."
        }
    }

    // MARK: - Hide Tab Bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = false

        // Restore floating tab bar frame
        if let mainTab = tabBarController as? MainTabBarController {
        }
    }

    // MARK: - Scroll View
    private func setupScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    // MARK: - Back Button
    private func setupBackButton() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .black
        backButton.backgroundColor = .white
        backButton.layer.cornerRadius = 22
        backButton.layer.shadowOpacity = 0.1
        backButton.layer.shadowRadius = 4
        backButton.layer.shadowOffset = CGSize(width: 0, height: 2)

        backButton.addTarget(self, action: #selector(backPressed), for: .touchUpInside)

        contentView.addSubview(backButton)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func backPressed() {
        // Navigate to home screen instead of back to ConfirmOrderSellerVC
        navigateToHome()
    }

    private func navigateToHome() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            let tab = MainTabBarController()
            tab.selectedIndex = 0 // Home tab
            window.rootViewController = tab
            window.makeKeyAndVisible()
        }
    }

    // MARK: - Illustration
    private func setupIllustration() {
        iconCircle.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.backgroundColor = UIColor(red: 0.87, green: 0.94, blue: 0.98, alpha: 1.0)
        iconCircle.layer.cornerRadius = 60

        bagImage.translatesAutoresizingMaskIntoConstraints = false
        bagImage.image = UIImage(systemName: "bag")
        bagImage.tintColor = primaryTeal
        bagImage.contentMode = .scaleAspectFit

        contentView.addSubview(iconCircle)
        iconCircle.addSubview(bagImage)

        NSLayoutConstraint.activate([
            iconCircle.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 60),
            iconCircle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconCircle.widthAnchor.constraint(equalToConstant: 120),
            iconCircle.heightAnchor.constraint(equalToConstant: 120),

            bagImage.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            bagImage.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor),
            bagImage.widthAnchor.constraint(equalToConstant: 50),
            bagImage.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Labels
    private func setupLabels() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Order Accepted!"
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textAlignment = .center

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        // Will be updated with real buyer name in viewDidLoad
        subtitleLabel.text = "The order has been successfully\naccepted."
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: iconCircle.bottomAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }

    // MARK: - Buttons
    private func setupButtons() {

        viewOrderButton.translatesAutoresizingMaskIntoConstraints = false
        viewOrderButton.setTitle("View Order Detail", for: .normal)
        viewOrderButton.backgroundColor = primaryTeal
        viewOrderButton.setTitleColor(.white, for: .normal)
        viewOrderButton.layer.cornerRadius = 26
        viewOrderButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        viewListingsButton.translatesAutoresizingMaskIntoConstraints = false
        viewListingsButton.setTitle("View Listings", for: .normal)
        viewListingsButton.setTitleColor(primaryTeal, for: .normal)
        viewListingsButton.layer.borderWidth = 2
        viewListingsButton.layer.borderColor = primaryTeal.cgColor
        viewListingsButton.layer.cornerRadius = 26
        viewListingsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        contentView.addSubview(viewOrderButton)
        contentView.addSubview(viewListingsButton)

        NSLayoutConstraint.activate([
            viewOrderButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            viewOrderButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            viewOrderButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            viewOrderButton.heightAnchor.constraint(equalToConstant: 52),

            viewListingsButton.topAnchor.constraint(equalTo: viewOrderButton.bottomAnchor, constant: 18),
            viewListingsButton.leadingAnchor.constraint(equalTo: viewOrderButton.leadingAnchor),
            viewListingsButton.trailingAnchor.constraint(equalTo: viewOrderButton.trailingAnchor),
            viewListingsButton.heightAnchor.constraint(equalToConstant: 52),
            viewListingsButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -80)
        ])
    }

    // MARK: - Navigation Actions
    @objc private func openOrderDetails() {
        let vc = OrderDetailsViewController()
        vc.orderId = self.orderId  // Pass orderId for real data loading

        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
            return
        }

        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    @objc private func goToListings() {
        // Navigate to Listings tab (index 3) via fresh MainTabBarController
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            let tab = MainTabBarController()
            tab.selectedIndex = 3 // Listings tab
            window.rootViewController = tab
            window.makeKeyAndVisible()
        }
    }
}
