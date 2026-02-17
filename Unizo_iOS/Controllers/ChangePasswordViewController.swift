//
//  ChangePasswordViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 24/12/25.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    // MARK: - UI Elements

    private let oldPasswordLabel = UILabel()
    private let oldPasswordField = UITextField()

    private let newPasswordLabel = UILabel()
    private let newPasswordField = UITextField()

    private let errorLabel = UILabel()
    private let forgotPasswordButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    private let loadingSpinner = UIActivityIndicatorView(style: .medium)

    // MARK: - Colors
    private let primaryButtonColor = UIColor(red: 0.12, green: 0.28, blue: 0.35, alpha: 1.0)
    private let screenBackground = UIColor.systemGroupedBackground

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupKeyboardHandling()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Keyboard Handling
    private func setupKeyboardHandling() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = screenBackground

        // Navigation
        navigationItem.title = "Change Password".localized
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )

        // Labels
        oldPasswordLabel.text = "Enter old password:".localized
        oldPasswordLabel.font = .systemFont(ofSize: 15, weight: .medium)

        newPasswordLabel.text = "Enter new password:".localized
        newPasswordLabel.font = .systemFont(ofSize: 15, weight: .medium)

        // TextFields
        configureTextField(oldPasswordField, placeholder: "Old Password".localized)
        configureTextField(newPasswordField, placeholder: "New Password".localized)

        oldPasswordField.isSecureTextEntry = true
        newPasswordField.isSecureTextEntry = true
        oldPasswordField.textContentType = .password
        newPasswordField.textContentType = .newPassword

        // Error label (hidden by default)
        errorLabel.font = .systemFont(ofSize: 13)
        errorLabel.textColor = .systemRed
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true

        // Forgot password
        forgotPasswordButton.setTitle("Forgot Password?".localized, for: .normal)
        forgotPasswordButton.setTitleColor(.systemBlue, for: .normal)
        forgotPasswordButton.titleLabel?.font = .systemFont(ofSize: 14)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)

        // Save Button
        saveButton.setTitle("Save".localized, for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        saveButton.backgroundColor = primaryButtonColor
        saveButton.layer.cornerRadius = 28
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        // Loading spinner
        loadingSpinner.hidesWhenStopped = true
        loadingSpinner.color = .white

        // Add subviews
        [
            oldPasswordLabel,
            oldPasswordField,
            newPasswordLabel,
            newPasswordField,
            errorLabel,
            forgotPasswordButton,
            saveButton,
            loadingSpinner
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    private func configureTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 14
        textField.font = .systemFont(ofSize: 16)
        textField.setLeftPadding(16)
    }

    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([

            // Old password label
            oldPasswordLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            oldPasswordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            oldPasswordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Old password field
            oldPasswordField.topAnchor.constraint(equalTo: oldPasswordLabel.bottomAnchor, constant: 8),
            oldPasswordField.leadingAnchor.constraint(equalTo: oldPasswordLabel.leadingAnchor),
            oldPasswordField.trailingAnchor.constraint(equalTo: oldPasswordLabel.trailingAnchor),
            oldPasswordField.heightAnchor.constraint(equalToConstant: 52),

            // New password label
            newPasswordLabel.topAnchor.constraint(equalTo: oldPasswordField.bottomAnchor, constant: 24),
            newPasswordLabel.leadingAnchor.constraint(equalTo: oldPasswordLabel.leadingAnchor),
            newPasswordLabel.trailingAnchor.constraint(equalTo: oldPasswordLabel.trailingAnchor),

            // New password field
            newPasswordField.topAnchor.constraint(equalTo: newPasswordLabel.bottomAnchor, constant: 8),
            newPasswordField.leadingAnchor.constraint(equalTo: oldPasswordLabel.leadingAnchor),
            newPasswordField.trailingAnchor.constraint(equalTo: oldPasswordLabel.trailingAnchor),
            newPasswordField.heightAnchor.constraint(equalToConstant: 52),

            // Error label
            errorLabel.topAnchor.constraint(equalTo: newPasswordField.bottomAnchor, constant: 12),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Forgot password
            forgotPasswordButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 8),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Save button
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 56),

            // Loading spinner (centered on save button)
            loadingSpinner.centerXAnchor.constraint(equalTo: saveButton.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor)
        ])
    }

    // MARK: - Actions
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func saveTapped() {
        dismissKeyboard()
        errorLabel.isHidden = true

        let oldPassword = oldPasswordField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let newPassword = newPasswordField.text?.trimmingCharacters(in: .whitespaces) ?? ""

        // Validation
        guard !oldPassword.isEmpty else {
            showError("Please enter your old password.")
            return
        }
        guard !newPassword.isEmpty else {
            showError("Please enter a new password.")
            return
        }
        guard newPassword.count >= 6 else {
            showError("New password must be at least 6 characters.")
            return
        }
        guard oldPassword != newPassword else {
            showError("New password must be different from old password.")
            return
        }

        setLoading(true)

        Task {
            do {
                try await AuthManager.shared.changePassword(
                    oldPassword: oldPassword,
                    newPassword: newPassword
                )

                await MainActor.run {
                    self.setLoading(false)
                    self.showSuccessAndPop()
                }
            } catch {
                await MainActor.run {
                    self.setLoading(false)
                    self.showError(error.localizedDescription)
                }
            }
        }
    }

    @objc private func forgotPasswordTapped() {
        let resetVC = ResetPasswordViewController()
        resetVC.modalPresentationStyle = .overFullScreen
        resetVC.modalTransitionStyle = .coverVertical
        present(resetVC, animated: true)
    }

    // MARK: - Helpers
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    private func setLoading(_ loading: Bool) {
        if loading {
            saveButton.setTitle("", for: .normal)
            loadingSpinner.startAnimating()
            saveButton.isEnabled = false
            oldPasswordField.isEnabled = false
            newPasswordField.isEnabled = false
        } else {
            saveButton.setTitle("Save".localized, for: .normal)
            loadingSpinner.stopAnimating()
            saveButton.isEnabled = true
            oldPasswordField.isEnabled = true
            newPasswordField.isEnabled = true
        }
    }

    private func showSuccessAndPop() {
        let alert = UIAlertController(
            title: "Password Changed",
            message: "Your password has been updated successfully.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
