//
//  AccountViewController.swift
//  Unizo_iOS
//

import UIKit

class AccountViewController: UIViewController {

    // MARK: - ScrollView & Content View

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - UI Components

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Account"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()

    private let profileImageView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = 35
        img.clipsToBounds = true
        img.image = UIImage(named: "nishtha")
        img.contentMode = .scaleAspectFill
        return img
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Nishtha"
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "ng7389@srmist.edu.in"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()

    // MARK: - Feature Buttons Section (with teal backgrounds)

    private let featureContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.85, green: 0.96, blue: 0.98, alpha: 1)
        v.layer.cornerRadius = 30

        // ADD SHADOW HERE
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.25
        v.layer.shadowRadius = 18
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.masksToBounds = false

        return v
    }()


    private func makeFeatureItem(icon: String, title: String) -> UIStackView {

        // Background circle (#74E7DA)
        let bgView = UIView()
        bgView.backgroundColor = UIColor(red: 0.454, green: 0.906, blue: 0.855, alpha: 1)
        bgView.layer.cornerRadius = 22
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.widthAnchor.constraint(equalToConstant: 65).isActive = true
        bgView.heightAnchor.constraint(equalToConstant: 65).isActive = true

        // Icon (BLACK)
        let imageView = UIImageView(image: UIImage(systemName: icon))
        imageView.tintColor = .black         // ← FIXED HERE
        imageView.contentMode = .scaleAspectFit

        bgView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: bgView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: bgView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 26),
            imageView.heightAnchor.constraint(equalToConstant: 26)
        ])

        // Label (BLACK)
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black             // ← FIXED HERE
        label.textAlignment = .center
        label.numberOfLines = 2

        // Stack
        let stack = UIStackView(arrangedSubviews: [bgView, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        stack.isUserInteractionEnabled = true

        return stack
    }

    private lazy var itemPayments = makeFeatureItem(icon: "creditcard", title: "Payments")
    private lazy var itemTickets = makeFeatureItem(icon: "ticket", title: "Event\nTickets")
    private lazy var itemDashboard = makeFeatureItem(icon: "chart.bar", title: "Seller\nDashboard")

    private let featureStack: UIStackView = {
        let st = UIStackView()
        st.axis = .horizontal
        st.distribution = .equalSpacing
        st.alignment = .center
        st.spacing = 20
        return st
    }()

    // MARK: - Settings Section Labels

    private let generalSettingsLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "General Settings"
        lbl.font = .systemFont(ofSize: 18, weight: .bold)
        return lbl
    }()

    private let otherSettingsLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Other"
        lbl.font = .systemFont(ofSize: 18, weight: .bold)
        return lbl
    }()

    // MARK: - Settings Rows

    private func makeRow(title: String, action: Selector) -> UIView {
        let container = UIView()

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 16)

        let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrow.tintColor = .lightGray

        container.addSubview(label)
        container.addSubview(arrow)

        label.translatesAutoresizingMaskIntoConstraints = false
        arrow.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            arrow.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            arrow.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        container.isUserInteractionEnabled = true
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))

        return container
    }

    private lazy var rowMyOrders = makeRow(title: "My Orders", action: #selector(openOrders))
    private lazy var rowProfile = makeRow(title: "My Profile", action: #selector(openProfile))
    private lazy var rowAddress = makeRow(title: "My Address", action: #selector(openAddress))
    private lazy var rowNotifications = makeRow(title: "Notifications", action: #selector(openNotifications))

    private lazy var rowTerms = makeRow(title: "Terms & Conditions", action: #selector(openTerms))
    private lazy var rowPrivacy = makeRow(title: "Privacy Policy", action: #selector(openPrivacy))
    private lazy var rowSettings = makeRow(title: "Settings", action: #selector(openSettings))

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGray6
        setupUI()
        setupConstraints()
    }

    // MARK: - Setup UI

    private func setupUI() {

        // Scroll setup
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Main components
        contentView.addSubview(titleLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)

        contentView.addSubview(featureContainer)
        featureContainer.addSubview(featureStack)

        featureStack.addArrangedSubview(itemPayments)
        itemPayments.isUserInteractionEnabled = true
        itemPayments.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(openPayments))
        )
        featureStack.addArrangedSubview(itemTickets)
        itemTickets.isUserInteractionEnabled = true
        itemTickets.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openEvents)))
        featureStack.addArrangedSubview(itemDashboard)
        itemDashboard.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(openSellerDashboard))
        )

        contentView.addSubview(generalSettingsLabel)
        contentView.addSubview(rowMyOrders)
        contentView.addSubview(rowProfile)
        contentView.addSubview(rowAddress)
        contentView.addSubview(rowNotifications)

        contentView.addSubview(otherSettingsLabel)
        contentView.addSubview(rowTerms)
        contentView.addSubview(rowPrivacy)
        contentView.addSubview(rowSettings)
    }

    // MARK: - Constraints

    private func setupConstraints() {

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

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

        // All other constraints
        [
            titleLabel, profileImageView, nameLabel, emailLabel,
            featureContainer, featureStack,
            generalSettingsLabel, rowMyOrders, rowProfile, rowAddress, rowNotifications,
            otherSettingsLabel, rowTerms, rowPrivacy, rowSettings
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            profileImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),

            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 5),

            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),

            featureContainer.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 35),
            featureContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            featureContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            featureContainer.heightAnchor.constraint(equalToConstant: 150),

            featureStack.centerXAnchor.constraint(equalTo: featureContainer.centerXAnchor),
            featureStack.centerYAnchor.constraint(equalTo: featureContainer.centerYAnchor),
            featureStack.leadingAnchor.constraint(equalTo: featureContainer.leadingAnchor, constant: 30),
            featureStack.trailingAnchor.constraint(equalTo: featureContainer.trailingAnchor, constant: -30),

            // Raise Payments button slightly
            itemPayments.topAnchor.constraint(equalTo: featureStack.topAnchor, constant: 0),

            generalSettingsLabel.topAnchor.constraint(equalTo: featureContainer.bottomAnchor, constant: 40),
            generalSettingsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            rowMyOrders.topAnchor.constraint(equalTo: generalSettingsLabel.bottomAnchor, constant: 18),
            rowMyOrders.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 36),
            rowMyOrders.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            rowMyOrders.heightAnchor.constraint(equalToConstant: 45),

            rowProfile.topAnchor.constraint(equalTo: rowMyOrders.bottomAnchor, constant: 12),
            rowProfile.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 36),
            rowProfile.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            rowProfile.heightAnchor.constraint(equalToConstant: 45),

            rowAddress.topAnchor.constraint(equalTo: rowProfile.bottomAnchor, constant: 12),
            rowAddress.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 36),
            rowAddress.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            rowAddress.heightAnchor.constraint(equalToConstant: 45),

            rowNotifications.topAnchor.constraint(equalTo: rowAddress.bottomAnchor, constant: 12),
            rowNotifications.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 36),
            rowNotifications.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            rowNotifications.heightAnchor.constraint(equalToConstant: 45),


            otherSettingsLabel.topAnchor.constraint(equalTo: rowNotifications.bottomAnchor, constant: 35),
            otherSettingsLabel.leadingAnchor.constraint(equalTo: generalSettingsLabel.leadingAnchor),

            rowTerms.topAnchor.constraint(equalTo: otherSettingsLabel.bottomAnchor, constant: 18),
            rowTerms.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 36),
            rowTerms.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            rowTerms.heightAnchor.constraint(equalToConstant: 45),

            rowPrivacy.topAnchor.constraint(equalTo: rowTerms.bottomAnchor, constant: 12),
            rowPrivacy.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 36),
            rowPrivacy.trailingAnchor.constraint(equalTo: rowTerms.trailingAnchor),
            rowPrivacy.heightAnchor.constraint(equalToConstant: 45),

            rowSettings.topAnchor.constraint(equalTo: rowPrivacy.bottomAnchor, constant: 12),
            rowSettings.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 36),
            rowSettings.trailingAnchor.constraint(equalTo: rowPrivacy.trailingAnchor),
            rowSettings.heightAnchor.constraint(equalToConstant: 45),
            rowSettings.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    // MARK: - Navigation Actions

    @objc private func openOrders()
    {
            let vc = MyOrdersViewController()

            // IF inside Navigation Controller → PUSH
            if let nav = navigationController {
                nav.pushViewController(vc, animated: true)
                return
            }

            // ELSE present modally
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .coverVertical
            present(vc, animated: true)
    }
    
    @objc private func openProfile()
    {
        let vc = ProfileViewController()

            // If inside Navigation Controller → PUSH
            if let nav = navigationController {
                nav.pushViewController(vc, animated: true)
                return
            }

            // Otherwise → present full screen
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .coverVertical
            present(vc, animated: true)
    }
    @objc private func openAddress()
    {
            
        let vc = AddressViewController()
        vc.flowSource = .fromAccount
        // CASE 1 — If inside NavigationController → push
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
            return
        }

        // CASE 2 — Presented modally → present full screen
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true)
    }
    @objc private func openNotifications()
    {
        let vc = NotificationsViewController()

            // If inside a Navigation Controller → PUSH
            if let nav = navigationController {
                nav.pushViewController(vc, animated: true)
                return
            }

            // If NOT inside Navigation Controller → PRESENT
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .coverVertical
            present(vc, animated: true)
    }

    @objc private func openTerms()
    {
        let vc = TermsAndConditionsViewController()

            if let nav = navigationController {
                nav.pushViewController(vc, animated: true)
                return
            }

            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .coverVertical
            present(vc, animated: true)
    }
    @objc private func openPrivacy()
    {
        let vc = PrivacyPolicyViewController()
        
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
            return
        }
        
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true)
    }
    @objc private func openSettings()
    {
        let vc = SettingsViewController()

            if let nav = navigationController {
                nav.pushViewController(vc, animated: true)
                return
            }

            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .coverVertical
            present(vc, animated: true)
    }
    @objc private func openSellerDashboard() {
        let vc = SellerDashboardViewController()

        // If inside a Navigation Controller → PUSH
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
            return
        }

        // Else → PRESENT modally
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true)
    }
    @objc private func openEvents() {
        let vc = BrowseEventsViewController() // your target VC

        // If the Account screen is inside a navigation controller -> push
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
            return
        }

        // Otherwise present modally full screen
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true)
    }
    @objc private func openPayments() {
        let vc = PaymentsViewController()

        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
            return
        }

        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true)
    }
}
