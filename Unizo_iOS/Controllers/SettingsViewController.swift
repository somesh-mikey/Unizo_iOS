//
//  SettingsViewController.swift
//  Unizo_iOS
//

import UIKit
import StoreKit

final class SettingsViewController: UIViewController {

    // MARK: - Scroll View
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1)
        title = "Settings".localized
        navigationItem.largeTitleDisplayMode = .never
        setupScroll()
        setupSections()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
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
        let prefLabel = makeHeader("Preferences".localized)
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
        let supportLabel = makeHeader("Support".localized)
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
        let securityLabel = makeHeader("Security".localized)
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
        let accountLabel = makeHeader("Account Actions".localized)
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

        let languageRow = makeArrowRow(icon: "globe", title: "Language".localized)
        let languageTap = UITapGestureRecognizer(target: self, action: #selector(languageTapped))
        languageRow.addGestureRecognizer(languageTap)
        languageRow.isUserInteractionEnabled = true

        stackRows(card, rows: [
            makeSwitchRow(icon: "bell", title: "Push Notifications".localized, selector: #selector(togglePush)),
            makeSwitchRow(icon: "envelope", title: "Email Marketing".localized, selector: #selector(toggleEmail)),
            languageRow
        ])
        return card
    }

    private func makeSupportCard() -> UIView {
        let card = buildCard()

        let contactRow = makeArrowRow(icon: "phone", title: "Contact Us".localized)
        let contactTap = UITapGestureRecognizer(target: self, action: #selector(contactUsTapped))
        contactRow.addGestureRecognizer(contactTap)
        contactRow.isUserInteractionEnabled = true

        let rateRow = makeArrowRow(icon: "star.fill", title: "Rate Our App".localized)
        let rateTap = UITapGestureRecognizer(target: self, action: #selector(rateAppTapped))
        rateRow.addGestureRecognizer(rateTap)
        rateRow.isUserInteractionEnabled = true

        stackRows(card, rows: [
            contactRow,
            rateRow
        ])
        return card
    }

    private func makeSecurityCard() -> UIView {
        let card = buildCard()

        let passwordRow = makeArrowRow(icon: "key", title: "Change Password".localized)
        let passwordTap = UITapGestureRecognizer(target: self, action: #selector(changePasswordTapped))
        passwordRow.addGestureRecognizer(passwordTap)
        passwordRow.isUserInteractionEnabled = true

        stackRows(card, rows: [
            passwordRow,
            makeSwitchRow(icon: "touchid", title: "Biometric Login".localized, selector: #selector(toggleBiometric))
        ])
        return card
    }

    private func makeAccountCard() -> UIView {
        let card = buildCard()

        if MainTabBarController.isGuestMode {
            // Guest: show Sign In option instead of Sign Out / Delete Account
            let signInRow = makeArrowRow(icon: "person.crop.circle.badge.plus", title: "Sign In".localized)
            let signInTap = UITapGestureRecognizer(target: self, action: #selector(signInTapped))
            signInRow.addGestureRecognizer(signInTap)
            signInRow.isUserInteractionEnabled = true
            stackRows(card, rows: [signInRow])
        } else {
            let signOutRow = makeArrowRow(icon: "arrow.right.square", title: "Sign Out".localized)
            let signOutTap = UITapGestureRecognizer(target: self, action: #selector(signOutTapped))
            signOutRow.addGestureRecognizer(signOutTap)
            signOutRow.isUserInteractionEnabled = true

            let deleteAccountRow = makeArrowRow(icon: "trash", title: "Delete Account".localized)
            let deleteAccountTap = UITapGestureRecognizer(target: self, action: #selector(deleteAccountTapped))
            deleteAccountRow.addGestureRecognizer(deleteAccountTap)
            deleteAccountRow.isUserInteractionEnabled = true

            stackRows(card, rows: [signOutRow, deleteAccountRow])
        }

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

    // MARK: - Navigation Actions
    @objc private func languageTapped() {
        print("Language Screen pushed.")
        let vc = LanguageViewController()
        pushFromSettings(vc)
    }

    @objc private func contactUsTapped() {
        print("Contact Us screen pushed.")
        let vc = ContactUsViewController()
        pushFromSettings(vc)
    }

    @objc private func changePasswordTapped() {
        print("Change Password screen pushed.")
        let vc = ChangePasswordViewController()
        pushFromSettings(vc)
    }

    private func pushFromSettings(_ vc: UIViewController) {
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }



    @objc private func rateAppTapped() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        } else {
            // Fallback: open App Store page
            if let url = URL(string: "itms-apps://itunes.apple.com/app/idYOUR_APP_ID?action=write-review") {
                UIApplication.shared.open(url)
            }
        }
    }

    // MARK: - Sign In (Guest mode)
    @objc private func signInTapped() {
        navigateToWelcome()
    }

    // MARK: - Sign Out
    @objc private func signOutTapped() {
        let alert = UIAlertController(
            title: "Sign Out".localized,
            message: "Are you sure you want to sign out?".localized,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out".localized, style: .destructive) { [weak self] _ in
            self?.performSignOut()
        })

        present(alert, animated: true)
    }

    private func performSignOut() {
        Task {
            do {
                // Stop realtime listeners first
                await NotificationManager.shared.stopListening()
                await ChatManager.shared.stopListening()
                await OrderRealtimeManager.shared.unsubscribeAll()

                // Sign out from Firebase
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
                        title: "Error".localized,
                        message: String(format: "Failed to sign out: %@".localized, error.localizedDescription),
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    // MARK: - Delete Account
    @objc private func deleteAccountTapped() {
        let alert = UIAlertController(
            title: "Delete Account".localized,
            message: "Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.".localized,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete".localized, style: .destructive) { [weak self] _ in
            self?.presentDeleteAccountReauthScreen()
        })

        present(alert, animated: true)
    }

    private func presentDeleteAccountReauthScreen() {
        let reauthVC = DeleteAccountReauthViewController()
        reauthVC.onDeleteTapped = { [weak self] password, onFailure in
            self?.performDeleteAccount(password: password, onFailure: onFailure)
        }

        let nav = UINavigationController(rootViewController: reauthVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    private func performDeleteAccount(password: String, onFailure: @escaping (Error?) -> Void) {
        Task {
            do {
                // Delete user account from Firebase
                try await AuthManager.shared.deleteAccount(reauthPassword: password)

                // Stop realtime listeners after successful deletion.
                await NotificationManager.shared.stopListening()
                await ChatManager.shared.stopListening()
                await OrderRealtimeManager.shared.unsubscribeAll()

                print("✅ Account deleted successfully")

                // Navigate to welcome screen
                await MainActor.run {
                    self.navigateToWelcome()
                }
            } catch {
                print("❌ Delete account failed:", error)
                await MainActor.run {
                    onFailure(error)
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

private final class DeleteAccountReauthViewController: UIViewController {

    var onDeleteTapped: ((String, @escaping (Error?) -> Void) -> Void)?
    private var isSubmitting = false

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.text = "For security, please re-enter your password to delete your account.".localized
        return label
    }()

    private let passwordField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        tf.placeholder = "Password".localized
        tf.backgroundColor = .secondarySystemBackground
        tf.layer.cornerRadius = 12
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        tf.leftViewMode = .always
        return tf
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.text = ""
        return label
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Delete Account".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancel".localized, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .tertiarySystemBackground
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1)
        title = "Re-authenticate".localized

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close".localized,
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )

        setupUI()
        setupKeyboardDismissTap()
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        setLoading(false)
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Confirm Account Deletion".localized
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, passwordField, infoLabel, loadingIndicator, deleteButton, cancelButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 14
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            passwordField.heightAnchor.constraint(equalToConstant: 52),
            deleteButton.heightAnchor.constraint(equalToConstant: 50),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            loadingIndicator.heightAnchor.constraint(equalToConstant: 20),

            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupKeyboardDismissTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func closeTapped() {
        guard !isSubmitting else { return }
        dismiss(animated: true)
    }

    @objc private func deleteTapped() {
        guard !isSubmitting else { return }
        dismissKeyboard()

        let password = passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !password.isEmpty else {
            infoLabel.text = "Password is required".localized
            return
        }

        infoLabel.text = ""
        setLoading(true)

        onDeleteTapped?(password) { [weak self] error in
            guard let self else { return }
            guard let error else { return }
            self.setLoading(false)
            self.infoLabel.text = self.userFriendlyMessage(for: error)
        }

        if onDeleteTapped == nil {
            setLoading(false)
            infoLabel.text = "Unable to process this request right now.".localized
        }
    }

    private func setLoading(_ loading: Bool) {
        isSubmitting = loading
        passwordField.isEnabled = !loading
        deleteButton.isEnabled = !loading
        cancelButton.isEnabled = !loading
        navigationItem.leftBarButtonItem?.isEnabled = !loading

        if loading {
            loadingIndicator.startAnimating()
            deleteButton.alpha = 0.7
            cancelButton.alpha = 0.7
        } else {
            loadingIndicator.stopAnimating()
            deleteButton.alpha = 1
            cancelButton.alpha = 1
        }
    }

    private func userFriendlyMessage(for error: Error) -> String {
        if let authError = error as? AuthManagerError {
            return authError.localizedDescription
        }
        if AuthManager.isRequiresRecentLoginError(error) {
            return "Session expired. Please log in again and retry account deletion.".localized
        }
        return error.localizedDescription
    }
}
