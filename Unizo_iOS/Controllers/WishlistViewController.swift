//
//  WishlistViewController.swift
//  Unizo_iOS
//
//  Created by Somesh on 21/11/25.
//

import UIKit

class WishlistViewController: UIViewController {

    // MARK: - UI
    var items: [ProductUIModel] = []
    private var collectionView: UICollectionView!
    private let refreshControl = UIRefreshControl()

    // MARK: - Data
    private var wishlistItems: [ProductUIModel] = []
    private let wishlistRepository = WishlistRepository()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1)

        configureNavigationBar()
        setupCollectionView()

        // RULE D — Observe product sold/deleted notifications
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

        Task {
            await loadWishlist()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Product Deleted Handler
    /// Removes a sold product from the wishlist UI immediately.
    /// This is UI-only removal — the Supabase wishlist entry is cleaned up on next load.
    /// Posted on MainActor, so this handler runs on the main thread.
    @objc private func handleProductDeleted(_ notification: Notification) {
        guard let productId = notification.userInfo?["productId"] as? String else { return }
        wishlistItems.removeAll { $0.id == productId }
        collectionView.reloadData()
    }

    @objc private func handleBlockedUsersDidChange(_ notification: Notification) {
        let blockedSellerId = notification.userInfo?["blockedSellerId"] as? String
        let shouldRefreshData = notification.userInfo?["refreshData"] as? Bool ?? false
        let blockedSellerSet = BlockedUsersStore.all()

        let beforeCount = wishlistItems.count
        wishlistItems.removeAll { product in
            guard let sellerId = product.sellerId else { return false }
            if let blockedSellerId {
                return sellerId == blockedSellerId
            }
            return blockedSellerSet.contains(sellerId)
        }

        let removedCount = max(0, beforeCount - wishlistItems.count)
        if removedCount > 0 {
            print("🚫 [Moderation] Wishlist removed \(removedCount) blocked-seller products")
            collectionView.reloadData()
            return
        }

        if shouldRefreshData {
            print("🔄 [Moderation] Wishlist refreshing after unblock")
            Task {
                await self.loadWishlist()
            }
        }
    }


    // MARK: - Navigation Bar Setup
    private func configureNavigationBar() {
        title = "My Wishlist".localized
        navigationItem.largeTitleDisplayMode = .never
    }


    // MARK: - Collection View Setup
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true

        // Reuse your ProductCell
        collectionView.register(ProductCell.self,
                                forCellWithReuseIdentifier: ProductCell.reuseIdentifier)

        // Pull-to-refresh
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UICollectionView DataSource + Delegate
extension WishlistViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        wishlistItems.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProductCell.reuseIdentifier,
            for: indexPath
        ) as! ProductCell

        cell.configure(with: wishlistItems[indexPath.item])
        return cell
    }

    // 2-column layout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let availableWidth = collectionView.bounds.width - 30 // spacing + section insets
        let width = floor(availableWidth / 2)
        return CGSize(width: width, height: ProductCell.preferredHeight(for: traitCollection))
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        10
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        15
    }
    @objc private func handleRefresh() {
        HapticFeedback.pullToRefresh()

        Task {
            await loadWishlist()
            await MainActor.run {
                self.refreshControl.endRefreshing()
            }
        }
    }
    @MainActor
    private func loadWishlist() async {
        do {
            // Use authenticated user ID instead of local Session.userId
            guard let userId = await AuthManager.shared.currentUserId else {
                print("⚠️ No authenticated user for wishlist")
                return
            }

            let dtos = try await wishlistRepository.fetchWishlist(
                userId: userId
            )

            self.wishlistItems = dtos.map(ProductMapper.toUIModel)
            self.collectionView.reloadData()

            print("❤️ Wishlist loaded:", wishlistItems.count)

        } catch {
            print("❌ Failed to load wishlist:", error)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = true

        Task {
            await loadWishlist()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = false
    }

}

