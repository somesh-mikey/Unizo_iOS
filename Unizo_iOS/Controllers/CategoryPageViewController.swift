//
//  CategoryPageViewController.swift
//  Unizo_iOS
//
//  Created by Somesh on 18/11/25.
//

import UIKit

class CategoryPageViewController: UIViewController, UITabBarDelegate {

    // MARK: - Data
    var categoryIndex: Int = 0
    var items: [Product] = []
    // MARK: - Category Data
    private let hostelEssentialsItems: [Product] = [
        Product(name: "Prestige Electric Kettle", price: 649, rating: 4.9, negotiable: false, imageName: "electrickettle"),
        Product(name: "Table Lamp", price: 500, rating: 4.2, negotiable: true, imageName: "lamp"),
        Product(name: "Table Fan", price: 849, rating: 4.2, negotiable: false, imageName: "tablefan"),
        Product(name: "Cooler", price: 5499, rating: 4.4, negotiable: true, imageName: "cooler"),
        Product(name: "Flask", price: 899, rating: 4.3, negotiable: true, imageName: "flask"),
        Product(name: "Jhumka", price: 249, rating: 4.1, negotiable: false, imageName: "jhumka"),
        Product(name: "Study Table", price: 699, rating: 4.8, negotiable: true, imageName: "studytable"),
        Product(name: "Helmet", price: 579, rating: 4.9, negotiable: false, imageName: "helmet")
    ]

    private let furnitureItems: [Product] = [
        Product(name: "Wooden Dining Chair Set", price: 999, rating: 4.3, negotiable: false, imageName: "woodendiningchair"),
        Product(name: "Ergonomic Mesh Office Chair", price: 1299, rating: 4.7, negotiable: true, imageName: "ergonomicmeshchair"),
        Product(name: "Swivel Study Chair", price: 799, rating: 4.1, negotiable: false, imageName: "swivelstudychair"),
        Product(name: "Classic Metal Frame Chair", price: 499, rating: 3.9, negotiable: false, imageName: "classicmetalframechair"),
        Product(name: "Padded Chair", price: 899, rating: 4.4, negotiable: true, imageName: "paddedofficechair"),
        Product(name: "Office Chair", price: 899, rating: 4.3, negotiable: false, imageName: "officechair"),
        Product(name: "Ergo Comfort Chair", price: 1299, rating: 4.8, negotiable: false, imageName: "ergocomfortchair"),
        Product(name: "Rolling Task Chair", price: 699, rating: 3.8, negotiable: true, imageName: "rollingtaskchair"),
        Product(name: "Executive Office Chair", price: 1099, rating: 4.1, negotiable: false, imageName: "executiveofficechair"),
        Product(name: "Adjustable Work Chair", price: 499, rating: 4.2, negotiable: true, imageName: "adjustableworkchair")
    ]

    private let fashionItems: [Product] = [
        Product(name: "Under Armour Cap", price: 500, rating: 4.6, negotiable: true, imageName: "cap"),
        Product(name: "M Cap", price: 300, rating: 2.7, negotiable: false, imageName: "MCap"),
        Product(name: "NY Cap", price: 400, rating: 4.8, negotiable: true, imageName: "yellowcap"),
        Product(name: "Blue Cap", price: 200, rating: 3.5, negotiable: false, imageName: "streetcap"),
        Product(name: "Street Cap", price: 200, rating: 3.1, negotiable: true, imageName: "NYcap"),
        Product(name: "Casual Fit Cap", price: 249, rating: 4.1, negotiable: false, imageName: "casualfitcap")
    ]
    private let sportsItems: [Product] = [
        Product(
                name: "SS Size 5 Bat",
                price: 1299,
                rating: 4.6,
                negotiable: true,
                imageName: "SSbat"
            ),

            Product(
                name: "Cosco Tennis Ball Set",
                price: 299,
                rating: 4.1,
                negotiable: false,
                imageName: "coscotennisballs"
            ),

            Product(
                name: "BAS Size 6 Bat",
                price: 899,
                rating: 4.2,
                negotiable: false,
                imageName: "BASbat"
            ),

            Product(
                name: "Roller Skates",
                price: 650,
                rating: 3.5,
                negotiable: true,
                imageName: "rollerskates"
            ),

            Product(
                name: "Football Spikes",
                price: 399,
                rating: 3.1,
                negotiable: true,
                imageName: "footballspikes"
            ),

            Product(
                name: "Cricket Kit",
                price: 2999,
                rating: 4.9,
                negotiable: true,
                imageName: "cricketkit"
            ),

            Product(
                name: "Carrom Board",
                price: 700,
                rating: 4.2,
                negotiable: false,
                imageName: "carromboard"
            ),

            Product(
                name: "Cricket Pads",
                price: 599,
                rating: 4.3,
                negotiable: false,
                imageName: "cricketpads"
            ),

            Product(
                name: "Table Tennis Bat",
                price: 375,
                rating: 4.9,
                negotiable: false,
                imageName: "tabletennis"
            ),

            Product(
                name: "Badminton Racket",
                price: 550,
                rating: 3.8,
                negotiable: true,
                imageName: "badmintonracket"
            )
        ]
    private let gadgetsItems: [Product] = [
        
        Product(
            name: "pTron Headphones",
            price: 1000,
            rating: 4.2,
            negotiable: true,
            imageName: "ptronheadphones"
        ),

        Product(
            name: "Boult ProBass Headphones",
            price: 1100,
            rating: 3.9,
            negotiable: false,
            imageName: "boultprobassheadphones"
        ),

        Product(
            name: "pTron Headphones",
            price: 1000,
            rating: 4.2,
            negotiable: false,
            imageName: "ptronheadphones"
        ),

        Product(
            name: "JBL T450BT",
            price: 1500,
            rating: 4.9,
            negotiable: true,
            imageName: "jblheadphones"
        ),

        Product(
            name: "boAt Rockerz 450",
            price: 1200,
            rating: 3.1,
            negotiable: false,
            imageName: "boatrockerzheadphones"
        ),

        Product(
            name: "Noise Two Wireless",
            price: 1800,
            rating: 2.9,
            negotiable: true,
            imageName: "noisetwowireless"
        ),

        Product(
            name: "Intex Headphones",
            price: 1300,
            rating: 2.1,
            negotiable: false,
            imageName: "intexheadphones"
        ),

        Product(
            name: "Leaf Bass Wireless",
            price: 1400,
            rating: 4.6,
            negotiable: true,
            imageName: "leafbasswireless"
        )
    ]


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

    private let tabBar = UITabBar()

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Ensure the tab bar stays visually on top of the scroll view
        view.bringSubviewToFront(tabBar)
        updateCollectionHeight()

        // Add bottom inset so content above the tab bar is accessible
        let tabBarHeight = tabBar.frame.height
        var insets = scrollView.contentInset
        if insets.bottom != tabBarHeight {
            insets.bottom = tabBarHeight
            scrollView.contentInset = insets
            scrollView.scrollIndicatorInsets = insets
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

        setupTabBar()          // ← IMPORTANT: Tab bar added first
        setupTopSection()      // Top identical to Landing
        setupScrollSection()   // White content section
        buildTrendingCategories()
        highlightSelectedCategory()
        setupCollectionView()
        loadCategoryBanner()
        collectionView.reloadData()
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
        navBarView.backgroundColor = UIColor(red: 0.21, green: 0.49, blue: 0.57, alpha: 1)
        topContainer.addSubview(navBarView)
        navBarView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            navBarView.topAnchor.constraint(equalTo: topContainer.topAnchor),
            navBarView.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor),
            navBarView.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor),
            navBarView.heightAnchor.constraint(equalToConstant: 120)
        ])

        // TOOLBAR
        navBarView.addSubview(toolbar)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.tintColor = .white
        toolbar.isTranslucent = false
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)

        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: navBarView.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: navBarView.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: navBarView.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 44)
        ])

        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let menu = UIBarButtonItem(image: UIImage(systemName: "ellipsis"),
                                   style: .plain,
                                   target: self,
                                   action: #selector(menuButtonTapped))
        toolbar.setItems([flex, menu], animated: false)

        // Hostel Essentials LABEL
        homeLabel.text = "Home"
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
            trendingCategoriesbg.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: -10)
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
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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


    // MARK: - TAB BAR (added first!)
    private func setupTabBar() {

        view.addSubview(tabBar)
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBar.delegate = self

        NSLayoutConstraint.activate([
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: 80)
        ])

        tabBar.items = [
            UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0),
            UITabBarItem(title: "Chat", image: UIImage(systemName: "message.fill"), tag: 1),
            UITabBarItem(title: "Post", image: UIImage(systemName: "square.and.arrow.up.fill"), tag: 2),
            UITabBarItem(title: "Listings", image: UIImage(systemName: "rectangle.grid.2x2.fill"), tag: 3),
            UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle"), tag: 4)
        ]

        tabBar.tintColor = UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1)
        tabBar.unselectedItemTintColor = .darkGray
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .white
    }
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 0 {   // Home
            navigationController?.popToRootViewController(animated: true)
        }
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
    @objc private func menuButtonTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cart", style: .default))
        alert.addAction(UIAlertAction(title: "Wishlist", style: .default))
        alert.addAction(UIAlertAction(title: "Notifications", style: .default))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = toolbar.items?.last
        }

        present(alert, animated: true)
    }

    @objc private func categoryTapped(_ sender: UIButton) {
        let index = sender.tag

        // Mapping same as in LandingPage
        let mapping: [(title: String, items: [Product])] = [
            ("Hostel Essentials", hostelEssentialsItems),
            ("Furniture", furnitureItems),
            ("Fashion", fashionItems),
            ("Sports", sportsItems),
            ("Gadgets", gadgetsItems)
        ]

        guard index < mapping.count else { return }

        let selectedCategory = mapping[index]

        // OPEN NEW CATEGORY PAGE
        let vc = CategoryPageViewController()
        vc.items = selectedCategory.items
        vc.categoryIndex = index
        vc.title = selectedCategory.title

        navigationController?.pushViewController(vc, animated: false)
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
}

