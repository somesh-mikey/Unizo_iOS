//
//  OrderCardView.swift
//  Unizo_iOS
//
//  Created by Somesh on 25/11/25.
//

import UIKit

class OrderCardView: UIView {

    private let container = UIView()
    private let orderLabel = UILabel()
    private let dateLabel = UILabel()
    private let statusLabel = UILabel()
    
    private let productImage = UIImageView()
    private let productTitle = UILabel()
    private let productDetail = UILabel()
    private let productPrice = UILabel()
    private let moreItemsLabel = UILabel()

    private let divider = UIView()
    private let totalLabel = UILabel()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Configure
    func configure(order: MyOrdersViewController.Order) {
        orderLabel.text = "Order #\(order.orderID)"
        dateLabel.text = "Placed on \(order.date)"

        statusLabel.text = order.status
        statusLabel.textColor = order.statusColor
        statusLabel.backgroundColor = order.statusColor.withAlphaComponent(0.15)

        let firstItem = order.items.first!
        productImage.image = UIImage(named: firstItem.imageName)
        productTitle.text = firstItem.title
        productDetail.text = firstItem.detail
        productPrice.text = firstItem.price

        // compute total
        let total = order.items.compactMap { Int($0.price.replacingOccurrences(of: "₹", with: "")) }
            .reduce(0, +)
        totalLabel.text = "Total: ₹\(total)"

        // More items label
        if order.items.count > 1 {
            let extra = order.items.count - 1
            moreItemsLabel.text = "+\(extra) more item\(extra > 1 ? "s" : "") →"
            moreItemsLabel.isHidden = false
        } else {
            moreItemsLabel.isHidden = true
        }
    }

    // MARK: - UI Setup
    private func setupUI() {

        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.shadowOpacity = 0.1
        container.layer.shadowRadius = 5
        container.layer.shadowOffset = CGSize(width: 0, height: 2)

        addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false

        orderLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .gray

        statusLabel.font = .systemFont(ofSize: 12, weight: .medium)
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = 10
        statusLabel.layer.masksToBounds = true

        productImage.layer.cornerRadius = 8
        productImage.clipsToBounds = true
        productImage.contentMode = .scaleAspectFill

        productTitle.font = .systemFont(ofSize: 14, weight: .semibold)
        productDetail.font = .systemFont(ofSize: 12)
        productDetail.textColor = .gray

        productPrice.font = .systemFont(ofSize: 14, weight: .bold)

        moreItemsLabel.font = .systemFont(ofSize: 12, weight: .medium)
        moreItemsLabel.textColor = .systemBlue

        divider.backgroundColor = UIColor(white: 0.9, alpha: 1)

        totalLabel.font = .systemFont(ofSize: 14, weight: .semibold)

        [
            orderLabel, dateLabel, statusLabel,
            productImage, productTitle, productDetail, productPrice,
            moreItemsLabel, divider, totalLabel
        ].forEach { container.addSubview($0) }

        [
            orderLabel, dateLabel, statusLabel,
            productImage, productTitle, productDetail, productPrice,
            moreItemsLabel, divider, totalLabel
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }

    // MARK: - Constraints
    private func setupConstraints() {

        NSLayoutConstraint.activate([

            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Header
            orderLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            orderLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),

            statusLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            statusLabel.centerYAnchor.constraint(equalTo: orderLabel.centerYAnchor),
            statusLabel.widthAnchor.constraint(equalToConstant: 90),
            statusLabel.heightAnchor.constraint(equalToConstant: 22),

            dateLabel.topAnchor.constraint(equalTo: orderLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: orderLabel.leadingAnchor),

            // First product
            productImage.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            productImage.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            productImage.widthAnchor.constraint(equalToConstant: 60),
            productImage.heightAnchor.constraint(equalToConstant: 60),

            productTitle.topAnchor.constraint(equalTo: productImage.topAnchor),
            productTitle.leadingAnchor.constraint(equalTo: productImage.trailingAnchor, constant: 12),

            productDetail.topAnchor.constraint(equalTo: productTitle.bottomAnchor, constant: 2),
            productDetail.leadingAnchor.constraint(equalTo: productTitle.leadingAnchor),

            productPrice.topAnchor.constraint(equalTo: productDetail.bottomAnchor, constant: 4),
            productPrice.leadingAnchor.constraint(equalTo: productTitle.leadingAnchor),

            moreItemsLabel.topAnchor.constraint(equalTo: productImage.bottomAnchor, constant: 8),
            moreItemsLabel.leadingAnchor.constraint(equalTo: productImage.leadingAnchor),

            // Divider
            divider.topAnchor.constraint(equalTo: moreItemsLabel.bottomAnchor, constant: 16),
            divider.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            divider.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            divider.heightAnchor.constraint(equalToConstant: 1),

            // Total label
            totalLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 12),
            totalLabel.leadingAnchor.constraint(equalTo: divider.leadingAnchor),
            totalLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
    }
}


