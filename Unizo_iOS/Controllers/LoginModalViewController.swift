//
//  LoginModalViewController.swift
//  Unizo_iOS
//

import UIKit
import Supabase

final class LoginModalViewController: UIViewController {

    // MARK: - Supabase
    private let supabase = SupabaseManager.shared.client

    // MARK: - Containers (Card + Group)
    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 248/255, alpha: 1)
        v.layer.cornerRadius = 40
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()

    private let fieldsGroupView: UIView = {
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
    private func styledField(_ placeholder: String, secure: Bool = false) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.textColor = .darkGray

        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no

        if secure {
            tf.isSecureTextEntry = true
            tf.textContentType = .oneTimeCode
            tf.passwordRules = nil
        } else {
            tf.textContentType = .emailAddress
            tf.keyboardType = .emailAddress
        }

        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        tf.leftViewMode = .always

        return tf
    }

    private lazy var collegeEmailField = styledField("College Email")

    private lazy var passwordField: UITextField = styledField("Password", secure: true)

    // MARK: - Dividers
    private func divider() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.lightGray.withAlphaComponent(0.35)
        return v
    }


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

    // MARK: - Keyboard Handling
    private var cardBottomConstraint: NSLayoutConstraint!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBaseUI()
        layoutUI()
        setupActions()
        addPasswordEye()
        setupKeyboardObservers()
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

        // Dismiss keyboard on tap outside fields
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        cardView.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        let keyboardHeight = keyboardFrame.height

        UIView.animate(withDuration: duration) {
            self.cardBottomConstraint.constant = -keyboardHeight
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

    // MARK: - Base Styling
    private func setupBaseUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)

        // Add tap gesture to dismiss when tapping outside the card
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        view.addSubview(cardView)
        [
            titleLabel, fieldsGroupView,
            forgotPasswordButton, loginButton
        ].forEach { cardView.addSubview($0) }
    }

    @objc private func handleTapOutside(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !cardView.frame.contains(location) {
            dismiss(animated: true, completion: nil)
        }
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
        cardBottomConstraint = cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardBottomConstraint,
            cardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.42)
        ])

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 28),
            titleLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor)
        ])

        // FIELDS GROUP (College Email + Password)
        let fieldsDivider = divider()
        fieldsGroupView.addSubview(collegeEmailField)
        fieldsGroupView.addSubview(fieldsDivider)
        fieldsGroupView.addSubview(passwordField)

        [fieldsGroupView, collegeEmailField, fieldsDivider, passwordField].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            fieldsGroupView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 26),
            fieldsGroupView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 32),
            fieldsGroupView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -32),
            fieldsGroupView.heightAnchor.constraint(equalToConstant: 110),

            collegeEmailField.topAnchor.constraint(equalTo: fieldsGroupView.topAnchor),
            collegeEmailField.leadingAnchor.constraint(equalTo: fieldsGroupView.leadingAnchor),
            collegeEmailField.trailingAnchor.constraint(equalTo: fieldsGroupView.trailingAnchor),
            collegeEmailField.heightAnchor.constraint(equalToConstant: 55),

            fieldsDivider.topAnchor.constraint(equalTo: collegeEmailField.bottomAnchor),
            fieldsDivider.leadingAnchor.constraint(equalTo: fieldsGroupView.leadingAnchor),
            fieldsDivider.trailingAnchor.constraint(equalTo: fieldsGroupView.trailingAnchor),
            fieldsDivider.heightAnchor.constraint(equalToConstant: 1),

            passwordField.topAnchor.constraint(equalTo: fieldsDivider.bottomAnchor),
            passwordField.leadingAnchor.constraint(equalTo: fieldsGroupView.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: fieldsGroupView.trailingAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 54)
        ])

        // Forgot Password
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            forgotPasswordButton.topAnchor.constraint(equalTo: fieldsGroupView.bottomAnchor, constant: 14),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor)
        ])

        // Login Button
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 20),
            loginButton.leadingAnchor.constraint(equalTo: fieldsGroupView.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: fieldsGroupView.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
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

                // Start notification listener
                await NotificationManager.shared.startListening()

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
