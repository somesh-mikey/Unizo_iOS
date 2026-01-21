//
//  LoginModalViewController.swift
//  Unizo_iOS
//

import UIKit
import Supabase

final class LoginModalViewController: UIViewController {

    // MARK: - Supabase
    private let supabase = SupabaseManager.shared.client

    // MARK: - Containers (Card + Groups)
    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 248/255, alpha: 1)
        v.layer.cornerRadius = 40
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()

    private let topGroupView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        return v
    }()

    private let bottomGroupView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        return v
    }()

    // MARK: - Title
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Login To Your Account"
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lbl.textAlignment = .center
        lbl.textColor = .black
        return lbl
    }()

    // MARK: - Text Fields
    private func styledField(_ placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.textColor = .darkGray
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        tf.leftViewMode = .always
        return tf
    }

    private lazy var collegeRegField = styledField("College Registration Number")
    private lazy var collegeEmailField = styledField("College Email")
    private lazy var phoneField = styledField("Your Phone Number")

    private lazy var passwordField: UITextField = {
        let tf = styledField("Password")
        tf.isSecureTextEntry = true
        return tf
    }()

    // MARK: - Dividers
    private func divider() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.lightGray.withAlphaComponent(0.35)
        return v
    }

    // MARK: - OR Label
    private let orLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "OR"
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = .gray
        return lbl
    }()

    // MARK: - Forgot Password
    private let forgotPasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Forgot Password?", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return btn
    }()

    // MARK: - Login Button
    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Login", for: .normal)
        btn.backgroundColor = UIColor(red: 0/255, green: 76/255, blue: 97/255, alpha: 1)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return btn
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBaseUI()
        layoutUI()
        setupActions()
        addPasswordEye()
    }

    // MARK: - Base Styling
    private func setupBaseUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)

        view.addSubview(cardView)
        [
            titleLabel, topGroupView, orLabel,
            bottomGroupView, forgotPasswordButton, loginButton
        ].forEach { cardView.addSubview($0) }
    }

    // MARK: - Password Eye Toggle
    private func addPasswordEye() {
        let eyeButton = UIButton(type: .system)
        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        eyeButton.tintColor = .gray
        eyeButton.frame = CGRect(x: 0, y: 0, width: 30, height: 20)
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        passwordField.rightView = eyeButton
        passwordField.rightViewMode = .always
    }

    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        passwordField.isSecureTextEntry.toggle()
        let icon = passwordField.isSecureTextEntry ? "eye.slash" : "eye"
        sender.setImage(UIImage(systemName: icon), for: .normal)
    }

    // MARK: - Layout
    private func layoutUI() {

        cardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.58)
        ])

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor)
        ])

        // TOP GROUP (2 fields)
        let topDivider = divider()
        topGroupView.addSubview(collegeRegField)
        topGroupView.addSubview(topDivider)
        topGroupView.addSubview(collegeEmailField)

        [topGroupView, collegeRegField, topDivider, collegeEmailField].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            topGroupView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 22),
            topGroupView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 32),
            topGroupView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -32),
            topGroupView.heightAnchor.constraint(equalToConstant: 110),

            collegeRegField.topAnchor.constraint(equalTo: topGroupView.topAnchor),
            collegeRegField.leadingAnchor.constraint(equalTo: topGroupView.leadingAnchor),
            collegeRegField.trailingAnchor.constraint(equalTo: topGroupView.trailingAnchor),
            collegeRegField.heightAnchor.constraint(equalToConstant: 55),

            topDivider.topAnchor.constraint(equalTo: collegeRegField.bottomAnchor),
            topDivider.leadingAnchor.constraint(equalTo: topGroupView.leadingAnchor),
            topDivider.trailingAnchor.constraint(equalTo: topGroupView.trailingAnchor),
            topDivider.heightAnchor.constraint(equalToConstant: 1),

            collegeEmailField.topAnchor.constraint(equalTo: topDivider.bottomAnchor),
            collegeEmailField.leadingAnchor.constraint(equalTo: topGroupView.leadingAnchor),
            collegeEmailField.trailingAnchor.constraint(equalTo: topGroupView.trailingAnchor),
            collegeEmailField.heightAnchor.constraint(equalToConstant: 54)
        ])

        // OR Label
        orLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            orLabel.topAnchor.constraint(equalTo: topGroupView.bottomAnchor, constant: 16),
            orLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor)
        ])

        // BOTTOM GROUP (2 fields)
        let bottomDivider = divider()
        bottomGroupView.addSubview(phoneField)
        bottomGroupView.addSubview(bottomDivider)
        bottomGroupView.addSubview(passwordField)

        [bottomGroupView, phoneField, bottomDivider, passwordField].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            bottomGroupView.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 16),
            bottomGroupView.leadingAnchor.constraint(equalTo: topGroupView.leadingAnchor),
            bottomGroupView.trailingAnchor.constraint(equalTo: topGroupView.trailingAnchor),
            bottomGroupView.heightAnchor.constraint(equalToConstant: 110),

            phoneField.topAnchor.constraint(equalTo: bottomGroupView.topAnchor),
            phoneField.leadingAnchor.constraint(equalTo: bottomGroupView.leadingAnchor),
            phoneField.trailingAnchor.constraint(equalTo: bottomGroupView.trailingAnchor),
            phoneField.heightAnchor.constraint(equalToConstant: 55),

            bottomDivider.topAnchor.constraint(equalTo: phoneField.bottomAnchor),
            bottomDivider.leadingAnchor.constraint(equalTo: bottomGroupView.leadingAnchor),
            bottomDivider.trailingAnchor.constraint(equalTo: bottomGroupView.trailingAnchor),
            bottomDivider.heightAnchor.constraint(equalToConstant: 1),

            passwordField.topAnchor.constraint(equalTo: bottomDivider.bottomAnchor),
            passwordField.leadingAnchor.constraint(equalTo: bottomGroupView.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: bottomGroupView.trailingAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 54)
        ])

        // Forgot Password
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            forgotPasswordButton.topAnchor.constraint(equalTo: bottomGroupView.bottomAnchor, constant: 12),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor)
        ])

        // Login Button
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 18),
            loginButton.leadingAnchor.constraint(equalTo: bottomGroupView.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: bottomGroupView.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            loginButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24)
        ])
    }

    // MARK: - Actions
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
    }

    @objc private func loginTapped() {

        // Get login credentials - use email field for authentication
        guard let emailRaw = collegeEmailField.text, !emailRaw.isEmpty,
              let passwordRaw = passwordField.text, !passwordRaw.isEmpty else {
            showAlert(message: "Please enter email and password")
            return
        }

        // Trim whitespace from email and password
        let email = emailRaw.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordRaw.trimmingCharacters(in: .whitespacesAndNewlines)

        // Show loading state
        loginButton.isEnabled = false
        loginButton.setTitle("Logging in...", for: .normal)

        // Authenticate with Supabase
        Task {
            do {
                print("🔐 Attempting login with email: \(email)")
                print("🔐 Password length: \(password.count) characters")

                try await supabase.auth.signIn(
                    email: email,
                    password: password
                )

                print("✅ Login successful")

                // Navigate to main app
                await MainActor.run {
                    dismiss(animated: true) {
                        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                              let window = scene.windows.first else { return }

                        let tab = MainTabBarController()
                        tab.selectedIndex = 0

                        window.rootViewController = tab
                        window.makeKeyAndVisible()

                        UIView.transition(with: window,
                                          duration: 0.25,
                                          options: .transitionCrossDissolve,
                                          animations: nil,
                                          completion: nil)
                    }
                }

            } catch {
                print("❌ Login failed:", error)
                await MainActor.run {
                    loginButton.isEnabled = true
                    loginButton.setTitle("Login", for: .normal)
                    showAlert(message: "Login failed: \(error.localizedDescription)")
                }
            }
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func forgotPasswordTapped() {

        print("FORGOT PASSWORD TAPPED")

        dismiss(animated: true) {

            // 1. Get active window
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                print(" No window found")
                return
            }

            // 2. Get the actual visible controller
            var presenter = window.rootViewController

            // If something is already presented on root → present from that instead
            while let presented = presenter?.presentedViewController {
                presenter = presented
            }

            guard let safePresenter = presenter else {
                print(" No presenter available")
                return
            }

            // 3. Create reset screen
            let resetVC = ResetPasswordViewController()
            resetVC.modalPresentationStyle = .overFullScreen
            resetVC.modalTransitionStyle = .coverVertical

            // 4. Present safely
            safePresenter.present(resetVC, animated: true)
            print(" ResetPasswordVC Presented")
        }
    }
}
