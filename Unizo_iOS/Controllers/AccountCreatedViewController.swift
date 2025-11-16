//
//  AccountCreatedViewController.swift
//  Unizo_iOS
//
//  Created by Soham on 13/11/25.
//

import UIKit

class AccountCreatedViewController: UIViewController {

    // MARK: - UI Elements
    private let iconOuterCircle: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 176/255, green: 224/255, blue: 214/255, alpha: 1)   // Figma outer circle color
        view.layer.cornerRadius = 50
        return view
    }()
    
    private let iconInnerCircle: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "person.crop.circle")?
            .withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor(red: 88/255, green: 136/255, blue: 153/255, alpha: 1)
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Account has Been Set Up!"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your new go-to place for affordable finds and quick deals, right within your campus."
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.85)
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
    }()
    
    private let getStartedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Get Started", for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 76/255, blue: 97/255, alpha: 1)  
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return button
    }()
    

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        
        getStartedButton.addTarget(self, action: #selector(getStartedTapped), for: .touchUpInside)
    }

    
    // MARK: - UI Setup
    private func setupUI() {
        
        // FULL SCREEN BACKGROUND COLOR (EXACTLY LIKE FIGMA)
        view.backgroundColor = UIColor(red: 61/255, green: 124/255, blue: 152/255, alpha: 1)
        
        // Add all subviews
        view.addSubview(iconOuterCircle)
        iconOuterCircle.addSubview(iconInnerCircle)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(getStartedButton)
    }

    
    // MARK: - Constraints
    private func setupConstraints() {
        
        [
            iconOuterCircle,
            iconInnerCircle,
            titleLabel,
            subtitleLabel,
            getStartedButton
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            
            // ICON OUTER CIRCLE
            iconOuterCircle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconOuterCircle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120),
            iconOuterCircle.widthAnchor.constraint(equalToConstant: 100),
            iconOuterCircle.heightAnchor.constraint(equalToConstant: 100),
            
            // ICON INNER CIRCLE
            iconInnerCircle.centerXAnchor.constraint(equalTo: iconOuterCircle.centerXAnchor),
            iconInnerCircle.centerYAnchor.constraint(equalTo: iconOuterCircle.centerYAnchor),
            iconInnerCircle.widthAnchor.constraint(equalToConstant: 70),
            iconInnerCircle.heightAnchor.constraint(equalToConstant: 70),
            
            // TITLE LABEL
            titleLabel.topAnchor.constraint(equalTo: iconOuterCircle.bottomAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            // SUBTITLE LABEL
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // GET STARTED BUTTON
            getStartedButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            getStartedButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            getStartedButton.heightAnchor.constraint(equalToConstant: 52),
            getStartedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }
    
    
    // MARK: - Actions
    @objc private func getStartedTapped() {
        print("Get Started Pressed")
        
        // TODO: Navigate to next screen
        // For now:
        self.dismiss(animated: true)
    }
}
