//
//  LoginModalViewController.swift
//  Unizo_iOS
//
//  Created by Soham on 12/11/25.
//

import UIKit

class LoginModalViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var loginTitleLabel: UILabel!
    @IBOutlet weak var collegeRegTextField: UITextField!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var collegeEmailTextField: UITextField!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    private let phoneSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        return view
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }

    // MARK: - UI Setup
    private func setupUI() {
        // Background overlay
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        // Card View styling
        cardView.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 248/255, alpha: 1)
        cardView.layer.cornerRadius = 40
        cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        cardView.clipsToBounds = true

        // Title Label
        loginTitleLabel.text = "Login To Your Account"
        loginTitleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        loginTitleLabel.textColor = .black
        loginTitleLabel.textAlignment = .center

        // Text Fields Styling
        setupTextField(collegeRegTextField, placeholder: "College Registration Number")
        setupTextField(collegeEmailTextField, placeholder: "College Email")
        setupTextField(phoneTextField, placeholder: "Your Phone Number")
        setupTextField(passwordTextField, placeholder: "Password")
        passwordTextField.isSecureTextEntry = true

        // Add Eye Toggle Button
        let eyeButton = UIButton(type: .system)
        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        eyeButton.tintColor = .gray
        eyeButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        passwordTextField.rightView = eyeButton
        passwordTextField.rightViewMode = .always

        // Separator line
        separatorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        cardView.addSubview(phoneSeparatorView)

        // OR Label
        orLabel.text = "OR"
        orLabel.textAlignment = .center
        orLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        orLabel.textColor = .gray

        // Forgot Password Button
        forgotPasswordButton.setTitle("Forgot Password?", for: .normal)
        forgotPasswordButton.setTitleColor(UIColor.systemBlue, for: .normal)
        forgotPasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)

        // Login Button
        loginButton.setTitle("Login", for: .normal)
        loginButton.backgroundColor = UIColor(red: 0/255, green: 76/255, blue: 97/255, alpha: 1)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 10
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }

    private func setupTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.textColor = .darkGray
        textField.backgroundColor = .white
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        textField.layer.cornerRadius = 8
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
    }

    // MARK: - Password Visibility Toggle
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
        let iconName = passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
        sender.setImage(UIImage(systemName: iconName), for: .normal)
    }

    // MARK: - Constraints Setup
    private func setupConstraints() {

        // 1️⃣ Disable autoresizing masks
        [
            cardView,
            loginTitleLabel,
            collegeRegTextField,
            separatorView,
            collegeEmailTextField,
            orLabel,
            phoneTextField,
            phoneSeparatorView,
            passwordTextField,
            forgotPasswordButton,
            loginButton
        ].forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }

        //let safe = view.safeAreaLayoutGuide******************************************

        NSLayoutConstraint.activate([
            // --- Card View ---
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),

            // --- Title ---
            loginTitleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            loginTitleLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            // --- College Reg Text Field ---
            collegeRegTextField.topAnchor.constraint(equalTo: loginTitleLabel.bottomAnchor, constant: 22),
            collegeRegTextField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 32),
            collegeRegTextField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -32),
            collegeRegTextField.heightAnchor.constraint(equalToConstant: 46),

            // --- Separator ---
            separatorView.topAnchor.constraint(equalTo: collegeRegTextField.bottomAnchor, constant: 10),
            separatorView.leadingAnchor.constraint(equalTo: collegeRegTextField.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: collegeRegTextField.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            // --- College Email Text Field ---
            collegeEmailTextField.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            collegeEmailTextField.leadingAnchor.constraint(equalTo: collegeRegTextField.leadingAnchor),
            collegeEmailTextField.trailingAnchor.constraint(equalTo: collegeRegTextField.trailingAnchor),
            collegeEmailTextField.heightAnchor.constraint(equalToConstant: 46),

            // --- OR Label ---
            orLabel.topAnchor.constraint(equalTo: collegeEmailTextField.bottomAnchor, constant: 16),
            orLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            // --- Phone Number Text Field ---
            phoneTextField.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 16),
            phoneTextField.leadingAnchor.constraint(equalTo: collegeEmailTextField.leadingAnchor),
            phoneTextField.trailingAnchor.constraint(equalTo: collegeEmailTextField.trailingAnchor),
            phoneTextField.heightAnchor.constraint(equalToConstant: 46),
            
            // --- SECOND Separator (between phone and password) ---
            phoneSeparatorView.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 10),
            phoneSeparatorView.leadingAnchor.constraint(equalTo: phoneTextField.leadingAnchor),
            phoneSeparatorView.trailingAnchor.constraint(equalTo: phoneTextField.trailingAnchor),
            phoneSeparatorView.heightAnchor.constraint(equalToConstant: 1),

            // --- Password Text Field ---
            passwordTextField.topAnchor.constraint(equalTo: phoneSeparatorView.bottomAnchor, constant: 10),
            passwordTextField.leadingAnchor.constraint(equalTo: phoneTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: phoneTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 46),

            // --- Forgot Password ---
            forgotPasswordButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 8),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            // --- Login Button ---
            loginButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 18),
            loginButton.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            loginButton.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -30)
        ])
    }

    // MARK: - Actions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        print("Login button tapped")
        dismiss(animated: true)
    }
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {

        // Dismiss Login Popup FIRST
        self.dismiss(animated: true) {

            // Find the root view controller (Welcome screen)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {

                let resetVC = ResetPasswordViewController(nibName: "ResetPasswordViewController", bundle: nil)
                resetVC.modalPresentationStyle = .overCurrentContext
                resetVC.modalTransitionStyle = .coverVertical

                rootVC.present(resetVC, animated: true)
            }
        }
    }
}
