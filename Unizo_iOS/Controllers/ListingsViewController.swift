//
//  ListingsViewController.swift
//  Unizo_iOS
//

import UIKit

class ListingsViewController: UIViewController {

    private let sellerDashboardRepository = SellerDashboardRepository()
    private let chatRepository = ChatRepository()
    private let productRepository = ProductRepository()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "My Listings".localized
        label.font = .systemFont(ofSize: 35, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let listingsCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search listings...".localized
        sb.searchBarStyle = .minimal
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()

    private let filterSegmentedControl: UISegmentedControl = {
        let items = ["All".localized, "Available".localized, "Pending".localized, "Sold".localized]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentTintColor = .brandPrimary
        sc.setTitleTextAttributes([
            .foregroundColor: UIColor.brandPrimary,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)
        sc.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)
        return sc
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = Spacing.lg
        layout.sectionInset = UIEdgeInsets(top: Spacing.md, left: 0, bottom: Spacing.xxxl, right: 0)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.alwaysBounceVertical = true
        cv.keyboardDismissMode = .onDrag
        return cv
    }()

    private let refreshControl = UIRefreshControl()

    private let emptyStateContainer: UIView = {
        let v = UIView()
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let emptyStateImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "tray")
        iv.tintColor = .tertiaryLabel
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let emptyStateLabel: UILabel = {
        let l = UILabel()
        l.text = "No listings yet".localized
        l.font = UIFont.preferredFont(forTextStyle: .title3)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let emptyStateSubtitle: UILabel = {
        let l = UILabel()
        l.text = "Start selling by posting\nyour first item".localized
        l.font = UIFont.preferredFont(forTextStyle: .subheadline)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .tertiaryLabel
        l.textAlignment = .center
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    struct Listing {
        let image: UIImage?
        let imageURL: String?
        let category: String
        let name: String
        let status: String
        let price: String
        let productId: String
        let viewsCount: Int
        let createdAt: Date?
        let quantity: Int
        let buyerName: String?
        let orderStatus: String?
        let interestedBuyersCount: Int
        let dealRequestsCount: Int
        var hasNewInterestedBuyers: Bool
        var hasNewDealRequests: Bool

        var hasNewActivity: Bool {
            hasNewInterestedBuyers || hasNewDealRequests
        }
    }

    private var allListings: [Listing] = []
    private var filteredListings: [Listing] = []
    private var products: [ProductDTO] = []
    private var currentUserId: String?

    private var currentSearchText: String = ""
    private var currentFilter: String = "All"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        setupCollectionView()
        setupSearchBar()
        setupFilterControl()

        // Observe .productSold — when a product is sold via order acceptance,
        // update the seller's listings to show "Sold" status badge (do NOT remove)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleProductSold(_:)),
            name: .productSold,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .productSold, object: nil)
    }

    /// When a product is sold, refresh the listings from Firestore to pick up the
    /// updated "Sold" status. Do NOT remove the product — sellers need sales history.
    @objc private func handleProductSold(_ notification: Notification) {
        guard let productId = notification.userInfo?["productId"] as? String else { return }

        print("🏷️ [ListingsVC] Product sold notification received for \(productId) — refreshing listings")

        // Update allListings status locally for immediate UI feedback
        for i in allListings.indices {
            if allListings[i].productId == productId {
                allListings[i] = Listing(
                    image: allListings[i].image,
                    imageURL: allListings[i].imageURL,
                    category: allListings[i].category,
                    name: allListings[i].name,
                    status: "Sold",
                    price: allListings[i].price,
                    productId: allListings[i].productId,
                    viewsCount: allListings[i].viewsCount,
                    createdAt: allListings[i].createdAt,
                    quantity: 0,
                    buyerName: allListings[i].buyerName,
                    orderStatus: allListings[i].orderStatus,
                    interestedBuyersCount: allListings[i].interestedBuyersCount,
                    dealRequestsCount: allListings[i].dealRequestsCount,
                    hasNewInterestedBuyers: allListings[i].hasNewInterestedBuyers,
                    hasNewDealRequests: allListings[i].hasNewDealRequests
                )
            }
        }

        applyFilters()
        updateListingsCount()

        // Also trigger a full refresh from Firestore to get authoritative data
        fetchUserListings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserListings()
    }

    private func fetchUserListings() {
        Task {
            do {
                guard let userId = await AuthManager.shared.currentUserId else {
                    await MainActor.run { self.refreshControl.endRefreshing() }
                    return
                }

                print("🟪 [DealDebug] ListingsViewController.fetchUserListings start sellerId=\(userId)")

                let fetchedProducts = try await sellerDashboardRepository.fetchSellerProducts()
                let conversations = try await chatRepository.fetchConversations()
                let sellerOrders = try await sellerDashboardRepository.fetchSellerOrders()
                print("🟪 [DealDebug] ListingsViewController.fetchUserListings fetchedProducts=\(fetchedProducts.count), conversations=\(conversations.count), sellerOrders=\(sellerOrders.count)")

                var productBuyersSet: [String: Set<String>] = [:]
                for conv in conversations where conv.seller_id == userId {
                    productBuyersSet[conv.product_id, default: Set<String>()].insert(conv.buyer_id)
                }

                var interestedBuyersMap: [String: Int] = [:]
                for (productId, buyersSet) in productBuyersSet {
                    interestedBuyersMap[productId] = buyersSet.count
                }

                var dealBuyersSet: [String: Set<String>] = [:]
                for order in sellerOrders where order.status == .pending {
                    guard let buyerId = order.buyerId else { continue }
                    dealBuyersSet[order.productId, default: Set<String>()].insert(buyerId)
                }

                var dealRequestsMap: [String: Int] = [:]
                for (productId, buyersSet) in dealBuyersSet {
                    dealRequestsMap[productId] = buyersSet.count
                }

                let pendingOrdersCount = sellerOrders.filter { $0.status == .pending }.count
                let dealSummary = dealRequestsMap.map { "\($0.key):\($0.value)" }.joined(separator: ", ")
                print("🟪 [DealDebug] ListingsViewController.fetchUserListings pendingOrders=\(pendingOrdersCount), dealRequestsMapCount=\(dealRequestsMap.count)")
                if !dealSummary.isEmpty {
                    print("🟪 [DealDebug] ListingsViewController.fetchUserListings dealRequestsByProduct \(dealSummary)")
                }

                let deletedIDs = DeletedListingsStore.all()

                await MainActor.run {
                    self.currentUserId = userId
                    self.products = fetchedProducts.filter {
                        guard let id = $0.id else { return false }
                        return !deletedIDs.contains(id)
                    }

                    self.allListings = self.products.compactMap { product in
                        guard let productId = product.id else { return nil }

                        let displayStatus: String
                        switch product.status {
                        case .sold:
                            displayStatus = "Sold"
                        case .pending:
                            displayStatus = "Pending"
                        case .available, .none:
                            displayStatus = "Available"
                        }

                        return Listing(
                            image: nil,
                            imageURL: product.imageUrl,
                            category: product.category ?? "Other",
                            name: product.title,
                            status: displayStatus,
                            price: "₹\(Int(product.price))",
                            productId: productId,
                            viewsCount: product.viewsCount ?? 0,
                            createdAt: nil,
                            quantity: product.quantity ?? 1,
                            buyerName: nil,
                            orderStatus: nil,
                            interestedBuyersCount: interestedBuyersMap[productId] ?? 0,
                            dealRequestsCount: dealRequestsMap[productId] ?? 0,
                            hasNewInterestedBuyers: (interestedBuyersMap[productId] ?? 0) > ListingMenuBadgeStore.lastSeenInterestedCount(for: productId, userId: userId),
                            hasNewDealRequests: (dealRequestsMap[productId] ?? 0) > ListingMenuBadgeStore.lastSeenDealRequestsCount(for: productId, userId: userId)
                        )
                    }

                    self.applyFilters()
                    self.updateListingsCount()
                    self.refreshControl.endRefreshing()
                }
            } catch {
                print("❌ [ListingsVC] \(type(of: error)): \(error)")
                await MainActor.run {
                    self.refreshControl.endRefreshing()
                    self.emptyStateLabel.text = "Couldn't load listings.\nPull to retry."
                    self.emptyStateContainer.isHidden = false
                    self.collectionView.isHidden = true
                }
            }
        }
    }

    private func applyFilters() {
        var result = allListings

        if currentFilter != "All" {
            result = result.filter { $0.status == currentFilter }
        }

        if !currentSearchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(currentSearchText) ||
                $0.category.localizedCaseInsensitiveContains(currentSearchText)
            }
        }

        filteredListings = result
        collectionView.reloadData()
        updateEmptyState()
    }

    private func updateEmptyState() {
        let isEmpty = filteredListings.isEmpty

        emptyStateContainer.isHidden = !isEmpty
        collectionView.isHidden = isEmpty

        if isEmpty {
            if !currentSearchText.isEmpty {
                emptyStateLabel.text = "No results found".localized
                emptyStateSubtitle.text = "Try a different search term".localized
                emptyStateImageView.image = UIImage(systemName: "magnifyingglass")
            } else if currentFilter != "All" {
                emptyStateLabel.text = String(format: "No %@ listings".localized, currentFilter.lowercased())
                emptyStateSubtitle.text = "Items with this status\nwill appear here".localized
                emptyStateImageView.image = UIImage(systemName: "tray")
            } else {
                emptyStateLabel.text = "No listings yet".localized
                emptyStateSubtitle.text = "Start selling by posting\nyour first item".localized
                emptyStateImageView.image = UIImage(systemName: "tray")
            }
        }
    }

    private func updateListingsCount() {
        let total = allListings.count
        let available = allListings.filter { $0.status == "Available" }.count
        let sold = allListings.filter { $0.status == "Sold" }.count

        listingsCountLabel.text = String(format: "%d listings • %d available • %d sold".localized, total, available, sold)
    }

    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(listingsCountLabel)
        view.addSubview(searchBar)
        view.addSubview(filterSegmentedControl)
        view.addSubview(collectionView)
        view.addSubview(emptyStateContainer)

        emptyStateContainer.addSubview(emptyStateImageView)
        emptyStateContainer.addSubview(emptyStateLabel)
        emptyStateContainer.addSubview(emptyStateSubtitle)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 75),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.contentMargin),

            listingsCountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.xs),
            listingsCountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.contentMargin),

            searchBar.topAnchor.constraint(equalTo: listingsCountLabel.bottomAnchor, constant: Spacing.md),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.sm),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.sm),

            filterSegmentedControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: Spacing.sm),
            filterSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.contentMargin),
            filterSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.contentMargin),
            filterSegmentedControl.heightAnchor.constraint(equalToConstant: 35),

            collectionView.topAnchor.constraint(equalTo: filterSegmentedControl.bottomAnchor, constant: Spacing.md),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.contentMargin),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.contentMargin),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),

            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateContainer.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateContainer.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 60),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 60),

            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: Spacing.lg),
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateContainer.centerXAnchor),

            emptyStateSubtitle.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: Spacing.sm),
            emptyStateSubtitle.centerXAnchor.constraint(equalTo: emptyStateContainer.centerXAnchor),
            emptyStateSubtitle.bottomAnchor.constraint(equalTo: emptyStateContainer.bottomAnchor)
        ])

        titleLabel.accessibilityTraits = .header
        filterSegmentedControl.accessibilityLabel = "Filter listings".localized
        searchBar.accessibilityLabel = "Search listings".localized
        searchBar.accessibilityHint = "Search listings by name or category".localized
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EnhancedListingCell.self, forCellWithReuseIdentifier: EnhancedListingCell.reuseIdentifier)

        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    private func setupSearchBar() {
        searchBar.delegate = self
    }

    private func setupFilterControl() {
        filterSegmentedControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
    }

    @objc private func handleRefresh() {
        HapticFeedback.pullToRefresh()
        fetchUserListings()
    }

    @objc private func filterChanged() {
        HapticFeedback.selection()
        let index = filterSegmentedControl.selectedSegmentIndex
        currentFilter = filterSegmentedControl.titleForSegment(at: index) ?? "All"
        applyFilters()
    }
}

extension ListingsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchText = searchText
        applyFilters()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        currentSearchText = ""
        searchBar.resignFirstResponder()
        applyFilters()
    }
}

extension ListingsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredListings.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EnhancedListingCell.reuseIdentifier,
            for: indexPath
        ) as! EnhancedListingCell

        cell.configure(with: filteredListings[indexPath.row])
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        CGSize(width: collectionView.frame.width, height: 160)
    }
}

extension ListingsViewController: EnhancedListingCellDelegate {

    func didTapView(on cell: EnhancedListingCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let listing = filteredListings[indexPath.row]

        guard let product = products.first(where: { $0.id == listing.productId }) else { return }

        let productUIModel = ProductMapper.toUIModel(product)
        let detailVC = ItemDetailsViewController(nibName: "ItemDetailsViewController", bundle: nil)
        detailVC.product = productUIModel
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func didTapEdit(on cell: EnhancedListingCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let listing = filteredListings[indexPath.row]

        guard let product = products.first(where: { $0.id == listing.productId }) else { return }

        if product.status == .sold {
            HapticFeedback.warning()
            let alert = UIAlertController(
                title: "Cannot Edit".localized,
                message: "Once sold, listing cannot be edited.".localized,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
            present(alert, animated: true)
            return
        }

        let editVC = EditListingViewController()
        editVC.product = product
        navigationController?.pushViewController(editVC, animated: true)
    }

    func didTapManageOrder(on cell: EnhancedListingCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let listing = filteredListings[indexPath.row]
        
        Task { @MainActor in
            let loadingAlert = UIAlertController(title: nil, message: "Validating order...", preferredStyle: .alert)
            present(loadingAlert, animated: true)
            
            do {
                if let activeOrderId = try await OrderRepository().getActiveOrderId(for: listing.productId) {
                    loadingAlert.dismiss(animated: true) {
                        let vc = OrderDetailsViewController()
                        vc.orderId = activeOrderId
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    loadingAlert.dismiss(animated: true) {
                        let errorAlert = UIAlertController(title: "No Active Order", message: "There is no confirmed active order for this listing yet.", preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(errorAlert, animated: true)
                    }
                }
            } catch {
                loadingAlert.dismiss(animated: true) {
                    let errorAlert = UIAlertController(title: "Error", message: "Failed to validate order status.", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(errorAlert, animated: true)
                }
            }
        }
    }

    func didTapDelete(on cell: EnhancedListingCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let listing = filteredListings[indexPath.row]

        guard let product = products.first(where: { $0.id == listing.productId }) else { return }

        let alert = UIAlertController(
            title: "Delete Listing".localized,
            message: String(format: "Are you sure you want to delete \"%@\"?".localized, product.title),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete".localized, style: .destructive) { [weak self] _ in
            self?.deleteProduct(product, listing: listing)
        })

        present(alert, animated: true)
    }

    func didTapDealRequests(on cell: EnhancedListingCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let listing = filteredListings[indexPath.row]

        markDealRequestsSeen(for: listing)

        let dealRequestsVC = DealRequestsViewController(productId: listing.productId, productTitle: listing.name)
        navigationController?.pushViewController(dealRequestsVC, animated: true)
    }

    func didTapInterestedBuyers(on cell: EnhancedListingCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let listing = filteredListings[indexPath.row]

        markInterestedBuyersSeen(for: listing)

        fetchInterestedBuyerNames(for: listing.productId, productName: listing.name)
    }

    private func markInterestedBuyersSeen(for listing: Listing) {
        guard let userId = currentUserId else { return }

        ListingMenuBadgeStore.setLastSeenInterestedCount(
            listing.interestedBuyersCount,
            for: listing.productId,
            userId: userId
        )

        updateBadgeState(for: listing.productId) { item in
            item.hasNewInterestedBuyers = false
        }
    }

    private func markDealRequestsSeen(for listing: Listing) {
        guard let userId = currentUserId else { return }

        ListingMenuBadgeStore.setLastSeenDealRequestsCount(
            listing.dealRequestsCount,
            for: listing.productId,
            userId: userId
        )

        updateBadgeState(for: listing.productId) { item in
            item.hasNewDealRequests = false
        }
    }

    private func updateBadgeState(for productId: String, mutate: (inout Listing) -> Void) {
        if let allIndex = allListings.firstIndex(where: { $0.productId == productId }) {
            mutate(&allListings[allIndex])
        }

        if let filteredIndex = filteredListings.firstIndex(where: { $0.productId == productId }) {
            mutate(&filteredListings[filteredIndex])
            collectionView.reloadItems(at: [IndexPath(row: filteredIndex, section: 0)])
        } else {
            collectionView.reloadData()
        }
    }

    private func fetchInterestedBuyerNames(for productId: String, productName: String) {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let conversations = try await self.chatRepository.fetchConversations()
                    .filter { $0.product_id == productId }

                var seenBuyerIds = Set<String>()
                var buyerNames: [String] = []
                for conv in conversations {
                    let buyerId = conv.buyer_id
                    guard !seenBuyerIds.contains(buyerId) else { continue }
                    seenBuyerIds.insert(buyerId)
                    let fullName = conv.buyer?.displayName ?? ""
                    buyerNames.append(fullName.isEmpty ? "Unknown Buyer".localized : fullName)
                }

                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.showInterestedBuyersAlert(buyerNames: buyerNames, productName: productName)
                }
            } catch {
                print("Failed to fetch interested buyers: \(error)")
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    let alert = UIAlertController(
                        title: "Error".localized,
                        message: "Failed to load interested buyers".localized,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    private func showInterestedBuyersAlert(buyerNames: [String], productName: String) {
        let title = "Interested Buyers".localized
        let message: String
        if buyerNames.isEmpty {
            message = "No interested buyers yet".localized
        } else {
            let buyerList = buyerNames.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
            message = "\(productName)\n\n\(buyerList)"
        }

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "OK".localized, style: .cancel))
        present(alert, animated: true)
    }

    private func deleteProduct(_ product: ProductDTO, listing: Listing) {
        HapticFeedback.delete()

        guard let productId = product.id else { return }

        DeletedListingsStore.add(productId)

        products.removeAll { $0.id == productId }
        allListings.removeAll { $0.productId == listing.productId }
        applyFilters()
        updateListingsCount()

        NotificationCenter.default.post(
            name: .productDeleted,
            object: nil,
            userInfo: ["productId": listing.productId]
        )

        Task {
            do {
                try await productRepository.softDeleteProduct(productId: productId)
                print("✅ Product soft-deleted (is_active=false): \(productId)")
            } catch {
                print("⚠️ Soft-delete failed: \(error)")
            }

            do {
                try await productRepository.deleteProduct(productId: productId)
                print("✅ Product hard-deleted: \(productId)")
            } catch {
                print("⚠️ Hard-delete failed (soft-delete already hides it): \(error)")
            }
        }
    }
}

enum DeletedListingsStore {
    private static let key = "deleted_listing_ids"

    static func all() -> Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
    }

    static func add(_ id: String) {
        var set = all()
        set.insert(id)
        UserDefaults.standard.set(Array(set), forKey: key)
    }
}

enum ListingMenuBadgeStore {
    private static let interestedKeyPrefix = "listings_last_seen_interested"
    private static let dealKeyPrefix = "listings_last_seen_deal"

    static func lastSeenInterestedCount(for productId: String, userId: String) -> Int {
        let key = "\(interestedKeyPrefix)_\(userId)_\(productId)"
        return UserDefaults.standard.integer(forKey: key)
    }

    static func setLastSeenInterestedCount(_ count: Int, for productId: String, userId: String) {
        let key = "\(interestedKeyPrefix)_\(userId)_\(productId)"
        UserDefaults.standard.set(count, forKey: key)
    }

    static func lastSeenDealRequestsCount(for productId: String, userId: String) -> Int {
        let key = "\(dealKeyPrefix)_\(userId)_\(productId)"
        return UserDefaults.standard.integer(forKey: key)
    }

    static func setLastSeenDealRequestsCount(_ count: Int, for productId: String, userId: String) {
        let key = "\(dealKeyPrefix)_\(userId)_\(productId)"
        UserDefaults.standard.set(count, forKey: key)
    }
}
