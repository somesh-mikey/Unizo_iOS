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
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private var collectionView: UICollectionView!

    // MARK: - Data
    private var wishlistItems: [ProductUIModel] = []
    private let wishlistRepository = WishlistRepository(supabase: supabase)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground

        setupNavigationBar()
        setupCollectionView()
        backButton.addTarget(self, action: #selector(backPressed), for: .touchUpInside)

        Task {
            await loadWishlist()
        }
    }


    // MARK: - Navigation Bar Setup
    private func setupNavigationBar() {
        // Back Button with glowing style
        backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        backButton.tintColor = .black
        backButton.backgroundColor = .white
        backButton.layer.cornerRadius = 22
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOpacity = 0.1
        backButton.layer.shadowRadius = 8
        backButton.layer.shadowOffset = CGSize(width: 0, height: 2)

        // Title
        titleLabel.text = "My Wishlist"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .black

        // Add to View
        view.addSubview(backButton)
        view.addSubview(titleLabel)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Back button
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            // Title centered
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
        ])
    }


    // MARK: - Collection View Setup
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true

        // Reuse your ProductCell
        collectionView.register(ProductCell.self,
                                forCellWithReuseIdentifier: ProductCell.reuseIdentifier)

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
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

        let totalSpacing: CGFloat = 10 + 10 + 10  // left + right + between
        let width = (collectionView.bounds.width - totalSpacing) / 2

        return CGSize(width: width, height: 250)
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
    @objc private func backPressed() {

        // CASE 1 — If opened with Navigation Controller
        if let nav = navigationController {
            nav.popViewController(animated: true)
            return
        }

        // CASE 2 — If presented modally
        if presentingViewController != nil {
            dismiss(animated: true)
            return
        }

        // CASE 3 — Fallback (rare)
        let landingVC = LandingScreenViewController()
        landingVC.modalPresentationStyle = .fullScreen
        present(landingVC, animated: true)
    }
    @MainActor
    private func loadWishlist() async {
        do {
            let dtos = try await wishlistRepository.fetchWishlist(
                userId: Session.userId
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
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = true

        Task {
            await loadWishlist()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = false

        // If you have a custom floating tab bar
        if let tab = tabBarController as? MainTabBarController {
        }
    }

}

