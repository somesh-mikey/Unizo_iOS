//
//  ResetPasswordViewController.swift
//  Unizo_iOS
//
//  Created by Soham on 13/11/25.
//

import UIKit

class ResetPasswordViewController: UIViewController {

    // MARK: - UI Elements
    private let cardView = UIView()
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private let emailField = UITextField()
    private let phoneField = UITextField()
    
    private let orLabel = UILabel()
    
    private let backToLoginButton = UIButton(type: .system)
    private let sendResetButton = UIButton(type: .system)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }

    // MARK: - UI Setup
    private func setupUI() {

        // Background dim
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        // --- Card View ---
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 40
        //cardView.layer.borderWidth = 3
        //cardView.layer.borderColor = UIColor(red: 68/255, green: 130/255, blue: 255/255, alpha: 1).cgColor
        cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        cardView.clipsToBounds = true
        view.addSubview(cardView)

        // --- Title ---
        titleLabel.text = "Reset Your Password"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .black

        // --- Subtitle ---
        subtitleLabel.text = "Don’t worry! Enter your email address and we’ll send\nyou a link to reset your password."
        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .left

        // --- Fields ---
        setupTextField(emailField, placeholder: "College Email")
        setupTextField(phoneField, placeholder: "Your Phone Number")

        // OR Label
        orLabel.text = "OR"
        orLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        orLabel.textColor = .gray
        orLabel.textAlignment = .center

        // Back To Login
        backToLoginButton.setTitle("Back to Login.", for: .normal)
        backToLoginButton.setTitleColor(.systemBlue, for: .normal)
        backToLoginButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        backToLoginButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        // Send Reset Button
        sendResetButton.setTitle("Send Reset Link", for: .normal)
        sendResetButton.backgroundColor = UIColor(red: 0/255, green: 76/255, blue: 97/255, alpha: 1)
        sendResetButton.setTitleColor(.white, for: .normal)
        sendResetButton.layer.cornerRadius = 14
        sendResetButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        sendResetButton.addTarget(self, action: #selector(sendResetTapped), for: .touchUpInside)

        // Add Subviews
        [titleLabel, subtitleLabel, emailField, orLabel, phoneField, backToLoginButton, sendResetButton]
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

        cardView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        emailField.translatesAutoresizingMaskIntoConstraints = false
        orLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneField.translatesAutoresizingMaskIntoConstraints = false
        backToLoginButton.translatesAutoresizingMaskIntoConstraints = false
        sendResetButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            // Card View
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.45),

            // Title
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 32),

            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            // Email Field
            emailField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 22),
            emailField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            emailField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -32),
            emailField.heightAnchor.constraint(equalToConstant: 44),

            // OR Label
            orLabel.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 12),
            orLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            // Phone Field
            phoneField.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 6),
            phoneField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            phoneField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            phoneField.heightAnchor.constraint(equalToConstant: 44),

            // Back To Login
            backToLoginButton.topAnchor.constraint(equalTo: phoneField.bottomAnchor, constant: 8),
            backToLoginButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            // Send Reset Button
            sendResetButton.topAnchor.constraint(equalTo: backToLoginButton.bottomAnchor, constant: 22),
            sendResetButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            sendResetButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            sendResetButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Actions
    @objc private func backTapped() {
        dismiss(animated: true)
    }

    @objc private func sendResetTapped() {
        dismiss(animated: true)
    }
}
