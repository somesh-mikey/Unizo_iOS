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
    @IBOutlet weak var bottomCardView: UIView!

    // TASK-08: Guest browsing button (programmatic)
    private let guestBrowseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

          // 🔥 DEBUG: Generate & log local user session ID
          print("SESSION USER ID:", Session.userId.uuidString)

          setupUI()
          setupConstraints()
          setupGuestButton()
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
           getStartedLabel.text = "Get Started Today".localized
           getStartedLabel.textAlignment = .center
           getStartedLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
           getStartedLabel.textColor = .black

           accountLabel.text = "Don't have an account?".localized
           accountLabel.textAlignment = .center
           accountLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
           accountLabel.textColor = .lightGray

           // --- LOGIN BUTTON ---
           if #available(iOS 15.0, *) {
               loginButton.configuration = nil
           }
           loginButton.setTitle("Login".localized, for: .normal)
           loginButton.backgroundColor = UIColor(red: 0/255, green: 76/255, blue: 97/255, alpha: 1)
           loginButton.setTitleColor(.white, for: .normal)
           loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
           loginButton.layer.cornerRadius = 24
           loginButton.clipsToBounds = true

           // --- SIGN-UP BUTTONS ---
        setupOutlinedButton(emailSignUpButton,
                            title: "Sign Up with Email".localized,
                            iconName: "envelope.fill",
                            tintColor: UIColor(red: 0/255, green: 76/255, blue: 97/255, alpha: 1))

       }

       // MARK: - Constraints Setup
    // MARK: - Constraints Setup
    private func setupConstraints() {
        // Disable autoresizing masks
        [booksImageView, bikeImageView, headphonesImageView, tshirtImageView,
         footballImageView, bottomCardView, getStartedLabel, loginButton,
         accountLabel, emailSignUpButton].forEach {
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
            // "Get Started Today" heading
            getStartedLabel.topAnchor.constraint(equalTo: bottomCardView.topAnchor, constant: 24),
            getStartedLabel.centerXAnchor.constraint(equalTo: bottomCardView.centerXAnchor),

            // Login button
            loginButton.topAnchor.constraint(equalTo: getStartedLabel.bottomAnchor, constant: 28),
            loginButton.leadingAnchor.constraint(equalTo: bottomCardView.leadingAnchor, constant: 32),
            loginButton.trailingAnchor.constraint(equalTo: bottomCardView.trailingAnchor, constant: -32),
            loginButton.heightAnchor.constraint(equalToConstant: 48),

            // "Don't have an account?" label
            accountLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 14),
            accountLabel.centerXAnchor.constraint(equalTo: bottomCardView.centerXAnchor),

            // Email sign-up button
            emailSignUpButton.topAnchor.constraint(equalTo: accountLabel.bottomAnchor, constant: 20),
            emailSignUpButton.leadingAnchor.constraint(equalTo: bottomCardView.leadingAnchor, constant: 32),
            emailSignUpButton.trailingAnchor.constraint(equalTo: bottomCardView.trailingAnchor, constant: -32),
            emailSignUpButton.heightAnchor.constraint(equalToConstant: 48)
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

        if #available(iOS 15.0, *) {
            button.configuration = nil
        }
        
        // Completely clear the button's default content
        button.setTitle("", for: .normal)
        button.setImage(nil, for: .normal)
        button.titleLabel?.isHidden = true

        // Remove any existing subviews (in case called multiple times)
        button.subviews.forEach { subview in
            if subview is UIStackView || subview is UIImageView || subview is UILabel {
                subview.removeFromSuperview()
            }
        }

        // 🔥 Bolder border
        button.layer.borderColor = tintColor.cgColor
        button.layer.borderWidth = 1.4
        button.layer.cornerRadius = 24
        button.layer.masksToBounds = true
        button.backgroundColor = .white

        // Icon
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        if iconName == "google_logo" {
            iconImageView.image = UIImage(named: "google_logo")
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            iconImageView.image = UIImage(systemName: iconName, withConfiguration: config)
            iconImageView.tintColor = tintColor
        }

        // Label
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = tintColor
        label.translatesAutoresizingMaskIntoConstraints = false

        button.addSubview(iconImageView)
        button.addSubview(label)

        // Shift logo specifically to the left and center the text
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 24),
            iconImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),

            label.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
    }

    // MARK: - Guest Button Setup
    private func setupGuestButton() {
        bottomCardView.addSubview(guestBrowseButton)
        guestBrowseButton.addTarget(self, action: #selector(guestBrowseTapped), for: .touchUpInside)

        setupOutlinedButton(guestBrowseButton,
                            title: "Browse as Guest".localized,
                            iconName: "person.fill",
                            tintColor: UIColor(red: 0/255, green: 76/255, blue: 97/255, alpha: 1))

        NSLayoutConstraint.activate([
            guestBrowseButton.topAnchor.constraint(equalTo: emailSignUpButton.bottomAnchor, constant: 16),
            guestBrowseButton.leadingAnchor.constraint(equalTo: bottomCardView.leadingAnchor, constant: 32),
            guestBrowseButton.trailingAnchor.constraint(equalTo: bottomCardView.trailingAnchor, constant: -32),
            guestBrowseButton.heightAnchor.constraint(equalToConstant: 48),
            guestBrowseButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomCardView.bottomAnchor, constant: -24)
        ])
    }


    // MARK: - Actions
    @objc private func guestBrowseTapped() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        MainTabBarController.isGuestMode = true
        window.rootViewController = MainTabBarController()
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
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

