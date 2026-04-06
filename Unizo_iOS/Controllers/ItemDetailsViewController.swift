//
//  ItemDetailsViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 12/11/25.
//  Updated to match Figma-style sections and seller card.
//


import UIKit
import FirebaseFirestore

// MARK: - Report/Block DTOs
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

    // MARK: - Repository
    private let productRepository = ProductRepository()

    // MARK: - Image Gallery
    private var galleryImages: [String] = []
    private var currentImageIndex = 0

    private let imageCarouselCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()

    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = .brandPrimary
        pc.pageIndicatorTintColor = .systemGray4
        pc.hidesForSinglePage = true
        return pc
    }()

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
    private let wishlistRepo = WishlistRepository()
    private var isWishlisted = false
    private var wishlistStateVersion = 0

    private let descriptionHeaderLabel: UILabel = {
        let l = UILabel()
        l.text = "Description".localized
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
        l.text = "Features".localized
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
    private let colourTitleLabel = ItemDetailsViewController.makeSmallGrayTitle("Colour".localized)
    private let colourValueLabel = ItemDetailsViewController.makeValueLabel("White")

    private let sizeTitleLabel = ItemDetailsViewController.makeSmallGrayTitle("Size".localized)
    private let sizeValueLabel = ItemDetailsViewController.makeValueLabel("Large")

    private let conditionTitleLabel = ItemDetailsViewController.makeSmallGrayTitle("Condition".localized)
    private let conditionValueLabel = ItemDetailsViewController.makeValueLabel("New")

    // Seller card
    private let sellerCard: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.brandLight
        v.layer.cornerRadius = Spacing.cornerRadiusMedium
        v.layer.masksToBounds = false
        v.layer.shadowColor = UIColor.cardShadow.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowRadius = 8
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        return v
    }()

    /// Circular avatar with seller initials
    private let sellerAvatarView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1.0)
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        return v
    }()

    private let sellerInitialsLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    /// "Seller" pill badge
    private let sellerBadgeLabel: UILabel = {
        let l = UILabel()
        l.text = "  Seller  "
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1.0)
        l.backgroundColor = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 0.12)
        l.layer.cornerRadius = 9
        l.clipsToBounds = true
        l.textAlignment = .center
        return l
    }()

    /// Bold seller real name
    private let sellerTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Seller".localized
        l.font = UIFont.preferredFont(forTextStyle: .headline)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .label
        return l
    }()

    private let sellerRatingLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.preferredFont(forTextStyle: .subheadline)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .brandPrimary
        return l
    }()

    private let sellerNameLabel: UILabel = {
        let l = UILabel()
        l.text = ""
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .label
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

    // MARK: - Sold State Banner
    /// Non-dismissible banner shown when the product is sold while the user is viewing it.
    private let soldBanner: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemRed.withAlphaComponent(0.9)
        v.layer.cornerRadius = 8
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let soldBannerLabel: UILabel = {
        let l = UILabel()
        l.text = "This item has been sold".localized
        l.font = UIFont.preferredFont(forTextStyle: .headline)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .white
        l.textAlignment = .center
        l.accessibilityLabel = "This item has been sold".localized
        l.accessibilityTraits = .staticText
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView?.isHidden = true
        featuresTextView?.isHidden = true
        setupNavigationBar()
        setupUIForIBOutlets()   // ensure IBOutlets are styled
        setupProgrammaticUI()   // add programmatic labels & layout
        populateData()
        // Update button titles
        addToCartButton.setTitle("Chat".localized, for: .normal)
        buyNowButton.setTitle("Deal".localized, for: .normal)

        addToCartButton.addTarget(self, action: #selector(chatWithSellerTapped), for: .touchUpInside)
        buyNowButton.addTarget(self, action: #selector(dealTapped), for: .touchUpInside)

        // Add tap animations to buttons for iOS native feel
        addToCartButton.addTapAnimation()
        buyNowButton.addTapAnimation()

        // Disable purchase buttons if product is sold or unavailable
        updatePurchaseButtonsState()

        // Increment view count when user views the product
        incrementProductViewCount()

        // RULE E — Observe product sold/deleted while user is viewing details.
        // Posted on MainActor, so this handler runs on the main thread.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleProductDeleted(_:)),
            name: .productDeleted,
            object: nil
        )

        // Setup the sold banner (hidden by default)
        setupSoldBanner()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Sold Banner Setup
    private func setupSoldBanner() {
        view.addSubview(soldBanner)
        soldBanner.addSubview(soldBannerLabel)

        NSLayoutConstraint.activate([
            soldBanner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            soldBanner.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            soldBanner.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            soldBanner.heightAnchor.constraint(equalToConstant: 44),

            soldBannerLabel.centerXAnchor.constraint(equalTo: soldBanner.centerXAnchor),
            soldBannerLabel.centerYAnchor.constraint(equalTo: soldBanner.centerYAnchor),
            soldBannerLabel.leadingAnchor.constraint(greaterThanOrEqualTo: soldBanner.leadingAnchor, constant: 12),
            soldBannerLabel.trailingAnchor.constraint(lessThanOrEqualTo: soldBanner.trailingAnchor, constant: -12)
        ])
    }

    // MARK: - Product Deleted Handler
    /// When the currently displayed product is sold, disable Deal button and show sold banner.
    /// Does NOT auto-dismiss the VC — lets the user navigate back themselves (avoids jarring UX).
    @objc private func handleProductDeleted(_ notification: Notification) {
        guard let productId = notification.userInfo?["productId"] as? String,
              productId == product?.id else { return }

        // Mutate product state so isAvailable returns false
        product?.status = .sold
        product?.quantity = 0

        // Disable Deal button immediately
        buyNowButton.isEnabled = false
        buyNowButton.setTitle("Sold".localized, for: .normal)
        buyNowButton.backgroundColor = .systemGray3

        // Show sold banner with animation
        soldBanner.alpha = 0
        soldBanner.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.soldBanner.alpha = 1
        }

        // Announce to VoiceOver
        UIAccessibility.post(notification: .announcement, argument: "This item has been sold".localized)
    }

    // MARK: - View Count
    private func incrementProductViewCount() {
        guard let product = product, let productId = product.id else { return }

        Task {
            do {
                // Only increment if the viewer is not the seller
                let currentUserId = await AuthManager.shared.currentUserId
                if let sellerId = product.sellerId, currentUserId == sellerId {
                    // Seller viewing their own product - don't increment
                    return
                }

                try await productRepository.incrementViewCount(productId: productId)
            } catch {
                // Silently fail - view count is not critical
                print("⚠️ Failed to increment view count: \(error)")
            }
        }
    }

    private func updatePurchaseButtonsState() {
        guard let product = product else { return }

        Task { @MainActor in
            let currentUserId = await AuthManager.shared.currentUserId
            let isOwnProduct = currentUserId == product.sellerId

            if isOwnProduct {
                addToCartButton.isHidden = true
                buyNowButton.isHidden = true
            } else if !product.isAvailable {
                // Product is sold or out of stock - disable Deal button but keep Chat enabled
                buyNowButton.isEnabled = false
                buyNowButton.setTitle("Sold".localized, for: .normal)
                buyNowButton.backgroundColor = .systemGray3
            } else {
                addToCartButton.isHidden = false
                buyNowButton.isHidden = false
            }
        }
    }

    private func showUnavailableAlert() {
        let alert = UIAlertController(
            title: "Item Unavailable".localized,
            message: "Sorry, this item is no longer available for purchase.".localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
        present(alert, animated: true)

        // Update button states
        updatePurchaseButtonsState()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: false)
        syncWishlistState()
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

        // Hide the old rating label (it's now in the seller card)
        ratingLabel.isHidden = true

        // Setup gallery images
        galleryImages = p.allImages
        pageControl.numberOfPages = galleryImages.count
        pageControl.currentPage = 0
        imageCarouselCollectionView.reloadData()

        // Hide the old IBOutlet image view (we're using the carousel now)
        productImageView.isHidden = true

        categoryLabel.text = p.category ?? "General".localized

        // Description
        descriptionBodyLabel.text =
            ((p.description?.isEmpty == false) ? p.description : "No description available.".localized)

        // Attributes
        colourValueLabel.text = p.colour ?? "—"
        sizeValueLabel.text = p.size ?? "—"
        conditionValueLabel.text = p.condition ?? "—"

        // Seller name and rating
        sellerNameLabel.text = p.sellerName

        // Seller initials for avatar
        let parts = p.sellerName.split(separator: " ")
        if let first = parts.first?.prefix(1), let last = parts.dropFirst().first?.prefix(1) {
            sellerInitialsLabel.text = "\(first)\(last)".uppercased()
        } else {
            sellerInitialsLabel.text = String(p.sellerName.prefix(2)).uppercased()
        }

        // Seller rating (SF Symbol star + brand color)
        let ratingText = NSMutableAttributedString()
        let starImage = UIImage(systemName: "star.fill")?
            .withTintColor(.brandPrimary, renderingMode: .alwaysOriginal)
        let starAttachment = NSTextAttachment()
        starAttachment.image = starImage
        starAttachment.bounds = CGRect(x: 0, y: -2, width: 14, height: 14)
        ratingText.append(NSAttributedString(attachment: starAttachment))
        ratingText.append(NSAttributedString(string: " \(String(format: "%.1f", p.rating))"))
        sellerRatingLabel.attributedText = ratingText

        syncWishlistState()
    }

    private func syncWishlistState() {
        Task {
            let versionAtStart = wishlistStateVersion

            do {
                guard let userId = await AuthManager.shared.currentUserId, !userId.isEmpty else { return }

                guard let productId = self.product?.id, !productId.isEmpty else {
                    return
                }

                let isCurrentlyWishlisted = try await self.wishlistRepo.contains(productId: productId, userId: userId)

                await MainActor.run {
                    guard versionAtStart == self.wishlistStateVersion else { return }
                    self.isWishlisted = isCurrentlyWishlisted
                    self.updateHeartIcon()
                }
            } catch {
                print("❌ Failed to load wishlist state: \(type(of: error)): \(error)")
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

        // Chat button style (outline)
        addToCartButton.layer.cornerRadius = Spacing.buttonHeight / 2
        addToCartButton.layer.borderWidth = 1.5
        addToCartButton.layer.borderColor = UIColor.brandPrimary.cgColor
        addToCartButton.setTitleColor(.brandPrimary, for: .normal)
        addToCartButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        addToCartButton.titleLabel?.adjustsFontForContentSizeCategory = true

        // Deal button style (filled primary)
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

        // Setup image carousel
        imageCarouselCollectionView.delegate = self
        imageCarouselCollectionView.dataSource = self
        imageCarouselCollectionView.register(ImageCarouselCell.self, forCellWithReuseIdentifier: "ImageCarouselCell")

        // Add programmatic elements to contentView.
        // NOTE: We intentionally do NOT add descriptionTextView / featuresTextView here because
        // we now use descriptionBodyLabel and featuresBodyLabel.
        // Rating moved to seller card, so not included here
        let programmaticViews: [UIView] = [
            imageCarouselCollectionView,
            pageControl,
            categoryLabel,
            titleLabel,
            priceLabel,
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
        sellerCard.addSubview(sellerAvatarView)
        sellerAvatarView.addSubview(sellerInitialsLabel)
        sellerCard.addSubview(sellerBadgeLabel)
        sellerCard.addSubview(sellerNameLabel)
        sellerCard.addSubview(sellerRatingLabel)

        sellerAvatarView.translatesAutoresizingMaskIntoConstraints = false
        sellerInitialsLabel.translatesAutoresizingMaskIntoConstraints = false
        sellerBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        sellerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        sellerRatingLabel.translatesAutoresizingMaskIntoConstraints = false

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

        // Image carousel
        NSLayoutConstraint.activate([
            imageCarouselCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            imageCarouselCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageCarouselCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageCarouselCollectionView.heightAnchor.constraint(equalToConstant: 280),

            pageControl.topAnchor.constraint(equalTo: imageCarouselCollectionView.bottomAnchor, constant: 8),
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])

        // Category / Title / Price (rating moved to seller card)
        NSLayoutConstraint.activate([
            categoryLabel.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 10),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            titleLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            priceLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        // Description section (anchored to titleLabel since rating is removed)
        NSLayoutConstraint.activate([
            descriptionHeaderLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18),
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

        // Seller card constraints — taller to fit avatar + name + badge
        NSLayoutConstraint.activate([
            sellerCard.topAnchor.constraint(equalTo: conditionValueLabel.bottomAnchor, constant: 18),
            sellerCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            sellerCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            sellerCard.heightAnchor.constraint(equalToConstant: 76),
            sellerCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])

        // Seller card internal layout
        NSLayoutConstraint.activate([
            // Avatar circle (left)
            sellerAvatarView.leadingAnchor.constraint(equalTo: sellerCard.leadingAnchor, constant: 14),
            sellerAvatarView.centerYAnchor.constraint(equalTo: sellerCard.centerYAnchor),
            sellerAvatarView.widthAnchor.constraint(equalToConstant: 48),
            sellerAvatarView.heightAnchor.constraint(equalToConstant: 48),

            sellerInitialsLabel.centerXAnchor.constraint(equalTo: sellerAvatarView.centerXAnchor),
            sellerInitialsLabel.centerYAnchor.constraint(equalTo: sellerAvatarView.centerYAnchor),

            // Seller name (bold, next to avatar)
            sellerNameLabel.leadingAnchor.constraint(equalTo: sellerAvatarView.trailingAnchor, constant: 12),
            sellerNameLabel.topAnchor.constraint(equalTo: sellerCard.topAnchor, constant: 18),

            // "Seller" badge pill (below name)
            sellerBadgeLabel.leadingAnchor.constraint(equalTo: sellerNameLabel.leadingAnchor),
            sellerBadgeLabel.topAnchor.constraint(equalTo: sellerNameLabel.bottomAnchor, constant: 4),
            sellerBadgeLabel.heightAnchor.constraint(equalToConstant: 18),

            // Rating on the right
            sellerRatingLabel.centerYAnchor.constraint(equalTo: sellerCard.centerYAnchor),
            sellerRatingLabel.trailingAnchor.constraint(equalTo: sellerCard.trailingAnchor, constant: -16)
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
        title = "Item Details".localized
        navigationController?.navigationBar.prefersLargeTitles = false

        let heartButton = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(heartTapped)
        )

        // More options button (Report, Block)
        let moreButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(showMoreOptions)
        )

        heartButton.tintColor = .label
        moreButton.tintColor = .label

        // Accessibility for more button
        moreButton.accessibilityLabel = "More options".localized
        moreButton.accessibilityHint = "Double tap to report or block this listing".localized

        navigationItem.rightBarButtonItems = [moreButton, heartButton]
    }

    // MARK: - Report & Block (App Store Requirement)
    @objc private func showMoreOptions() {
        Task { @MainActor in
            var activeOrderId: String? = nil
            do {
                if let productId = product.id {
                    activeOrderId = try await OrderRepository().getActiveOrderId(for: productId)
                }
            } catch {
                print("Error fetching active order: \(error)")
            }
            
            self.presentMoreOptionsSheet(withOrderId: activeOrderId)
        }
    }
    
    private func presentMoreOptionsSheet(withOrderId orderId: String?) {
        let actionSheet = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )

        // Manage Order action (only if there is an active order)
        if let orderId = orderId {
            actionSheet.addAction(UIAlertAction(
                title: "Manage Order".localized,
                style: .default,
                handler: { [weak self] _ in
                    let vc = OrderDetailsViewController()
                    vc.orderId = orderId
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            ))
        }

        // Report Listing action
        actionSheet.addAction(UIAlertAction(
            title: "Report Listing".localized,
            style: .destructive,
            handler: { [weak self] _ in
                self?.showReportOptions()
            }
        ))

        // Block Seller action
        actionSheet.addAction(UIAlertAction(
            title: "Block Seller".localized,
            style: .destructive,
            handler: { [weak self] _ in
                self?.blockSeller()
            }
        ))

        // Cancel
        actionSheet.addAction(UIAlertAction(
            title: "Cancel".localized,
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
            title: "Report Listing".localized,
            message: "Why are you reporting this listing?".localized,
            preferredStyle: .actionSheet
        )

        let reportReasons = [
            "Inappropriate content".localized,
            "Misleading or scam".localized,
            "Prohibited item".localized,
            "Incorrect category".localized,
            "Spam".localized,
            "Other".localized
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

        reportSheet.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))

        // For iPad
        if let popover = reportSheet.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItems?.first
        }

        present(reportSheet, animated: true)
    }

    private func submitReport(reason: String) {
        guard let product = product,
              let productId = product.id else { return }

        // TODO: Persist report through repository once reports are centralized.
        // For now, show confirmation
        Task {
            do {
                guard let userId = await AuthManager.shared.currentUserId else {
                    showAlert(title: "Error".localized, message: "Please log in to report listings".localized)
                    return
                }

                // Create report in Firestore
                let reportDTO = ReportInsertDTO(
                    reporter_id: userId,
                    product_id: productId,
                    seller_id: product.sellerId ?? "",
                    reason: reason,
                    status: "pending"
                )

                try await Firestore.firestore().collection("reports").addDocument(data: [
                    "reporter_id": reportDTO.reporter_id,
                    "product_id": reportDTO.product_id,
                    "seller_id": reportDTO.seller_id,
                    "reason": reportDTO.reason,
                    "status": reportDTO.status,
                    "created_at": ISO8601DateFormatter().string(from: Date())
                ])

                await MainActor.run {
                    self.showAlert(
                        title: "Report Submitted".localized,
                        message: "Thank you for helping keep Unizo safe. Our team will review this listing.".localized
                    )
                }
            } catch {
                print("❌ Failed to submit report: \(error)")
                await MainActor.run {
                    self.showAlert(
                        title: "Report Submitted".localized,
                        message: "Thank you for helping keep Unizo safe. Our team will review this listing.".localized
                    )
                }
            }
        }
    }

    private func blockSeller() {
        guard let product = product,
              let sellerId = product.sellerId else {
            showAlert(title: "Error".localized, message: "Unable to block this seller".localized)
            return
        }

        let confirmAlert = UIAlertController(
            title: "Block Seller".localized,
            message: String(format: "You won't see listings from %@ anymore. This action can be undone in Settings.".localized, product.sellerName),
            preferredStyle: .alert
        )

        confirmAlert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))
        confirmAlert.addAction(UIAlertAction(title: "Block".localized, style: .destructive) { [weak self] _ in
            self?.performBlockSeller(sellerId: sellerId, sellerName: product.sellerName)
        })

        present(confirmAlert, animated: true)
    }

    private func performBlockSeller(sellerId: String, sellerName: String) {
        Task {
            do {
                guard let userId = await AuthManager.shared.currentUserId else {
                    showAlert(title: "Error".localized, message: "Please log in to block sellers".localized)
                    return
                }

                // Add to blocked_users collection in Firestore
                let blockDTO = BlockedUserInsertDTO(
                    user_id: userId,
                    blocked_user_id: sellerId
                )
                let documentId = "\(blockDTO.user_id)_\(blockDTO.blocked_user_id)"
                try await Firestore.firestore().collection("blocked_users").document(documentId).setData([
                    "user_id": blockDTO.user_id,
                    "blocked_user_id": blockDTO.blocked_user_id,
                    "created_at": ISO8601DateFormatter().string(from: Date())
                ])

                BlockedUsersStore.add(sellerId)

                await MainActor.run {
                    self.showAlert(
                        title: "Seller Blocked".localized,
                        message: String(format: "You won't see listings from %@ anymore.".localized, sellerName)
                    ) { [weak self] in
                        // Go back after blocking
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            } catch {
                print("❌ Failed to block seller: \(error)")
                await MainActor.run {
                    // Still show success for MVP (local blocking)
                    BlockedUsersStore.add(sellerId)
                    self.showAlert(
                        title: "Seller Blocked".localized,
                        message: String(format: "You won't see listings from %@ anymore.".localized, sellerName)
                    ) { [weak self] in
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }

    // MARK: - Guest Gate
    /// Returns true if in guest mode (and shows sign-in alert). Returns false if not guest.
    private func showGuestGateIfNeeded() -> Bool {
        guard MainTabBarController.isGuestMode else { return false }

        let alert = UIAlertController(
            title: "Sign In Required".localized,
            message: "Please sign in to use this feature".localized,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Sign In".localized, style: .default) { [weak self] _ in
            guard let self = self else { return }
            let welcomeVC = WelcomeViewController()
            welcomeVC.modalPresentationStyle = .fullScreen
            welcomeVC.modalTransitionStyle = .crossDissolve
            self.present(welcomeVC, animated: true)
        })

        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))

        present(alert, animated: true)
        return true
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

    /// Navigate to chat with the seller
    @objc private func chatWithSellerTapped() {
        print("🟦 [ChatDebug] chatWithSellerTapped triggered")
        if showGuestGateIfNeeded() { return }

        guard let product = product,
                            let productId = product.id,
              let sellerId = product.sellerId else {
            print("🟥 [ChatDebug] Missing product/seller info. productId=\(product?.id ?? "nil"), sellerId=\(product?.sellerId ?? "nil")")
            return
        }

        Task {
            guard let currentUserId = await AuthManager.shared.currentUserId, currentUserId != sellerId else {
                await MainActor.run {
                    let alert = UIAlertController(title: "Cannot Chat".localized, message: "You cannot chat with yourself about your own listing.".localized, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
                    self.present(alert, animated: true)
                }
                return
            }

            await MainActor.run {
                print("🟦 [ChatDebug] Preparing chat. productId=\(productId), sellerId=\(sellerId), sellerName=\(product.sellerName)")

                HapticFeedback.selection()

                // Show loading indicator
                let loadingAlert = UIAlertController(title: nil, message: "Opening chat...".localized, preferredStyle: .alert)
                let loadingIndicator = UIActivityIndicatorView(style: .medium)
                loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
                loadingIndicator.startAnimating()
                loadingAlert.view.addSubview(loadingIndicator)

                NSLayoutConstraint.activate([
                    loadingIndicator.centerXAnchor.constraint(equalTo: loadingAlert.view.centerXAnchor),
                    loadingIndicator.bottomAnchor.constraint(equalTo: loadingAlert.view.bottomAnchor, constant: -20)
                ])

                self.present(loadingAlert, animated: true)

                Task {
                    do {
                        // Get or create conversation id for this product
                        print("🟦 [ChatDebug] Calling ChatManager.getOrCreateConversationId")
                        let conversationId = try await ChatManager.shared.getOrCreateConversationId(
                            productId: productId,
                            sellerId: sellerId
                        )
                        print("🟩 [ChatDebug] Conversation id received=\(conversationId)")

                        await MainActor.run {
                            loadingAlert.dismiss(animated: true) { [weak self] in
                                print("🟦 [ChatDebug] Pushing ChatDetailViewController with conversationId=\(conversationId)")
                                let chatVC = ChatDetailViewController()
                                chatVC.conversationIdString = conversationId
                                chatVC.productIdString = productId
                                chatVC.chatTitle = product.name
                                chatVC.otherUserName = product.sellerName
                                chatVC.isSeller = false  // Current user is buyer, chatting with seller

                                self?.navigationController?.pushViewController(chatVC, animated: true)
                            }
                        }

                    } catch ChatError.cannotChatWithSelf {
                        await MainActor.run {
                            loadingAlert.dismiss(animated: true) { [weak self] in
                                let alert = UIAlertController(
                                    title: "Cannot Chat".localized,
                                    message: "You cannot chat with yourself about your own listing.".localized,
                                    preferredStyle: .alert
                                )
                                alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
                                self?.present(alert, animated: true)
                            }
                        }

                    } catch {
                        print("🟥 [ChatDebug] Failed to open chat: \(error)")
                        await MainActor.run {
                            loadingAlert.dismiss(animated: true) { [weak self] in
                                let alert = UIAlertController(
                                    title: "Error".localized,
                                    message: String(format: "%@\n%@", "Could not open chat. Please try again.".localized, error.localizedDescription),
                                    preferredStyle: .alert
                                )
                                alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
                                self?.present(alert, animated: true)
                            }
                            HapticFeedback.error()
                        }
                    }
                }
            }
        }
    }

    /// Navigate to Deal flow (same as previous Buy Now)
    @objc private func dealTapped() {
        if showGuestGateIfNeeded() { return }

        guard let product else { return }

        Task {
            guard let currentUserId = await AuthManager.shared.currentUserId, currentUserId != product.sellerId else {
                await MainActor.run {
                    let alert = UIAlertController(title: "Cannot Place Deal".localized, message: "You cannot place a deal on your own product.".localized, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
                    self.present(alert, animated: true)
                }
                return
            }

            await MainActor.run {
                // Check if product is still available
                guard product.isAvailable else {
                    HapticFeedback.error()
                    self.showUnavailableAlert()
                    return
                }

                HapticFeedback.placeOrder()

                let vc = AddressViewController()
                vc.flowSource = .fromCheckout
                vc.orderItems = [OrderItem(product: product)]
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    @objc private func heartTapped() {
        if showGuestGateIfNeeded() { return }

        guard let product = product else {
            print("❌ heartTapped: product is nil")
            return
        }
        guard let productId = product.id, !productId.isEmpty else {
            print("❌ heartTapped: product.id is nil or empty — @DocumentID mapping failed")
            print("❌ Product name was: \(product.name)")
            showToastMessage("Unable to wishlist this item. Please try again.".localized)
            return
        }

        let previousWishlistState = isWishlisted
        wishlistStateVersion += 1

        Task {
            do {
                guard let userId = await AuthManager.shared.currentUserId, !userId.isEmpty else {
                    print("❌ heartTapped: No authenticated Firebase user — Auth.auth().currentUser is nil")
                    await MainActor.run {
                        self.showToastMessage("Please sign in to use wishlist".localized)
                    }
                    return
                }

                print("✅ heartTapped: userId = \(userId), productId = \(productId)")

                if isWishlisted {
                    try await wishlistRepo.remove(
                        productId: productId,
                        userId: userId
                    )
                    HapticFeedback.removeFromWishlist()
                } else {
                    try await wishlistRepo.add(
                        productId: productId,
                        userId: userId
                    )
                    HapticFeedback.addToWishlist()
                }

                await MainActor.run {
                    self.isWishlisted.toggle()
                    self.updateHeartIcon()
                }
            } catch {
                print("❌ Wishlist error type: \(type(of: error))")
                print("❌ Wishlist error full: \(error)")
                print("❌ Wishlist error description: \(error.localizedDescription)")

                // Revert to previous state — do NOT leave UI in wrong state
                await MainActor.run {
                    self.isWishlisted = previousWishlistState
                    self.updateHeartIcon()
                    HapticFeedback.error()
                    self.showToastMessage(
                        previousWishlistState
                            ? "Failed to remove from wishlist".localized
                            : "Failed to add to wishlist".localized
                    )
                }
            }
        }
    }

    private func showToastMessage(_ message: String) {
        let toast = UILabel()
        toast.text = message
        toast.backgroundColor = UIColor.label.withAlphaComponent(0.85)
        toast.textColor = .systemBackground
        toast.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        toast.textAlignment = .center
        toast.layer.cornerRadius = 10
        toast.clipsToBounds = true
        toast.alpha = 0
        toast.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(toast)
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                           constant: -80),
            toast.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor,
                                          constant: -40),
            toast.heightAnchor.constraint(equalToConstant: 40),
            toast.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor,
                                            constant: 20)
        ])

        UIView.animate(withDuration: 0.3, animations: { toast.alpha = 1 }) { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0, animations: {
                toast.alpha = 0
            }) { _ in toast.removeFromSuperview() }
        }
    }

}

// MARK: - Image Carousel Collection View
extension ItemDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(galleryImages.count, 1) // Show at least 1 placeholder
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCarouselCell", for: indexPath) as! ImageCarouselCell

        if indexPath.item < galleryImages.count {
            cell.configure(with: galleryImages[indexPath.item])
        } else {
            cell.configurePlaceholder()
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == imageCarouselCollectionView else { return }
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        pageControl.currentPage = page
        currentImageIndex = page
    }
}

// MARK: - Image Carousel Cell
private class ImageCarouselCell: UICollectionViewCell {

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = .systemGray6
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func configure(with imageURL: String) {
        if imageURL.hasPrefix("http") {
            imageView.loadImage(from: imageURL)
        } else {
            imageView.image = UIImage(named: imageURL)
        }
    }

    func configurePlaceholder() {
        imageView.image = UIImage(systemName: "photo")
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.contentMode = .scaleAspectFit
    }
}

