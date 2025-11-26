//
//  OrderRejectedViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 21/11/25.
//

import UIKit

class OrderRejectedViewController: UIViewController {

    // MARK: - Colors
    private let bgColor = UIColor(red: 0.94, green: 0.95, blue: 0.98, alpha: 1.0)
    private let darkTeal = UIColor(red: 0.07, green: 0.33, blue: 0.42, alpha: 1.0)
    private let borderTeal = UIColor(red: 0.00, green: 0.62, blue: 0.71, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = bgColor
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func setupUI() {

        // ----------------------------------------------------
        // TOP BACK BUTTON
        // ----------------------------------------------------
        let backCircle = UIView()
        backCircle.backgroundColor = .white
        backCircle.layer.cornerRadius = 22
        backCircle.layer.shadowColor = UIColor.black.cgColor
        backCircle.layer.shadowOpacity = 0.1
        backCircle.layer.shadowRadius = 4
        backCircle.layer.shadowOffset = CGSize(width: 0, height: 2)
        backCircle.translatesAutoresizingMaskIntoConstraints = false

        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(backPressed), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backCircle.addSubview(backButton)

        view.addSubview(backCircle)

        NSLayoutConstraint.activate([
            backCircle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backCircle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backCircle.widthAnchor.constraint(equalToConstant: 44),
            backCircle.heightAnchor.constraint(equalToConstant: 44),

            backButton.centerXAnchor.constraint(equalTo: backCircle.centerXAnchor),
            backButton.centerYAnchor.constraint(equalTo: backCircle.centerYAnchor)
        ])

        // ----------------------------------------------------
        // RED ICON CIRCLE
        // ----------------------------------------------------
        let iconCircle = UIView()
        iconCircle.backgroundColor = UIColor(red: 0.95, green: 0.41, blue: 0.39, alpha: 1.0) // Red circle
        iconCircle.layer.cornerRadius = 60
        iconCircle.translatesAutoresizingMaskIntoConstraints = false

        let iconImage = UIImageView(image: UIImage(named: "RedBag"))
        iconImage.contentMode = .scaleAspectFit
        iconImage.translatesAutoresizingMaskIntoConstraints = false

        iconCircle.addSubview(iconImage)
        view.addSubview(iconCircle)

        NSLayoutConstraint.activate([
            iconCircle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconCircle.topAnchor.constraint(equalTo: backCircle.bottomAnchor, constant: 60),
            iconCircle.widthAnchor.constraint(equalToConstant: 120),
            iconCircle.heightAnchor.constraint(equalToConstant: 120),

            iconImage.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            iconImage.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor),
            iconImage.widthAnchor.constraint(equalToConstant: 60),
            iconImage.heightAnchor.constraint(equalToConstant: 60)
        ])

        // ----------------------------------------------------
        // TITLE LABEL
        // ----------------------------------------------------
        let titleLabel = UILabel()
        titleLabel.text = "Order Rejected!"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        

        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: iconCircle.bottomAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        // ----------------------------------------------------
        // SUBTITLE LABEL
        // ----------------------------------------------------
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Jonathan’s order has been successfully\nrejected."
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        // ----------------------------------------------------
        // DISABLED PRIMARY BUTTON
        // ----------------------------------------------------
        let disabledButton = UIButton(type: .system)
        disabledButton.setTitle("View Order Detail", for: .normal)
        disabledButton.setTitleColor(.white, for: .normal)
        disabledButton.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        disabledButton.layer.cornerRadius = 25
        disabledButton.isEnabled = false
        disabledButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(disabledButton)

        NSLayoutConstraint.activate([
            disabledButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            disabledButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            disabledButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            disabledButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // ----------------------------------------------------
        // SECONDARY BUTTON (OUTLINED)
        // ----------------------------------------------------
        let secondaryButton = UIButton(type: .system)
        secondaryButton.setTitle("View Listings", for: .normal)
        secondaryButton.setTitleColor(borderTeal, for: .normal)
        secondaryButton.layer.borderColor = borderTeal.cgColor
        secondaryButton.layer.borderWidth = 2
        secondaryButton.layer.cornerRadius = 25
        secondaryButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(secondaryButton)

        NSLayoutConstraint.activate([
            secondaryButton.topAnchor.constraint(equalTo: disabledButton.bottomAnchor, constant: 20),
            secondaryButton.leadingAnchor.constraint(equalTo: disabledButton.leadingAnchor),
            secondaryButton.trailingAnchor.constraint(equalTo: disabledButton.trailingAnchor),
            secondaryButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Actions
    @objc private func backPressed() {
        navigationController?.popViewController(animated: true)
    }
}
