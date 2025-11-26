//
//  ListingsViewController.swift
//  Unizo_iOS
//
//  Created by Somesh on 26/11/25.
//

import UIKit

class ListingsViewController: UIViewController {

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
        let category: String
        let name: String
        let status: String
        let price: String
    }

    // MARK: - Dummy Data
    private var listings: [Listing] = [

        // 1 — Sports
        Listing(image: UIImage(named: "SSbat"),
                category: "Sports",
                name: "SS Size 5 Bat",
                status: "Pending",
                price: "₹1299"),

        // 2 — Sports
        Listing(image: UIImage(named: "rollerskates"),
                category: "Sports",
                name: "Roller Skates",
                status: "Sold for",
                price: "₹650"),

        // 3 — Sports
        Listing(image: UIImage(named: "badmintonracket"),
                category: "Sports",
                name: "Badminton Racket",
                status: "Sold for",
                price: "₹550"),

        // 4 — Hostel Essentials
        Listing(image: UIImage(named: "electrickettle"),
                category: "Hostel Essentials",
                name: "Prestige Electric Kettle",
                status: "Sold for",
                price: "₹649"),

        // 5 — Hostel Essentials
        Listing(image: UIImage(named: "lamp"),
                category: "Hostel Essentials",
                name: "Table Lamp",
                status: "Pending",
                price: "₹500"),

        // 6 — Hostel Essentials
        Listing(image: UIImage(named: "cooler"),
                category: "Hostel Essentials",
                name: "Room Cooler",
                status: "Pending",
                price: "₹5499"),

        // 7 — Fashion
        Listing(image: UIImage(named: "cap"),
                category: "Fashion",
                name: "Under Armour Cap",
                status: "Sold for",
                price: "₹500"),

        // 8 — Fashion
        Listing(image: UIImage(named: "yellowcap"),
                category: "Fashion",
                name: "NY Cap",
                status: "Pending",
                price: "₹400"),

        // 9 — Gadgets
        Listing(image: UIImage(named: "jblheadphones"),
                category: "Gadgets",
                name: "JBL T450BT",
                status: "Sold for",
                price: "₹1500"),

        // 10 — Gadgets
        Listing(image: UIImage(named: "leafbasswireless"),
                category: "Gadgets",
                name: "Leaf Bass Wireless",
                status: "Pending",
                price: "₹1400")
    ]


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 1.0, alpha: 1)

        setupUI()
        setupCollectionView()
    }

    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
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
