//
//  OrderPlacedViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 19/11/25.
//

import UIKit

class OrderPlacedViewController: UIViewController {

    // MARK: - Outlets from XIB
    @IBOutlet weak var topBarContainer: UIView!
    @IBOutlet weak var iconContainer: UIView!
    @IBOutlet weak var titleContainer: UIView!
    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var suggestedTitleContainer: UIView!
    @IBOutlet weak var productsContainer: UIView!

    // MARK: - Buttons (ADDED)
    private let continueShoppingButton = UIButton(type: .system)
    private let backButton = UIButton(type: .system)

    // MARK: - Colors
    private let bgColor      = UIColor(red: 0.96, green: 0.97, blue: 1.0, alpha: 1.0)
    private let primaryTeal  = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1.0)
    private let accentTeal   = UIColor(red: 0.00, green: 0.62, blue: 0.71, alpha: 1.0)
    private let myOrderDetailButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = bgColor

        layoutContainers()
        setupTopBar()
        setupIconSection()
        setupTitleSection()
        setupButtons()
        setupSuggestedTitle()
        setupProductsSection()
        myOrderDetailButton.addTarget(self, action: #selector(openOrderDetails), for: .touchUpInside)

        // MARK: - Attach Actions (ADDED)
        continueShoppingButton.addTarget(self, action: #selector(continueShoppingTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backPressed), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false

        // Restore floating pill tab bar height + position
        if let mainTab = tabBarController as? MainTabBarController {
        }
    }


    // MARK: - Layout containers
    private func layoutContainers() {
        let allContainers: [UIView] = [
            topBarContainer,
            iconContainer,
            titleContainer,
            buttonContainer,
            suggestedTitleContainer,
            productsContainer
        ]

        allContainers.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .clear
        }

        NSLayoutConstraint.activate([
            topBarContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBarContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBarContainer.heightAnchor.constraint(equalToConstant: 56),

            iconContainer.topAnchor.constraint(equalTo: topBarContainer.bottomAnchor, constant: 16),
            iconContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            iconContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            iconContainer.heightAnchor.constraint(equalToConstant: 180),

            titleContainer.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 8),
            titleContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleContainer.heightAnchor.constraint(equalToConstant: 80),

            buttonContainer.topAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: 20),
            buttonContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonContainer.heightAnchor.constraint(equalToConstant: 120),

            suggestedTitleContainer.topAnchor.constraint(equalTo: buttonContainer.bottomAnchor, constant: 24),
            suggestedTitleContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            suggestedTitleContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            suggestedTitleContainer.heightAnchor.constraint(equalToConstant: 30),

            productsContainer.topAnchor.constraint(equalTo: suggestedTitleContainer.bottomAnchor, constant: 8),
            productsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            productsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            productsContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 40)
        ])
    }

    // MARK: - Top bar (back button)
    private func setupTopBar() {
        let backCircle = UIView()
        backCircle.backgroundColor = .white
        backCircle.layer.cornerRadius = 20
        backCircle.layer.shadowColor = UIColor.black.cgColor
        backCircle.layer.shadowOpacity = 0.06
        backCircle.layer.shadowRadius = 4
        backCircle.layer.shadowOffset = CGSize(width: 0, height: 2)
        backCircle.translatesAutoresizingMaskIntoConstraints = false

        // MARK: - Use CLASS backButton (CHANGED)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .black
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backCircle.addSubview(backButton)

        topBarContainer.addSubview(backCircle)

        NSLayoutConstraint.activate([
            backCircle.leadingAnchor.constraint(equalTo: topBarContainer.leadingAnchor, constant: 20),
            backCircle.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            backCircle.widthAnchor.constraint(equalToConstant: 40),
            backCircle.heightAnchor.constraint(equalToConstant: 40),

            backButton.centerXAnchor.constraint(equalTo: backCircle.centerXAnchor),
            backButton.centerYAnchor.constraint(equalTo: backCircle.centerYAnchor)
        ])
    }

    // MARK: - Icon section
    private func setupIconSection() {
        let circle = UIView()
        circle.backgroundColor = UIColor(red: 0.87, green: 0.94, blue: 0.98, alpha: 1.0)
        circle.layer.cornerRadius = 65
        circle.translatesAutoresizingMaskIntoConstraints = false

        let bagImage = UIImageView()
        bagImage.image = UIImage(systemName: "bag")
        bagImage.tintColor = primaryTeal
        bagImage.contentMode = .scaleAspectFit
        bagImage.translatesAutoresizingMaskIntoConstraints = false

        circle.addSubview(bagImage)
        iconContainer.addSubview(circle)

        NSLayoutConstraint.activate([
            circle.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            circle.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            circle.widthAnchor.constraint(equalToConstant: 130),
            circle.heightAnchor.constraint(equalToConstant: 130),

            bagImage.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            bagImage.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            bagImage.widthAnchor.constraint(equalToConstant: 50),
            bagImage.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Title section
    private func setupTitleSection() {
        let titleLabel = UILabel()
        titleLabel.text = "Order Placed!"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Your order has been successfully\nprocessed and its on its way to you soon"
        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        titleContainer.addSubview(titleLabel)
        titleContainer.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: titleContainer.topAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: titleContainer.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor, constant: -40)
        ])
    }

    // MARK: - Buttons
    private func setupButtons() {

        let primaryButton = myOrderDetailButton
        primaryButton.setTitle("My Order Detail", for: .normal)
        primaryButton.setTitleColor(.white, for: .normal)
        primaryButton.backgroundColor = primaryTeal
        primaryButton.layer.cornerRadius = 24
        primaryButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false

        // MARK: - Use CLASS continueShoppingButton (CHANGED)
        continueShoppingButton.setTitle("Continue Shopping", for: .normal)
        continueShoppingButton.setTitleColor(primaryTeal, for: .normal)
        continueShoppingButton.backgroundColor = .clear
        continueShoppingButton.layer.cornerRadius = 24
        continueShoppingButton.layer.borderWidth = 2
        continueShoppingButton.layer.borderColor = primaryTeal.cgColor
        continueShoppingButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        continueShoppingButton.translatesAutoresizingMaskIntoConstraints = false

        buttonContainer.addSubview(primaryButton)
        buttonContainer.addSubview(continueShoppingButton)

        NSLayoutConstraint.activate([
            primaryButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
            primaryButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor, constant: 30),
            primaryButton.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor, constant: -30),
            primaryButton.heightAnchor.constraint(equalToConstant: 50),

            continueShoppingButton.topAnchor.constraint(equalTo: primaryButton.bottomAnchor, constant: 14),
            continueShoppingButton.leadingAnchor.constraint(equalTo: primaryButton.leadingAnchor),
            continueShoppingButton.trailingAnchor.constraint(equalTo: primaryButton.trailingAnchor),
            continueShoppingButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Suggested title
    private func setupSuggestedTitle() {
        let label = UILabel()
        label.text = "Products You Might Like"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false

        suggestedTitleContainer.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: suggestedTitleContainer.leadingAnchor, constant: 20),
            label.centerYAnchor.constraint(equalTo: suggestedTitleContainer.centerYAnchor)
        ])
    }

    // MARK: - Products grid
    private func setupProductsSection() {
        let productsStack = UIStackView()
        productsStack.axis = .vertical
        productsStack.spacing = 24
        productsStack.translatesAutoresizingMaskIntoConstraints = false

        productsContainer.addSubview(productsStack)

        NSLayoutConstraint.activate([
            productsStack.topAnchor.constraint(equalTo: productsContainer.topAnchor),
            productsStack.leadingAnchor.constraint(equalTo: productsContainer.leadingAnchor, constant: 20),
            productsStack.trailingAnchor.constraint(equalTo: productsContainer.trailingAnchor, constant: -20),
            productsStack.bottomAnchor.constraint(equalTo: productsContainer.bottomAnchor, constant: -16)
        ])

        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.spacing = 16
        row1.distribution = .fillEqually
        row1.translatesAutoresizingMaskIntoConstraints = false

        row1.addArrangedSubview(makeDetailedProductCard(imageName: "Kettle",
                                                        title: "Prestige Electric Kettle",
                                                        rating: "4.9",
                                                        negotiableStatus: "Non - Negotiable",
                                                        price: "₹649"))

        row1.addArrangedSubview(makeDetailedProductCard(imageName: "lamp",
                                                        title: "Table Lamp",
                                                        rating: "4.2",
                                                        negotiableStatus: "Negotiable",
                                                        price: "₹500"))

        productsStack.addArrangedSubview(row1)

        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.spacing = 16
        row2.distribution = .fillEqually
        row2.translatesAutoresizingMaskIntoConstraints = false

        row2.addArrangedSubview(makeSimpleImageCard(imageName: "NoiseHeadphone"))
        row2.addArrangedSubview(makeSimpleImageCard(imageName: "Rackets"))

        productsStack.addArrangedSubview(row2)
    }

    private func makeDetailedProductCard(
        imageName: String,
        title: String,
        rating: String,
        negotiableStatus: String,
        price: String
    ) -> UIView {

        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 14
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.1
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 4
        card.translatesAutoresizingMaskIntoConstraints = false

        let productImage = UIImageView()
        productImage.image = UIImage(named: imageName)
        productImage.contentMode = .scaleAspectFill
        productImage.clipsToBounds = true
        productImage.layer.cornerRadius = 10
        productImage.translatesAutoresizingMaskIntoConstraints = false

        let nameLabel = UILabel()
        nameLabel.text = title
        nameLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        let ratingLabel = UILabel()
        ratingLabel.font = UIFont.systemFont(ofSize: 12)
        ratingLabel.textColor = UIColor(red: 0, green: 0.55, blue: 0.75, alpha: 1)
        ratingLabel.text = "★ \(rating)  |  \(negotiableStatus)"
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false

        let priceLabel = UILabel()
        priceLabel.text = price
        priceLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(productImage)
        card.addSubview(nameLabel)
        card.addSubview(ratingLabel)
        card.addSubview(priceLabel)

        NSLayoutConstraint.activate([
            productImage.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            productImage.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            productImage.widthAnchor.constraint(equalToConstant: 92),
            productImage.heightAnchor.constraint(equalToConstant: 119),

            nameLabel.topAnchor.constraint(equalTo: productImage.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),

            ratingLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            ratingLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            priceLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 6),
            priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])

        return card
    }

    private func makeSimpleImageCard(imageName: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 14
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.1
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 4
        card.translatesAutoresizingMaskIntoConstraints = false

        let productImage = UIImageView()
        productImage.image = UIImage(named: imageName)
        productImage.contentMode = .scaleAspectFill
        productImage.clipsToBounds = true
        productImage.layer.cornerRadius = 10
        productImage.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(productImage)

        NSLayoutConstraint.activate([
            productImage.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            productImage.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            productImage.widthAnchor.constraint(equalToConstant: 92),
            productImage.heightAnchor.constraint(equalToConstant: 119),
            productImage.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])

        return card
    }

    // MARK: - Actions
    @objc private func backPressed() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func continueShoppingTapped() {
        let vc = LandingScreenViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true, completion: nil)
    }
    @objc private func openOrderDetails() {
        let vc = OrderDetailsViewController()

        // If you are using a navigation controller (recommended)
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
            return
        }

        // If the screen was presented modally
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
