//
//  ItemDetailsViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 12/11/25.
//

import UIKit

class ItemDetailsViewController: UIViewController {

    // MARK: - Incoming Product (From Landing Screen)
    var product: Product?

    // MARK: - Outlets from XIB
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var featuresTextView: UITextView!
    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var buyNowButton: UIButton!

    // Scroll container
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupLayout()
        fillProductData()      // ⭐ Load product details
    }

    // MARK: - Fill UI with Product Data
    private func fillProductData() {

        guard let p = product else { return }

        title = p.name
        titleLabel.text = p.name
        priceLabel.text = "₹\(p.price)"
        ratingLabel.text = "⭐️ \(p.rating)"
        productImageView.image = UIImage(named: p.imageName)

        // Fake values (if needed)
        categoryLabel.text = "General"

        descriptionTextView.text = "This is a high-quality item available on Unizo."
        featuresTextView.text = "• Great condition\n• 100% authentic\n• Trusted seller"

        // Negotiable styling
        if p.negotiable {
            priceLabel.textColor = UIColor(red: 0/255, green: 142/255, blue: 153/255, alpha: 1)
        } else {
            priceLabel.textColor = .black
        }
    }


    // MARK: - Navigation Bar
    private func setupNavigationBar() {
        title = "Item Details"
        navigationController?.navigationBar.prefersLargeTitles = false

        let heartButton = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(heartTapped)
        )

        let cartButton = UIBarButtonItem(
            image: UIImage(systemName: "cart"),
            style: .plain,
            target: self,
            action: #selector(cartTapped)
        )

        heartButton.tintColor = .black
        cartButton.tintColor = .black
        navigationItem.rightBarButtonItems = [cartButton, heartButton]
    }


    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white

        // Image styling
        productImageView.contentMode = .scaleAspectFit
        productImageView.layer.cornerRadius = 12
        productImageView.layer.masksToBounds = true

        // Label styling
        categoryLabel.textColor = .systemGray
        categoryLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        priceLabel.font = UIFont.boldSystemFont(ofSize: 20)
        ratingLabel.font = UIFont.systemFont(ofSize: 15)
        ratingLabel.textColor = UIColor(red: 0/255, green: 142/255, blue: 153/255, alpha: 1)

        // TextViews styling
        [descriptionTextView, featuresTextView].forEach {
            $0?.isScrollEnabled = false
            $0?.backgroundColor = .clear
            $0?.textColor = .black
            $0?.font = UIFont.systemFont(ofSize: 14)
            $0?.textContainerInset = .zero
            $0?.textContainer.lineFragmentPadding = 0
        }

        // Buttons styling
        addToCartButton.layer.cornerRadius = 22
        addToCartButton.layer.borderWidth = 1.5
        addToCartButton.layer.borderColor = UIColor.systemTeal.cgColor
        addToCartButton.backgroundColor = .clear
        addToCartButton.setTitleColor(.systemTeal, for: .normal)
        addToCartButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)

        buyNowButton.layer.cornerRadius = 22
        buyNowButton.backgroundColor = UIColor(red: 22/255, green: 63/255, blue: 75/255, alpha: 1)
        buyNowButton.setTitleColor(.white, for: .normal)
        buyNowButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }


    // MARK: - Layout Setup
    private func setupLayout() {

        // Add scrollView
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // Add all XIB views to our contentView
        [
            productImageView, categoryLabel, titleLabel,
            priceLabel, ratingLabel, descriptionTextView, featuresTextView
        ].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        // Bottom buttons (outside scroll)
        let buttonStack = UIStackView(arrangedSubviews: [addToCartButton, buyNowButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        view.addSubview(buttonStack)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        // ScrollView constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -10),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Image
        NSLayoutConstraint.activate([
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            productImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            productImageView.heightAnchor.constraint(equalToConstant: 240)
        ])

        // Labels & text
        NSLayoutConstraint.activate([
            categoryLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 10),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            titleLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            priceLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            descriptionTextView.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 10),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            featuresTextView.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 10),
            featuresTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            featuresTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            featuresTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])

        // Buttons at bottom
        NSLayoutConstraint.activate([
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            addToCartButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Actions
    @objc private func heartTapped() {
        print("❤️ Heart tapped")
    }

    @objc private func cartTapped() {
        print("🛒 Cart tapped")
    }
}
