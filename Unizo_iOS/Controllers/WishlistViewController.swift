//
//  WishlistViewController.swift
//  Unizo_iOS
//
//  Created by Somesh on 21/11/25.
//

import UIKit

class WishlistViewController: UIViewController {

    // MARK: - UI
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private var collectionView: UICollectionView!

    // MARK: - Data
    var wishlistItems: [ProductUIModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        loadDummyWishlist()
        setupNavigationBar()
        setupCollectionView()
        backButton.addTarget(self, action: #selector(backPressed), for: .touchUpInside)
    }
    
    // MARK: Dummy Data
    private func loadDummyWishlist() {
        wishlistItems = [
            ProductUIModel(
                id: UUID(),
                name: "Soundforce Headphones",
                price: 1200,
                rating: 3.6,
                negotiable: false,
                imageName: "soundforceheadphones"
            ),
            ProductUIModel(
                id: UUID(),
                name: "Casual Fit Cap",
                price: 300,
                rating: 4.0,
                negotiable: true,
                imageName: "casualfitcap"
            ),
            ProductUIModel(
                id: UUID(),
                name: "Tennis Rackets",
                price: 2300,
                rating: 3.9,
                negotiable: true,
                imageName: "tennisrackets"
            ),
            ProductUIModel(
                id: UUID(),
                name: "Computer Chair",
                price: 3500,
                rating: 3.1,
                negotiable: false,
                imageName: "computerchair"
            ),
            ProductUIModel(
                id: UUID(),
                name: "Hostel Table Lamp",
                price: 500,
                rating: 4.2,
                negotiable: true,
                imageName: "lamp"
            )
        ]
    }


    // MARK: - Navigation Bar Setup
    private func setupNavigationBar() {
        // Back Button
        backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        backButton.tintColor = .black

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
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),

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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = true
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

