//
//  EnhancedListingCell.swift
//  Unizo_iOS
//
//  Enhanced listing cell with buyer info, views, and more details
//  Following Apple Human Interface Guidelines
//

import UIKit

protocol EnhancedListingCellDelegate: AnyObject {
    func didTapEdit(on cell: EnhancedListingCell)
    func didTapDelete(on cell: EnhancedListingCell)
    func didTapView(on cell: EnhancedListingCell)
}

final class EnhancedListingCell: UICollectionViewCell {

    static let reuseIdentifier = "EnhancedListingCell"

    weak var delegate: EnhancedListingCellDelegate?

    // MARK: - UI Components

    private let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = Spacing.cornerRadiusSmall
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .tertiarySystemBackground
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let statusBadge: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .caption2)
        lbl.adjustsFontForContentSizeCategory = true
        lbl.textAlignment = .center
        lbl.layer.cornerRadius = 4
        lbl.clipsToBounds = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let categoryLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .caption1)
        lbl.adjustsFontForContentSizeCategory = true
        lbl.textColor = .secondaryLabel
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .headline)
        lbl.adjustsFontForContentSizeCategory = true
        lbl.numberOfLines = 2
        lbl.textColor = .label
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let priceLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .title3)
        lbl.adjustsFontForContentSizeCategory = true
        lbl.textColor = .brandPrimary
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // Stats row (views, quantity)
    private let statsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = Spacing.md
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let viewsIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "eye")
        iv.tintColor = .secondaryLabel
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let viewsLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .caption1)
        lbl.adjustsFontForContentSizeCategory = true
        lbl.textColor = .secondaryLabel
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let quantityIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "shippingbox")
        iv.tintColor = .secondaryLabel
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let quantityLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .caption1)
        lbl.adjustsFontForContentSizeCategory = true
        lbl.textColor = .secondaryLabel
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // Interested buyers indicator
    private let interestedBuyersContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .systemOrange.withAlphaComponent(0.12)
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()

    private let interestedBuyersIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.2.fill")
        iv.tintColor = .systemOrange
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let interestedBuyersLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl.textColor = .systemOrange
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // Buyer info section (shown for sold/pending items)
    private let buyerContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        v.layer.cornerRadius = Spacing.cornerRadiusSmall
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let buyerIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.fill")
        iv.tintColor = .systemBlue
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let buyerLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .caption1)
        lbl.adjustsFontForContentSizeCategory = true
        lbl.textColor = .systemBlue
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // Action buttons
    private let editButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        btn.tintColor = .brandPrimary
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "trash"), for: .normal)
        btn.tintColor = .systemRed
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = Spacing.cornerRadiusMedium
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        // Add subviews
        contentView.addSubview(productImageView)
        contentView.addSubview(statusBadge)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(statsStackView)
        contentView.addSubview(interestedBuyersContainer)
        contentView.addSubview(buyerContainerView)
        contentView.addSubview(editButton)
        contentView.addSubview(deleteButton)

        // Interested buyers container
        interestedBuyersContainer.addSubview(interestedBuyersIcon)
        interestedBuyersContainer.addSubview(interestedBuyersLabel)

        // Stats stack
        let viewsStack = UIStackView(arrangedSubviews: [viewsIcon, viewsLabel])
        viewsStack.axis = .horizontal
        viewsStack.spacing = 4

        let quantityStack = UIStackView(arrangedSubviews: [quantityIcon, quantityLabel])
        quantityStack.axis = .horizontal
        quantityStack.spacing = 4

        statsStackView.addArrangedSubview(viewsStack)
        statsStackView.addArrangedSubview(quantityStack)

        // Buyer container
        buyerContainerView.addSubview(buyerIcon)
        buyerContainerView.addSubview(buyerLabel)

        NSLayoutConstraint.activate([
            // Product image
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.md),
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.md),
            productImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Spacing.md),
            productImageView.widthAnchor.constraint(equalToConstant: 100),

            // Status badge (top right of image)
            statusBadge.topAnchor.constraint(equalTo: productImageView.topAnchor, constant: 4),
            statusBadge.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: -4),
            statusBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 50),
            statusBadge.heightAnchor.constraint(equalToConstant: 18),

            // Category
            categoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.md),
            categoryLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: Spacing.md),
            categoryLabel.trailingAnchor.constraint(lessThanOrEqualTo: editButton.leadingAnchor, constant: -Spacing.sm),

            // Name
            nameLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: Spacing.xs),
            nameLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: Spacing.md),
            nameLabel.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: -Spacing.sm),

            // Price
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Spacing.xs),
            priceLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: Spacing.md),

            // Stats stack
            statsStackView.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: Spacing.sm),
            statsStackView.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: Spacing.md),

            // Icons sizing
            viewsIcon.widthAnchor.constraint(equalToConstant: 14),
            viewsIcon.heightAnchor.constraint(equalToConstant: 14),
            quantityIcon.widthAnchor.constraint(equalToConstant: 14),
            quantityIcon.heightAnchor.constraint(equalToConstant: 14),

            // Interested buyers container (shown for available items with interested buyers)
            interestedBuyersContainer.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: Spacing.md),
            interestedBuyersContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Spacing.md),
            interestedBuyersContainer.heightAnchor.constraint(equalToConstant: 24),

            interestedBuyersIcon.leadingAnchor.constraint(equalTo: interestedBuyersContainer.leadingAnchor, constant: 8),
            interestedBuyersIcon.centerYAnchor.constraint(equalTo: interestedBuyersContainer.centerYAnchor),
            interestedBuyersIcon.widthAnchor.constraint(equalToConstant: 16),
            interestedBuyersIcon.heightAnchor.constraint(equalToConstant: 14),

            interestedBuyersLabel.leadingAnchor.constraint(equalTo: interestedBuyersIcon.trailingAnchor, constant: 4),
            interestedBuyersLabel.trailingAnchor.constraint(equalTo: interestedBuyersContainer.trailingAnchor, constant: -10),
            interestedBuyersLabel.centerYAnchor.constraint(equalTo: interestedBuyersContainer.centerYAnchor),

            // Buyer container
            buyerContainerView.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: Spacing.md),
            buyerContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Spacing.md),
            buyerContainerView.heightAnchor.constraint(equalToConstant: 24),

            buyerIcon.leadingAnchor.constraint(equalTo: buyerContainerView.leadingAnchor, constant: Spacing.sm),
            buyerIcon.centerYAnchor.constraint(equalTo: buyerContainerView.centerYAnchor),
            buyerIcon.widthAnchor.constraint(equalToConstant: 14),
            buyerIcon.heightAnchor.constraint(equalToConstant: 14),

            buyerLabel.leadingAnchor.constraint(equalTo: buyerIcon.trailingAnchor, constant: 4),
            buyerLabel.trailingAnchor.constraint(equalTo: buyerContainerView.trailingAnchor, constant: -Spacing.sm),
            buyerLabel.centerYAnchor.constraint(equalTo: buyerContainerView.centerYAnchor),

            // Action buttons (44pt touch target per Apple HIG)
            editButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.sm),
            editButton.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor),
            editButton.widthAnchor.constraint(equalToConstant: Spacing.minTouchTarget),
            editButton.heightAnchor.constraint(equalToConstant: Spacing.minTouchTarget),

            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.sm),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.sm),
            deleteButton.widthAnchor.constraint(equalToConstant: Spacing.minTouchTarget),
            deleteButton.heightAnchor.constraint(equalToConstant: Spacing.minTouchTarget)
        ])
    }

    private func setupActions() {
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        // Tap gesture for cell
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        contentView.addGestureRecognizer(tapGesture)
    }

    @objc private func editTapped() {
        HapticFeedback.light()
        delegate?.didTapEdit(on: self)
    }

    @objc private func deleteTapped() {
        HapticFeedback.light()
        delegate?.didTapDelete(on: self)
    }

    @objc private func cellTapped() {
        HapticFeedback.light()
        delegate?.didTapView(on: self)
    }

    // MARK: - Configure

    func configure(with listing: ListingsViewController.Listing) {
        categoryLabel.text = listing.category
        nameLabel.text = listing.name
        priceLabel.text = listing.price
        viewsLabel.text = String(format: "%d views".localized, listing.viewsCount)
        quantityLabel.text = String(format: "Qty: %d".localized, listing.quantity)

        // Status badge styling
        statusBadge.text = " \(listing.status) "
        switch listing.status.lowercased() {
        case "sold":
            statusBadge.backgroundColor = .systemRed.withAlphaComponent(0.15)
            statusBadge.textColor = .systemRed
            editButton.isHidden = true
        case "pending":
            statusBadge.backgroundColor = .systemOrange.withAlphaComponent(0.15)
            statusBadge.textColor = .systemOrange
            editButton.isHidden = false
        case "available":
            statusBadge.backgroundColor = .systemGreen.withAlphaComponent(0.15)
            statusBadge.textColor = .systemGreen
            editButton.isHidden = false
        default:
            statusBadge.backgroundColor = .systemGray.withAlphaComponent(0.15)
            statusBadge.textColor = .systemGray
            editButton.isHidden = false
        }

        // Buyer info (show for sold/pending)
        if let buyerName = listing.buyerName, listing.status != "Available" {
            buyerContainerView.isHidden = false
            interestedBuyersContainer.isHidden = true
            buyerLabel.text = String(format: "Buyer: %@".localized, buyerName)
        } else {
            buyerContainerView.isHidden = true

            // Show interested buyers count for available items
            if listing.status == "Available" && listing.interestedBuyersCount > 0 {
                interestedBuyersContainer.isHidden = false
                let buyerText = listing.interestedBuyersCount == 1 ? "1 interested buyer".localized : "\(listing.interestedBuyersCount) " + "interested buyers".localized
                interestedBuyersLabel.text = buyerText
            } else {
                interestedBuyersContainer.isHidden = true
            }
        }

        // Load image
        if let imageURLString = listing.imageURL, let url = URL(string: imageURLString) {
            loadImage(from: url)
        } else {
            productImageView.image = listing.image ?? UIImage(systemName: "photo")
        }

        // Accessibility
        setupAccessibility(for: listing)
    }

    private func setupAccessibility(for listing: ListingsViewController.Listing) {
        isAccessibilityElement = false
        accessibilityElements = [productImageView, nameLabel, priceLabel, statusBadge, interestedBuyersContainer, editButton, deleteButton]

        productImageView.isAccessibilityElement = true
        productImageView.accessibilityLabel = "Product image for \(listing.name)"
        productImageView.accessibilityTraits = .image

        nameLabel.isAccessibilityElement = true
        nameLabel.accessibilityLabel = listing.name
        nameLabel.accessibilityTraits = .staticText

        priceLabel.isAccessibilityElement = true
        priceLabel.accessibilityLabel = "Price: \(listing.price)"
        priceLabel.accessibilityTraits = .staticText

        statusBadge.isAccessibilityElement = true
        statusBadge.accessibilityLabel = "Status: \(listing.status)"
        statusBadge.accessibilityTraits = .staticText

        // Interested buyers accessibility
        interestedBuyersContainer.isAccessibilityElement = true
        if listing.interestedBuyersCount > 0 {
            let buyerText = listing.interestedBuyersCount == 1 ? "1 interested buyer" : "\(listing.interestedBuyersCount) interested buyers"
            interestedBuyersContainer.accessibilityLabel = buyerText
        }
        interestedBuyersContainer.accessibilityTraits = .staticText

        editButton.isAccessibilityElement = true
        editButton.accessibilityLabel = "Edit listing"
        editButton.accessibilityHint = "Double tap to edit this listing"
        editButton.accessibilityTraits = .button

        deleteButton.isAccessibilityElement = true
        deleteButton.accessibilityLabel = "Delete listing"
        deleteButton.accessibilityHint = "Double tap to delete this listing"
        deleteButton.accessibilityTraits = .button

        var fullAccessibilityLabel = "\(listing.name), \(listing.category), \(listing.price), \(listing.status)"
        if listing.interestedBuyersCount > 0 {
            let buyerText = listing.interestedBuyersCount == 1 ? "1 interested buyer" : "\(listing.interestedBuyersCount) interested buyers"
            fullAccessibilityLabel += ", \(buyerText)"
        }
        accessibilityLabel = fullAccessibilityLabel
        accessibilityHint = "Double tap to view details"
    }

    private func loadImage(from url: URL) {
        productImageView.image = UIImage(systemName: "photo")

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        UIView.transition(with: self.productImageView,
                                          duration: AnimationDuration.quick,
                                          options: .transitionCrossDissolve) {
                            self.productImageView.image = image
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    self.productImageView.image = UIImage(systemName: "photo.fill")
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.image = nil
        buyerContainerView.isHidden = true
        interestedBuyersContainer.isHidden = true
        editButton.isHidden = false
    }
}
