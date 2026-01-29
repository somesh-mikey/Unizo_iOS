//
//  ListingsViewController.swift
//  Unizo_iOS
//
//  Created by Somesh on 26/11/25.
//

import UIKit
import Supabase

class ListingsViewController: UIViewController {

    // MARK: - Supabase
    private let supabase = SupabaseManager.shared.client

    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Listings"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 32, right: 0)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        return cv
    }()

    // MARK: - Listing Model
    struct Listing {
        let image: UIImage?
        let imageURL: String?
        let category: String
        let name: String
        let status: String
        let price: String
    }

    // MARK: - Listings Data
    private var listings: [Listing] = []


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 1.0, alpha: 1)

        setupUI()
        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Fetch user's listings every time view appears
        fetchUserListings()
    }

    // MARK: - Fetch User Listings from Supabase
    private func fetchUserListings() {
        Task {
            do {
                // Get current user ID
                let userId = try await supabase.auth.session.user.id.uuidString

                // Fetch products for this seller
                let response = try await supabase
                    .from("products")
                    .select("*")
                    .eq("seller_id", value: userId)
                    .order("created_at", ascending: false)
                    .execute()

                let products = try JSONDecoder().decode([ProductDTO].self, from: response.data)

                print("✅ Fetched \(products.count) listings")

                // Convert ProductDTO to Listing model
                await MainActor.run {
                    self.listings = products.map { product in
                        Listing(
                            image: nil,
                            imageURL: product.imageUrl,
                            category: product.category ?? "Other",
                            name: product.title,
                            status: "Pending",
                            price: "₹\(Int(product.price))"
                        )
                    }
                    self.collectionView.reloadData()
                    print("✅ Updated listings UI with \(self.listings.count) items")
                }

            } catch {
                print("❌ Failed to fetch listings:", error)
            }
        }
    }

    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ListingCell.self, forCellWithReuseIdentifier: "ListingCell")
    }
}

// MARK: - CollectionView Delegate & DataSource
extension ListingsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listings.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ListingCell",
            for: indexPath
        ) as! ListingCell

        cell.configure(with: listings[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.frame.width, height: 135)
    }
}
