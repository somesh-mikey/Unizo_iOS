
//  CartViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 13/11/25
//  Cleaned & production-ready
//

import UIKit
import ObjectiveC

// Associated object key for storing product ID on delete buttons
private struct AssociatedKeys {
    static var productId = "cartItemProductId"
}

final class CartViewController: UIViewController {

    // MARK: - Dependencies
    private let productRepository = ProductRepository(supabase: supabase)
    private var suggestionsHeightConstraint: NSLayoutConstraint!
    private var suggestionsTopToCartConstraint: NSLayoutConstraint!
    private var suggestionsTopToEmptyStateConstraint: NSLayoutConstraint!

    // MARK: - Data
    private var cartItems: [CartItem] {
        CartManager.shared.items
    }

    private var suggestedProducts: [ProductUIModel] = []

    // MARK: - UI Containers
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let refreshControl = UIRefreshControl()

    // MARK: - Empty State
    private let emptyStateContainer: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    private let emptyCartImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "cart")
        iv.tintColor = .tertiaryLabel
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let emptyStateLabel: UILabel = {
        let l = UILabel()
        l.text = "Your cart is empty"
        l.font = UIFont.preferredFont(forTextStyle: .title3)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        return l
    }()

    private let emptyStateSubtitle: UILabel = {
        let l = UILabel()
        l.text = "Looks like you haven't added\nanything to your cart yet"
        l.font = UIFont.preferredFont(forTextStyle: .subheadline)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .tertiaryLabel
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    // MARK: - Cart Items
    private let itemsTitle: UILabel = {
        let l = UILabel()
        l.text = "Items"
        l.font = UIFont.preferredFont(forTextStyle: .title2)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .label
        return l
    }()

    private let cartItemsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    // MARK: - Suggestions
    private let suggestionsTitle: UILabel = {
        let l = UILabel()
        l.text = "You may also like"
        l.font = UIFont.preferredFont(forTextStyle: .headline)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .label
        return l
    }()

    private lazy var suggestionsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 16

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(ProductCell.self,
                    forCellWithReuseIdentifier: ProductCell.reuseIdentifier)
        return cv
    }()

    // MARK: - Bottom Bar
    private let bottomBar = UIView()
    private let itemsCountLabel = UILabel()
    private let totalPriceLabel = UILabel()
    private let checkoutButton = UIButton()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGroupedBackground

        setupNavBar()
        setupScrollView()
        setupEmptyState()
        setupCartItemsSection()
        setupSuggestions()
        setupBottomBar()

        ensureProductsLoaded()
        refreshCartUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        refreshCartUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Navigation
    private func setupNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backPressed)
        )
    }

    @objc private func backPressed() {
        // Always go back to Landing VC (root of navigation stack)
        navigationController?.popToRootViewController(animated: true)
    }

    @objc private func handleRefresh() {
        HapticFeedback.pullToRefresh()

        Task {
            // Refresh product data for suggestions
            _ = try? await productRepository.fetchAllProducts(page: 1)

            await MainActor.run {
                self.refreshCartUI()
                self.refreshControl.endRefreshing()
            }
        }
    }

    // MARK: - ScrollView
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // Pull-to-refresh
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        scrollView.refreshControl = refreshControl

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -95),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    // MARK: - Empty State
    private func setupEmptyState() {
        contentView.addSubview(emptyStateContainer)
        emptyStateContainer.translatesAutoresizingMaskIntoConstraints = false

        [emptyCartImageView, emptyStateLabel, emptyStateSubtitle].forEach {
            emptyStateContainer.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            emptyStateContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
            emptyStateContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emptyStateContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            emptyCartImageView.topAnchor.constraint(equalTo: emptyStateContainer.topAnchor),
            emptyCartImageView.centerXAnchor.constraint(equalTo: emptyStateContainer.centerXAnchor),
            emptyCartImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyCartImageView.heightAnchor.constraint(equalToConstant: 80),

            emptyStateLabel.topAnchor.constraint(equalTo: emptyCartImageView.bottomAnchor, constant: 20),
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateContainer.centerXAnchor),

            emptyStateSubtitle.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 8),
            emptyStateSubtitle.centerXAnchor.constraint(equalTo: emptyStateContainer.centerXAnchor),
            emptyStateSubtitle.bottomAnchor.constraint(equalTo: emptyStateContainer.bottomAnchor)
        ])
    }

    // MARK: - Cart Items Section
    private func setupCartItemsSection() {
        [itemsTitle, cartItemsStack].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            itemsTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            itemsTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            cartItemsStack.topAnchor.constraint(equalTo: itemsTitle.bottomAnchor, constant: 16),
            cartItemsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cartItemsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - Suggestions
    private func setupSuggestions() {
        [suggestionsTitle, suggestionsCollectionView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        suggestionsHeightConstraint =
            suggestionsCollectionView.heightAnchor.constraint(equalToConstant: 0)

        // Create two top constraints - one for when cart has items, one for empty state
        suggestionsTopToCartConstraint = suggestionsTitle.topAnchor.constraint(equalTo: cartItemsStack.bottomAnchor, constant: 30)
        suggestionsTopToEmptyStateConstraint = suggestionsTitle.topAnchor.constraint(equalTo: emptyStateContainer.bottomAnchor, constant: 40)

        // Initially activate cart constraint (will be updated in refreshCartUI)
        suggestionsTopToCartConstraint.isActive = true
        suggestionsTopToEmptyStateConstraint.isActive = false

        NSLayoutConstraint.activate([
            suggestionsTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            suggestionsCollectionView.topAnchor.constraint(equalTo: suggestionsTitle.bottomAnchor, constant: 16),
            suggestionsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            suggestionsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            suggestionsCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),

            suggestionsHeightConstraint
        ])
    }

    private func updateSuggestionsTopConstraint(forEmptyCart isEmpty: Bool) {
        suggestionsTopToCartConstraint.isActive = !isEmpty
        suggestionsTopToEmptyStateConstraint.isActive = isEmpty
    }

    // MARK: - Bottom Bar
    private func setupBottomBar() {
        bottomBar.backgroundColor = .systemBackground
        bottomBar.layer.cornerRadius = Spacing.cornerRadiusXL

        // Items count label with Dynamic Type
        itemsCountLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        itemsCountLabel.adjustsFontForContentSizeCategory = true
        itemsCountLabel.textColor = .secondaryLabel

        // Total price label with Dynamic Type
        totalPriceLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        totalPriceLabel.adjustsFontForContentSizeCategory = true
        totalPriceLabel.textColor = .label

        // Checkout button with brand colors
        checkoutButton.setTitle("Checkout", for: .normal)
        checkoutButton.backgroundColor = .brandPrimary
        checkoutButton.layer.cornerRadius = Spacing.buttonHeight / 2
        checkoutButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        checkoutButton.titleLabel?.adjustsFontForContentSizeCategory = true
        checkoutButton.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
        checkoutButton.addTapAnimation()

        [itemsCountLabel, totalPriceLabel, checkoutButton].forEach {
            bottomBar.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        view.addSubview(bottomBar)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 95),

            itemsCountLabel.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 30),
            itemsCountLabel.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),

            totalPriceLabel.centerXAnchor.constraint(equalTo: bottomBar.centerXAnchor),
            totalPriceLabel.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),

            checkoutButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -25),
            checkoutButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            checkoutButton.widthAnchor.constraint(equalToConstant: 130),
            checkoutButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }

    // MARK: - UI Refresh
    private func refreshCartUI() {
        navigationItem.title = "Cart (\(cartItems.count))"

        cartItemsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let isEmpty = cartItems.isEmpty

        // Toggle visibility based on cart state
        emptyStateContainer.isHidden = !isEmpty
        itemsTitle.isHidden = isEmpty
        cartItemsStack.isHidden = isEmpty
        bottomBar.isHidden = isEmpty

        // Update suggestions constraint based on cart state
        updateSuggestionsTopConstraint(forEmptyCart: isEmpty)

        if isEmpty {
            loadSuggestions(category: nil)
            return
        }

        for item in cartItems {
            cartItemsStack.addArrangedSubview(makeCartItemCard(for: item))
        }

        itemsCountLabel.text = "\(cartItems.count) item(s)"
        totalPriceLabel.text = "₹\(Int(CartManager.shared.totalAmount))"

        loadSuggestions(category: cartItems.first?.product.category)
    }

    // MARK: - Cart Item Card (Final Mockup Style)
    private func makeCartItemCard(for item: CartItem) -> UIView {

        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = Spacing.cornerRadiusMedium

        // Image
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Spacing.cornerRadiusSmall
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .tertiarySystemBackground

        if let img = item.product.imageURL {
            img.hasPrefix("http")
                ? imageView.loadImage(from: img)
                : (imageView.image = UIImage(named: img))
        }

        // Category with Dynamic Type
        let categoryLabel = UILabel()
        categoryLabel.text = item.product.category ?? "General"
        categoryLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        categoryLabel.adjustsFontForContentSizeCategory = true
        categoryLabel.textColor = .secondaryLabel

        // Title with Dynamic Type
        let titleLabel = UILabel()
        titleLabel.text = item.product.name
        titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2

        // Sold By with Dynamic Type
        let soldByLabel = UILabel()
        soldByLabel.text = "Sold by \(item.product.sellerName)"
        soldByLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        soldByLabel.adjustsFontForContentSizeCategory = true
        soldByLabel.textColor = .brandPrimary

        // Text Stack
        let textStack = UIStackView(arrangedSubviews: [
            categoryLabel,
            titleLabel,
            soldByLabel
        ])
        textStack.axis = .vertical
        textStack.spacing = Spacing.xs

        // Price with Dynamic Type
        let priceLabel = UILabel()
        priceLabel.text = "₹\(Int(item.product.price))"
        priceLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        priceLabel.adjustsFontForContentSizeCategory = true
        priceLabel.textColor = .label
        priceLabel.textAlignment = .right
        
        let deleteButton = UIButton(type: .system)
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.addTarget(self, action: #selector(deleteCartItem(_:)), for: .touchUpInside)

        // Attach productId
        objc_setAssociatedObject(
            deleteButton,
            &AssociatedKeys.productId,
            item.product.id,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        // Add Subviews
        [imageView, textStack, priceLabel, deleteButton].forEach {
            card.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 120),

            imageView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            imageView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),

            priceLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            priceLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            textStack.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant: -12),
            textStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            
            // Delete button - 44pt minimum touch target per Apple HIG
            deleteButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -4),
            deleteButton.topAnchor.constraint(equalTo: soldByLabel.bottomAnchor, constant: 0),
            deleteButton.widthAnchor.constraint(equalToConstant: 44),
            deleteButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        // MARK: - Accessibility (Apple HIG Compliance)
        card.isAccessibilityElement = false
        card.accessibilityElements = [imageView, titleLabel, priceLabel, deleteButton]

        imageView.isAccessibilityElement = true
        imageView.accessibilityLabel = "Product image for \(item.product.name)"
        imageView.accessibilityTraits = .image

        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityLabel = item.product.name
        titleLabel.accessibilityTraits = .staticText

        priceLabel.isAccessibilityElement = true
        priceLabel.accessibilityLabel = "Price: \(Int(item.product.price)) rupees"
        priceLabel.accessibilityTraits = .staticText

        deleteButton.isAccessibilityElement = true
        deleteButton.accessibilityLabel = "Remove \(item.product.name) from cart"
        deleteButton.accessibilityHint = "Double tap to remove this item from your cart"
        deleteButton.accessibilityTraits = .button

        return card
    }

    // MARK: - Suggestions Loader
    private func loadSuggestions(category: String?) {
        let source = productRepository.cachedProducts
        let filtered = category == nil
            ? source.shuffled()
            : source.filter { $0.category == category }

        suggestedProducts = filtered.prefix(4).map(ProductMapper.toUIModel)

        let rows = ceil(Double(suggestedProducts.count) / 2)
        suggestionsHeightConstraint.constant =
            CGFloat(rows) * 280 + max(0, rows - 1) * 16

        suggestionsCollectionView.reloadData()
    }

    private func ensureProductsLoaded() {
        guard productRepository.cachedProducts.isEmpty else { return }

        Task {
            _ = try? await productRepository.fetchAllProducts(page: 1)
            await MainActor.run { self.refreshCartUI() }
        }
    }
    @objc private func deleteCartItem(_ sender: UIButton) {
        guard let productId = objc_getAssociatedObject(
            sender,
            &AssociatedKeys.productId
        ) as? UUID else { return }

        // Haptic feedback for delete action
        HapticFeedback.removeFromCart()

        // Frontend-only removal (persists across navigation)
        CartManager.shared.remove(productId: productId)

        // Rebuild UI safely
        refreshCartUI()
    }

    // MARK: - Checkout
    @objc private func checkoutTapped() {
        // Disable button during validation
        checkoutButton.isEnabled = false
        checkoutButton.setTitle("Checking...", for: .normal)

        Task {
            // Validate cart items before checkout
            let validationResult = await CartManager.shared.validateCart(productRepository: productRepository)

            await MainActor.run {
                self.checkoutButton.isEnabled = true
                self.checkoutButton.setTitle("Checkout", for: .normal)

                if validationResult.hasUnavailableItems {
                    // Show alert about unavailable items
                    self.showUnavailableItemsAlert(unavailableItems: validationResult.unavailableItems)
                } else {
                    // All items available, proceed to checkout
                    self.proceedToCheckout()
                }
            }
        }
    }

    private func showUnavailableItemsAlert(unavailableItems: [CartItem]) {
        HapticFeedback.warning()

        let itemNames = unavailableItems.map { $0.product.name }.joined(separator: ", ")

        let alert = UIAlertController(
            title: "Items No Longer Available",
            message: "The following items are no longer available and will be removed from your cart:\n\n\(itemNames)",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Remove & Continue", style: .default) { _ in
            // Remove unavailable items
            let productIds = unavailableItems.map { $0.product.id }
            CartManager.shared.removeUnavailableItems(productIds: productIds)

            // Refresh UI
            self.refreshCartUI()

            // If cart still has items, proceed to checkout
            if !CartManager.shared.items.isEmpty {
                self.proceedToCheckout()
            }
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    private func proceedToCheckout() {
        HapticFeedback.medium()

        let vc = AddressViewController()
        vc.flowSource = .fromCart

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}

// MARK: - CollectionView
extension CartViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        suggestedProducts.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProductCell.reuseIdentifier,
            for: indexPath
        ) as! ProductCell
        cell.configure(with: suggestedProducts[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 12) / 2
        return CGSize(width: width, height: 280)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selected = suggestedProducts[indexPath.item]
        let vc = ItemDetailsViewController(
            nibName: "ItemDetailsViewController",
            bundle: nil
        )
        vc.product = selected
        navigationController?.pushViewController(vc, animated: true)
    }
}
