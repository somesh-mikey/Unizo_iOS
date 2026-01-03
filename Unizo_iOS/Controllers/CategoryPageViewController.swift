//
//  CategoryPageViewController.swift
//  Unizo_iOS
//
//  Created by Somesh on 18/11/25.
// push changes

import UIKit

class CategoryPageViewController: UIViewController, UITabBarDelegate {

    // MARK: - Data
    var categoryIndex: Int = 0
    var items: [ProductUIModel] = []


    // MARK: - UI
    private let topContainer = UIView()
    private let navBarView = UIView()
    private let toolbar = UIToolbar()
    private let homeLabel = UILabel()
    private let searchBar = UISearchBar()
    private let trendingCategoriesbg = UIView()
    private let trendingLabel = UILabel()
    private let categoryStackView = UIStackView()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let bannerImage = UIImageView()
    private let collectionView: UICollectionView

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateCollectionHeight()

        // Extend scroll behind tab bar but avoid clipping content
        if let tabBarHeight = self.tabBarController?.tabBar.frame.height {
            scrollView.contentInset.bottom = tabBarHeight + 20
            scrollView.scrollIndicatorInsets.bottom = tabBarHeight
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

        guard !items.isEmpty else {
                print("⚠️ CategoryPageViewController loaded with empty items")
                return
            }
        // Full teal background (same as Landing)
        view.backgroundColor = UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1)

        setupTopSection()      // Top identical to Landing
        setupScrollSection()   // White content section
        buildTrendingCategories()
        highlightSelectedCategory()
        setupCollectionView()
        loadCategoryBanner()
        collectionView.reloadData()
        let backButton = UIBarButtonItem(
                image: UIImage(systemName: "chevron.backward"),
                style: .plain,
                target: self,
                action: #selector(backToLanding)
            )
            backButton.tintColor = .white
            navigationItem.leftBarButtonItem = backButton
        setupNavigationBarMenuButton()

        if let navBar = navigationController?.navigationBar {
            navBar.layoutMargins = .zero
            navBar.subviews.first?.layoutMargins = .zero
            navBar.directionalLayoutMargins = .zero
        }
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
    }

    // MARK: - TOP SECTION (Identical to Landing)
    private func setupTopSection() {

        topContainer.backgroundColor = .clear
        view.addSubview(topContainer)
        topContainer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topContainer.heightAnchor.constraint(equalToConstant: 360)
        ])

        // NAVBAR
        navBarView.backgroundColor = UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1)
        topContainer.addSubview(navBarView)
        navBarView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            navBarView.topAnchor.constraint(equalTo: topContainer.topAnchor),
            navBarView.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor),
            navBarView.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor),
            navBarView.heightAnchor.constraint(equalToConstant: 120)
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

        // Hostel Essentials LABEL
        homeLabel.text = "Categories"
        homeLabel.textColor = .white
        homeLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        navBarView.addSubview(homeLabel)
        homeLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            homeLabel.leadingAnchor.constraint(equalTo: navBarView.leadingAnchor, constant: 20),
            homeLabel.bottomAnchor.constraint(equalTo: navBarView.bottomAnchor, constant: -10)
        ])

        // SEARCH BAR
        topContainer.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: navBarView.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor, constant: -20),
            searchBar.heightAnchor.constraint(equalToConstant: 44)
        ])

        // TRENDING BG
        trendingCategoriesbg.backgroundColor = UIColor(red: 0.83, green: 0.95, blue: 0.96, alpha: 1)
        trendingCategoriesbg.layer.cornerRadius = 20
        topContainer.addSubview(trendingCategoriesbg)
        trendingCategoriesbg.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            trendingCategoriesbg.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor),
            trendingCategoriesbg.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor),
            trendingCategoriesbg.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            trendingCategoriesbg.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor)
        ])

        // TRENDING LABEL
        trendingLabel.text = "Trending Categories"
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
        categoryStackView.spacing = 5
        categoryStackView.distribution = .fillEqually

        NSLayoutConstraint.activate([
            categoryStackView.topAnchor.constraint(equalTo: trendingLabel.bottomAnchor, constant: 10),
            categoryStackView.leadingAnchor.constraint(equalTo: trendingCategoriesbg.leadingAnchor, constant: 10),
            categoryStackView.trailingAnchor.constraint(equalTo: trendingCategoriesbg.trailingAnchor, constant: -10),
            categoryStackView.bottomAnchor.constraint(equalTo: trendingCategoriesbg.bottomAnchor, constant: -12)
        ])
    }

    // MARK: - TRENDING BUTTONS
    private func buildTrendingCategories() {

        let categories = [
            ("cart", "Hostel Essentials"),
            ("tablecells", "Furniture"),
            ("tshirt", "Fashion"),
            ("sportscourt", "Sports"),
            ("headphones", "Gadgets")
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

        scrollView.backgroundColor = .white
        contentView.backgroundColor = .white
        scrollView.delaysContentTouches = true
        scrollView.canCancelContentTouches = true

        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topContainer.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // SAFE: TabBar already added to hierarchy
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Banner
        contentView.addSubview(bannerImage)
        bannerImage.translatesAutoresizingMaskIntoConstraints = false
        bannerImage.layer.cornerRadius = 16
        bannerImage.clipsToBounds = true
        bannerImage.contentMode = .scaleAspectFill

        NSLayoutConstraint.activate([
            bannerImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            bannerImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bannerImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            bannerImage.heightAnchor.constraint(equalToConstant: 180)
        ])

        // Collection
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        let bottomConstraint = collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        bottomConstraint.priority = .required

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: bannerImage.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            bottomConstraint
        ])
    }
    private func updateCollectionHeight() {
        collectionView.layoutIfNeeded()
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height

        for constraint in collectionView.constraints where constraint.firstAttribute == .height {
            collectionView.removeConstraint(constraint)
        }

        collectionView.heightAnchor.constraint(equalToConstant: contentHeight).isActive = true
    }


    // MARK: - Collection Setup
    private func setupCollectionView() {

        collectionView.register(ProductCell.self,
                                forCellWithReuseIdentifier: ProductCell.reuseIdentifier)

        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = true

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
    @objc private func menuButtonTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cart", style: .default, handler: { _ in
            // push Cart screen
            let vc = CartViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Wishlist", style: .default, handler: { _ in
            let vc = WishlistViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Notifications", style: .default, handler: { _ in
            let vc = NotificationsViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }

        present(alert, animated: true)
    }

    @objc private func categoryTapped(_ sender: UIButton) {
        let index = sender.tag
        categoryIndex = index
        highlightSelectedCategory()
    }

}


// MARK: - CollectionView Delegates
extension CategoryPageViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count   // Items passed from Landing
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProductCell.reuseIdentifier,
            for: indexPath
        ) as! ProductCell

        cell.configure(with: items[indexPath.item])
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let width = (collectionView.bounds.width - 30) / 2
        return CGSize(width: width, height: 260)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    @objc private func backToLanding() {
        navigationController?.popToRootViewController(animated: true)
    }
    private func setupNavigationBarMenuButton() {
        navigationItem.rightBarButtonItem = makeEllipsisButton(
            target: self,
            action: #selector(menuButtonTapped)
        )
        navigationItem.rightBarButtonItem?.customView?.translatesAutoresizingMaskIntoConstraints = false
        navigationItem.rightBarButtonItem?.customView?.widthAnchor.constraint(equalToConstant: 44).isActive = true
        navigationItem.rightBarButtonItem?.customView?.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let selected = items[indexPath.item]

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
        btn.contentEdgeInsets = .zero

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
