//
//  ListingCell.swift
//

import UIKit

protocol ListingCellDelegate: AnyObject {
    func didTapEdit(on cell: ListingCell)
    func didTapDelete(on cell: ListingCell)
    func didTapView(on cell: ListingCell)  // Tap to view product details
}

final class ListingCell: UICollectionViewCell {

    weak var delegate: ListingCellDelegate?

    private let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let categoryLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = .darkGray
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        lbl.numberOfLines = 1
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let statusLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = .gray
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let priceLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let editButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        btn.tintColor = .darkGray
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "trash"), for: .normal)
        btn.tintColor = .red
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 20
        backgroundColor = .white
        setupUI()

        // Add tap gesture to view product details
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        contentView.addGestureRecognizer(tapGesture)
    }

    @objc private func cellTapped() {
        delegate?.didTapView(on: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {

        contentView.addSubview(productImageView)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(editButton)
        contentView.addSubview(deleteButton)

        NSLayoutConstraint.activate([

            // Image
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            productImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            productImageView.widthAnchor.constraint(equalToConstant: 70),
            productImageView.heightAnchor.constraint(equalToConstant: 70),

            // CATEGORY (LEFT TOP)
            categoryLabel.topAnchor.constraint(equalTo: productImageView.topAnchor),
            categoryLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 12),

            // STATUS (RIGHT TOP — aligned with category)
            statusLabel.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // NAME (under category)
            nameLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 6),
            nameLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceLabel.leadingAnchor, constant: -8),

            // PRICE (aligned to NAME vertically)
            priceLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // EDIT BUTTON (under name) - 44pt minimum touch target per Apple HIG
            editButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            editButton.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor, constant: -10),
            editButton.widthAnchor.constraint(equalToConstant: 44),
            editButton.heightAnchor.constraint(equalToConstant: 44),

            // DELETE BUTTON next to edit - 44pt minimum touch target per Apple HIG
            deleteButton.centerYAnchor.constraint(equalTo: editButton.centerYAnchor),
            deleteButton.leadingAnchor.constraint(equalTo: editButton.trailingAnchor, constant: 4),
            deleteButton.widthAnchor.constraint(equalToConstant: 44),
            deleteButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        // Add button actions
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }

    @objc private func editButtonTapped() {
        delegate?.didTapEdit(on: self)
    }

    @objc private func deleteButtonTapped() {
        delegate?.didTapDelete(on: self)
    }

    func configure(with item: ListingsViewController.Listing) {
        categoryLabel.text = item.category
        nameLabel.text = item.name
        statusLabel.text = item.status
        priceLabel.text = item.price

        // Set status label color based on status
        switch item.status.lowercased() {
        case "sold":
            statusLabel.textColor = .systemRed
        case "pending":
            statusLabel.textColor = .systemOrange
        case "available":
            statusLabel.textColor = .systemGreen
        default:
            statusLabel.textColor = .gray
        }

        // Load image from URL if available, otherwise use provided image
        if let imageURLString = item.imageURL, let url = URL(string: imageURLString) {
            loadImage(from: url)
        } else {
            productImageView.image = item.image ?? UIImage(systemName: "photo")
        }

        // MARK: - Accessibility (Apple HIG Compliance)
        setupAccessibility(for: item)
    }

    private func setupAccessibility(for item: ListingsViewController.Listing) {
        // Cell accessibility
        isAccessibilityElement = false
        accessibilityElements = [productImageView, nameLabel, statusLabel, priceLabel, editButton, deleteButton]

        // Product image
        productImageView.isAccessibilityElement = true
        productImageView.accessibilityLabel = "Product image for \(item.name)"
        productImageView.accessibilityTraits = .image

        // Name label
        nameLabel.isAccessibilityElement = true
        nameLabel.accessibilityLabel = item.name
        nameLabel.accessibilityTraits = .staticText

        // Status label
        statusLabel.isAccessibilityElement = true
        statusLabel.accessibilityLabel = "Status: \(item.status)"
        statusLabel.accessibilityTraits = .staticText

        // Price label
        priceLabel.isAccessibilityElement = true
        priceLabel.accessibilityLabel = "Price: \(item.price)"
        priceLabel.accessibilityTraits = .staticText

        // Edit button
        editButton.isAccessibilityElement = true
        editButton.accessibilityLabel = "Edit listing"
        editButton.accessibilityHint = "Double tap to edit this listing"
        editButton.accessibilityTraits = .button

        // Delete button
        deleteButton.isAccessibilityElement = true
        deleteButton.accessibilityLabel = "Delete listing"
        deleteButton.accessibilityHint = "Double tap to delete this listing"
        deleteButton.accessibilityTraits = .button

        // Overall cell accessibility summary
        accessibilityLabel = "\(item.name), \(item.category), \(item.price), \(item.status)"
        accessibilityHint = "Double tap to view details"
    }

    private func loadImage(from url: URL) {
        // Set placeholder
        productImageView.image = UIImage(systemName: "photo")

        // Load image asynchronously
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.productImageView.image = image
                    }
                }
            } catch {
                print("❌ Failed to load image from \(url): \(error)")
                await MainActor.run {
                    self.productImageView.image = UIImage(systemName: "photo.fill")
                }
            }
        }
    }
}

