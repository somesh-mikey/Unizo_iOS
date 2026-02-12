//
//  SettingsViewController.swift
//  Unizo_iOS
//

import UIKit

final class SettingsViewController: UIViewController {

    // MARK: - Scroll View
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1)
        setupNavBar()
        setupScroll()
        setupSections()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Navigation Bar
    private func setupNavBar() {
        title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = false

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backPressed)
        )
    }

    @objc private func backPressed() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Scroll Setup
    private func setupScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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

    // MARK: - Sections Layout
    private func setupSections() {

        var lastBottom: NSLayoutYAxisAnchor = contentView.topAnchor
        let sectionSpacing: CGFloat = 28

        // Preferences
        let prefLabel = makeHeader("Preferences")
        contentView.addSubview(prefLabel)
        NSLayoutConstraint.activate([
            prefLabel.topAnchor.constraint(equalTo: lastBottom, constant: 25),
            prefLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
        lastBottom = prefLabel.bottomAnchor

        let prefCard = makePreferencesCard()
        contentView.addSubview(prefCard)
        NSLayoutConstraint.activate([
            prefCard.topAnchor.constraint(equalTo: lastBottom, constant: 10),
            prefCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            prefCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        lastBottom = prefCard.bottomAnchor

        // Support
        let supportLabel = makeHeader("Support")
        contentView.addSubview(supportLabel)
        NSLayoutConstraint.activate([
            supportLabel.topAnchor.constraint(equalTo: lastBottom, constant: sectionSpacing),
            supportLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
        lastBottom = supportLabel.bottomAnchor

        let supportCard = makeSupportCard()
        contentView.addSubview(supportCard)
        NSLayoutConstraint.activate([
            supportCard.topAnchor.constraint(equalTo: lastBottom, constant: 10),
            supportCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            supportCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        lastBottom = supportCard.bottomAnchor

        // Security
        let securityLabel = makeHeader("Security")
        contentView.addSubview(securityLabel)
        NSLayoutConstraint.activate([
            securityLabel.topAnchor.constraint(equalTo: lastBottom, constant: sectionSpacing),
            securityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
        lastBottom = securityLabel.bottomAnchor

        let securityCard = makeSecurityCard()
        contentView.addSubview(securityCard)
        NSLayoutConstraint.activate([
            securityCard.topAnchor.constraint(equalTo: lastBottom, constant: 10),
            securityCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            securityCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        lastBottom = securityCard.bottomAnchor

        // Account Actions
        let accountLabel = makeHeader("Account Actions")
        contentView.addSubview(accountLabel)
        NSLayoutConstraint.activate([
            accountLabel.topAnchor.constraint(equalTo: lastBottom, constant: sectionSpacing),
            accountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
        lastBottom = accountLabel.bottomAnchor

        let accountCard = makeAccountCard()
        contentView.addSubview(accountCard)
        NSLayoutConstraint.activate([
            accountCard.topAnchor.constraint(equalTo: lastBottom, constant: 10),
            accountCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            accountCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            accountCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    // MARK: - Header Label
    private func makeHeader(_ title: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = title
        lbl.font = .systemFont(ofSize: 18, weight: .semibold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }

    // MARK: - Cards
    private func buildCard() -> UIView {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }

    // MARK: - Cards Content
    private func makePreferencesCard() -> UIView {
        let card = buildCard()
        stackRows(card, rows: [
            makeSwitchRow(icon: "bell", title: "Push Notifications", selector: #selector(togglePush)),
            makeSwitchRow(icon: "envelope", title: "Email Marketing", selector: #selector(toggleEmail)),
            makeArrowRow(icon: "globe", title: "Language")
        ])
        return card
    }

    private func makeSupportCard() -> UIView {
        let card = buildCard()
        stackRows(card, rows: [
            makeArrowRow(icon: "phone", title: "Contact Us"),
            makeArrowRow(icon: "star", title: "Rate Our App")
        ])
        return card
    }

    private func makeSecurityCard() -> UIView {
        let card = buildCard()
        stackRows(card, rows: [
            makeArrowRow(icon: "key", title: "Change Password"),
            makeSwitchRow(icon: "touchid", title: "Biometric Login", selector: #selector(toggleBiometric))
        ])
        return card
    }

    private func makeAccountCard() -> UIView {
        let card = buildCard()

        let signOutRow = makeArrowRow(icon: "arrow.right.square", title: "Sign Out")
        let signOutTap = UITapGestureRecognizer(target: self, action: #selector(signOutTapped))
        signOutRow.addGestureRecognizer(signOutTap)
        signOutRow.isUserInteractionEnabled = true

        let deleteAccountRow = makeArrowRow(icon: "trash", title: "Delete Account")
        let deleteAccountTap = UITapGestureRecognizer(target: self, action: #selector(deleteAccountTapped))
        deleteAccountRow.addGestureRecognizer(deleteAccountTap)
        deleteAccountRow.isUserInteractionEnabled = true

        stackRows(card, rows: [
            signOutRow,
            deleteAccountRow
        ])
        return card
    }

    // MARK: - Rows
    private func makeArrowRow(icon: String, title: String) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let image = UIImageView(image: UIImage(systemName: icon))
        image.tintColor = UIColor(red: 0.07, green: 0.33, blue: 0.42, alpha: 1)
        image.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false

        let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrow.tintColor = .gray
        arrow.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(image)
        row.addSubview(label)
        row.addSubview(arrow)

        NSLayoutConstraint.activate([
            image.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            image.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            image.widthAnchor.constraint(equalToConstant: 24),
            image.heightAnchor.constraint(equalToConstant: 24),

            label.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            arrow.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            arrow.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            row.heightAnchor.constraint(equalToConstant: 55)
        ])

        return row
    }

    private func makeSwitchRow(icon: String, title: String, selector: Selector) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let image = UIImageView(image: UIImage(systemName: icon))
        image.tintColor = UIColor(red: 0.07, green: 0.33, blue: 0.42, alpha: 1)
        image.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false

        let sw = UISwitch()
        sw.onTintColor = UIColor(red: 0.07, green: 0.33, blue: 0.42, alpha: 1)
        sw.addTarget(self, action: selector, for: .valueChanged)
        sw.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(image)
        row.addSubview(label)
        row.addSubview(sw)

        NSLayoutConstraint.activate([
            image.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            image.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            image.widthAnchor.constraint(equalToConstant: 24),
            image.heightAnchor.constraint(equalToConstant: 24),

            label.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            sw.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            sw.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            row.heightAnchor.constraint(equalToConstant: 55)
        ])

        return row
    }

    // MARK: - Separators + Stack Rows
    private func makeSeparator() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }

    private func stackRows(_ card: UIView, rows: [UIView]) {

        var previous: UIView? = nil

        for (index, row) in rows.enumerated() {

            card.addSubview(row)

            NSLayoutConstraint.activate([
                row.leadingAnchor.constraint(equalTo: card.leadingAnchor),
                row.trailingAnchor.constraint(equalTo: card.trailingAnchor)
            ])

            if let prev = previous {
                row.topAnchor.constraint(equalTo: prev.bottomAnchor).isActive = true
            } else {
                row.topAnchor.constraint(equalTo: card.topAnchor).isActive = true
            }

            previous = row

            if index < rows.count - 1 {
                let sep = makeSeparator()
                card.addSubview(sep)

                NSLayoutConstraint.activate([
                    sep.topAnchor.constraint(equalTo: row.bottomAnchor),
                    sep.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 56),
                    sep.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
                    sep.heightAnchor.constraint(equalToConstant: 1)
                ])

                previous = sep
            }
        }

        previous?.bottomAnchor.constraint(equalTo: card.bottomAnchor).isActive = true
    }

    // MARK: - Switch Actions
    @objc private func togglePush(_ sender: UISwitch) {
        print("Push Notifications:", sender.isOn)
    }

    @objc private func toggleEmail(_ sender: UISwitch) {
        print("Email Marketing:", sender.isOn)
    }

    @objc private func toggleBiometric(_ sender: UISwitch) {
        print("Biometric Login:", sender.isOn)
    }

    // MARK: - Sign Out
    @objc private func signOutTapped() {
        let alert = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you want to sign out?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
            self?.performSignOut()
        })

        present(alert, animated: true)
    }

    private func performSignOut() {
        Task {
            do {
                // Stop notification listener first
                await NotificationManager.shared.stopListening()

                // Sign out from Supabase
                try await AuthManager.shared.signOut()

                print("✅ User signed out successfully")

                // Navigate to welcome screen
                await MainActor.run {
                    self.navigateToWelcome()
                }
            } catch {
                print("❌ Sign out failed:", error)
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Failed to sign out: \(error.localizedDescription)",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    // MARK: - Delete Account
    @objc private func deleteAccountTapped() {
        let alert = UIAlertController(
            title: "Delete Account",
            message: "Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performDeleteAccount()
        })

        present(alert, animated: true)
    }

    private func performDeleteAccount() {
        Task {
            do {
                // Stop notification listener first
                await NotificationManager.shared.stopListening()

                // Delete user account from Supabase
                try await AuthManager.shared.deleteAccount()

                print("✅ Account deleted successfully")

                // Navigate to welcome screen
                await MainActor.run {
                    self.navigateToWelcome()
                }
            } catch {
                print("❌ Delete account failed:", error)
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Failed to delete account: \(error.localizedDescription)",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    // MARK: - Navigation Helper
    private func navigateToWelcome() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        let welcomeVC = WelcomeViewController()
        window.rootViewController = welcomeVC
        window.makeKeyAndVisible()

        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
}
