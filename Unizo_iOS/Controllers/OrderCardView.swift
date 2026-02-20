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

    // Store order data for navigation
    private var currentOrder: OrderDTO?

    // Tap callback for navigation
    var onTap: ((OrderDTO) -> Void)?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Configure (Legacy - for sample data)
    func configure(order: MyOrdersViewController.Order) {
        orderLabel.text = String(format: "Order #%@".localized, order.orderID)
        dateLabel.text = String(format: "Placed on %@".localized, order.date)

        statusLabel.text = order.status
        statusLabel.textColor = order.statusColor
        statusLabel.backgroundColor = order.statusColor.withAlphaComponent(0.15)

        guard let firstItem = order.items.first else { return }
        productImage.image = UIImage(named: firstItem.imageName)
        productTitle.text = firstItem.title
        productDetail.text = firstItem.detail
        productPrice.text = firstItem.price

        // compute total
        let total = order.items.compactMap { Int($0.price.replacingOccurrences(of: "₹", with: "")) }
            .reduce(0, +)
        totalLabel.text = String(format: "Total: ₹%@".localized, "\(total)")

        // More items label
        if order.items.count > 1 {
            let extra = order.items.count - 1
            moreItemsLabel.text = extra > 1 ? String(format: "+%d more items →".localized, extra) : String(format: "+%d more item →".localized, extra)
            moreItemsLabel.isHidden = false
        } else {
            moreItemsLabel.isHidden = true
        }
    }

    // MARK: - Configure (Real data from OrderDTO)
    func configure(with order: OrderDTO) {
        // Store order for navigation
        self.currentOrder = order

        // Format order ID (show last 8 characters of UUID)
        let shortId = String(order.id.uuidString.suffix(8)).uppercased()
        orderLabel.text = String(format: "Order #%@".localized, shortId)

        // Format date
        dateLabel.text = String(format: "Placed on %@".localized, formatDate(order.created_at))

        // Status with color
        let status = OrderStatus(rawValue: order.status) ?? .pending
        statusLabel.text = status.rawValue.capitalized
        let statusColor = colorForStatus(status)
        statusLabel.textColor = statusColor
        statusLabel.backgroundColor = statusColor.withAlphaComponent(0.15)

        // First item display
        if let firstItem = order.items?.first {
            productTitle.text = firstItem.product?.title ?? "Product"

            // Build detail string
            var details: [String] = []
            if let colour = firstItem.colour, !colour.isEmpty {
                details.append("Color: \(colour)")
            }
            if let size = firstItem.size, !size.isEmpty {
                details.append(size)
            }
            productDetail.text = details.isEmpty ? "Qty: \(firstItem.quantity)" : details.joined(separator: " • ")

            productPrice.text = "₹\(Int(firstItem.price_at_purchase))"

            // Load image from URL
            if let imageUrl = firstItem.product?.imageUrl, !imageUrl.isEmpty {
                productImage.loadImage(from: imageUrl)
            } else {
                productImage.image = UIImage(systemName: "photo")
                productImage.tintColor = .systemGray3
            }
        } else {
            productTitle.text = "No items".localized
            productDetail.text = ""
            productPrice.text = ""
            productImage.image = UIImage(systemName: "photo")
            productImage.tintColor = .systemGray3
        }

        // Total amount
        totalLabel.text = String(format: "Total: ₹%d".localized, Int(order.total_amount))

        // More items label
        let itemCount = order.items?.count ?? 0
        if itemCount > 1 {
            let extra = itemCount - 1
            moreItemsLabel.text = extra > 1 ? String(format: "+%d more items →".localized, extra) : String(format: "+%d more item →".localized, extra)
            moreItemsLabel.isHidden = false
        } else {
            moreItemsLabel.isHidden = true
        }

        // Accessibility
        let shortIdForA11y = String(order.id.uuidString.suffix(8)).uppercased()
        let orderStatus = OrderStatus(rawValue: order.status) ?? .pending
        isAccessibilityElement = true
        accessibilityLabel = String(format: "Order %@, %@".localized, shortIdForA11y, orderStatus.rawValue.capitalized)
        accessibilityTraits = .button
        accessibilityHint = "View order details".localized
    }

    // MARK: - Helpers
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMM d, yyyy"
            return outputFormatter.string(from: date)
        }

        // Fallback: try without fractional seconds
        inputFormatter.formatOptions = [.withInternetDateTime]
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMM d, yyyy"
            return outputFormatter.string(from: date)
        }

        return dateString
    }

    private func colorForStatus(_ status: OrderStatus) -> UIColor {
        switch status {
        case .pending:
            return .systemOrange
        case .confirmed:
            return .systemBlue
        case .shipped:
            return .systemBlue
        case .delivered:
            return .systemGreen
        case .cancelled:
            return .systemRed
        }
    }

    // MARK: - UI Setup
    private func setupUI() {

        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.shadowOpacity = 0.1
        container.layer.shadowRadius = 5
        container.layer.shadowOffset = CGSize(width: 0, height: 2)

        // Add tap gesture for navigation
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true

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

    // MARK: - Actions
    @objc private func cardTapped() {
        guard let order = currentOrder else { return }
        onTap?(order)
    }
}


