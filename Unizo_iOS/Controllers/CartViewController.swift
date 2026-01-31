//
//  CartViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 13/11/25
//  Cleaned & production-ready
//

import UIKit

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

    // MARK: - Empty State
    private let emptyStateContainer: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    private let emptyCartImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "cart")
        iv.tintColor = UIColor(red: 0.75, green: 0.75, blue: 0.78, alpha: 1)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let emptyStateLabel: UILabel = {
        let l = UILabel()
        l.text = "Your cart is empty"
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        l.textColor = .darkGray
        l.textAlignment = .center
        return l
    }()

    private let emptyStateSubtitle: UILabel = {
        let l = UILabel()
        l.text = "Looks like you haven't added\nanything to your cart yet"
        l.font = .systemFont(ofSize: 14)
        l.textColor = .gray
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    // MARK: - Cart Items
    private let itemsTitle: UILabel = {
        let l = UILabel()
        l.text = "Items"
        l.font = .systemFont(ofSize: 22, weight: .semibold)
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
        l.font = .systemFont(ofSize: 18, weight: .semibold)
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

    private let darkTeal = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.98, alpha: 1)

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

    // MARK: - ScrollView
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

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
        bottomBar.backgroundColor = .white
        bottomBar.layer.cornerRadius = 30

        checkoutButton.setTitle("Checkout", for: .normal)
        checkoutButton.backgroundColor = darkTeal
        checkoutButton.layer.cornerRadius = 22
        checkoutButton.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)

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
        card.backgroundColor = .white
        card.layer.cornerRadius = 14

        // Image
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor(white: 0.94, alpha: 1)

        if let img = item.product.imageURL {
            img.hasPrefix("http")
                ? imageView.loadImage(from: img)
                : (imageView.image = UIImage(named: img))
        }

        // Category
        let categoryLabel = UILabel()
        categoryLabel.text = item.product.category ?? "General"
        categoryLabel.font = .systemFont(ofSize: 12)
        categoryLabel.textColor = .gray

        // Title
        let titleLabel = UILabel()
        titleLabel.text = item.product.name
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.numberOfLines = 2

        // Sold By
        let soldByLabel = UILabel()
        soldByLabel.text = "Sold by \(item.product.sellerName)"
        soldByLabel.font = .systemFont(ofSize: 12)
        soldByLabel.textColor = UIColor.systemBlue

        // Text Stack
        let textStack = UIStackView(arrangedSubviews: [
            categoryLabel,
            titleLabel,
            soldByLabel
        ])
        textStack.axis = .vertical
        textStack.spacing = 4

        // Price (VERTICALLY CENTERED)
        let priceLabel = UILabel()
        priceLabel.text = "₹\(Int(item.product.price))"
        priceLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        priceLabel.textAlignment = .right

        // Add Subviews
        [imageView, textStack, priceLabel].forEach {
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
            textStack.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])

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

    // MARK: - Checkout
    @objc private func checkoutTapped() {
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
