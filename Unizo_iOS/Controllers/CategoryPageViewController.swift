//
//  CategoryPageViewController.swift
//  Unizo_iOS
//
//  Created by Somesh on 18/11/25.
// push changes

import UIKit

class CategoryPageViewController: UIViewController, UITabBarDelegate, UIScrollViewDelegate, UISearchBarDelegate {

    private let categoryTitles: [String] = [
        "Hostel Essentials".localized,
        "Furniture".localized,
        "Fashion".localized,
        "Sports".localized,
        "Gadgets".localized
    ]

    // MARK: - Data
    var categoryIndex: Int = 0
    var items: [ProductUIModel] = []


    // MARK: - UI
    private let topContainer = UIView()
    private let navBarView = UIView()
    private let homeLabel = UILabel()

    // Menu button (replaces UIToolbar - per Apple HIG)
    private let menuButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    private let searchBar = UISearchBar()
    private let recentSearchesContainer = UIView()
    private let recentSearchesTableView = UITableView(frame: .zero, style: .plain)
    private let recentSearchesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Recent Searches".localized
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let clearRecentSearchesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear".localized, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private var recentSearches: [String] = []
    private var recentSearchesHeightConstraint: NSLayoutConstraint?
    private let trendingCategoriesbg = UIView()
    private let trendingLabel = UILabel()
    private let categoryStackView = UIStackView()
    private let lowerBackgroundView = UIView()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let bannerImage = UIImageView()
    private let collectionView: UICollectionView
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No products in this category yet.".localized
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // MARK: - Search
    private var filteredItems: [ProductUIModel] = []
    private var isFiltering: Bool { !(searchBar.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty }
    private var topContainerTopConstraint: NSLayoutConstraint!

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateCollectionHeight()

        // Extend scroll behind tab bar but avoid clipping content
        if let tabBarHeight = self.tabBarController?.tabBar.frame.height {
            scrollView.contentInset.bottom = tabBarHeight + 20
            var indicatorInsets = scrollView.verticalScrollIndicatorInsets
            indicatorInsets.bottom = tabBarHeight
            scrollView.verticalScrollIndicatorInsets = indicatorInsets
        }
    }


    // MARK: - Init
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Full teal background (same as Landing)
        view.backgroundColor = UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1)

        setupTopSection()      // Top identical to Landing
        setupScrollSection()   // White content section
        buildTrendingCategories()
        highlightSelectedCategory()
        setupCollectionView()
        loadCategoryBanner()
        loadRecentSearches()
        collectionView.reloadData()
        updateEmptyState()

        registerForKeyboardNotifications()

        // Hide navigation bar completely (no back button, no title, no toolbar)
        navigationController?.setNavigationBarHidden(true, animated: false)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleProductDeleted(_:)),
            name: .productDeleted,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBlockedUsersDidChange(_:)),
            name: .blockedUsersDidChange,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hideRecentSearchesPanel),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    @objc private func handleProductDeleted(_ notification: Notification) {
        guard let productId = notification.userInfo?["productId"] as? String else { return }
        items.removeAll { $0.id == productId }
        filteredItems.removeAll { $0.id == productId }
        collectionView.reloadData()
        updateCollectionHeight()
        updateEmptyState()
    }

    @objc private func handleBlockedUsersDidChange(_ notification: Notification) {
        let blockedSellerId = notification.userInfo?["blockedSellerId"] as? String
        let shouldRefreshData = notification.userInfo?["refreshData"] as? Bool ?? false
        let blockedSellerSet = BlockedUsersStore.all()

        let shouldRemove: (ProductUIModel) -> Bool = { product in
            guard let sellerId = product.sellerId else { return false }
            if let blockedSellerId {
                return sellerId == blockedSellerId
            }
            return blockedSellerSet.contains(sellerId)
        }

        let beforeCount = items.count
        items.removeAll(where: shouldRemove)
        filteredItems.removeAll(where: shouldRemove)

        let removedCount = max(0, beforeCount - items.count)
        if removedCount > 0 {
            print("🚫 [Moderation] Category page removed \(removedCount) blocked-seller products")
            collectionView.reloadData()
            updateCollectionHeight()
            updateEmptyState()
            return
        }

        if shouldRefreshData {
            let selectedCategory = categoryTitles.indices.contains(categoryIndex)
                ? categoryTitles[categoryIndex]
                : "Hostel Essentials".localized
            let productRepository = ProductRepository()

            print("🔄 [Moderation] Category page refreshing after unblock for category=\(selectedCategory)")

            Task {
                do {
                    let dtos = try await productRepository.fetchProductsByCategory(selectedCategory)
                    let products = dtos.map(ProductMapper.toUIModel)

                    await MainActor.run {
                        self.items = products
                        if self.isFiltering {
                            let query = self.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
                            self.filteredItems = query.isEmpty
                                ? []
                                : products.filter {
                                    $0.name.lowercased().contains(query) ||
                                    (($0.description ?? "").lowercased().contains(query))
                                }
                        }
                        self.collectionView.reloadData()
                        self.updateCollectionHeight()
                        self.updateEmptyState()
                    }
                } catch {
                    print("❌ [Moderation] Category refresh after unblock failed: \(error)")
                }
            }
        }
    }

    deinit {
        // Removes all observers including .productDeleted and keyboard notifications
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - TOP SECTION (Identical to Landing)
    private func setupTopSection() {

        topContainer.backgroundColor = .clear
        view.addSubview(topContainer)
        topContainer.translatesAutoresizingMaskIntoConstraints = false

        // Store reference for scroll-based collapsing
        topContainerTopConstraint = topContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)

        NSLayoutConstraint.activate([
            topContainerTopConstraint,
            topContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topContainer.heightAnchor.constraint(equalToConstant: 145) // Only navBar height
        ])

        // NAVBAR - fills entire top container
        navBarView.backgroundColor = UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1)
        topContainer.addSubview(navBarView)
        navBarView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            navBarView.topAnchor.constraint(equalTo: topContainer.topAnchor),
            navBarView.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor),
            navBarView.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor),
            navBarView.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor) // Fill entire container
        ])

        // TOOLBAR
//        navBarView.addSubview(toolbar)
//        toolbar.translatesAutoresizingMaskIntoConstraints = false
//        toolbar.tintColor = .white
//        toolbar.isTranslucent = false
//        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
//        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
//
//        NSLayoutConstraint.activate([
//            toolbar.topAnchor.constraint(equalTo: navBarView.topAnchor),
//            toolbar.leadingAnchor.constraint(equalTo: navBarView.leadingAnchor),
//            toolbar.trailingAnchor.constraint(equalTo: navBarView.trailingAnchor),
//            toolbar.heightAnchor.constraint(equalToConstant: 44)
//        ])
//
//        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let menu = UIBarButtonItem(image: UIImage(systemName: "ellipsis"),
//                                   style: .plain,
//                                   target: self,
//                                   action: #selector(menuButtonTapped))
//        toolbar.setItems([flex, menu], animated: false)

        // --- Menu Button (Apple HIG: Use plain buttons, not toolbars, for navigation areas) ---
        navBarView.addSubview(menuButton)
        configureMenuButton()

        // 44pt minimum touch target per Apple HIG
        NSLayoutConstraint.activate([
            menuButton.topAnchor.constraint(equalTo: navBarView.topAnchor, constant: Spacing.sm),
            menuButton.trailingAnchor.constraint(equalTo: navBarView.trailingAnchor, constant: -Spacing.md),
            menuButton.widthAnchor.constraint(equalToConstant: Spacing.minTouchTarget),
            menuButton.heightAnchor.constraint(equalToConstant: Spacing.minTouchTarget)
        ])

        // Home LABEL - same styling and positioning as LandingVC
        homeLabel.text = "Home".localized
        homeLabel.textColor = .white
        homeLabel.font = UIFont.systemFont(ofSize: 35, weight: .bold)
        homeLabel.isUserInteractionEnabled = false
        homeLabel.backgroundColor = .clear
        navBarView.addSubview(homeLabel)
        homeLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            homeLabel.leadingAnchor.constraint(equalTo: navBarView.leadingAnchor, constant: 20),
            homeLabel.centerYAnchor.constraint(equalTo: menuButton.centerYAnchor)
        ])

        // SEARCH BAR - add to navBarView (same as LandingVC)
        navBarView.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search".localized
        searchBar.delegate = self

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: menuButton.bottomAnchor, constant: Spacing.md),
            searchBar.leadingAnchor.constraint(equalTo: navBarView.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: navBarView.trailingAnchor, constant: -20),
            searchBar.heightAnchor.constraint(equalToConstant: 44)
        ])

        setupRecentSearchesPanel()

        // Trending categories will be added to scroll content in setupScrollSection()
    }

    private func setupRecentSearchesPanel() {
        recentSearchesContainer.translatesAutoresizingMaskIntoConstraints = false
        recentSearchesContainer.backgroundColor = .white
        recentSearchesContainer.layer.cornerRadius = 14
        recentSearchesContainer.layer.masksToBounds = false
        recentSearchesContainer.layer.shadowColor = UIColor.black.cgColor
        recentSearchesContainer.layer.shadowOpacity = 0.08
        recentSearchesContainer.layer.shadowRadius = 10
        recentSearchesContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        recentSearchesContainer.isHidden = true
        view.addSubview(recentSearchesContainer)

        NSLayoutConstraint.activate([
            recentSearchesContainer.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            recentSearchesContainer.leadingAnchor.constraint(equalTo: navBarView.leadingAnchor, constant: 20),
            recentSearchesContainer.trailingAnchor.constraint(equalTo: navBarView.trailingAnchor, constant: -20)
        ])

        recentSearchesHeightConstraint = recentSearchesContainer.heightAnchor.constraint(equalToConstant: 0)
        recentSearchesHeightConstraint?.isActive = true

        let header = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = .white
        recentSearchesContainer.addSubview(header)

        header.addSubview(recentSearchesTitleLabel)
        header.addSubview(clearRecentSearchesButton)
        clearRecentSearchesButton.addTarget(self, action: #selector(clearRecentSearchesTapped), for: .touchUpInside)

        recentSearchesTableView.translatesAutoresizingMaskIntoConstraints = false
        recentSearchesTableView.dataSource = self
        recentSearchesTableView.delegate = self
        recentSearchesTableView.backgroundColor = .white
        recentSearchesTableView.tableFooterView = UIView()
        recentSearchesTableView.separatorInset = UIEdgeInsets(top: 0, left: 42, bottom: 0, right: 16)
        recentSearchesTableView.showsVerticalScrollIndicator = false
        recentSearchesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryRecentSearchCell")
        recentSearchesContainer.addSubview(recentSearchesTableView)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: recentSearchesContainer.topAnchor),
            header.leadingAnchor.constraint(equalTo: recentSearchesContainer.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: recentSearchesContainer.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 40),

            recentSearchesTitleLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 12),
            recentSearchesTitleLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),

            clearRecentSearchesButton.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -12),
            clearRecentSearchesButton.centerYAnchor.constraint(equalTo: header.centerYAnchor),

            recentSearchesTableView.topAnchor.constraint(equalTo: header.bottomAnchor),
            recentSearchesTableView.leadingAnchor.constraint(equalTo: recentSearchesContainer.leadingAnchor),
            recentSearchesTableView.trailingAnchor.constraint(equalTo: recentSearchesContainer.trailingAnchor),
            recentSearchesTableView.bottomAnchor.constraint(equalTo: recentSearchesContainer.bottomAnchor)
        ])

        view.bringSubviewToFront(recentSearchesContainer)
    }

    private func loadRecentSearches() {
        recentSearches = SearchHistoryStore.all()
        recentSearchesTableView.reloadData()
    }

    private func updateRecentSearchesVisibility(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let shouldShow = searchBar.isFirstResponder && trimmed.isEmpty && !recentSearches.isEmpty

        recentSearchesContainer.isHidden = !shouldShow
        recentSearchesHeightConstraint?.constant = shouldShow
            ? min(40 + CGFloat(recentSearches.count) * 48, 300)
            : 0

        if shouldShow {
            view.bringSubviewToFront(recentSearchesContainer)
        }
    }

    @objc private func clearRecentSearchesTapped() {
        SearchHistoryStore.clear()
        loadRecentSearches()
        updateRecentSearchesVisibility(for: searchBar.text ?? "")
    }

    private func saveRecentSearch(_ query: String) {
        SearchHistoryStore.add(query)
        loadRecentSearches()
    }

    private func openSearchResults(keyword: String, animated: Bool) {
        let shouldAutoFocus = keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let vc = SearchResultsViewController(keyword: keyword, shouldAutoFocus: shouldAutoFocus)
        if let nav = navigationController {
            nav.pushViewController(vc, animated: animated)
        } else {
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: animated)
        }
    }

    @objc private func hideRecentSearchesPanel() {
        recentSearchesContainer.isHidden = true
        recentSearchesHeightConstraint?.constant = 0
    }

    // MARK: - TRENDING BUTTONS
    private func buildTrendingCategories() {

        let categories = [
            ("cart", categoryTitles[0]),
            ("tablecells", categoryTitles[1]),
            ("tshirt", categoryTitles[2]),
            ("sportscourt", categoryTitles[3]),
            ("headphones", categoryTitles[4])
        ]

        for i in 0..<5 {
            let (icon, name) = categories[i]

            let v = UIStackView()
            v.axis = .vertical
            v.alignment = .center
            v.spacing = 6
            v.isUserInteractionEnabled = true   // ← CRITICAL FIX


            let btn = UIButton(type: .system)
            btn.tag = i
            btn.isUserInteractionEnabled = true
            btn.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
            btn.setImage(UIImage(systemName: icon), for: .normal)
            btn.tintColor = UIColor(red: 0.03, green: 0.22, blue: 0.27, alpha: 1)
            btn.backgroundColor = UIColor(red: 0.65, green: 0.91, blue: 0.96, alpha: 1)
            btn.layer.cornerRadius = 28
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.widthAnchor.constraint(equalToConstant: 56).isActive = true
            btn.heightAnchor.constraint(equalToConstant: 56).isActive = true

            let lbl = UILabel()
            lbl.text = name
            lbl.numberOfLines = 2
            lbl.textAlignment = .center
            lbl.font = UIFont.systemFont(ofSize: 12)
            lbl.isUserInteractionEnabled = false

            v.addArrangedSubview(btn)
            v.addArrangedSubview(lbl)
            categoryStackView.addArrangedSubview(v)
        }
    }

    private func highlightSelectedCategory() {
        guard categoryIndex < categoryStackView.arrangedSubviews.count else { return }

        if let categoryStack = categoryStackView.arrangedSubviews[categoryIndex] as? UIStackView,
           let btn = categoryStack.arrangedSubviews.first as? UIButton {

            btn.backgroundColor = UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1)
            btn.tintColor = .white
        }
    }

    // MARK: - SCROLL SECTION
    private func setupScrollSection() {

        // --- White background below trending categories (covers bottom overscroll area) ---
        lowerBackgroundView.backgroundColor = .white
        lowerBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lowerBackgroundView)
        NSLayoutConstraint.activate([
            lowerBackgroundView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 150),
            lowerBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lowerBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            lowerBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        scrollView.backgroundColor = .clear
        contentView.backgroundColor = .white
        scrollView.delaysContentTouches = true
        scrollView.canCancelContentTouches = true
        scrollView.delegate = self

        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        // Dismiss keyboard on drag
        scrollView.keyboardDismissMode = .onDrag

        // Scroll starts from top of trending categories (same as LandingVC)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 22),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor)
        ])

        // Tap to dismiss keyboard when tapping the content area
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        contentView.addGestureRecognizer(tap)

        // --- Add teal background strip behind trending categories for rounded corner effect ---
        let tealStrip = UIView()
        tealStrip.backgroundColor = UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1) // #3D7C98 teal
        tealStrip.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tealStrip)
        NSLayoutConstraint.activate([
            tealStrip.topAnchor.constraint(equalTo: contentView.topAnchor),
            tealStrip.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tealStrip.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tealStrip.heightAnchor.constraint(equalToConstant: 30)
        ])

        // --- Add Trending Categories to scroll content ---
        trendingCategoriesbg.backgroundColor = UIColor(red: 0.83, green: 0.95, blue: 0.96, alpha: 1)
        trendingCategoriesbg.layer.cornerRadius = 20
        trendingCategoriesbg.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        trendingCategoriesbg.clipsToBounds = true
        trendingCategoriesbg.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(trendingCategoriesbg)
        NSLayoutConstraint.activate([
            trendingCategoriesbg.topAnchor.constraint(equalTo: contentView.topAnchor),
            trendingCategoriesbg.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trendingCategoriesbg.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        // TRENDING LABEL
        trendingLabel.text = "Trending Categories".localized
        trendingLabel.font = UIFont.boldSystemFont(ofSize: 17)
        trendingCategoriesbg.addSubview(trendingLabel)
        trendingLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            trendingLabel.topAnchor.constraint(equalTo: trendingCategoriesbg.topAnchor, constant: 10),
            trendingLabel.leadingAnchor.constraint(equalTo: trendingCategoriesbg.leadingAnchor, constant: 15)
        ])

        // STACK
        trendingCategoriesbg.addSubview(categoryStackView)
        categoryStackView.translatesAutoresizingMaskIntoConstraints = false
        categoryStackView.axis = .horizontal
        categoryStackView.alignment = .top
        categoryStackView.spacing = 5
        categoryStackView.distribution = .fillEqually

        NSLayoutConstraint.activate([
            categoryStackView.topAnchor.constraint(equalTo: trendingLabel.bottomAnchor, constant: 10),
            categoryStackView.leadingAnchor.constraint(equalTo: trendingCategoriesbg.leadingAnchor, constant: 10),
            categoryStackView.trailingAnchor.constraint(equalTo: trendingCategoriesbg.trailingAnchor, constant: -10)
        ])

        // Set bottom constraint for trendingCategoriesbg height
        trendingCategoriesbg.bottomAnchor
            .constraint(equalTo: categoryStackView.bottomAnchor, constant: 25)
            .isActive = true

        // Banner
        contentView.addSubview(bannerImage)
        bannerImage.translatesAutoresizingMaskIntoConstraints = false
        bannerImage.layer.cornerRadius = 16
        bannerImage.clipsToBounds = true
        bannerImage.contentMode = .scaleAspectFill

        NSLayoutConstraint.activate([
            bannerImage.topAnchor.constraint(equalTo: trendingCategoriesbg.bottomAnchor, constant: 20),
            bannerImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bannerImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            bannerImage.heightAnchor.constraint(equalToConstant: 180)
        ])

        // Collection
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emptyStateLabel)

        let bottomConstraint = collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        bottomConstraint.priority = .required

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: bannerImage.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            bottomConstraint,

            emptyStateLabel.topAnchor.constraint(equalTo: bannerImage.bottomAnchor, constant: 40),
            emptyStateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
    }
    private func updateCollectionHeight() {
        collectionView.layoutIfNeeded()
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        view.layoutIfNeeded()

        let floatingBarCover = (tabBarController?.tabBar.frame.height ?? 70) + 30
        let collectionTopInView = collectionView.convert(.zero, to: view).y
        let minHeightToScreenBottom = max(0, view.bounds.height - collectionTopInView)
        let height = max(contentHeight + floatingBarCover, minHeightToScreenBottom + floatingBarCover)

        for constraint in collectionView.constraints where constraint.firstAttribute == .height {
            collectionView.removeConstraint(constraint)
        }

        collectionView.heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    private func updateEmptyState() {
        let source = isFiltering ? filteredItems : items
        if source.isEmpty {
            if isFiltering {
                emptyStateLabel.text = "No matching products found.".localized
            } else {
                let categoryName = categoryTitles.indices.contains(categoryIndex)
                    ? categoryTitles[categoryIndex]
                    : "this category".localized
                emptyStateLabel.text = String(format: "No products in %@ yet.".localized, categoryName)
            }
        }
        emptyStateLabel.isHidden = !source.isEmpty
    }

    // MARK: - Keyboard Observers
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    private func unregisterForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }

    @objc private func keyboardWillShow(_ n: Notification) {
        guard let userInfo = n.userInfo,
              let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let keyboardHeight = frame.height
        var inset = scrollView.contentInset
        inset.bottom = keyboardHeight
        scrollView.contentInset = inset
        scrollView.scrollIndicatorInsets = inset
    }

    @objc private func keyboardWillHide(_ n: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }

    @objc private func dismissKeyboard() {
        searchBar.resignFirstResponder()
        view.endEditing(true)
    }


    // MARK: - Collection Setup
    private func setupCollectionView() {

        collectionView.register(ProductCell.self,
                                forCellWithReuseIdentifier: ProductCell.reuseIdentifier)

        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
            layout.minimumLineSpacing = 15
            layout.minimumInteritemSpacing = 10
        }
    }

    // MARK: - Load Banner
    private func loadCategoryBanner() {
        let banners = [
            "hostelessentials",  // index 0
            "furniturebanner",   // index 1
            "fashionbanner",     // index 2
            "sportsbanner",      // index 3
            "gadgetsbanner"      // index 4
        ]

        let bannerName = banners[categoryIndex]
        bannerImage.image = UIImage(named: bannerName)
    }

    // MARK: - Actions
//    @objc private func menuButtonTapped() {
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Cart", style: .default))
//        alert.addAction(UIAlertAction(title: "Wishlist", style: .default))
//        alert.addAction(UIAlertAction(title: "Notifications", style: .default))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//
//        if let popover = alert.popoverPresentationController {
//            popover.barButtonItem = toolbar.items?.last
//        }
//
//        present(alert, animated: true)
//    }
    // MARK: - Native Pull-Down Menu (UIMenu)
    private func configureMenuButton() {
        let wishlistAction = UIAction(
            title: "Wishlist".localized,
            image: UIImage(systemName: "heart")
        ) { [weak self] _ in
            guard let self = self else { return }
            let vc = WishlistViewController()
            if let nav = self.navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle = .coverVertical
                self.present(vc, animated: true)
            }
        }

        let notificationsAction = UIAction(
            title: "Notifications".localized,
            image: UIImage(systemName: "bell")
        ) { [weak self] _ in
            guard let self = self else { return }
            let vc = NotificationsViewController()
            if let nav = self.navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle = .coverVertical
                self.present(vc, animated: true)
            }
        }

        menuButton.menu = UIMenu(children: [wishlistAction, notificationsAction])
        menuButton.showsMenuAsPrimaryAction = true
    }

    @objc private func categoryTapped(_ sender: UIButton) {
        hideRecentSearchesPanel()

        let index = sender.tag

        // If same category, do nothing
        guard index != categoryIndex else { return }

        // Reset all buttons to default state
        resetAllCategoryButtons()

        // Update index and highlight selected
        categoryIndex = index
        highlightSelectedCategory()

        // Fetch new products for selected category
        let selectedCategory = categoryTitles.indices.contains(index)
            ? categoryTitles[index]
            : "Hostel Essentials".localized
        let productRepository = ProductRepository()

        Task {
            do {
                let dtos = try await productRepository.fetchProductsByCategory(selectedCategory)
                let products = dtos.map(ProductMapper.toUIModel)

                await MainActor.run {
                    self.items = products
                    self.loadCategoryBanner()
                    self.collectionView.reloadData()
                    self.collectionView.layoutIfNeeded()
                    self.updateCollectionHeight()
                    self.updateEmptyState()

                    // Scroll to top
                    self.scrollView.setContentOffset(.zero, animated: true)
                }
            } catch {
                print("❌ Category fetch failed:", error)
            }
        }
    }

    private func resetAllCategoryButtons() {
        for case let stack as UIStackView in categoryStackView.arrangedSubviews {
            if let btn = stack.arrangedSubviews.first as? UIButton {
                btn.backgroundColor = UIColor(red: 0.65, green: 0.91, blue: 0.96, alpha: 1)
                btn.tintColor = UIColor(red: 0.03, green: 0.22, blue: 0.27, alpha: 1)
            }
        }
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self.scrollView else { return }

        // Keep top pull-down region fully blue; restore white lower background otherwise.
        lowerBackgroundView.isHidden = scrollView.contentOffset.y < 0
    }

}

// MARK: - Search
extension CategoryPageViewController {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        hideRecentSearchesPanel()
        openSearchResults(keyword: "", animated: false)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateRecentSearchesVisibility(for: searchText)

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            filteredItems.removeAll()
            collectionView.reloadData()
            updateCollectionHeight()
            updateEmptyState()
            return
        }

        filteredItems = items.filter { p in
            let lower = query.lowercased()
            if p.name.lowercased().contains(lower) { return true }
            if let desc = p.description?.lowercased(), desc.contains(lower) { return true }
            return false
        }

        collectionView.reloadData()
        updateCollectionHeight()
        updateEmptyState()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let query = (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            searchBar.resignFirstResponder()
            updateRecentSearchesVisibility(for: "")
            return
        }

        saveRecentSearch(query)
        searchBar.resignFirstResponder()
        updateRecentSearchesVisibility(for: query)
        openSearchResults(keyword: query, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        updateRecentSearchesVisibility(for: searchBar.text ?? "")
    }
}


// MARK: - CollectionView Delegates
extension CategoryPageViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let source = isFiltering ? filteredItems : items
        return source.count   // Items passed from Landing
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProductCell.reuseIdentifier,
            for: indexPath
        ) as! ProductCell

        let source = isFiltering ? filteredItems : items
        cell.configure(with: source[indexPath.item])
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let width = floor((collectionView.bounds.width - 30) / 2)
        return CGSize(width: width, height: ProductCell.preferredHeight(for: traitCollection))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide navigation bar (no back button, no title)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        // Show tab bar
        tabBarController?.tabBar.isHidden = false
        (tabBarController as? MainTabBarController)?.showFloatingTabBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        hideRecentSearchesPanel()

        let source = isFiltering ? filteredItems : items
        let selected = source[indexPath.item]

        let vc = ItemDetailsViewController(
            nibName: "ItemDetailsViewController",
            bundle: nil
        )
        vc.product = selected

        navigationController?.pushViewController(vc, animated: true)
    }

}
extension UIViewController {
    func makeEllipsisButton(target: Any?, action: Selector) -> UIBarButtonItem {

        // FIX 1 — Correct container size
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 44),
            container.heightAnchor.constraint(equalToConstant: 44)
        ])

        // FIX 2 — Exact replica button
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false

        // IDENTICAL BACKGROUND COLOR
        btn.backgroundColor = UIColor(red: 0.83, green: 0.95, blue: 0.96, alpha: 1)

        // IDENTICAL BORDER
        btn.layer.cornerRadius = 22
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.45).cgColor
        btn.layer.borderWidth = 1.5

        // IDENTICAL SHADOW
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.12
        btn.layer.shadowOffset = CGSize(width: 0, height: 3)
        btn.layer.shadowRadius = 6

        // ICON
        btn.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        btn.tintColor = .black

        // IMPORTANT — remove automatic padding
        if #available(iOS 15.0, *) {
            var config = btn.configuration ?? UIButton.Configuration.plain()
            config.contentInsets = .zero
            btn.configuration = config
        } else {
            btn.contentEdgeInsets = .zero
        }

        btn.addTarget(target, action: action, for: .touchUpInside)

        // ADD → CENTER
        container.addSubview(btn)
        NSLayoutConstraint.activate([
            btn.widthAnchor.constraint(equalToConstant: 44),
            btn.heightAnchor.constraint(equalToConstant: 44),
            btn.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            btn.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        return UIBarButtonItem(customView: container)
    }
}

extension CategoryPageViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        recentSearches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryRecentSearchCell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = recentSearches[indexPath.row]
        content.textProperties.color = .label
        content.image = UIImage(systemName: "clock")
        content.imageProperties.tintColor = .secondaryLabel
        content.imageToTextPadding = 10

        cell.contentConfiguration = content
        cell.backgroundColor = .white
        cell.selectionStyle = .default
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let term = recentSearches[indexPath.row]
        searchBar.text = term
        saveRecentSearch(term)
        searchBar.resignFirstResponder()
        updateRecentSearchesVisibility(for: term)
        openSearchResults(keyword: term, animated: true)
    }
}
