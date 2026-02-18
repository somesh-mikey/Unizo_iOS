//
//  ResetPasswordViewController.swift
//  Unizo_iOS
//
//  Created by Soham on 13/11/25.
//

import UIKit

class ResetPasswordViewController: UIViewController {

    // MARK: - Mode
    /// When true, the user is already logged in and can set a new password directly.
    /// When false (default), the user is on the login screen and needs an email reset link.
    var isLoggedInMode: Bool = false

    // MARK: - UI Elements
    private let cardView = UIView()

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    // Email mode
    private let emailField = UITextField()

    // Logged-in mode (set new password directly)
    private let newPasswordField = UITextField()
    private let confirmPasswordField = UITextField()

    private let errorLabel = UILabel()

    private let backToLoginButton = UIButton(type: .system)
    private let actionButton = UIButton(type: .system)
    private let loadingSpinner = UIActivityIndicatorView(style: .medium)

    // MARK: - Keyboard Handling
    private var cardBottomConstraint: NSLayoutConstraint!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Detect if user is logged in
        isLoggedInMode = AuthManager.shared.isLoggedInSync

        setupUI()
        setupConstraints()
        setupKeyboardObservers()

        // Add tap gesture to dismiss when tapping outside the card
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Keyboard Observers
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        let cardTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        cardTap.cancelsTouchesInView = false
        cardView.addGestureRecognizer(cardTap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        UIView.animate(withDuration: duration) {
            self.cardBottomConstraint.constant = -keyboardFrame.height
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        UIView.animate(withDuration: duration) {
            self.cardBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }

    @objc private func handleTapOutside(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !cardView.frame.contains(location) {
            dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 40
        cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        cardView.clipsToBounds = true
        view.addSubview(cardView)

        let tealColor = UIColor(red: 0/255, green: 76/255, blue: 97/255, alpha: 1)

        if isLoggedInMode {
            // --- Logged-in: Set new password directly ---
            titleLabel.text = "Set New Password".localized
            subtitleLabel.text = "Enter and confirm your new password below.".localized

            setupTextField(newPasswordField, placeholder: "New Password".localized)
            newPasswordField.isSecureTextEntry = true
            newPasswordField.textContentType = .newPassword

            setupTextField(confirmPasswordField, placeholder: "Confirm Password".localized)
            confirmPasswordField.isSecureTextEntry = true
            confirmPasswordField.textContentType = .newPassword

            actionButton.setTitle("Update Password".localized, for: .normal)

            // Hide email field
            emailField.isHidden = true

            backToLoginButton.setTitle("Cancel".localized, for: .normal)
        } else {
            // --- Not logged-in: Email reset link ---
            titleLabel.text = "Reset Your Password".localized
            subtitleLabel.text = "Don't worry! Enter your email address and we'll send\nyou a link to reset your password.".localized

            setupTextField(emailField, placeholder: "College Email".localized)
            emailField.keyboardType = .emailAddress
            emailField.autocapitalizationType = .none
            emailField.autocorrectionType = .no

            actionButton.setTitle("Send Reset Link".localized, for: .normal)

            // Hide password fields
            newPasswordField.isHidden = true
            confirmPasswordField.isHidden = true

            backToLoginButton.setTitle("Back to Login.".localized, for: .normal)
        }

        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .black

        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .left

        errorLabel.font = .systemFont(ofSize: 13)
        errorLabel.textColor = .systemRed
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true

        backToLoginButton.setTitleColor(.systemBlue, for: .normal)
        backToLoginButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        backToLoginButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        actionButton.backgroundColor = tealColor
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.layer.cornerRadius = 14
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)

        loadingSpinner.hidesWhenStopped = true
        loadingSpinner.color = .white

        [titleLabel, subtitleLabel, emailField, newPasswordField, confirmPasswordField, errorLabel, backToLoginButton, actionButton, loadingSpinner]
            .forEach { cardView.addSubview($0) }
    }

    private func setupTextField(_ tf: UITextField, placeholder: String) {
        tf.placeholder = placeholder
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        tf.layer.cornerRadius = 20
        tf.layer.borderWidth = 0.4
        tf.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - Constraints
    private func setupConstraints() {
        [cardView, titleLabel, subtitleLabel, emailField, newPasswordField, confirmPasswordField,
         errorLabel, backToLoginButton, actionButton, loadingSpinner].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        cardBottomConstraint = cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        // Common constraints
        var constraints: [NSLayoutConstraint] = [
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardBottomConstraint,

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 32),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -32),

            loadingSpinner.centerXAnchor.constraint(equalTo: actionButton.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor)
        ]

        if isLoggedInMode {
            // Card is taller for two fields
            constraints += [
                cardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.42),

                newPasswordField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 22),
                newPasswordField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                newPasswordField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -32),
                newPasswordField.heightAnchor.constraint(equalToConstant: 44),

                confirmPasswordField.topAnchor.constraint(equalTo: newPasswordField.bottomAnchor, constant: 12),
                confirmPasswordField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                confirmPasswordField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -32),
                confirmPasswordField.heightAnchor.constraint(equalToConstant: 44),

                errorLabel.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: 8),
                errorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                errorLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -32),

                backToLoginButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 4),
                backToLoginButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

                actionButton.topAnchor.constraint(equalTo: backToLoginButton.bottomAnchor, constant: 18),
                actionButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                actionButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -32),
                actionButton.heightAnchor.constraint(equalToConstant: 50)
            ]
        } else {
            constraints += [
                cardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.38),

                emailField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 22),
                emailField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                emailField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -32),
                emailField.heightAnchor.constraint(equalToConstant: 44),

                errorLabel.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 8),
                errorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                errorLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -32),

                backToLoginButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 4),
                backToLoginButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

                actionButton.topAnchor.constraint(equalTo: backToLoginButton.bottomAnchor, constant: 22),
                actionButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                actionButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -32),
                actionButton.heightAnchor.constraint(equalToConstant: 50)
            ]
        }

        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Actions
    @objc private func backTapped() {
        dismiss(animated: true)
    }

    @objc private func actionTapped() {
        if isLoggedInMode {
            handleUpdatePassword()
        } else {
            handleSendResetLink()
        }
    }

    // MARK: - Logged-in: Update Password Directly
    private func handleUpdatePassword() {
        view.endEditing(true)
        errorLabel.isHidden = true

        let newPassword = newPasswordField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let confirmPassword = confirmPasswordField.text?.trimmingCharacters(in: .whitespaces) ?? ""

        guard !newPassword.isEmpty else {
            showError("Please enter a new password.")
            return
        }
        guard newPassword.count >= 6 else {
            showError("Password must be at least 6 characters.")
            return
        }
        guard newPassword == confirmPassword else {
            showError("Passwords do not match.")
            return
        }

        setLoading(true)

        Task {
            do {
                try await AuthManager.shared.updatePassword(newPassword: newPassword)

                print("✅ [ResetPassword] Password updated successfully")

                await MainActor.run {
                    self.setLoading(false)
                    let alert = UIAlertController(
                        title: "Password Updated".localized,
                        message: "Your password has been changed successfully.".localized,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK".localized, style: .default) { [weak self] _ in
                        self?.dismiss(animated: true)
                    })
                    self.present(alert, animated: true)
                }
            } catch {
                print("❌ [ResetPassword] Password update failed: \(error)")

                await MainActor.run {
                    self.setLoading(false)
                    self.showError("Failed to update password: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Not logged-in: Send Reset Email
    private func handleSendResetLink() {
        view.endEditing(true)
        errorLabel.isHidden = true

        let email = emailField.text?.trimmingCharacters(in: .whitespaces) ?? ""

        print("📧 [ResetPassword] Send Reset tapped. Email: '\(email)'")

        guard !email.isEmpty else {
            showError("Please enter your college email address.")
            return
        }

        guard email.contains("@") && email.contains(".") else {
            showError("Please enter a valid email address.")
            return
        }

        print("📧 [ResetPassword] Validation passed. Calling AuthManager...")
        setLoading(true)

        Task {
            do {
                try await AuthManager.shared.sendPasswordResetEmail(to: email)

                print("✅ [ResetPassword] Reset email sent successfully for: \(email)")

                await MainActor.run {
                    self.setLoading(false)
                    let alert = UIAlertController(
                        title: "Reset Link Sent".localized,
                        message: String(format: "We've sent a password reset link to %@. Please check your inbox and spam folder.".localized, email),
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK".localized, style: .default) { [weak self] _ in
                        self?.dismiss(animated: true)
                    })
                    self.present(alert, animated: true)
                }
            } catch {
                print("❌ [ResetPassword] Reset email failed: \(error)")
                print("❌ [ResetPassword] Error: \(error.localizedDescription)")

                await MainActor.run {
                    self.setLoading(false)
                    self.showError("Failed to send reset link: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Helpers
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    private func setLoading(_ loading: Bool) {
        if loading {
            actionButton.setTitle("", for: .normal)
            loadingSpinner.startAnimating()
            actionButton.isEnabled = false
            emailField.isEnabled = false
            newPasswordField.isEnabled = false
            confirmPasswordField.isEnabled = false
        } else {
            actionButton.setTitle(isLoggedInMode ? "Update Password".localized : "Send Reset Link".localized, for: .normal)
            loadingSpinner.stopAnimating()
            actionButton.isEnabled = true
            emailField.isEnabled = true
            newPasswordField.isEnabled = true
            confirmPasswordField.isEnabled = true
        }
    }
}
