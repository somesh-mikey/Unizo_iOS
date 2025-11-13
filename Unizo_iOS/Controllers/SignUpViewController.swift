//
//  SignUpViewController.swift
//  Unizo_iOS
//
//  Created by Soham on 2025-11-13.
//

import UIKit

final class SignUpViewController: UIViewController {

    // MARK: - UI

    /// big rounded bottom card (same top-rounded shape as Login)
    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "card view background colour") ?? UIColor(red: 246/255, green: 246/255, blue: 248/255, alpha: 1)
        v.layer.cornerRadius = 40
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.clipsToBounds = true
        return v
    }()

    /// the inner white large container that holds all 7 fields
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

    // Separators between fields (6 separators for 7 fields)
    private var separators: [UIView] = []

    // Checkbox + terms
    private let checkBoxButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "square"), for: .normal)
        b.tintColor = .darkGray
        return b
    }()

    private let termsLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = UIFont.systemFont(ofSize: 12)
        l.textColor = .gray
        l.text = "By clicking sign up, I hereby agree and consent to the Terms & Conditions. I confirm that I have read the Privacy Policy, and I certify that I am 18 years or older."
        return l
    }()

    private let signUpButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Sign Up", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor(red: 0/255, green: 76/255, blue: 97/255, alpha: 1)
        b.layer.cornerRadius = 14
        b.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return b
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        setupFields()
        setupHierarchy()
        setupConstraints()
        setupActions()
    }

    // MARK: - Setup

    private func makeField(placeholder: String, secure: Bool = false) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = .darkGray
        tf.borderStyle = .none      // no border — separators handle the division
        tf.backgroundColor = .clear
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
        // create text fields (7)
        firstNameTF        = makeField(placeholder: "First Name")
        lastNameTF         = makeField(placeholder: "Last Name")
        regTF              = makeField(placeholder: "College Registration Number")
        emailTF            = makeField(placeholder: "College Email")
        phoneTF            = makeField(placeholder: "Your Phone Number")
        createPasswordTF   = makeField(placeholder: "Create Password", secure: true)
        confirmPasswordTF  = makeField(placeholder: "Confirm Password", secure: true)

        // create 6 separators
        separators = (0..<6).map { _ in makeSeparator() }

        // attach eye buttons to the two password fields
        addEyeButton(to: createPasswordTF)
        addEyeButton(to: confirmPasswordTF)
    }

    private func setupHierarchy() {
        // top-level card
        view.addSubview(cardView)

        // title and container
        cardView.addSubview(titleLabel)
        cardView.addSubview(fieldsContainer)

        // add fields + separators to the container, in order
        let fields = [firstNameTF, lastNameTF, regTF, emailTF, phoneTF, createPasswordTF, confirmPasswordTF]

        for i in 0..<fields.count {
            fieldsContainer.addSubview(fields[i])
            if i < separators.count {
                fieldsContainer.addSubview(separators[i])
            }
        }

        // checkbox, terms, signup button (under container)
        cardView.addSubview(checkBoxButton)
        cardView.addSubview(termsLabel)
        cardView.addSubview(signUpButton)
    }

    private func setupActions() {
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        checkBoxButton.addTarget(self, action: #selector(toggleCheckBox), for: .touchUpInside)
    }

    // MARK: - Eye toggle helper
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
        // determine which textfield this button belongs to
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

    // MARK: - Actions

    @objc private func toggleCheckBox() {
        let isChecked = (checkBoxButton.currentImage == UIImage(systemName: "checkmark.square"))
        checkBoxButton.setImage(UIImage(systemName: isChecked ? "square" : "checkmark.square"), for: .normal)
    }

    @objc private func didTapSignUp() {
        // hook into your registration flow here
        print("Sign Up button tapped")

        let vc = AccountCreatedViewController(nibName: "AccountCreatedViewController", bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    // MARK: - Constraints

    private func setupConstraints() {
        // turn off autoresizing masks
        [cardView, titleLabel, fieldsContainer, checkBoxButton, termsLabel, signUpButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        let fields = [firstNameTF, lastNameTF, regTF, emailTF, phoneTF, createPasswordTF, confirmPasswordTF]
        fields.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        separators.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        // Card view - full width, bottom anchored, takes about 75% of height
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.75)
        ])

        // Title
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20)
        ])

        // Fields container: inside card, rounded white box
        NSLayoutConstraint.activate([
            fieldsContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            fieldsContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            fieldsContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16)
        ])

        // Layout the 7 fields + 6 separators vertically inside fieldsContainer
        // field height: 34 (as you requested)
        // separators height: 1
        // inside container left/right edges align to container edges
        var previousAnchor = fieldsContainer.topAnchor
        for i in 0..<fields.count {
            let tf = fields[i]
            NSLayoutConstraint.activate([
                tf.topAnchor.constraint(equalTo: previousAnchor, constant: (i == 0 ? 12 : 12)),
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
                previousAnchor = sep.bottomAnchor
            } else {
                previousAnchor = tf.bottomAnchor
            }
        }

        // Ensure fieldsContainer has a bottom anchor (so Auto Layout can determine its intrinsic height)
        NSLayoutConstraint.activate([
            fieldsContainer.bottomAnchor.constraint(equalTo: previousAnchor, constant: 12)
        ])

        // Checkbox and terms - placed under fieldsContainer
        NSLayoutConstraint.activate([
            checkBoxButton.topAnchor.constraint(equalTo: fieldsContainer.bottomAnchor, constant: 14),
            checkBoxButton.leadingAnchor.constraint(equalTo: fieldsContainer.leadingAnchor),
            checkBoxButton.widthAnchor.constraint(equalToConstant: 22),
            checkBoxButton.heightAnchor.constraint(equalToConstant: 22),

            termsLabel.centerYAnchor.constraint(equalTo: checkBoxButton.centerYAnchor),
            termsLabel.leadingAnchor.constraint(equalTo: checkBoxButton.trailingAnchor, constant: 8),
            termsLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20)
        ])

        // Sign up button below terms
        NSLayoutConstraint.activate([
            signUpButton.topAnchor.constraint(equalTo: termsLabel.bottomAnchor, constant: 18),
            signUpButton.leadingAnchor.constraint(equalTo: fieldsContainer.leadingAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: fieldsContainer.trailingAnchor),
            signUpButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Bottom spacing - keep some breathing room
        NSLayoutConstraint.activate([
            signUpButton.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -28)
        ])
    }
}
