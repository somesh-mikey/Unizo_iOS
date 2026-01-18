//
//  ProductCell.swift
//  Unizo_iOS
//
//  Created by Somesh on 21/11/25.
//

import UIKit

final class ProductCell: UICollectionViewCell {
    static let reuseIdentifier = "ProductCell"
    
    private let negotiableLabel = UILabel()
    private let starImageView = UIImageView()
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
        
        // --- Star Image ---
        starImageView.image = UIImage(systemName: "star.fill")
        starImageView.tintColor = UIColor.systemYellow
        starImageView.contentMode = .scaleAspectFit
        cardView.addSubview(starImageView)
        starImageView.translatesAutoresizingMaskIntoConstraints = false

        // --- Negotiable Label ---
        negotiableLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        negotiableLabel.textColor = UIColor.darkGray
        negotiableLabel.textAlignment = .left
        cardView.addSubview(negotiableLabel)
        negotiableLabel.translatesAutoresizingMaskIntoConstraints = false

        
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
            
            // STAR ICON
            starImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            starImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            starImageView.widthAnchor.constraint(equalToConstant: 14),
            starImageView.heightAnchor.constraint(equalToConstant: 14),

            // RATING LABEL
            ratingLabel.centerYAnchor.constraint(equalTo: starImageView.centerYAnchor),
            ratingLabel.leadingAnchor.constraint(equalTo: starImageView.trailingAnchor, constant: 4),

            // NEGOTIABLE LABEL
            negotiableLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 4),
            negotiableLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),

            // PRICE LABEL
            priceLabel.topAnchor.constraint(equalTo: negotiableLabel.bottomAnchor, constant: 6),
            priceLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            priceLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -10),
            priceLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10)

        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImage.image = UIImage(named: "placeholder")
    }

    
    func configure(with product: ProductUIModel) {

        nameLabel.text = product.name
        priceLabel.text = "₹\(Int(product.price))"
        ratingLabel.text = String(format: "%.1f", product.rating)

        negotiableLabel.text = product.negotiable
            ? "Negotiable"
            : "Non-Negotiable"

        negotiableLabel.textColor = product.negotiable
            ? UIColor.systemGreen
            : UIColor.systemRed

        // 🔥 RESET IMAGE FOR REUSE
        productImage.image = UIImage(named: "placeholder")

        // 🔥 LOAD FROM URL (SAME AS BANNERS)
        ImageLoader.shared.load(
            product.imageURL ?? "",
            into: productImage,
            placeholder: UIImage(named: "placeholder")
            
        )
        print("🖼 Loading product image:", product.imageURL ?? "nil")

    }

}
