//
//  ProductCell.swift
//  Unizo_iOS
//
//  Created by Somesh on 21/11/25.
//

import UIKit

final class ProductCell: UICollectionViewCell {
    static let reuseIdentifier = "ProductCell"

    private let cardView = UIView()
    private let productImage = UIImageView()
    private let nameLabel = UILabel()
    private let ratingLabel = UILabel()
    private let priceLabel = UILabel()
    private let separator = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear

        // --- Card View ---
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 10
        cardView.layer.masksToBounds = true
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        // --- Soft shadow ---
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.08
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 6
        contentView.layer.masksToBounds = false

        // --- Product Image ---
        productImage.contentMode = .scaleAspectFill
        productImage.clipsToBounds = true
        productImage.layer.cornerRadius = 8
        cardView.addSubview(productImage)
        productImage.translatesAutoresizingMaskIntoConstraints = false

        // --- Separator Line ---
        separator.backgroundColor = UIColor(white: 0.9, alpha: 1)
        cardView.addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false

        // --- Labels ---
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        nameLabel.numberOfLines = 2
        nameLabel.textColor = .black

        ratingLabel.font = UIFont.systemFont(ofSize: 12)
        ratingLabel.textColor = UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1) // teal

        priceLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        priceLabel.textColor = .black

        [nameLabel, ratingLabel, priceLabel].forEach {
            cardView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        // --- Layout Constraints ---
        NSLayoutConstraint.activate([
            // PRODUCT IMAGE
            productImage.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            productImage.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            productImage.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
            productImage.heightAnchor.constraint(equalToConstant: 140),

            // SEPARATOR
            separator.topAnchor.constraint(equalTo: productImage.bottomAnchor, constant: 8),
            separator.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            separator.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            separator.heightAnchor.constraint(equalToConstant: 1),

            // NAME LABEL
            nameLabel.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),

            // RATING LABEL (below name)
            ratingLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            ratingLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),

            // PRICE LABEL (below rating)
            priceLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            priceLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -10),
            priceLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10)
        ])
    }


    func configure(with product: ProductUIModel) {
        productImage.image = UIImage(named: product.imageName)
        nameLabel.text = product.name
        let negotiableText = product.negotiable ? "Negotiable" : "Non - Negotiable"
        ratingLabel.text = "★ \(String(format: "%.1f", product.rating)) | \(negotiableText)"
        priceLabel.text = "₹\(product.price)"
    }
}
