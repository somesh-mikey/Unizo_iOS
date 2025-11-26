//
//  ProductPostedViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 26/11/25.
//

import UIKit

class ProductPostedViewController: UIViewController {

    // MARK: - UI Elements
    private let iconContainer = UIView()
    private let iconImageView = UIImageView()
    private let dottedLinesView = UIImageView()

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let viewListingsButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.14, green: 0.42, blue: 0.53, alpha: 1.0)  // teal bg

        setupIcon()
        setupText()
        setupButton()
    }

    // MARK: Icon Setup
    private func setupIcon() {

        // Container (transparent)
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iconContainer)

        NSLayoutConstraint.activate([
            iconContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120),
            iconContainer.widthAnchor.constraint(equalToConstant: 180),
            iconContainer.heightAnchor.constraint(equalToConstant: 180)
        ])

        // Dotted lines (use your dotted image if you have)
        dottedLinesView.image = UIImage(named: "dotted-lines") ?? UIImage()
        dottedLinesView.contentMode = .scaleAspectFit
        dottedLinesView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(dottedLinesView)

        NSLayoutConstraint.activate([
            dottedLinesView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            dottedLinesView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            dottedLinesView.widthAnchor.constraint(equalToConstant: 160),
            dottedLinesView.heightAnchor.constraint(equalToConstant: 160)
        ])

        // Moneybag icon
        iconImageView.image = UIImage(named: "Money") ?? UIImage(systemName: "bag.fill")!
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconImageView)

        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 150),
            iconImageView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }

    // MARK: Text Setup
    private func setupText() {

        // Title
        titleLabel.text = "Your Product has been posted!"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Subtitle
        subtitleLabel.text = "We’ll reach out to the best valued customers."
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = UIColor(white: 1.0, alpha: 0.8)
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: Button Setup
    private func setupButton() {

        viewListingsButton.setTitle("View Listings", for: .normal)
        viewListingsButton.backgroundColor = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1.0)
        viewListingsButton.layer.cornerRadius = 26
        viewListingsButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        viewListingsButton.translatesAutoresizingMaskIntoConstraints = false

        viewListingsButton.addTarget(self, action: #selector(goToListings), for: .touchUpInside)

        view.addSubview(viewListingsButton)

        NSLayoutConstraint.activate([
            viewListingsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            viewListingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            viewListingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -35),
            viewListingsButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }

    @objc private func goToListings() {
        print("View Listings tapped")
        // Push next VC here
    }
}
