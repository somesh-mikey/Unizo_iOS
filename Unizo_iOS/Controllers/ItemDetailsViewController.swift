//
//  ItemDetailsViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 12/11/25.
//

import UIKit

class ItemDetailsViewController: UIViewController {

    // MARK: - Outlets from XIB
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!

    @IBOutlet weak var descriptionTitleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!

    @IBOutlet weak var featuresTitleLabel: UILabel!
    @IBOutlet weak var featuresTextView: UITextView!

    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var buyNowButton: UIButton!
    @IBOutlet weak var bottomBarView: UIView!   // ← Add an empty view at bottom of XIB


    // Scroll view and content view
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupScrollLayout()
        styleUI()
    }

    // MARK: - Navigation Bar
    private func setupNavigationBar() {
        title = "Cart"
        navigationController?.navigationBar.prefersLargeTitles = false

        let heartButton = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(heartTapped)
        )
        heartButton.tintColor = .black

        let cartButton = UIBarButtonItem(
            image: UIImage(systemName: "cart"),
            style: .plain,
            target: self,
            action: #selector(cartTapped)
        )
        cartButton.tintColor = .black

        navigationItem.rightBarButtonItems = [cartButton, heartButton]
    }

    @objc func heartTapped() {}
    @objc func cartTapped() {}


    // MARK: - SCROLL + CONSTRAINTS
    private func setupScrollLayout() {

        // 1️⃣ Add scrollView to main view
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // scrollView ends ABOVE bottom bar
            scrollView.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor)
        ])

        // 2️⃣ Add content view inside scroll view
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            // VERY IMPORTANT ↓
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // 3️⃣ Move all XIB items → into contentView
        let allItems: [UIView] = [
            productImageView, categoryLabel, titleLabel, priceLabel, ratingLabel,
            descriptionTitleLabel, descriptionTextView,
            featuresTitleLabel, featuresTextView
        ]

        allItems.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        // 4️⃣ Set constraints EXACT according to Figma

        NSLayoutConstraint.activate([

            // Image
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            productImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            productImageView.heightAnchor.constraint(equalToConstant: 260),

            // Category
            categoryLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 14),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            // Title
            titleLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            // Price
            priceLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Rating
            ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            // Description Title
            descriptionTitleLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 18),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            // Description Text
            descriptionTextView.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 8),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Features Title
            featuresTitleLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 24),
            featuresTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            // Features Text
            featuresTextView.topAnchor.constraint(equalTo: featuresTitleLabel.bottomAnchor, constant: 8),
            featuresTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            featuresTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // BOTTOM OF SCROLL CONTENT (VERY IMPORTANT)
            featuresTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }


    // MARK: - UI Styling
    private func styleUI() {

        descriptionTextView.isEditable = false
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.backgroundColor = .clear

        featuresTextView.isEditable = false
        featuresTextView.isScrollEnabled = false
        featuresTextView.backgroundColor = .clear

        addToCartButton.layer.cornerRadius = 22
        addToCartButton.layer.borderWidth = 1
        addToCartButton.layer.borderColor = UIColor.systemTeal.cgColor
        addToCartButton.setTitleColor(.systemTeal, for: .normal)

        buyNowButton.layer.cornerRadius = 22
        buyNowButton.backgroundColor = UIColor(red: 3/255, green: 54/255, blue: 73/255, alpha: 1)
        buyNowButton.setTitleColor(.white, for: .normal)
    }
}
