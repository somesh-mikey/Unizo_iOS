//
//  AccountViewController.swift
//  Unizo_iOS
//

import UIKit

final class AccountViewController: UIViewController {

    // MARK: - Data
    private let userRepository = UserRepository()
    private var currentUser: UserDTO?

    // MARK: - Scroll
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - Header
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Account"
        l.font = .systemFont(ofSize: 35, weight: .bold)
        return l
    }()

    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 35
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = UIColor.systemGray5
        // Default placeholder icon
        iv.image = UIImage(systemName: "person.circle.fill")
        iv.tintColor = UIColor.systemGray3
        return iv
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.text = "Loading..."
        l.font = .systemFont(ofSize: 22, weight: .semibold)
        return l
    }()

    private let emailLabel: UILabel = {
        let l = UILabel()
        l.text = ""
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        return l
    }()

    // MARK: - Feature Container (UPDATED)
    private let featureContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.83, green: 0.95, blue: 0.96, alpha: 1)
        v.layer.cornerRadius = 22

        // Subtle depth (almost flat like mockup)
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowRadius = 10
        v.layer.shadowOffset = CGSize(width: 0, height: 4)

        return v
    }()

    private let featureStack: UIStackView = {
        let st = UIStackView()
        st.axis = .horizontal
        st.distribution = .equalSpacing
        st.alignment = .top
        return st
    }()

    // MARK: - Section Labels
    private let generalLabel = AccountViewController.makeSectionLabel("General Settings")
    private let otherLabel = AccountViewController.makeSectionLabel("Other")

    // MARK: - Cards
    private let generalCard = AccountViewController.makeCard()
    private let otherCard = AccountViewController.makeCard()

    // MARK: - Rows
    private lazy var rowProfile = makeRow("My Profile", icon: "person", action: #selector(openProfile))
    private lazy var rowAddress = makeRow("My Hotspots", icon: "mappin.and.ellipse", action: #selector(openAddress))
    private lazy var rowNotifications = makeRow("Notifications", icon: "bell", action: #selector(openNotifications))

    private lazy var rowTerms = makeRow("Terms & Conditions", icon: "doc.text", action: #selector(openTerms))
    private lazy var rowPrivacy = makeRow("Privacy Policy", icon: "doc.text", action: #selector(openPrivacy))
    private lazy var rowSettings = makeRow("Settings", icon: "gearshape", action: #selector(openSettings))

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupUI()
        setupConstraints()
        loadUserData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload user data in case profile was updated
        loadUserData()
    }

    // MARK: - Load User Data
    private func loadUserData() {
        Task {
            do {
                let user = try await userRepository.fetchCurrentUser()
                await MainActor.run {
                    self.currentUser = user
                    self.updateUIWithUserData(user)
                }
            } catch {
                print("Failed to load user data:", error)
            }
        }
    }

    private func updateUIWithUserData(_ user: UserDTO?) {
        guard let user = user else {
            nameLabel.text = "Guest"
            emailLabel.text = "Not signed in"
            return
        }

        nameLabel.text = user.displayName
        emailLabel.text = user.email ?? ""

        // Load profile image if available
        if let imageUrlString = user.profile_image_url,
           let imageUrl = URL(string: imageUrlString) {
            loadProfileImage(from: imageUrl)
        } else {
            // Keep default placeholder
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = UIColor.systemGray3
        }
    }

    private func loadProfileImage(from url: URL) {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.profileImageView.image = image
                        self.profileImageView.tintColor = nil
                    }
                }
            } catch {
                print("Failed to load profile image:", error)
            }
        }
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Disable automatic content inset adjustment to remove extra space at top
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.clipsToBounds = true

        // All content including title is inside scrollView
        [
            titleLabel, profileImageView, nameLabel, emailLabel,
            featureContainer, generalLabel, generalCard,
            otherLabel, otherCard
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        featureContainer.addSubview(featureStack)
        featureStack.translatesAutoresizingMaskIntoConstraints = false

        featureStack.addArrangedSubview(makeFeatureItem("shippingbox", "Orders", #selector(openOrders)))
        featureStack.addArrangedSubview(makeFeatureItem("ticket", "Event Tickets", #selector(openEvents)))
        featureStack.addArrangedSubview(makeFeatureItem("chart.bar", "Seller Dashboard", #selector(openSellerDashboard)))

        addGroupedRows(
            rows: [rowProfile, rowAddress, rowNotifications],
            to: generalCard
        )

        addGroupedRows(
            rows: [rowTerms, rowPrivacy, rowSettings],
            to: otherCard
        )
    }

    // MARK: - Constraints
    private func setupConstraints() {

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 75),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            profileImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            featureContainer.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20),
            featureContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            featureContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            featureContainer.heightAnchor.constraint(equalToConstant: 120),

            featureStack.centerXAnchor.constraint(equalTo: featureContainer.centerXAnchor),
            featureStack.topAnchor.constraint(equalTo: featureContainer.topAnchor, constant: 16),
            featureStack.leadingAnchor.constraint(equalTo: featureContainer.leadingAnchor, constant: 24),
            featureStack.trailingAnchor.constraint(equalTo: featureContainer.trailingAnchor, constant: -24),

            generalLabel.topAnchor.constraint(equalTo: featureContainer.bottomAnchor, constant: 35),
            generalLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            generalCard.topAnchor.constraint(equalTo: generalLabel.bottomAnchor, constant: 12),
            generalCard.leadingAnchor.constraint(equalTo: featureContainer.leadingAnchor),
            generalCard.trailingAnchor.constraint(equalTo: featureContainer.trailingAnchor),

            otherLabel.topAnchor.constraint(equalTo: generalCard.bottomAnchor, constant: 30),
            otherLabel.leadingAnchor.constraint(equalTo: generalLabel.leadingAnchor),

            otherCard.topAnchor.constraint(equalTo: otherLabel.bottomAnchor, constant: 12),
            otherCard.leadingAnchor.constraint(equalTo: generalCard.leadingAnchor),
            otherCard.trailingAnchor.constraint(equalTo: generalCard.trailingAnchor),
            otherCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -120)
        ])
    }

    // MARK: - Helpers

    private static func makeSectionLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 18, weight: .bold)
        return l
    }

    private static func makeCard() -> UIView {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        return v
    }

    // MARK: - Feature Item (UPDATED)
    private func makeFeatureItem(_ icon: String, _ title: String, _ action: Selector) -> UIStackView {

        let bg = UIView()
        bg.backgroundColor = UIColor(red: 0.65, green: 0.91, blue: 0.96, alpha: 1)
        bg.layer.cornerRadius = 20
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.widthAnchor.constraint(equalToConstant: 56).isActive = true
        bg.heightAnchor.constraint(equalToConstant: 56).isActive = true

        let iv = UIImageView(image: UIImage(systemName: icon))
        iv.tintColor = UIColor(red: 0.03, green: 0.22, blue: 0.27, alpha: 1)
        iv.translatesAutoresizingMaskIntoConstraints = false
        bg.addSubview(iv)

        NSLayoutConstraint.activate([
            iv.centerXAnchor.constraint(equalTo: bg.centerXAnchor),
            iv.centerYAnchor.constraint(equalTo: bg.centerYAnchor),
            iv.widthAnchor.constraint(equalToConstant: 24),
            iv.heightAnchor.constraint(equalToConstant: 24)
        ])

        let lbl = UILabel()
        lbl.text = title
        lbl.font = .systemFont(ofSize: 13, weight: .medium)
        lbl.textAlignment = .center
        lbl.numberOfLines = 2

        let stack = UIStackView(arrangedSubviews: [bg, lbl])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        stack.isUserInteractionEnabled = true
        stack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))

        return stack
    }

    private func makeRow(_ title: String, icon: String, action: Selector) -> UIView {
        let row = UIView()

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = UIColor(red: 0.03, green: 0.22, blue: 0.27, alpha: 1)
        iconView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 16)

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .systemGray3

        [iconView, label, chevron].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview($0)
        }

        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 50),

            iconView.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            chevron.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])

        row.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
        return row
    }

    private func addGroupedRows(rows: [UIView], to card: UIView) {
        var last: UIView?

        for (index, row) in rows.enumerated() {
            row.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(row)

            NSLayoutConstraint.activate([
                row.leadingAnchor.constraint(equalTo: card.leadingAnchor),
                row.trailingAnchor.constraint(equalTo: card.trailingAnchor),
                row.topAnchor.constraint(equalTo: last?.bottomAnchor ?? card.topAnchor)
            ])

            if index < rows.count - 1 {
                let sep = UIView()
                sep.backgroundColor = UIColor.systemGray4
                sep.translatesAutoresizingMaskIntoConstraints = false
                card.addSubview(sep)

                NSLayoutConstraint.activate([
                    sep.topAnchor.constraint(equalTo: row.bottomAnchor),
                    sep.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                    sep.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
                    sep.heightAnchor.constraint(equalToConstant: 1)
                ])

                last = sep
            } else {
                last = row
            }
        }

        last?.bottomAnchor.constraint(equalTo: card.bottomAnchor).isActive = true
    }

    // MARK: - Navigation
    @objc private func openOrders() { push(MyOrdersViewController()) }
    @objc private func openProfile() { push(ProfileViewController()) }
    @objc private func openAddress() {
        let vc = AddressViewController()
        vc.flowSource = .fromAccount
        push(vc)
    }
    @objc private func openNotifications() { push(NotificationsViewController()) }
    @objc private func openTerms() { push(TermsAndConditionsViewController()) }
    @objc private func openPrivacy() { push(PrivacyPolicyViewController()) }
    @objc private func openSettings() { push(SettingsViewController()) }
    @objc private func openSellerDashboard() { push(SellerDashboardViewController()) }
    @objc private func openEvents() { push(BrowseEventsViewController()) }

    private func push(_ vc: UIViewController) {
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
}
