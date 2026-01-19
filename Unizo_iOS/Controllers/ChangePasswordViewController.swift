//
//  ChangePasswordViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 24/12/25.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    // MARK: - UI Elements

    private let titleLabel = UILabel()

    private let oldPasswordLabel = UILabel()
    private let oldPasswordField = UITextField()

    private let newPasswordLabel = UILabel()
    private let newPasswordField = UITextField()

    private let forgotPasswordButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)

    // MARK: - Colors
    private let primaryButtonColor = UIColor(red: 0.12, green: 0.28, blue: 0.35, alpha: 1.0)
    private let screenBackground = UIColor.systemGroupedBackground

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = screenBackground

        // Navigation
        navigationItem.title = "Change Password"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )

        // Title
        titleLabel.text = "Change Password"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center

        // Labels
        oldPasswordLabel.text = "Enter old password:"
        oldPasswordLabel.font = .systemFont(ofSize: 15, weight: .medium)

        newPasswordLabel.text = "Enter new password:"
        newPasswordLabel.font = .systemFont(ofSize: 15, weight: .medium)

        // TextFields
        configureTextField(oldPasswordField, placeholder: "Old Password")
        configureTextField(newPasswordField, placeholder: "New Password")

        oldPasswordField.isSecureTextEntry = true
        newPasswordField.isSecureTextEntry = true

        // Forgot password
        forgotPasswordButton.setTitle("Forgot Password?", for: .normal)
        forgotPasswordButton.setTitleColor(.systemBlue, for: .normal)
        forgotPasswordButton.titleLabel?.font = .systemFont(ofSize: 14)

        // Save Button
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        saveButton.backgroundColor = primaryButtonColor
        saveButton.layer.cornerRadius = 28

        // Add subviews
        [
            oldPasswordLabel,
            oldPasswordField,
            newPasswordLabel,
            newPasswordField,
            forgotPasswordButton,
            saveButton
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

            // Forgot password
            forgotPasswordButton.topAnchor.constraint(equalTo: newPasswordField.bottomAnchor, constant: 16),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Save button
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    // MARK: - Actions
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextField Padding Extension
//private extension UITextField {
//    func setLeftPadding(_ amount: CGFloat) {
//        let paddingView = UIView(
//            frame: CGRect(x: 0, y: 0, width: amount, height: frame.height)
//        )
//        leftView = paddingView
//        leftViewMode = .always
//    }
//}
