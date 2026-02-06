//
//  ProductCell.swift
//  Unizo_iOS
//
//  Created by Somesh on 21/11/25.
//

import UIKit

final class ProductCell: UICollectionViewCell {

    // MARK: - Reuse
    static let reuseIdentifier = "ProductCell"

    // MARK: - UI Elements
    private let cardView = UIView()
    private let productImageView = UIImageView()
    private let separator = UIView()

    private let nameLabel = UILabel()
    private let starImageView = UIImageView()
    private let ratingLabel = UILabel()
    private let negotiableLabel = UILabel()
    private let priceLabel = UILabel()

    // MARK: - Init (CRASH SAFE)
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()   // 🔥 REQUIRED – DO NOT fatalError
    }

    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Card View
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 14
        cardView.layer.masksToBounds = true
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false

        // Shadow
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.08
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 6
        contentView.layer.masksToBounds = false

        // Product Image
        productImageView.contentMode = .scaleAspectFill
        productImageView.clipsToBounds = true
        productImageView.layer.cornerRadius = 10
        cardView.addSubview(productImageView)
        productImageView.translatesAutoresizingMaskIntoConstraints = false

        // Separator
        separator.backgroundColor = UIColor(white: 0.9, alpha: 1)
        cardView.addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false

        // Name - Dynamic Type support
        nameLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.numberOfLines = 2
        nameLabel.textColor = .label

        // Star
        starImageView.image = UIImage(systemName: "star.fill")
        starImageView.tintColor = .systemYellow
        starImageView.contentMode = .scaleAspectFit

        // Rating - Dynamic Type support
        ratingLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        ratingLabel.adjustsFontForContentSizeCategory = true
        ratingLabel.textColor = UIColor.brandPrimary

        // Negotiable - Dynamic Type support
        negotiableLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        negotiableLabel.adjustsFontForContentSizeCategory = true

        // Price - Dynamic Type support
        priceLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        priceLabel.adjustsFontForContentSizeCategory = true
        priceLabel.textColor = .label

        // Add subviews
        [nameLabel, starImageView, ratingLabel, negotiableLabel, priceLabel]
            .forEach {
                cardView.addSubview($0)
                $0.translatesAutoresizingMaskIntoConstraints = false
            }

        // Constraints
        NSLayoutConstraint.activate([

            // Card
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            // Image
            productImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            productImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            productImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
            productImageView.heightAnchor.constraint(equalToConstant: 140),

            // Separator
            separator.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 8),
            separator.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            separator.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            separator.heightAnchor.constraint(equalToConstant: 1),

            // Name
            nameLabel.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),

            // Star
            starImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            starImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            starImageView.widthAnchor.constraint(equalToConstant: 14),
            starImageView.heightAnchor.constraint(equalToConstant: 14),

            // Rating
            ratingLabel.centerYAnchor.constraint(equalTo: starImageView.centerYAnchor),
            ratingLabel.leadingAnchor.constraint(equalTo: starImageView.trailingAnchor, constant: 4),

            // Negotiable
            negotiableLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 4),
            negotiableLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),

            // Price
            priceLabel.topAnchor.constraint(equalTo: negotiableLabel.bottomAnchor, constant: 6),
            priceLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            priceLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -10),
            priceLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10)
        ])
    }

    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.image = UIImage(named: "placeholder")
    }

    // MARK: - Configure
    func configure(with product: ProductUIModel) {

        nameLabel.text = product.name
        priceLabel.text = "₹\(Int(product.price))"
        ratingLabel.text = String(format: "%.1f", product.rating)

        negotiableLabel.text = product.negotiable ? "Negotiable" : "Non-Negotiable"
        negotiableLabel.textColor = product.negotiable ? .systemGreen : .systemRed

        productImageView.image = UIImage(named: "placeholder")

        ImageLoader.shared.load(
            product.imageURL ?? "",
            into: productImageView,
            placeholder: UIImage(named: "placeholder")
        )

        // MARK: - Accessibility (Apple HIG Compliance)
        setupAccessibility(for: product)
    }

    private func setupAccessibility(for product: ProductUIModel) {
        // Make the entire cell accessible as a single element for VoiceOver
        isAccessibilityElement = true
        accessibilityTraits = .button

        // Create a comprehensive accessibility label
        let negotiableText = product.negotiable ? "Negotiable" : "Non-Negotiable"
        let availabilityText = product.isAvailable ? "" : ", Sold out"

        accessibilityLabel = "\(product.name), Price: \(Int(product.price)) rupees, Rating: \(String(format: "%.1f", product.rating)) out of 5 stars, \(negotiableText)\(availabilityText)"
        accessibilityHint = "Double tap to view product details"

        // Individual element accessibility (for when cell is not a single accessible element)
        productImageView.isAccessibilityElement = false
        nameLabel.isAccessibilityElement = false
        priceLabel.isAccessibilityElement = false
        ratingLabel.isAccessibilityElement = false
        negotiableLabel.isAccessibilityElement = false
    }

}
