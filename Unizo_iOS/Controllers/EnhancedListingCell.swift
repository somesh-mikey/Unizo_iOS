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
    func didTapDealRequests(on cell: EnhancedListingCell)
    func didTapInterestedBuyers(on cell: EnhancedListingCell)
    func didTapManageOrder(on cell: EnhancedListingCell)
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

    // Activity menu for Interested Buyers + Deal Requests
    private let activityMenuButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        btn.tintColor = .brandPrimary
        btn.showsMenuAsPrimaryAction = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let menuBadgeView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemRed
        v.layer.cornerRadius = 5
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()

    // Buyer info section (shown for sold/pending items)
    private let buyerContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBlue.withAlphaComponent(0.18)
        v.layer.cornerRadius = Spacing.cornerRadiusSmall
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.35).cgColor
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
        contentView.addSubview(activityMenuButton)
        contentView.addSubview(menuBadgeView)
        contentView.addSubview(buyerContainerView)

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
            categoryLabel.trailingAnchor.constraint(lessThanOrEqualTo: activityMenuButton.leadingAnchor, constant: -Spacing.sm),

            // Name
            nameLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: Spacing.xs),
            nameLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: Spacing.md),
            nameLabel.trailingAnchor.constraint(equalTo: activityMenuButton.leadingAnchor, constant: -Spacing.sm),

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

            // Activity menu button at old delete position (top-right) and red badge
            activityMenuButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.sm),
            activityMenuButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.sm),
            activityMenuButton.widthAnchor.constraint(equalToConstant: Spacing.minTouchTarget),
            activityMenuButton.heightAnchor.constraint(equalToConstant: Spacing.minTouchTarget),

            menuBadgeView.widthAnchor.constraint(equalToConstant: 10),
            menuBadgeView.heightAnchor.constraint(equalToConstant: 10),
            menuBadgeView.topAnchor.constraint(equalTo: activityMenuButton.topAnchor, constant: 2),
            menuBadgeView.trailingAnchor.constraint(equalTo: activityMenuButton.trailingAnchor, constant: -4),

            // Buyer container (shown below views)
            buyerContainerView.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: Spacing.md),
            buyerContainerView.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: Spacing.sm),
            buyerContainerView.heightAnchor.constraint(equalToConstant: 24),
            buyerContainerView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -Spacing.md),

            buyerIcon.leadingAnchor.constraint(equalTo: buyerContainerView.leadingAnchor, constant: Spacing.sm),
            buyerIcon.centerYAnchor.constraint(equalTo: buyerContainerView.centerYAnchor),
            buyerIcon.widthAnchor.constraint(equalToConstant: 14),
            buyerIcon.heightAnchor.constraint(equalToConstant: 14),

            buyerLabel.leadingAnchor.constraint(equalTo: buyerIcon.trailingAnchor, constant: 4),
            buyerLabel.trailingAnchor.constraint(equalTo: buyerContainerView.trailingAnchor, constant: -Spacing.sm),
            buyerLabel.centerYAnchor.constraint(equalTo: buyerContainerView.centerYAnchor)
        ])
    }

    private func setupActions() {
        // Tap gesture for cell
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        contentView.addGestureRecognizer(tapGesture)

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
        case "pending":
            statusBadge.backgroundColor = .systemOrange.withAlphaComponent(0.15)
            statusBadge.textColor = .systemOrange
        case "available":
            statusBadge.backgroundColor = .systemGreen.withAlphaComponent(0.15)
            statusBadge.textColor = .systemGreen
        default:
            statusBadge.backgroundColor = .systemGray.withAlphaComponent(0.15)
            statusBadge.textColor = .systemGray
        }

        // Buyer info (show for sold only)
        if let buyerName = listing.buyerName, listing.status.lowercased() == "sold" {
            buyerContainerView.isHidden = false
            buyerLabel.text = String(format: "Buyer: %@".localized, buyerName)
        } else {
            buyerContainerView.isHidden = true
        }

        // Activity menu entries and badge
        configureActivityMenu(for: listing)
        menuBadgeView.isHidden = !listing.hasNewActivity

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
        accessibilityElements = [productImageView, nameLabel, priceLabel, statusBadge, activityMenuButton]

        productImageView.isAccessibilityElement = true
        productImageView.accessibilityLabel = String(format: "Product image for %@".localized, listing.name)
        productImageView.accessibilityTraits = .image

        nameLabel.isAccessibilityElement = true
        nameLabel.accessibilityLabel = listing.name
        nameLabel.accessibilityTraits = .staticText

        priceLabel.isAccessibilityElement = true
        priceLabel.accessibilityLabel = String(format: "Price: %@".localized, listing.price)
        priceLabel.accessibilityTraits = .staticText

        statusBadge.isAccessibilityElement = true
        statusBadge.accessibilityLabel = String(format: "Status: %@".localized, listing.status)
        statusBadge.accessibilityTraits = .staticText

        // Activity menu accessibility
        let interestedText = listing.interestedBuyersCount == 1
            ? "1 interested buyer".localized
            : String(format: "%d interested buyers".localized, listing.interestedBuyersCount)
        let dealText = listing.dealRequestsCount == 1
            ? "1 deal request".localized
            : String(format: "%d deal requests".localized, listing.dealRequestsCount)
        activityMenuButton.isAccessibilityElement = true
        activityMenuButton.accessibilityLabel = "Listing actions".localized
        activityMenuButton.accessibilityValue = "\(interestedText), \(dealText)"
        activityMenuButton.accessibilityHint = "Double tap to open interested buyers and deal requests".localized
        activityMenuButton.accessibilityTraits = .button

        // Combined accessibility label
        var fullAccessibilityLabel = "\(listing.name), \(listing.category), \(listing.price), \(listing.status)"
        if listing.interestedBuyersCount > 0 {
            let buyerText = listing.interestedBuyersCount == 1 ? "1 interested buyer".localized : "\(listing.interestedBuyersCount) " + "interested buyers".localized
            fullAccessibilityLabel += ", \(buyerText)"
        }
        if listing.dealRequestsCount > 0 {
            let dealText = listing.dealRequestsCount == 1 ? "1 deal request".localized : String(format: "%d deal requests".localized, listing.dealRequestsCount)
            fullAccessibilityLabel += ", \(dealText)"
        }
        accessibilityLabel = fullAccessibilityLabel
        accessibilityHint = "Double tap to view details".localized
    }

    private func configureActivityMenu(for listing: ListingsViewController.Listing) {
        let isSold = listing.status.caseInsensitiveCompare("Sold") == .orderedSame

        let interestedTitle = (!isSold && listing.interestedBuyersCount > 0)
            ? String(format: "Interested Buyers (%d)".localized, listing.interestedBuyersCount)
            : "Interested Buyers".localized

        let dealTitle = (!isSold && listing.dealRequestsCount > 0)
            ? String(format: "Deal Requests (%d)".localized, listing.dealRequestsCount)
            : "Deal Requests".localized

        let interestedAction = UIAction(
            title: interestedTitle,
            image: UIImage(systemName: "person.2.fill"),
            attributes: isSold ? [.disabled] : []
        ) { [weak self] _ in
            guard let self = self else { return }
            HapticFeedback.light()
            self.delegate?.didTapInterestedBuyers(on: self)
        }

        let dealAction = UIAction(
            title: dealTitle,
            image: UIImage(systemName: "cart.fill"),
            attributes: isSold ? [.disabled] : []
        ) { [weak self] _ in
            guard let self = self else { return }
            HapticFeedback.light()
            self.delegate?.didTapDealRequests(on: self)
        }

        let editAction = UIAction(
            title: "Edit Listing".localized,
            image: UIImage(systemName: "square.and.pencil")
        ) { [weak self] _ in
            guard let self = self else { return }
            HapticFeedback.light()
            self.delegate?.didTapEdit(on: self)
        }

        let manageAction = UIAction(
            title: "Manage Order".localized,
            image: UIImage(systemName: "doc.text.fill")
        ) { [weak self] _ in
            guard let self = self else { return }
            HapticFeedback.light()
            self.delegate?.didTapManageOrder(on: self)
        }

        let deleteAction = UIAction(
            title: "Delete Listing".localized,
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { [weak self] _ in
            guard let self = self else { return }
            HapticFeedback.light()
            self.delegate?.didTapDelete(on: self)
        }

        // Include Manage Order only if the order status is "Pending" (confirmed active orders are pending fulfillment)
        var actions: [UIMenuElement] = [interestedAction, dealAction]
        if listing.orderStatus == "pending" || listing.status == "sold" || listing.status == "pending" {
             actions.append(manageAction)
        } else {
             // To ensure it appears dynamically if active order exist but isn't marked properly
             actions.append(manageAction)
        }
        actions.append(editAction)
        actions.append(deleteAction)

        activityMenuButton.menu = UIMenu(children: actions)
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
        menuBadgeView.isHidden = true
    }
}
