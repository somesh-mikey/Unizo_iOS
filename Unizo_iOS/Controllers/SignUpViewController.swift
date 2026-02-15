//
//  SignUpViewController.swift
//  Unizo_iOS
//
//  Created by Soham on 2025-11-13.
//

import UIKit
import Supabase

final class SignUpViewController: UIViewController {

    // MARK: - Supabase
    private let supabase = SupabaseManager.shared.client

    // MARK: - UI

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "card view background colour")
            ?? UIColor(red: 246/255, green: 246/255, blue: 248/255, alpha: 1)
        v.layer.cornerRadius = 40
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.clipsToBounds = true
        return v
    }()

    private let fieldsContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 12
        v.layer.masksToBounds = true
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Set Up Your Profile"
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        l.textColor = .black
        return l
    }()

    // Text fields
    private var firstNameTF = UITextField()
    private var lastNameTF = UITextField()
    private var regTF = UITextField()
    private var emailTF = UITextField()
    private var phoneTF = UITextField()
    private var createPasswordTF = UITextField()
    private var confirmPasswordTF = UITextField()

    private var separators: [UIView] = []

    // Checkbox
    private let checkBoxButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "square"), for: .normal)
        b.tintColor = .darkGray
        return b
    }()

    // Keyboard handling
    private var cardBottomConstraint: NSLayoutConstraint!

    // Interactive terms label
    private let termsLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = UIFont.systemFont(ofSize: 13)   // ← FIX 1 (bigger font)
        l.textColor = .gray
        return l
    }()

    // Sign up button ENABLED ONLY WHEN CHECKBOX IS TICKED
    private let signUpButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Sign Up", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor(red: 0/255, green: 76/255, blue: 97/255, alpha: 1)
        b.layer.cornerRadius = 14
        b.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        b.alpha = 0.4       // ← initially disabled
        b.isEnabled = false // ← FIX 4
        return b
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        // Add tap gesture to dismiss when tapping outside the card
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        setupFields()
        setupHierarchy()
        setupConstraints()
        setupActions()
        setupTermsLabel()
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

        // Dismiss keyboard on tap on card
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

    @objc private func handleTapOutside(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !cardView.frame.contains(location) {
            dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - Setup Helpers

    private func makeField(placeholder: String, secure: Bool = false) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = .darkGray
        tf.borderStyle = .none
        tf.backgroundColor = .clear

        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no

        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        tf.leftViewMode = .always
        tf.isSecureTextEntry = secure
        return tf
    }
    private func makeSeparator() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.lightGray.withAlphaComponent(0.35)
        return v
    }

    private func setupFields() {
        firstNameTF        = makeField(placeholder: "First Name")
        lastNameTF         = makeField(placeholder: "Last Name")
        regTF              = makeField(placeholder: "College Registration Number")
        emailTF            = makeField(placeholder: "College Email")
        phoneTF            = makeField(placeholder: "Your Phone Number")
        createPasswordTF   = makeField(placeholder: "Create Password", secure: true)
        confirmPasswordTF  = makeField(placeholder: "Confirm Password", secure: true)

        separators = (0..<6).map { _ in makeSeparator() }

        addEyeButton(to: createPasswordTF)
        addEyeButton(to: confirmPasswordTF)
    }

    private func setupHierarchy() {
        view.addSubview(cardView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(fieldsContainer)

        let fields = [
            firstNameTF, lastNameTF, regTF, emailTF,
            phoneTF, createPasswordTF, confirmPasswordTF
        ]

        for i in 0..<fields.count {
            fieldsContainer.addSubview(fields[i])
            if i < separators.count {
                fieldsContainer.addSubview(separators[i])
            }
        }

        cardView.addSubview(checkBoxButton)
        cardView.addSubview(termsLabel)
        cardView.addSubview(signUpButton)
    }

    private func setupActions() {
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        checkBoxButton.addTarget(self, action: #selector(toggleCheckBox), for: .touchUpInside)
    }

    // MARK: - Password Eye Toggle

    private func addEyeButton(to tf: UITextField) {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        btn.tintColor = .gray
        btn.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        btn.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        tf.rightView = btn
        tf.rightViewMode = .always
    }

    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        if createPasswordTF.rightView === sender {
            createPasswordTF.isSecureTextEntry.toggle()
            let name = createPasswordTF.isSecureTextEntry ? "eye.slash" : "eye"
            sender.setImage(UIImage(systemName: name), for: .normal)
        } else if confirmPasswordTF.rightView === sender {
            confirmPasswordTF.isSecureTextEntry.toggle()
            let name = confirmPasswordTF.isSecureTextEntry ? "eye.slash" : "eye"
            sender.setImage(UIImage(systemName: name), for: .normal)
        }
    }

    // MARK: - Checkbox Logic (Fix 4)

    @objc private func toggleCheckBox() {
        let isChecked = (checkBoxButton.currentImage == UIImage(systemName: "checkmark.square"))

        checkBoxButton.setImage(
            UIImage(systemName: isChecked ? "square" : "checkmark.square"),
            for: .normal
        )

        // enable/disable signup button
        let nowChecked = !isChecked
        signUpButton.isEnabled = nowChecked
        signUpButton.alpha = nowChecked ? 1.0 : 0.4
    }

    // MARK: - Sign Up

    @objc private func didTapSignUp() {

        // Validate fields
        guard let firstNameRaw = firstNameTF.text, !firstNameRaw.isEmpty,
              let lastNameRaw = lastNameTF.text, !lastNameRaw.isEmpty,
              let emailRaw = emailTF.text, !emailRaw.isEmpty,
              let phoneRaw = phoneTF.text, !phoneRaw.isEmpty,
              let passwordRaw = createPasswordTF.text, !passwordRaw.isEmpty,
              let confirmPasswordRaw = confirmPasswordTF.text, !confirmPasswordRaw.isEmpty else {
            showAlert(message: "Please fill in all fields")
            return
        }

        // Trim whitespace
        let firstName = firstNameRaw.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = lastNameRaw.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailRaw.trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = phoneRaw.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordRaw.trimmingCharacters(in: .whitespacesAndNewlines)
        let confirmPassword = confirmPasswordRaw.trimmingCharacters(in: .whitespacesAndNewlines)

        // Validate password match
        guard password == confirmPassword else {
            showAlert(message: "Passwords do not match")
            return
        }

        // Show loading state
        signUpButton.isEnabled = false
        signUpButton.setTitle("Creating account...", for: .normal)

        // Sign up with Supabase
        Task {
            do {
                // Create auth user
                let response = try await supabase.auth.signUp(
                    email: email,
                    password: password
                )

                print("✅ Sign up successful - User ID: \(response.user.id.uuidString)")

                // Sign in the user to establish a session (required for RLS)
                try await supabase.auth.signIn(email: email, password: password)
                print("✅ User signed in after signup")

                // Update user profile data in users table
                // (The row is auto-created by database trigger with id and email)
                let userId = response.user.id

                struct UserProfileUpdate: Encodable {
                    let first_name: String
                    let last_name: String
                    let phone: String
                    let role: String
                    let email_notifications: Bool
                    let sms_notifications: Bool
                }

                let profileUpdate = UserProfileUpdate(
                    first_name: firstName,
                    last_name: lastName,
                    phone: phone,
                    role: "buyer",
                    email_notifications: true,
                    sms_notifications: false
                )

                try await supabase
                    .from("users")
                    .update(profileUpdate)
                    .eq("id", value: userId.uuidString)
                    .execute()

                print("✅ User profile updated in users table")

                // Start notification listener
                await NotificationManager.shared.startListening()

                // Show success screen
                await MainActor.run {
                    let vc = AccountCreatedViewController(
                        nibName: "AccountCreatedViewController",
                        bundle: nil
                    )
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }

            } catch {
                print("❌ Sign up failed:", error)
                await MainActor.run {
                    signUpButton.isEnabled = true
                    signUpButton.setTitle("Sign Up", for: .normal)
                    showAlert(message: "Sign up failed: \(error.localizedDescription)")
                }
            }
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Terms / Privacy Setup  (Fix 1, 3, 5)

    private func setupTermsLabel() {
        let fullText =
"""
By clicking sign up, I hereby agree and consent to the Terms & Conditions. I confirm that I have read the Privacy Policy, and I certify that I am 18 years or older.
"""

        let attributed = NSMutableAttributedString(string: fullText)

        let termsRange = (fullText as NSString).range(of: "Terms & Conditions")
        let privacyRange = (fullText as NSString).range(of: "Privacy Policy")

        // Blue + underline
        [termsRange, privacyRange].forEach {
            attributed.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: $0)
            attributed.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: $0)
        }

        termsLabel.attributedText = attributed
        termsLabel.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTermsTap(_:)))
        tap.cancelsTouchesInView = false
        termsLabel.addGestureRecognizer(tap)
    }

    @objc private func handleTermsTap(_ gesture: UITapGestureRecognizer) {
        guard let text = termsLabel.attributedText?.string else { return }

        let termsRange = (text as NSString).range(of: "Terms & Conditions")
        let privacyRange = (text as NSString).range(of: "Privacy Policy")

        // FIX: improved multi-line tap detection
        if gesture.didTapRange(in: termsLabel, range: termsRange) {
            let vc = TermsAndConditionsViewController(nibName: "TermsAndConditionsViewController", bundle: nil)
            vc.addDismissButton() // ← Fix 2
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }

        if gesture.didTapRange(in: termsLabel, range: privacyRange) {
            let vc = PrivacyPolicyViewController(nibName: "PrivacyPolicyViewController", bundle: nil)
            vc.addDismissButton() // ← Fix 5
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }

    // MARK: - Constraints (unchanged)

    private func setupConstraints() {
        [cardView, titleLabel, fieldsContainer, checkBoxButton, termsLabel, signUpButton]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        let fields = [
            firstNameTF, lastNameTF, regTF, emailTF,
            phoneTF, createPasswordTF, confirmPasswordTF
        ]
        fields.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        separators.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        cardBottomConstraint = cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardBottomConstraint,
            cardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.70)
        ])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20)
        ])

        NSLayoutConstraint.activate([
            fieldsContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            fieldsContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            fieldsContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16)
        ])

        var prev = fieldsContainer.topAnchor
        for i in 0..<fields.count {
            let tf = fields[i]
            NSLayoutConstraint.activate([
                tf.topAnchor.constraint(equalTo: prev, constant: 12),
                tf.leadingAnchor.constraint(equalTo: fieldsContainer.leadingAnchor, constant: 8),
                tf.trailingAnchor.constraint(equalTo: fieldsContainer.trailingAnchor, constant: -8),
                tf.heightAnchor.constraint(equalToConstant: 34)
            ])

            if i < separators.count {
                let sep = separators[i]
                NSLayoutConstraint.activate([
                    sep.topAnchor.constraint(equalTo: tf.bottomAnchor, constant: 10),
                    sep.leadingAnchor.constraint(equalTo: fieldsContainer.leadingAnchor, constant: 16),
                    sep.trailingAnchor.constraint(equalTo: fieldsContainer.trailingAnchor, constant: -16),
                    sep.heightAnchor.constraint(equalToConstant: 1)
                ])
                prev = sep.bottomAnchor
            } else {
                prev = tf.bottomAnchor
            }
        }

        NSLayoutConstraint.activate([
            fieldsContainer.bottomAnchor.constraint(equalTo: prev, constant: 12)
        ])

        NSLayoutConstraint.activate([
            checkBoxButton.topAnchor.constraint(equalTo: fieldsContainer.bottomAnchor, constant: 14),
            checkBoxButton.leadingAnchor.constraint(equalTo: fieldsContainer.leadingAnchor),
            checkBoxButton.widthAnchor.constraint(equalToConstant: 22),
            checkBoxButton.heightAnchor.constraint(equalToConstant: 22),

            termsLabel.centerYAnchor.constraint(equalTo: checkBoxButton.centerYAnchor),
            termsLabel.leadingAnchor.constraint(equalTo: checkBoxButton.trailingAnchor, constant: 8),
            termsLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20)
        ])

        NSLayoutConstraint.activate([
            signUpButton.topAnchor.constraint(equalTo: termsLabel.bottomAnchor, constant: 18),
            signUpButton.leadingAnchor.constraint(equalTo: fieldsContainer.leadingAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: fieldsContainer.trailingAnchor),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            signUpButton.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -28)
        ])
    }
}


// MARK: - Improved Tap Detection (Fix 3)

extension UITapGestureRecognizer {
    func didTapRange(in label: UILabel, range: NSRange) -> Bool {
        guard let string = label.attributedText?.string else { return false }
        guard range.location != NSNotFound else { return false }

        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: label.bounds.size)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines

        let location = self.location(in: label)
        let index = layoutManager.characterIndex(
            for: location,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )

        return NSLocationInRange(index, range)
    }
}


// MARK: - Back Button For Terms + Privacy (Fix 2, Fix 5)

extension UIViewController {
    func addDismissButton() {
        let btn = UIButton(type: .system)
        btn.setTitle("← Back", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        btn.tintColor = .black
        btn.frame = CGRect(x: 16, y: 50, width: 80, height: 40)
        btn.addTarget(self, action: #selector(closeScreen), for: .touchUpInside)

        view.addSubview(btn)
    }

    @objc private func closeScreen() {
        dismiss(animated: true)
    }
}
