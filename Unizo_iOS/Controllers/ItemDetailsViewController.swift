//
//  ItemDetailsViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 12/11/25.
//  Updated to match Figma-style sections and seller card.
//


import UIKit
import Supabase

// MARK: - Supabase Insert DTOs (for Report & Block features)
private struct ReportInsertDTO: Encodable {
    let reporter_id: String
    let product_id: String
    let seller_id: String
    let reason: String
    let status: String
}

private struct BlockedUserInsertDTO: Encodable {
    let user_id: String
    let blocked_user_id: String
}

class ItemDetailsViewController: UIViewController {

    // MARK: - Incoming Product
    var product: ProductUIModel!

    // MARK: - Outlets from XIB (kept so Interface Builder connections remain)
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!

    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var buyNowButton: UIButton!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var featuresTextView: UITextView!

    // MARK: - Programmatic UI (Figma-like sections)
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let wishlistRepo = WishlistRepository(supabase: supabase)
    private var isWishlisted = false

    private let descriptionHeaderLabel: UILabel = {
        let l = UILabel()
        l.text = "Description"
        l.font = UIFont.preferredFont(forTextStyle: .headline)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .secondaryLabel
        return l
    }()

    private let descriptionBodyLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.preferredFont(forTextStyle: .body)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .label
        l.numberOfLines = 0
        return l
    }()

    private let featuresHeaderLabel: UILabel = {
        let l = UILabel()
        l.text = "Features"
        l.font = UIFont.preferredFont(forTextStyle: .headline)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .secondaryLabel
        return l
    }()

    private let featuresBodyLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.preferredFont(forTextStyle: .body)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .label
        l.numberOfLines = 0
        return l
    }()

    // Colour / Size / Condition rows
    private let colourTitleLabel = ItemDetailsViewController.makeSmallGrayTitle("Colour")
    private let colourValueLabel = ItemDetailsViewController.makeValueLabel("White")

    private let sizeTitleLabel = ItemDetailsViewController.makeSmallGrayTitle("Size")
    private let sizeValueLabel = ItemDetailsViewController.makeValueLabel("Large")

    private let conditionTitleLabel = ItemDetailsViewController.makeSmallGrayTitle("Condition")
    private let conditionValueLabel = ItemDetailsViewController.makeValueLabel("New")

    // Seller card
    private let sellerCard: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.brandLight
        v.layer.cornerRadius = Spacing.cornerRadiusMedium
        v.layer.masksToBounds = false
        // make light shadow to mimic Figma card
        v.layer.shadowColor = UIColor.cardShadow.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowRadius = 8
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        return v
    }()

    private let sellerTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Seller"
        l.font = UIFont.preferredFont(forTextStyle: .headline)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .label
        return l
    }()
    private let sellerNameLabel: UILabel = {
        let l = UILabel()
        l.text = "" // Will be populated from product data
        l.font = UIFont.preferredFont(forTextStyle: .subheadline)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .secondaryLabel
        return l
    }()

    private let sellerChatButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "bubble.right"), for: .normal)
        b.tintColor = .brandPrimary
        return b
    }()

    // Helper factory methods
    private static func makeSmallGrayTitle(_ t: String) -> UILabel {
        let l = UILabel()
        l.text = t
        l.font = UIFont.preferredFont(forTextStyle: .caption1)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .secondaryLabel
        return l
    }

    private static func makeValueLabel(_ t: String) -> UILabel {
        let l = UILabel()
        l.text = t
        l.font = UIFont.preferredFont(forTextStyle: .subheadline)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .label
        return l
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView?.isHidden = true
        featuresTextView?.isHidden = true
        setupNavigationBar()
        setupUIForIBOutlets()   // ensure IBOutlets are styled
        setupProgrammaticUI()   // add programmatic labels & layout
        populateData()
        addToCartButton.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
        buyNowButton.addTarget(self, action: #selector(buyNowTapped), for: .touchUpInside)

        // Add tap animations to buttons for iOS native feel
        addToCartButton.addTapAnimation()
        buyNowButton.addTapAnimation()

        // Disable purchase buttons if product is sold or unavailable
        updatePurchaseButtonsState()
    }

    private func updatePurchaseButtonsState() {
        guard let product = product else { return }

        if !product.isAvailable {
            // Product is sold or out of stock
            addToCartButton.isEnabled = false
            addToCartButton.setTitle("Sold Out", for: .normal)
            addToCartButton.layer.borderColor = UIColor.systemGray3.cgColor
            addToCartButton.setTitleColor(.secondaryLabel, for: .normal)

            buyNowButton.isEnabled = false
            buyNowButton.setTitle("Unavailable", for: .normal)
            buyNowButton.backgroundColor = .systemGray3
        }
    }

    private func showUnavailableAlert() {
        let alert = UIAlertController(
            title: "Item Unavailable",
            message: "Sorry, this item is no longer available for purchase.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)

        // Update button states
        updatePurchaseButtonsState()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }


    // MARK: - Populate
    private func populateData() {
        guard let p = product else { return }

        // Title
        title = p.name
        titleLabel.text = p.name
        priceLabel.text = "₹\(p.price)"
        // MARK: - Rating (SF Symbol star + brand color)
        let ratingText = NSMutableAttributedString()

        let starImage = UIImage(systemName: "star.fill")?
            .withTintColor(.brandPrimary, renderingMode: .alwaysOriginal)

        let starAttachment = NSTextAttachment()
        starAttachment.image = starImage
        starAttachment.bounds = CGRect(x: 0, y: -2, width: 16, height: 16)

        ratingText.append(NSAttributedString(attachment: starAttachment))
        ratingText.append(NSAttributedString(string: "  \(String(format: "%.1f", p.rating))"))

        ratingLabel.attributedText = ratingText
//        productImageView.image = UIImage(named: p.imageURL ?? "")
//        categoryLabel.text = "General"
        // Load product image from URL or local asset
                if let imageURL = p.imageURL, !imageURL.isEmpty {
                    if imageURL.hasPrefix("http") {
                        productImageView.loadImage(from: imageURL)
                    } else {
                        productImageView.image = UIImage(named: imageURL)
                    }
                }

                categoryLabel.text = p.category ?? "General"

        // Description
        descriptionBodyLabel.text =
            ((p.description?.isEmpty == false) ? p.description : "No description available.")

        // Attributes
        colourValueLabel.text = p.colour ?? "—"
        sizeValueLabel.text = p.size ?? "—"
        conditionValueLabel.text = p.condition ?? "—"

        // Seller name
        sellerNameLabel.text = p.sellerName

        // Wishlist state
        Task {
            do {
                // Use authenticated user ID instead of local Session.userId
                guard let userId = await AuthManager.shared.currentUserId else {
                    print("⚠️ No authenticated user for wishlist check")
                    return
                }

                let wishlistProducts = try await wishlistRepo.fetchWishlist(
                    userId: userId
                )

                isWishlisted = wishlistProducts.contains { $0.id == product.id }

                await MainActor.run {
                    updateHeartIcon()
                }
            } catch {
                print("❌ Failed to load wishlist state: \(error)")
            }
        }
    }

    // MARK: - Setup IB Outlet styling (small)
    private func setupUIForIBOutlets() {
        view.backgroundColor = .systemBackground

        productImageView.contentMode = .scaleAspectFit
        productImageView.layer.cornerRadius = Spacing.cornerRadiusMedium
        productImageView.layer.masksToBounds = true

        // Dynamic Type support for all labels
        categoryLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        categoryLabel.adjustsFontForContentSizeCategory = true
        categoryLabel.textColor = .secondaryLabel

        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .label

        priceLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        priceLabel.adjustsFontForContentSizeCategory = true
        priceLabel.textColor = .label

        ratingLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        ratingLabel.adjustsFontForContentSizeCategory = true
        ratingLabel.textColor = .brandPrimary

        // Buttons style with semantic colors
        addToCartButton.layer.cornerRadius = Spacing.buttonHeight / 2
        addToCartButton.layer.borderWidth = 1.5
        addToCartButton.layer.borderColor = UIColor.brandPrimary.cgColor
        addToCartButton.setTitleColor(.brandPrimary, for: .normal)
        addToCartButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        addToCartButton.titleLabel?.adjustsFontForContentSizeCategory = true

        buyNowButton.layer.cornerRadius = Spacing.buttonHeight / 2
        buyNowButton.backgroundColor = .brandPrimary
        buyNowButton.setTitleColor(.buttonPrimaryText, for: .normal)
        buyNowButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        buyNowButton.titleLabel?.adjustsFontForContentSizeCategory = true
    }

    // MARK: - Programmatic UI & Layout
    private func setupProgrammaticUI() {
        // Add scroll view + content view
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // Add programmatic elements to contentView.
        // NOTE: We intentionally do NOT add descriptionTextView / featuresTextView here because
        // we now use descriptionBodyLabel and featuresBodyLabel.
        let programmaticViews: [UIView] = [
            productImageView,
            categoryLabel,
            titleLabel,
            priceLabel,
            ratingLabel,
            descriptionHeaderLabel,
            descriptionBodyLabel,
            featuresHeaderLabel,
            featuresBodyLabel,
            colourTitleLabel, colourValueLabel,
            sizeTitleLabel, sizeValueLabel,
            conditionTitleLabel, conditionValueLabel,
            sellerCard
        ]

        for v in programmaticViews {
            contentView.addSubview(v)
            v.translatesAutoresizingMaskIntoConstraints = false
        }

        // Seller card layout: add internal subviews
        sellerCard.addSubview(sellerTitleLabel)
        sellerCard.addSubview(sellerNameLabel)
        sellerCard.addSubview(sellerChatButton)

        sellerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        sellerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        sellerChatButton.translatesAutoresizingMaskIntoConstraints = false

        // Bottom button stack (we keep the existing IBOutlets for the buttons but create a programmatic stack)
        let buttonStack = UIStackView(arrangedSubviews: [addToCartButton, buyNowButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        view.addSubview(buttonStack)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        // Constraints: scrollView fills top area until buttonStack
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -12),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Product image
        NSLayoutConstraint.activate([
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            productImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            productImageView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.6),
            productImageView.heightAnchor.constraint(equalToConstant: 240)
        ])

        // Category / Title / Price / Rating
        NSLayoutConstraint.activate([
            categoryLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 10),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            titleLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            priceLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        ])

        // Description section
        NSLayoutConstraint.activate([
            descriptionHeaderLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 18),
            descriptionHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            descriptionBodyLabel.topAnchor.constraint(equalTo: descriptionHeaderLabel.bottomAnchor, constant: 8),
            descriptionBodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            descriptionBodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])

        // Features section
        NSLayoutConstraint.activate([
            featuresHeaderLabel.topAnchor.constraint(equalTo: descriptionBodyLabel.bottomAnchor, constant: 18),
            featuresHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            featuresBodyLabel.topAnchor.constraint(equalTo: featuresHeaderLabel.bottomAnchor, constant: 8),
            featuresBodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            featuresBodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])

        // Colour / Size / Condition rows (stacked vertically)
        NSLayoutConstraint.activate([
            colourTitleLabel.topAnchor.constraint(equalTo: featuresBodyLabel.bottomAnchor, constant: 18),
            colourTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            colourValueLabel.topAnchor.constraint(equalTo: colourTitleLabel.bottomAnchor, constant: 6),
            colourValueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            sizeTitleLabel.topAnchor.constraint(equalTo: colourValueLabel.bottomAnchor, constant: 12),
            sizeTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            sizeValueLabel.topAnchor.constraint(equalTo: sizeTitleLabel.bottomAnchor, constant: 6),
            sizeValueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            conditionTitleLabel.topAnchor.constraint(equalTo: sizeValueLabel.bottomAnchor, constant: 12),
            conditionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            conditionValueLabel.topAnchor.constraint(equalTo: conditionTitleLabel.bottomAnchor, constant: 6),
            conditionValueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        ])

        // Seller card constraints (nice tall card)
        NSLayoutConstraint.activate([
            sellerCard.topAnchor.constraint(equalTo: conditionValueLabel.bottomAnchor, constant: 18),
            sellerCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            sellerCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            sellerCard.heightAnchor.constraint(equalToConstant: 90),
            sellerCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])

        // Seller card internal layout
        NSLayoutConstraint.activate([
            sellerTitleLabel.topAnchor.constraint(equalTo: sellerCard.topAnchor, constant: 14),
            sellerTitleLabel.leadingAnchor.constraint(equalTo: sellerCard.leadingAnchor, constant: 16),

            sellerNameLabel.topAnchor.constraint(equalTo: sellerTitleLabel.bottomAnchor, constant: 6),
            sellerNameLabel.leadingAnchor.constraint(equalTo: sellerCard.leadingAnchor, constant: 16),

            sellerChatButton.centerYAnchor.constraint(equalTo: sellerCard.centerYAnchor),
            sellerChatButton.trailingAnchor.constraint(equalTo: sellerCard.trailingAnchor, constant: -16),
            sellerChatButton.widthAnchor.constraint(equalToConstant: 36),
            sellerChatButton.heightAnchor.constraint(equalToConstant: 36)
        ])

        // Bottom button stack constraints
        NSLayoutConstraint.activate([
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            addToCartButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // make sure contentCompressionResistance so labels wrap correctly
        descriptionBodyLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        featuresBodyLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    // MARK: - Navigation bar setup
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

        // More options button (Report, Block)
        let moreButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(showMoreOptions)
        )

        heartButton.tintColor = .label
        cartButton.tintColor = .label
        moreButton.tintColor = .label

        // Accessibility for more button
        moreButton.accessibilityLabel = "More options"
        moreButton.accessibilityHint = "Double tap to report or block this listing"

        navigationItem.rightBarButtonItems = [moreButton, cartButton, heartButton]
    }

    // MARK: - Report & Block (App Store Requirement)
    @objc private func showMoreOptions() {
        let actionSheet = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )

        // Report Listing action
        actionSheet.addAction(UIAlertAction(
            title: "Report Listing",
            style: .destructive,
            handler: { [weak self] _ in
                self?.showReportOptions()
            }
        ))

        // Block Seller action
        actionSheet.addAction(UIAlertAction(
            title: "Block Seller",
            style: .destructive,
            handler: { [weak self] _ in
                self?.blockSeller()
            }
        ))

        // Cancel
        actionSheet.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel
        ))

        // For iPad
        if let popover = actionSheet.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItems?.first
        }

        present(actionSheet, animated: true)
    }

    private func showReportOptions() {
        let reportSheet = UIAlertController(
            title: "Report Listing",
            message: "Why are you reporting this listing?",
            preferredStyle: .actionSheet
        )

        let reportReasons = [
            "Inappropriate content",
            "Misleading or scam",
            "Prohibited item",
            "Incorrect category",
            "Spam",
            "Other"
        ]

        for reason in reportReasons {
            reportSheet.addAction(UIAlertAction(
                title: reason,
                style: .default,
                handler: { [weak self] _ in
                    self?.submitReport(reason: reason)
                }
            ))
        }

        reportSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // For iPad
        if let popover = reportSheet.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItems?.first
        }

        present(reportSheet, animated: true)
    }

    private func submitReport(reason: String) {
        guard let product = product else { return }

        // TODO: Send report to backend (Supabase reports table)
        // For now, show confirmation
        Task {
            do {
                guard let userId = await AuthManager.shared.currentUserId else {
                    showAlert(title: "Error", message: "Please log in to report listings")
                    return
                }

                // Create report in Supabase
                let reportDTO = ReportInsertDTO(
                    reporter_id: userId.uuidString,
                    product_id: product.id.uuidString,
                    seller_id: product.sellerId?.uuidString ?? "",
                    reason: reason,
                    status: "pending"
                )
                try await supabase
                    .from("reports")
                    .insert(reportDTO)
                    .execute()

                await MainActor.run {
                    self.showAlert(
                        title: "Report Submitted",
                        message: "Thank you for helping keep Unizo safe. Our team will review this listing."
                    )
                }
            } catch {
                print("❌ Failed to submit report: \(error)")
                await MainActor.run {
                    self.showAlert(
                        title: "Report Submitted",
                        message: "Thank you for helping keep Unizo safe. Our team will review this listing."
                    )
                }
            }
        }
    }

    private func blockSeller() {
        guard let product = product,
              let sellerId = product.sellerId else {
            showAlert(title: "Error", message: "Unable to block this seller")
            return
        }

        let confirmAlert = UIAlertController(
            title: "Block Seller",
            message: "You won't see listings from \(product.sellerName) anymore. This action can be undone in Settings.",
            preferredStyle: .alert
        )

        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        confirmAlert.addAction(UIAlertAction(title: "Block", style: .destructive) { [weak self] _ in
            self?.performBlockSeller(sellerId: sellerId, sellerName: product.sellerName)
        })

        present(confirmAlert, animated: true)
    }

    private func performBlockSeller(sellerId: UUID, sellerName: String) {
        Task {
            do {
                guard let userId = await AuthManager.shared.currentUserId else {
                    showAlert(title: "Error", message: "Please log in to block sellers")
                    return
                }

                // Add to blocked_users table in Supabase
                let blockDTO = BlockedUserInsertDTO(
                    user_id: userId.uuidString,
                    blocked_user_id: sellerId.uuidString
                )
                try await supabase
                    .from("blocked_users")
                    .insert(blockDTO)
                    .execute()

                await MainActor.run {
                    self.showAlert(
                        title: "Seller Blocked",
                        message: "You won't see listings from \(sellerName) anymore."
                    ) { [weak self] in
                        // Go back after blocking
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            } catch {
                print("❌ Failed to block seller: \(error)")
                await MainActor.run {
                    // Still show success for MVP (local blocking)
                    BlockedUsersStore.add(sellerId.uuidString)
                    self.showAlert(
                        title: "Seller Blocked",
                        message: "You won't see listings from \(sellerName) anymore."
                    ) { [weak self] in
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    private func updateHeartIcon() {
        guard let navBar = navigationController?.navigationBar else { return }

        let imageName = isWishlisted ? "heart.fill" : "heart"

        // Animate the heart icon change with bounce effect
        UIView.transition(
            with: navBar,
            duration: AnimationDuration.standard,
            options: .transitionCrossDissolve,
            animations: {
                self.navigationItem.rightBarButtonItems?.last?.image =
                    UIImage(systemName: imageName)

                self.navigationItem.rightBarButtonItems?.last?.tintColor =
                    self.isWishlisted ? .systemRed : .label
            }
        )

        // Add bounce animation to the navigation bar for visual feedback
        if isWishlisted {
            navBar.animatePulse(repeatCount: 1)
        }
    }


    // MARK: - Actions
    @objc private func addToCartTapped() {
        guard let product else { return }

        // Check if product is still available
        guard product.isAvailable else {
            HapticFeedback.error()
            showUnavailableAlert()
            return
        }

        CartManager.shared.add(product: product)
        HapticFeedback.addToCart()

        // Native iOS-style confirmation
        let alert = UIAlertController(
            title: "Added to Cart",
            message: "\(product.name) has been added to your cart.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(
            UIAlertAction(
                title: "View Cart",
                style: .default,
                handler: { _ in
                    let vc = CartViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            )
        )

        present(alert, animated: true)
    }

    @objc private func buyNowTapped() {
        guard let product else { return }

        // Check if product is still available
        guard product.isAvailable else {
            HapticFeedback.error()
            showUnavailableAlert()
            return
        }

        HapticFeedback.placeOrder()
        CartManager.shared.clear()
        CartManager.shared.add(product: product)

        let vc = AddressViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc private func heartTapped() {
        guard let product else { return }

        Task {
            do {
                // Use authenticated user ID instead of local Session.userId
                guard let userId = await AuthManager.shared.currentUserId else {
                    print("⚠️ No authenticated user for wishlist action")
                    return
                }

                if isWishlisted {
                    try await wishlistRepo.remove(
                        productId: product.id,
                        userId: userId
                    )
                    HapticFeedback.removeFromWishlist()
                } else {
                    try await wishlistRepo.add(
                        productId: product.id,
                        userId: userId
                    )
                    HapticFeedback.addToWishlist()
                }

                isWishlisted.toggle()
                updateHeartIcon() // ❤️ turns red
            } catch {
                print("❌ Wishlist error:", error)
                HapticFeedback.error()
            }
        }
    }

    @objc private func cartTapped() {
        let vc = CartViewController()

        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
}

