//
//  SearchResultsViewController.swift
//  Unizo_iOS
//
//  Created by Somesh on 19/11/25.
//

import UIKit

class SearchResultsViewController: UIViewController {

    // MARK: - Data
    var allProducts: [Product] = []
    var filteredProducts: [Product] = []
    var keyword: String = ""

    // MARK: - UI
    private let navBar = UIView()
    private let backButton = UIButton(type: .system)
    private let searchBar = UISearchBar()
    private let clearButton = UIButton(type: .system)

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let collectionView: UICollectionView

    // Empty State
    private let emptyStateLabel = UILabel()

    // MARK: - Init
    init(keyword: String, allProducts: [Product]) {
        self.keyword = keyword
        self.allProducts = allProducts

        let layout = UICollectionViewFlowLayout()
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1)

        setupNavBar()
        setupScrollView()
        setupCollectionView()
        setupEmptyState()

        filterProducts(text: keyword)
    }

    // MARK: - Filtering Logic
    private func filterProducts(text: String) {
        let searchText = text.lowercased().trimmingCharacters(in: .whitespaces)

        if searchText.isEmpty {
            filteredProducts = allProducts
        } else {
            filteredProducts = allProducts.filter {
                $0.name.lowercased().contains(searchText)
            }
        }

        updateUI()
    }

    private func updateUI() {
        collectionView.reloadData()
        collectionView.layoutIfNeeded()

        // Expand collectionView height inside scroll view
        let height = collectionView.collectionViewLayout.collectionViewContentSize.height
        collectionView.heightAnchor.constraint(equalToConstant: height).isActive = true

        if filteredProducts.isEmpty {
            emptyStateLabel.isHidden = false
            collectionView.isHidden = true
        } else {
            emptyStateLabel.isHidden = true
            collectionView.isHidden = false
        }
    }

    // MARK: - NavBar UI
    private func setupNavBar() {
        view.addSubview(navBar)
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.backgroundColor = .clear

        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBar.heightAnchor.constraint(equalToConstant: 60)
        ])

        // Back Button
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        navBar.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 15),
            backButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 28),
            backButton.heightAnchor.constraint(equalToConstant: 28)
        ])

        // Search Bar
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        searchBar.text = keyword
        searchBar.delegate = self   // 🔥 Live Search

        navBar.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: navBar.trailingAnchor, constant: -50),
            searchBar.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 44)
        ])

        // Clear (X) Button
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        clearButton.tintColor = .white
        clearButton.addTarget(self, action: #selector(clearSearch), for: .touchUpInside)

        navBar.addSubview(clearButton)
        clearButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            clearButton.leadingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: 8),
            clearButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 28),
            clearButton.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    @objc private func goBack() { navigationController?.popViewController(animated: true) }

    @objc private func clearSearch() {
        searchBar.text = ""
        filterProducts(text: "")
    }

    // MARK: - ScrollView + Content
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .white

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .white

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    // MARK: - CollectionView
    private func setupCollectionView() {
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.register(ProductCell.self,
                                forCellWithReuseIdentifier: ProductCell.reuseIdentifier)

        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    // MARK: - Empty State UI
    private func setupEmptyState() {
        emptyStateLabel.text = "No results found"
        emptyStateLabel.font = UIFont.boldSystemFont(ofSize: 20)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = .darkGray
        emptyStateLabel.isHidden = true

        contentView.addSubview(emptyStateLabel)
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emptyStateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60)
        ])
    }
}

// MARK: - Live Search
extension SearchResultsViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // 1️⃣ CATEGORY SHORTCUTS (place at top)
        let lower = searchText.lowercased()

        // Category shortcuts by keyword
        if lower == "sports" || lower == "sport" {
            filteredProducts = allProducts.filter { $0.name.lowercased().contains("bat") ||
                                                    $0.name.lowercased().contains("ball") ||
                                                    $0.name.lowercased().contains("racket") ||
                                                    $0.name.lowercased().contains("skate") ||
                                                    $0.name.lowercased().contains("football") ||
                                                    $0.name.lowercased().contains("cricket") ||
                                                    $0.name.lowercased().contains("carrom") }
            updateUI()
            return
        }

        if lower == "fashion" || lower == "cap" || lower == "apparel" {
            filteredProducts = allProducts.filter { $0.name.lowercased().contains("cap") ||
                                                    $0.name.lowercased().contains("jeans") ||
                                                    $0.name.lowercased().contains("shirt") }
            updateUI()
            return
        }

        if lower == "gadgets" || lower == "gadget" || lower == "headphones" {
            filteredProducts = allProducts.filter { $0.name.lowercased().contains("headphone") ||
                                                    $0.name.lowercased().contains("wireless") ||
                                                    $0.name.lowercased().contains("jbl") ||
                                                    $0.name.lowercased().contains("noise") ||
                                                    $0.name.lowercased().contains("boat") }
            updateUI()
            return
        }

        // 2️⃣ NORMAL TEXT SEARCH (after category checks)
        if lower.isEmpty {
            filteredProducts = []
            updateUI()
            return
        }

        filteredProducts = allProducts.filter { $0.name.lowercased().contains(lower) }
        updateUI()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - CollectionView Delegates
extension SearchResultsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return filteredProducts.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProductCell.reuseIdentifier,
            for: indexPath
        ) as! ProductCell

        cell.configure(with: filteredProducts[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (collectionView.bounds.width - 30) / 2
        return CGSize(width: width, height: 260)
    }
}
