//
//  LandingScreenViewController.swift
//  Unizo_iOS
//
//  Created by Somesh on 12/11/25.
// push changes

import UIKit

// MARK: - Model
struct Product {
    let name: String
    let price: Int
    let rating: Double
    let negotiable: Bool
    let imageName: String
}

// MARK: - Controller
class LandingScreenViewController: UIViewController {

    // MARK: UI
    @IBOutlet weak var trendingCategoriesbg: UIView!
    @IBOutlet weak var scrollbg: UIView!
    private var collectionView: UICollectionView!
    private let topContainer = UIView()
    private let navBarView = UIView()
    private let homeLabel = UILabel()
    private let toolbar = UIToolbar()
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search"
        sb.searchBarStyle = .minimal
        return sb
    }()
    private let trendingLabel = UILabel()
    private let categoryStackView = UIStackView()

    private let mainScrollView = UIScrollView()
    private let contentView = UIView()

    private let carouselScrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private let segmentedControl = UISegmentedControl(items: ["All", "Most Popular", "Negotiable"])

    private let tabBar = UITabBar()

    // MARK: Data
    private let banners = ["banner1", "banner2", "banner3"]
    private var timer: Timer?
    private var currentBannerIndex = 0

    private let products: [Product] = [
        Product(name: "Under Armour Cap", price: 500, rating: 4.6, negotiable: true, imageName: "cap"),
        Product(name: "Slip Jeans", price: 349, rating: 3.7, negotiable: true, imageName: "jeans"),
        Product(name: "Pink Bicycle", price: 8900, rating: 4.6, negotiable: true, imageName: "pinkbicycle"),
        Product(name: "BAS Cricket Bat", price: 799, rating: 4.5, negotiable: false, imageName: "bat"),
        Product(name: "Bluetooth Headphones", price: 500, rating: 4.8, negotiable: true, imageName: "headphones1"),
        Product(name: "NY Cap", price: 499, rating: 4.1, negotiable: true, imageName: "NYcap"),
        Product(name: "Ergonomic Office Chair", price: 699, rating: 4.9, negotiable: false, imageName: "officechair"),
        Product(name: "Badminton Racket", price: 699, rating: 4.3, negotiable: true, imageName: "badmintonracket"),
        Product(name: "Table Tennis Bat", price: 999, rating: 4.6, negotiable: false, imageName: "tabletennis"),
        Product(name: "Noise Two Wireless", price: 599, rating: 4.4, negotiable: true, imageName: "headphones2")
    ]
    private var displayedProducts: [Product] = []
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


    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        setupCarousel()
        setupCollectionView()
        startAutoScroll()
        displayedProducts = products   // default
        searchBar.delegate = self

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionHeight()
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: Setup Views & Constraints
    private func setupViews() {
        // --- Screen Background ---
        view.backgroundColor = UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1) // #3D7C98

        // --- Top container translucent so teal is visible ---
        topContainer.backgroundColor = .clear

        // --- Scroll background solid white (covers below topContainer) ---
        scrollbg.backgroundColor = .white

        // --- Top Container ---
        view.addSubview(topContainer)
        topContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topContainer.heightAnchor.constraint(equalToConstant: 360) // slightly taller for spacing
        ])
        
        // --- NavBar ---
        navBarView.backgroundColor = UIColor(red: 0.21, green: 0.49, blue: 0.57, alpha: 1) // teal
        topContainer.addSubview(navBarView)
        navBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navBarView.topAnchor.constraint(equalTo: topContainer.topAnchor),
            navBarView.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor),
            navBarView.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor),
            navBarView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        // --- Toolbar ---
        toolbar.tintColor = .white
        toolbar.isTranslucent = false
        toolbar.backgroundColor = .clear
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        navBarView.addSubview(toolbar)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: navBarView.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: navBarView.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: navBarView.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let menuItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(menuButtonTapped)
        )
        toolbar.setItems([flexSpace, menuItem], animated: false)
        
        // --- Home Label ---
        homeLabel.text = "Home"
        homeLabel.textColor = .white
        homeLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        homeLabel.adjustsFontSizeToFitWidth = true
        homeLabel.minimumScaleFactor = 0.9
        navBarView.addSubview(homeLabel)
        homeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            homeLabel.leadingAnchor.constraint(equalTo: navBarView.leadingAnchor, constant: 20),
            homeLabel.bottomAnchor.constraint(equalTo: navBarView.bottomAnchor, constant: -10)
        ])
        
        // --- Search Bar ---
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
        
        // --- Trending Categories Background ---
        trendingCategoriesbg.backgroundColor = UIColor(red: 0.83, green: 0.95, blue: 0.96, alpha: 1) // #D4F2F4
        trendingCategoriesbg.layer.cornerRadius = 20
        trendingCategoriesbg.translatesAutoresizingMaskIntoConstraints = false
        topContainer.addSubview(trendingCategoriesbg)
        NSLayoutConstraint.activate([
            trendingCategoriesbg.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor, constant: 0),
            trendingCategoriesbg.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor, constant: 0),
            trendingCategoriesbg.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            trendingCategoriesbg.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: -10)
        ])
        
        // Optional soft shadow (Figma look)
        trendingCategoriesbg.layer.shadowColor = UIColor.black.cgColor
        trendingCategoriesbg.layer.shadowOpacity = 0.08
        trendingCategoriesbg.layer.shadowRadius = 6
        trendingCategoriesbg.layer.shadowOffset = CGSize(width: 0, height: 3)
        trendingCategoriesbg.layer.masksToBounds = false
        
        // --- Trending Label ---
        trendingLabel.text = "Trending Categories"
        trendingLabel.font = UIFont.boldSystemFont(ofSize: 17)
        trendingLabel.textColor = .black
        trendingCategoriesbg.addSubview(trendingLabel)
        trendingLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trendingLabel.topAnchor.constraint(equalTo: trendingCategoriesbg.topAnchor, constant: 10),
            trendingLabel.leadingAnchor.constraint(equalTo: trendingCategoriesbg.leadingAnchor, constant: 15)
        ])
        
        // --- Category Stack ---
        categoryStackView.axis = .horizontal
        categoryStackView.alignment = .center
        categoryStackView.distribution = .fillEqually
        categoryStackView.spacing = 5
        trendingCategoriesbg.addSubview(categoryStackView)
        categoryStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryStackView.topAnchor.constraint(equalTo: trendingLabel.bottomAnchor, constant: 10),
            categoryStackView.leadingAnchor.constraint(equalTo: trendingCategoriesbg.leadingAnchor, constant: 10),
            categoryStackView.trailingAnchor.constraint(equalTo: trendingCategoriesbg.trailingAnchor, constant: -10),
            categoryStackView.bottomAnchor.constraint(equalTo: trendingCategoriesbg.bottomAnchor, constant: -12)
        ])
        
        // --- Categories ---
        // --- Categories (FIXED BUTTON INTERACTION) ---
        let categories = [
            ("cart", "Hostel Essentials"),
            ("tablecells", "Furniture"),
            ("tshirt", "Fashion"),
            ("sportscourt", "Sports"),
            ("headphones", "Gadgets")
        ]

        for i in 0..<categories.count {

            let (icon, caption) = categories[i]

            let v = UIStackView()
            v.axis = .vertical
            v.alignment = .center
            v.distribution = .fill
            v.spacing = 6
            v.isUserInteractionEnabled = true   // CRITICAL FIX

            let btn = UIButton(type: .system)
            btn.tag = i                         // CORRECT TAG
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
            lbl.text = caption
            lbl.font = UIFont.systemFont(ofSize: 12)
            lbl.textAlignment = .center
            lbl.numberOfLines = 2
            lbl.isUserInteractionEnabled = false

            v.addArrangedSubview(btn)
            v.addArrangedSubview(lbl)
            categoryStackView.addArrangedSubview(v)
        }
        
        // --- Main Scroll Section ---
        view.addSubview(mainScrollView)
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.backgroundColor = .white
        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: topContainer.bottomAnchor),
            mainScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        mainScrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: mainScrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor)
        ])
        
        // --- Carousel ---
        contentView.addSubview(carouselScrollView)
        contentView.backgroundColor = .white
        carouselScrollView.isPagingEnabled = true
        carouselScrollView.delegate = self
        carouselScrollView.showsHorizontalScrollIndicator = false
        carouselScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            carouselScrollView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),

            // Horizontal inset for smaller rounded cards
            carouselScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            carouselScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            carouselScrollView.heightAnchor.constraint(equalToConstant: 140)
        ])

        
        // --- PageControl ---
        contentView.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: carouselScrollView.bottomAnchor, constant: 6),
            pageControl.centerXAnchor.constraint(equalTo: carouselScrollView.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 20)
        ])

        // ensure pageControl is above the carousel
        contentView.bringSubviewToFront(pageControl)

        
        // --- Segmented Control ---
        contentView.addSubview(segmentedControl)
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        // --- Segmented Control Styling ---
        segmentedControl.selectedSegmentIndex = 0

        // Selected segment background color
        segmentedControl.selectedSegmentTintColor = UIColor(
            red: 0.239, green: 0.486, blue: 0.596, alpha: 1
        ) // #3D7C98

        // Text color for unselected segments
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1),
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)

        // Text color for selected segment
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)

        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 12),
            segmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            segmentedControl.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        // --- Collection View ---
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        // --- Tab Bar ---
        view.addSubview(tabBar)
        tabBar.translatesAutoresizingMaskIntoConstraints = false
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
            UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle.fill"), tag: 4)
        ]
        tabBar.selectedItem = tabBar.items?.first
        
        // --- Tab Bar Styling ---
        tabBar.tintColor = UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1)                    // selected item color
        tabBar.unselectedItemTintColor = .darkGray    // unselected item color
        tabBar.isTranslucent = false

    }
    @objc private func segmentChanged() {

        // Update data based on selected segment
        switch segmentedControl.selectedSegmentIndex {

        case 0: // All
            displayedProducts = products

        case 1: // Most Popular
            displayedProducts = products.sorted { $0.rating > $1.rating }

        case 2: // Negotiable
            displayedProducts = products.filter { $0.negotiable }

        default:
            break
        }

        // Animate the update
        UIView.transition(with: collectionView,
                          duration: 0.35,
                          options: [.transitionCrossDissolve],
                          animations: { [weak self] in
                              self?.collectionView.reloadData()
                          },
                          completion: { [weak self] _ in
                              self?.updateCollectionHeight()
                          })

        // Add slight scale bounce
        collectionView.layer.transform = CATransform3DMakeScale(0.96, 0.96, 1)

        UIView.animate(withDuration: 0.35,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.8,
                       options: [.curveEaseOut],
                       animations: {
                           self.collectionView.layer.transform = CATransform3DIdentity
                       })
    }
    func openCategoryPage(title: String, items: [Product]) {
        // Preserve old API by forwarding with a default index
        openCategoryPage(title: title, items: items, categoryIndex: 0)
    }

    func openCategoryPage(title: String, items: [Product], categoryIndex: Int) {
        let vc = CategoryPageViewController()
        vc.title = title
        vc.items = items
        vc.categoryIndex = categoryIndex
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true)
        }
    }

    @objc private func categoryTapped(_ sender: UIButton) {
        let index = sender.tag

        let mapping: [(title: String, items: [Product])] = [
            ("Hostel Essentials", hostelEssentialsItems),
            ("Furniture", furnitureItems),
            ("Fashion", fashionItems),
            ("Sports", sportsItems),
            ("Gadgets", gadgetsItems)
        ]

        let selected = mapping[safe: index] ?? (title: "Category", items: [])
        openCategoryPage(title: selected.title, items: selected.items, categoryIndex: index)
    }


    // MARK: Toolbar Menu Action
    @objc private func menuButtonTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // --- CART ---
        alert.addAction(UIAlertAction(title: "Cart", style: .default, handler: { _ in
            let vc = CartViewController()
            vc.modalPresentationStyle = .fullScreen   // slides up from bottom
            vc.modalTransitionStyle = .coverVertical // smooth bottom animation
            self.present(vc, animated: true)
        }))

        // --- WISHLIST ---
        alert.addAction(UIAlertAction(title: "Wishlist", style: .default, handler: { _ in
            // Add your Wishlist VC here later
            let vc = WishlistViewController()
                if let nav = self.navigationController {
                    nav.pushViewController(vc, animated: true)
                } else {
                    vc.modalPresentationStyle = .fullScreen
                    vc.modalTransitionStyle = .coverVertical
                    self.present(vc, animated: true)
                }
        }))

        // --- NOTIFICATIONS ---
        alert.addAction(UIAlertAction(title: "Notifications", style: .default, handler: { _ in
            // Add Notifications VC here later
            print("Notifications tapped")
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = toolbar.items?.last
        }

        present(alert, animated: true)
    }

    // MARK: Carousel content
    private func setupCarousel() {

        carouselScrollView.isPagingEnabled = true
        carouselScrollView.showsHorizontalScrollIndicator = false
        carouselScrollView.delegate = self

        let banners: [UIImage] = [
            UIImage(named: "banner1")!,
            UIImage(named: "banner2")!,
            UIImage(named: "banner3")!
        ]

        let cardWidth = view.bounds.width - 40     // same as before (20 left + right)
        let cardHeight: CGFloat = 140

        for (index, img) in banners.enumerated() {

            // Wrapper for rounded corners & shadow
            let wrapper = UIView()
            wrapper.frame = CGRect(
                x: CGFloat(index) * (cardWidth + 20),
                y: 0,
                width: cardWidth,
                height: cardHeight
            )

            wrapper.backgroundColor = .clear
            wrapper.layer.shadowColor = UIColor.black.cgColor
            wrapper.layer.shadowOpacity = 0.12
            wrapper.layer.shadowRadius = 6
            wrapper.layer.shadowOffset = CGSize(width: 0, height: 3)

            // Image inside wrapper
            let iv = UIImageView(image: img)
            iv.clipsToBounds = true
            iv.layer.cornerRadius = 16
            iv.contentMode = .scaleAspectFill
            iv.frame = wrapper.bounds

            wrapper.addSubview(iv)
            carouselScrollView.addSubview(wrapper)
        }

        carouselScrollView.contentSize = CGSize(
            width: CGFloat(banners.count) * (cardWidth + 20),
            height: cardHeight
        )

        // PageControl setup
        pageControl.numberOfPages = banners.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.lightGray.withAlphaComponent(0.4)
        pageControl.currentPageIndicatorTintColor = UIColor.darkGray

        // Bring page control to front
        contentView.bringSubviewToFront(pageControl)
    }


    private func startAutoScroll() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            self.currentBannerIndex = (self.currentBannerIndex + 1) % self.banners.count
            let width = self.carouselScrollView.frameLayoutGuide.layoutFrame.width
            let offset = CGFloat(self.currentBannerIndex) * width

            self.carouselScrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        }
    }

    // MARK: Collection setup
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: ProductCell.reuseIdentifier)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
        }
    }

    private func updateCollectionHeight() {
        collectionView.layoutIfNeeded()
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        for c in collectionView.constraints where (c.firstAttribute == .height) {
            collectionView.removeConstraint(c)
        }
        collectionView.heightAnchor.constraint(equalToConstant: contentHeight).isActive = true
    }
}

// MARK: - ScrollView delegate
extension LandingScreenViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == carouselScrollView {
            let pageWidth = view.bounds.width - 40 + 20   // card width + spacing
            let pageIndex = round(scrollView.contentOffset.x / pageWidth)
            pageControl.currentPage = Int(pageIndex)
        }
    }

}

// MARK: - CollectionView delegate
extension LandingScreenViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        displayedProducts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCell.reuseIdentifier, for: indexPath) as? ProductCell else {
                return UICollectionViewCell()
            }
        cell.configure(with: displayedProducts[indexPath.item])

            return cell
        }

        // Two columns layout
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
            let availableWidth = collectionView.bounds.width - 30 // spacing and insets
            let width = floor(availableWidth / 2)
            return CGSize(width: width, height: 260)
        }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 10
        }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 15
        }
    }

    // MARK: - ProductCell

    // MARK: - Safe array index helper (optional)
    private extension Collection {
        subscript(safe index: Index) -> Element? {
            return indices.contains(index) ? self[index] : nil
        }
    }

extension LandingScreenViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

        // Combine all products from all categories
        let combinedProducts =
            products +
            hostelEssentialsItems +
            furnitureItems +
            fashionItems +
            sportsItems +
            gadgetsItems

        let vc = SearchResultsViewController(
            keyword: searchBar.text ?? "",
            allProducts: combinedProducts
        )

        navigationController?.pushViewController(vc, animated: true)
    }
}
