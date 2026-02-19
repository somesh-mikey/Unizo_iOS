//
//  ListingsViewController.swift
//  Unizo_iOS
//
//  Created by Somesh on 26/11/25.
//  Enhanced with search, filters, and buyer information
//

import UIKit
import Supabase

class ListingsViewController: UIViewController {

    // MARK: - Supabase
    private let supabase = SupabaseManager.shared.client

    // MARK: - UI Components
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

        // Match Landing Screen style - pill-shaped selected segment
        sc.selectedSegmentTintColor = .brandPrimary

        // Text color for unselected segments
        sc.setTitleTextAttributes([
            .foregroundColor: UIColor.brandPrimary,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)

        // Text color for selected segment
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

    // MARK: - Empty State
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

    // MARK: - Enhanced Listing Model
    struct Listing {
        let image: UIImage?
        let imageURL: String?
        let category: String
        let name: String
        let status: String
        let price: String
        let productId: UUID
        let viewsCount: Int
        let createdAt: Date?
        let quantity: Int
        let buyerName: String?
        let orderStatus: String?
        let interestedBuyersCount: Int  // Number of buyers who started a conversation/deal
        let dealRequestsCount: Int      // Number of buyers who placed a pending order (Deal)
    }

    // MARK: - Listings Data
    private var allListings: [Listing] = []
    private var filteredListings: [Listing] = []
    private var products: [ProductDTO] = []

    private var currentSearchText: String = ""
    private var currentFilter: String = "All"

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        setupCollectionView()
        setupSearchBar()
        setupFilterControl()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserListings()
    }

    // MARK: - Fetch User Listings
    private func fetchUserListings() {
        Task {
            do {
                let userId = try await supabase.auth.session.user.id.uuidString

                // Fetch products
                let response = try await supabase
                    .from("products")
                    .select("*")
                    .eq("seller_id", value: userId)
                    .order("created_at", ascending: false)
                    .execute()

                let fetchedProducts = try JSONDecoder().decode([ProductDTO].self, from: response.data)

                // Fetch interested buyers count for each product (conversations where user is seller)
                let conversationsResponse = try await supabase
                    .from("conversations")
                    .select("product_id, buyer_id")
                    .eq("seller_id", value: userId)
                    .execute()

                // Parse conversations and count unique buyers per product
                struct ConversationCount: Decodable {
                    let product_id: UUID
                    let buyer_id: UUID
                }

                let conversations = try JSONDecoder().decode([ConversationCount].self, from: conversationsResponse.data)

                // Group by product_id and count unique buyers
                var interestedBuyersMap: [UUID: Int] = [:]
                var productBuyersSet: [UUID: Set<UUID>] = [:]

                for conv in conversations {
                    if productBuyersSet[conv.product_id] == nil {
                        productBuyersSet[conv.product_id] = Set<UUID>()
                    }
                    productBuyersSet[conv.product_id]?.insert(conv.buyer_id)
                }

                for (productId, buyersSet) in productBuyersSet {
                    interestedBuyersMap[productId] = buyersSet.count
                }

                // Fetch pending deal requests (orders with status "pending") for seller's products
                let productIds = fetchedProducts.map { $0.id.uuidString }
                var dealRequestsMap: [UUID: Int] = [:]

                if !productIds.isEmpty {
                    struct OrderItemWithOrder: Decodable {
                        let product_id: UUID
                        struct OrderInfo: Decodable {
                            let id: UUID
                            let status: String
                            let user_id: UUID
                        }
                        let orders: OrderInfo
                    }

                    let orderItemsResponse = try await supabase
                        .from("order_items")
                        .select("product_id, orders!inner(id, status, user_id)")
                        .in("product_id", values: productIds)
                        .execute()

                    let orderItems = try JSONDecoder().decode([OrderItemWithOrder].self, from: orderItemsResponse.data)

                    // Filter for pending orders only and count unique buyers per product
                    var dealBuyersSet: [UUID: Set<UUID>] = [:]
                    for item in orderItems {
                        if item.orders.status == "pending" {
                            dealBuyersSet[item.product_id, default: Set<UUID>()].insert(item.orders.user_id)
                        }
                    }

                    for (productId, buyersSet) in dealBuyersSet {
                        dealRequestsMap[productId] = buyersSet.count
                    }
                }

                let deletedIDs = DeletedListingsStore.all()

                await MainActor.run {
                    // Filter deleted products
                    self.products = fetchedProducts.filter {
                        !deletedIDs.contains($0.id.uuidString)
                    }

                    self.allListings = self.products.map { product in
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
                            productId: product.id,
                            viewsCount: product.viewsCount ?? 0,
                            createdAt: nil,
                            quantity: product.quantity ?? 1,
                            buyerName: nil,
                            orderStatus: nil,
                            interestedBuyersCount: interestedBuyersMap[product.id] ?? 0,
                            dealRequestsCount: dealRequestsMap[product.id] ?? 0
                        )
                    }

                    self.applyFilters()
                    self.updateListingsCount()
                    self.refreshControl.endRefreshing()
                }

            } catch {
                print("❌ Failed to fetch listings:", error)
                await MainActor.run {
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }

    // MARK: - Filter Logic
    private func applyFilters() {
        var result = allListings

        // Apply status filter
        if currentFilter != "All" {
            result = result.filter { $0.status == currentFilter }
        }

        // Apply search filter
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

    // MARK: - UI Setup
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
            // Title
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 75),        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.contentMargin),

            // Listings count
            listingsCountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.xs),
            listingsCountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.contentMargin),

            // Search bar
            searchBar.topAnchor.constraint(equalTo: listingsCountLabel.bottomAnchor, constant: Spacing.md),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.sm),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.sm),

            // Filter segmented control (matching Landing Screen style)
            filterSegmentedControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: Spacing.sm),
            filterSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.contentMargin),
            filterSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.contentMargin),
            filterSegmentedControl.heightAnchor.constraint(equalToConstant: 35),

            // Collection view
            collectionView.topAnchor.constraint(equalTo: filterSegmentedControl.bottomAnchor, constant: Spacing.md),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.contentMargin),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.contentMargin),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Empty state container
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
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EnhancedListingCell.self, forCellWithReuseIdentifier: EnhancedListingCell.reuseIdentifier)

        // Pull-to-refresh
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

// MARK: - UISearchBarDelegate
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

// MARK: - CollectionView
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

        // Taller cells to accommodate more info
        CGSize(width: collectionView.frame.width, height: 160)
    }
}

// MARK: - EnhancedListingCellDelegate
extension ListingsViewController: EnhancedListingCellDelegate {

    func didTapView(on cell: EnhancedListingCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let listing = filteredListings[indexPath.row]

        // Find the original product
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

        let dealRequestsVC = DealRequestsViewController(productId: listing.productId, productTitle: listing.name)
        navigationController?.pushViewController(dealRequestsVC, animated: true)
    }

    private func deleteProduct(_ product: ProductDTO, listing: Listing) {
        HapticFeedback.delete()

        // Persist deletion locally
        DeletedListingsStore.add(product.id.uuidString)

        Task {
            do {
                try await supabase
                    .from("products")
                    .delete()
                    .eq("id", value: product.id.uuidString)
                    .execute()

                await MainActor.run {
                    // Remove from all data sources
                    self.products.removeAll { $0.id == product.id }
                    self.allListings.removeAll { $0.productId == product.id }
                    self.applyFilters()
                    self.updateListingsCount()
                }

            } catch {
                print("❌ Failed to delete product:", error)
            }
        }
    }
}

// MARK: - Local Deleted Listings Store
private enum DeletedListingsStore {
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
