//
//  SplashViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 26/11/25.
//

import UIKit

class SplashViewController: UIViewController {

    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 38/255, green: 99/255, blue: 121/255, alpha: 1)

        setupLogo()
        setupTitle()
    }

    private func setupLogo() {
        logoImageView.image = UIImage(named: "Unizo") // <--- add your icon in Assets
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            logoImageView.widthAnchor.constraint(equalToConstant: 250),
            logoImageView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }

    private func setupTitle() {
        titleLabel.text = "unizo."
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
