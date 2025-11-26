//
//  WelcomeViewController.swift
//  Unizo_iOS
//
//  Created by Somesh on 11/11/25.
//

import UIKit

class WelcomeViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var booksImageView: UIImageView!
    @IBOutlet weak var bikeImageView: UIImageView!
    @IBOutlet weak var headphonesImageView: UIImageView!
    @IBOutlet weak var tshirtImageView: UIImageView!
    @IBOutlet weak var footballImageView: UIImageView!

    @IBOutlet weak var getStartedLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var emailSignUpButton: UIButton!
    @IBOutlet weak var appleSignUpButton: UIButton!
    @IBOutlet weak var bottomCardView: UIView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }

    // MARK: - UI Setup
    private func setupUI() {
           view.backgroundColor = UIColor(red: 183/255, green: 230/255, blue: 235/255, alpha: 1)

           // --- IMAGE VIEWS STYLING ---
           styleImageView(booksImageView, color: UIColor(red: 253/255, green: 216/255, blue: 106/255, alpha: 1))
           styleImageView(bikeImageView, color: UIColor(red: 108/255, green: 200/255, blue: 200/255, alpha: 1))
           styleImageView(headphonesImageView, color: UIColor(red: 61/255, green: 190/255, blue: 235/255, alpha: 1))
           styleImageView(tshirtImageView, color: UIColor(red: 137/255, green: 211/255, blue: 197/255, alpha: 1))
           styleImageView(footballImageView, color: UIColor(red: 159/255, green: 209/255, blue: 128/255, alpha: 1))

           // --- CARD VIEW ---
           bottomCardView.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 248/255, alpha: 1)
           bottomCardView.layer.cornerRadius = 40
           bottomCardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
           bottomCardView.clipsToBounds = true

           // --- LABELS ---
           getStartedLabel.text = "Get Started Today"
           getStartedLabel.textAlignment = .center
           getStartedLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
           getStartedLabel.textColor = .black

           accountLabel.text = "Don’t have an account?"
           accountLabel.textAlignment = .center
           accountLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
           accountLabel.textColor = .lightGray

           // --- LOGIN BUTTON ---
           loginButton.setTitle("Login", for: .normal)
           loginButton.backgroundColor = UIColor(red: 0/255, green: 76/255, blue: 97/255, alpha: 1)
           loginButton.setTitleColor(.white, for: .normal)
           loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
           loginButton.layer.cornerRadius = 10

           // --- SIGN-UP BUTTONS ---
        setupOutlinedButton(emailSignUpButton,
                            title: "Sign Up with Email",
                            iconName: "envelope.fill",
                            tintColor: UIColor(red: 0/255, green: 76/255, blue: 97/255, alpha: 1))

        setupOutlinedButton(appleSignUpButton,
                            title: "Sign Up with Google",
                            iconName: "google_logo",   // ⭐️ Your asset name
                            tintColor: UIColor(red: 0/255, green: 76/255, blue: 97/255, alpha: 1))

       }

       // MARK: - Constraints Setup
    // MARK: - Constraints Setup
    private func setupConstraints() {
        // Disable autoresizing masks
        [booksImageView, bikeImageView, headphonesImageView, tshirtImageView,
         footballImageView, bottomCardView, getStartedLabel, loginButton,
         accountLabel, emailSignUpButton, appleSignUpButton].forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }

        let safe = view.safeAreaLayoutGuide

        // 🎯 Refined adaptive sizing
        let itemSize: CGFloat = 144
        let horizontalPadding: CGFloat = 36
        let interRow: CGFloat = 18
        let interColumn: CGFloat = 24

        NSLayoutConstraint.activate([
            // --- IMAGE GRID LAYOUT ---

            // Row 1: Books + Bike
            booksImageView.topAnchor.constraint(equalTo: safe.topAnchor, constant: 50),
            booksImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            booksImageView.widthAnchor.constraint(equalToConstant: itemSize),
            booksImageView.heightAnchor.constraint(equalToConstant: itemSize),

            bikeImageView.topAnchor.constraint(equalTo: booksImageView.topAnchor),
            bikeImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding),
            bikeImageView.widthAnchor.constraint(equalToConstant: itemSize),
            bikeImageView.heightAnchor.constraint(equalToConstant: itemSize),

            // Row 2: Headphones + T-shirt
            headphonesImageView.topAnchor.constraint(equalTo: booksImageView.bottomAnchor, constant: interRow),
            headphonesImageView.leadingAnchor.constraint(equalTo: booksImageView.leadingAnchor),
            headphonesImageView.widthAnchor.constraint(equalTo: booksImageView.widthAnchor),
            headphonesImageView.heightAnchor.constraint(equalTo: booksImageView.heightAnchor),

            tshirtImageView.topAnchor.constraint(equalTo: bikeImageView.bottomAnchor, constant: interRow),
            tshirtImageView.trailingAnchor.constraint(equalTo: bikeImageView.trailingAnchor),
            tshirtImageView.widthAnchor.constraint(equalTo: bikeImageView.widthAnchor),
            tshirtImageView.heightAnchor.constraint(equalTo: bikeImageView.heightAnchor),

            // Keep even horizontal distance between columns
            bikeImageView.leadingAnchor.constraint(greaterThanOrEqualTo: booksImageView.trailingAnchor, constant: interColumn),
            tshirtImageView.leadingAnchor.constraint(greaterThanOrEqualTo: headphonesImageView.trailingAnchor, constant: interColumn),

            // Row 3: Football (centered below both columns)
            footballImageView.topAnchor.constraint(equalTo: headphonesImageView.bottomAnchor, constant: interRow),
            footballImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            footballImageView.widthAnchor.constraint(equalTo: booksImageView.widthAnchor),
            footballImageView.heightAnchor.constraint(equalTo: booksImageView.heightAnchor),

            // --- BOTTOM CARD ---
            bottomCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // 👇 move the card up slightly to overlap the blue area
            bottomCardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomCardView.topAnchor.constraint(equalTo: footballImageView.bottomAnchor, constant: -20),
            bottomCardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 280)

        ])

        // --- CARD CONTENT ---
        NSLayoutConstraint.activate([
            // Move "Get Started Today" a little higher for better balance
            getStartedLabel.topAnchor.constraint(equalTo: bottomCardView.topAnchor, constant: 14),
            getStartedLabel.centerXAnchor.constraint(equalTo: bottomCardView.centerXAnchor),

            // Login button closer for visual grouping
            loginButton.topAnchor.constraint(equalTo: getStartedLabel.bottomAnchor, constant: 25),
            loginButton.leadingAnchor.constraint(equalTo: bottomCardView.leadingAnchor, constant: 32),
            loginButton.trailingAnchor.constraint(equalTo: bottomCardView.trailingAnchor, constant: -32),
            loginButton.heightAnchor.constraint(equalToConstant: 48),

            // Account label centered with tighter spacing
            accountLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 6),
            accountLabel.centerXAnchor.constraint(equalTo: bottomCardView.centerXAnchor),

            // Email sign-up with equal breathing space
            emailSignUpButton.topAnchor.constraint(equalTo: accountLabel.bottomAnchor, constant: 20),
            emailSignUpButton.leadingAnchor.constraint(equalTo: bottomCardView.leadingAnchor, constant: 32),
            emailSignUpButton.trailingAnchor.constraint(equalTo: bottomCardView.trailingAnchor, constant: -32),
            emailSignUpButton.heightAnchor.constraint(equalToConstant: 46),

            // Apple sign-up evenly spaced below email
            appleSignUpButton.topAnchor.constraint(equalTo: emailSignUpButton.bottomAnchor, constant: 14),
            appleSignUpButton.leadingAnchor.constraint(equalTo: bottomCardView.leadingAnchor, constant: 32),
            appleSignUpButton.trailingAnchor.constraint(equalTo: bottomCardView.trailingAnchor, constant: -32),
            appleSignUpButton.heightAnchor.constraint(equalToConstant: 46),

            // Perfect bottom padding for curved edge clearance
            appleSignUpButton.bottomAnchor.constraint(equalTo: bottomCardView.bottomAnchor, constant: -48)
        ])



    }

       // MARK: - Helper Methods
       private func styleImageView(_ imageView: UIImageView, color: UIColor) {
           imageView.backgroundColor = color
           imageView.layer.cornerRadius = 12
           imageView.contentMode = .scaleAspectFit
           imageView.clipsToBounds = true
       }

    private func setupOutlinedButton(_ button: UIButton,
                                     title: String,
                                     iconName: String,
                                     tintColor: UIColor) {

        button.setTitle(title, for: .normal)
        button.setTitleColor(tintColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)

        // 🔥 Bolder border
        button.layer.borderColor = tintColor.cgColor
        button.layer.borderWidth = 1.4
        button.layer.cornerRadius = 10

        // ----- ICON SETUP -----
        var icon: UIImage?

        if iconName == "google_logo" {
            // Use the asset and scale it down explicitly
            let base = UIImage(named: "google_logo")
            // Target smaller size (e.g., 14x14) for a subtler look
            let targetSize = CGSize(width: 30, height: 30)
            if let base = base {
                // Render a resized image to avoid layout fighting
                UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
                base.draw(in: CGRect(origin: .zero, size: targetSize))
                icon = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
        } else {
            icon = UIImage(systemName: iconName)
        }

        button.setImage(icon, for: .normal)
        // Ensure SF Symbols render with the provided tint (teal)
        if iconName != "google_logo" {
            button.tintColor = UIColor(red: 0/255, green: 76/255, blue: 97/255, alpha: 1)
        }
        button.imageView?.contentMode = .scaleAspectFit

        if iconName == "google_logo" {
            // More spacing between Google icon and text
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -22, bottom: 0, right: 16)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: -20)
        } else {
            // More spacing between email SF symbol and text (updated as per instructions)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -26, bottom: 0, right: 20)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: -24)
        }


        // Prevent the icon from shrinking
        button.imageView?.setContentHuggingPriority(.required, for: .horizontal)
    }

    // MARK: - Actions
    @IBAction func loginButtonTapped(_ sender: UIButton) {

        let loginVC = LoginModalViewController()   // <-- PROGRAMMATIC INIT (NO XIB)

        loginVC.modalPresentationStyle = .overCurrentContext
        loginVC.modalTransitionStyle = .coverVertical

        present(loginVC, animated: true)
    }
    @IBAction func emailSignUpButtonTapped(_ sender: UIButton) {

        let signUpVC = SignUpViewController(nibName: "SignUpViewController", bundle: nil)
        signUpVC.modalPresentationStyle = .overCurrentContext
        signUpVC.modalTransitionStyle = .coverVertical

        present(signUpVC, animated: true)
    }
    
}
