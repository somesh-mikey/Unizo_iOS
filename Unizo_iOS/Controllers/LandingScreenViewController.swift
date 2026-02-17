//
//  LandingScreenViewController.swift
//  Unizo_iOS
//
//  Created by Somesh on 12/11/25.
// push changes

import UIKit

// MARK: - Controller
class LandingScreenViewController: UIViewController {

    // MARK: UI
    @IBOutlet weak var trendingCategoriesbg: UIView!
    private var collectionView: UICollectionView!
    private var hasMorePages = true
    private let refreshControl = UIRefreshControl()
    private let loader = UIActivityIndicatorView(style: .large)
    private let productRepository = ProductRepository(supabase: supabase)

    private var allProducts: [ProductUIModel] = []
    private var popularProducts: [ProductUIModel] = []
    private var negotiableProducts: [ProductUIModel] = []

    private let topContainer = UIView()
    private let navBarView = UIView()
    private let homeLabel = UILabel()

    // Menu button (replaces UIToolbar - per Apple HIG, toolbars are for actions, not navigation)
    private let menuButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
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

    // MARK: Data
    private var banners: [BannerUIModel] = []
    private var timer: Timer?
    private var currentBannerIndex = 0
    private var currentPage = 0
    private var isLoadingMore = false
    private var didSetupCarousel = false






//    private let products: [Product] = [
//        Product(name: "Under Armour Cap", price: 500, rating: 4.6, negotiable: true, imageName: "Cap"),
//        Product(name: "Slip Jeans", price: 349, rating: 3.7, negotiable: true, imageName: "jeans"),
//        Product(name: "Pink Bicycle", price: 8900, rating: 4.6, negotiable: true, imageName: "PinkBicycle"),
//        Product(name: "BAS Cricket Bat", price: 799, rating: 4.5, negotiable: false, imageName: "bat"),
//        Product(name: "Bluetooth Headphones", price: 500, rating: 4.8, negotiable: true, imageName: "headphones1"),
//        Product(name: "NY Cap", price: 499, rating: 4.1, negotiable: true, imageName: "NYcap"),
//        Product(name: "Ergonomic Office Chair", price: 699, rating: 4.9, negotiable: false, imageName: "officechair"),
//        Product(name: "Badminton Racket", price: 699, rating: 4.3, negotiable: true, imageName: "badmintonracket"),
//        Product(name: "Table Tennis Bat", price: 999, rating: 4.6, negotiable: false, imageName: "tabletennis"),
//        Product(name: "Noise Two Wireless", price: 599, rating: 4.4, negotiable: true, imageName: "headphones2")
//    ]
    private var displayedProducts: [ProductUIModel] = []
//    private let hostelEssentialsItems: [Product] = [
//        Product(name: "Prestige Electric Kettle", price: 649, rating: 4.9, negotiable: false, imageName: "electrickettle"),
//        Product(name: "Table Lamp", price: 500, rating: 4.2, negotiable: true, imageName: "lamp"),
//        Product(name: "Table Fan", price: 849, rating: 4.2, negotiable: false, imageName: "tablefan"),
//        Product(name: "Cooler", price: 5499, rating: 4.4, negotiable: true, imageName: "cooler"),
//        Product(name: "Flask", price: 899, rating: 4.3, negotiable: true, imageName: "flask"),
//        Product(name: "Jhumka", price: 249, rating: 4.1, negotiable: false, imageName: "jhumka"),
//        Product(name: "Study Table", price: 699, rating: 4.8, negotiable: true, imageName: "studytable"),
//        Product(name: "Helmet", price: 579, rating: 4.9, negotiable: false, imageName: "helmet")
//    ]

//    private let furnitureItems: [Product] = [
//        Product(name: "Wooden Dining Chair Set", price: 999, rating: 4.3, negotiable: false, imageName: "woodendiningchair"),
//        Product(name: "Ergonomic Mesh Office Chair", price: 1299, rating: 4.7, negotiable: true, imageName: "ergonomicmeshchair"),
//        Product(name: "Swivel Study Chair", price: 799, rating: 4.1, negotiable: false, imageName: "swivelstudychair"),
//        Product(name: "Classic Metal Frame Chair", price: 499, rating: 3.9, negotiable: false, imageName: "classicmetalframechair"),
//        Product(name: "Padded Chair", price: 899, rating: 4.4, negotiable: true, imageName: "paddedofficechair"),
//        Product(name: "Office Chair", price: 899, rating: 4.3, negotiable: false, imageName: "officechair"),
//        Product(name: "Ergo Comfort Chair", price: 1299, rating: 4.8, negotiable: false, imageName: "ergocomfortchair"),
//        Product(name: "Rolling Task Chair", price: 699, rating: 3.8, negotiable: true, imageName: "rollingtaskchair"),
//        Product(name: "Executive Office Chair", price: 1099, rating: 4.1, negotiable: false, imageName: "executiveofficechair"),
//        Product(name: "Adjustable Work Chair", price: 499, rating: 4.2, negotiable: true, imageName: "adjustableworkchair")
//    ]
//    private let fashionItems: [Product] = [
//        Product(name: "Under Armour Cap", price: 500, rating: 4.6, negotiable: true, imageName: "Cap"),
//        Product(name: "M Cap", price: 300, rating: 2.7, negotiable: false, imageName: "MCap"),
//        Product(name: "NY Cap", price: 400, rating: 4.8, negotiable: true, imageName: "yellowcap"),
//        Product(name: "Blue Cap", price: 200, rating: 3.5, negotiable: false, imageName: "streetcap"),
//        Product(name: "Street Cap", price: 200, rating: 3.1, negotiable: true, imageName: "NYcap"),
//        Product(name: "Casual Fit Cap", price: 249, rating: 4.1, negotiable: false, imageName: "casualfitcap")
//    ]
//    private let sportsItems: [Product] = [
//    Product(
//        name: "SS Size 5 Bat",
//        price: 1299,
//        rating: 4.6,
//        negotiable: true,
//        imageName: "SSbat"
//    ),
//
//    Product(
//        name: "Cosco Tennis Ball Set",
//        price: 299,
//        rating: 4.1,
//        negotiable: false,
//        imageName: "coscotennisballs"
//    ),
//
//    Product(
//        name: "BAS Size 6 Bat",
//        price: 899,
//        rating: 4.2,
//        negotiable: false,
//        imageName: "BASbat"
//    ),
//
//    Product(
//        name: "Roller Skates",
//        price: 650,
//        rating: 3.5,
//        negotiable: true,
//        imageName: "rollerskates"
//    ),
//
//    Product(
//        name: "Football Spikes",
//        price: 399,
//        rating: 3.1,
//        negotiable: true,
//        imageName: "footballspikes"
//    ),
//
//    Product(
//        name: "Cricket Kit",
//        price: 2999,
//        rating: 4.9,
//        negotiable: true,
//        imageName: "cricketkit"
//    ),
//
//    Product(
//        name: "Carrom Board",
//        price: 700,
//        rating: 4.2,
//        negotiable: false,
//        imageName: "carromboard"
//    ),
//
//    Product(
//        name: "Cricket Pads",
//        price: 599,
//        rating: 4.3,
//        negotiable: false,
//        imageName: "cricketpads"
//    ),
//
//    Product(
//        name: "Table Tennis Bat",
//        price: 375,
//        rating: 4.9,
//        negotiable: false,
//        imageName: "tabletennis"
//    ),
//
//    Product(
//        name: "Badminton Racket",
//        price: 550,
//        rating: 3.8,
//        negotiable: true,
//        imageName: "badmintonracket"
//    )
//]
//    private let gadgetsItems: [Product] = [
//
//        Product(
//            name: "pTron Headphones",
//            price: 1000,
//            rating: 4.2,
//            negotiable: true,
//            imageName: "ptronheadphones"
//        ),
//
//        Product(
//            name: "Boult ProBass Headphones",
//            price: 1100,
//            rating: 3.9,
//            negotiable: false,
//            imageName: "boultprobassheadphones"
//        ),
//
//        Product(
//            name: "pTron Headphones",
//            price: 1000,
//            rating: 4.2,
//            negotiable: false,
//            imageName: "ptronheadphones"
//        ),
//
//        Product(
//            name: "JBL T450BT",
//            price: 1500,
//            rating: 4.9,
//            negotiable: true,
//            imageName: "jblheadphones"
//        ),
//
//        Product(
//            name: "boAt Rockerz 450",
//            price: 1200,
//            rating: 3.1,
//            negotiable: false,
//            imageName: "boatrockerzheadphones"
//        ),
//
//        Product(
//            name: "Noise Two Wireless",
//            price: 1800,
//            rating: 2.9,
//            negotiable: true,
//            imageName: "noisetwowireless"
//        ),
//
//        Product(
//            name: "Intex Headphones",
//            price: 1300,
//            rating: 2.1,
//            negotiable: false,
//            imageName: "intexheadphones"
//        ),
//
//        Product(
//            name: "Leaf Bass Wireless",
//            price: 1400,
//            rating: 4.6,
//            negotiable: true,
//            imageName: "leafbasswireless"
//        )
//    ]
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard !didSetupCarousel, !banners.isEmpty else { return }

        didSetupCarousel = true
        setupCarousel()
        startAutoScroll()
    }


    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        setupCarousel()
        setupCollectionView()
        loader.center = view.center
        view.addSubview(loader)
        loader.startAnimating()
        updateCollectionHeight()
        Task {
            await loadProducts()
        }
        Task {
            await loadBanners()
        }

        navigationController?.setNavigationBarHidden(true, animated: false)
        searchBar.delegate = self

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        (tabBarController as? MainTabBarController)?.showFloatingTabBar()
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

        // --- Top Container (navBar with Home + search, extends to scroll) ---
        view.addSubview(topContainer)
        topContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topContainer.heightAnchor.constraint(equalToConstant: 145) // extend to cover gap before scroll
        ])
        
        // --- NavBar ---
        navBarView.backgroundColor = UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1) // teal
        topContainer.addSubview(navBarView)
        navBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navBarView.topAnchor.constraint(equalTo: topContainer.topAnchor),
            navBarView.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor),
            navBarView.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor),
            navBarView.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor) // fill entire top container
        ])
        
        // --- Menu Button (Apple HIG: Use plain buttons, not toolbars, for navigation areas) ---
        navBarView.addSubview(menuButton)
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)

        // 44pt minimum touch target per Apple HIG
        NSLayoutConstraint.activate([
            menuButton.topAnchor.constraint(equalTo: navBarView.topAnchor, constant: Spacing.sm),
            menuButton.trailingAnchor.constraint(equalTo: navBarView.trailingAnchor, constant: -Spacing.md),
            menuButton.widthAnchor.constraint(equalToConstant: Spacing.minTouchTarget),
            menuButton.heightAnchor.constraint(equalToConstant: Spacing.minTouchTarget)
        ])

        // --- Home title ---
        homeLabel.text = "Home"
        homeLabel.textColor = .white
        homeLabel.font = UIFont.systemFont(ofSize: 35, weight: .bold)
        homeLabel.isUserInteractionEnabled = false
        homeLabel.backgroundColor = .clear

        navBarView.addSubview(homeLabel)
        homeLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            homeLabel.leadingAnchor.constraint(equalTo: navBarView.leadingAnchor, constant: 20),
            homeLabel.centerYAnchor.constraint(equalTo: menuButton.centerYAnchor)
        ])

        // --- Search Bar ---
        //topContainer.addSubview(searchBar)
        navBarView.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: menuButton.bottomAnchor, constant: Spacing.md),
            searchBar.leadingAnchor.constraint(equalTo: navBarView.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: navBarView.trailingAnchor, constant: -20),
            searchBar.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // --- White background below trending categories (covers tab bar area) ---
        let whiteBackground = UIView()
        whiteBackground.backgroundColor = .white
        whiteBackground.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(whiteBackground)
        NSLayoutConstraint.activate([
            whiteBackground.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 150), // below trending categories
            whiteBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            whiteBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            whiteBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // --- Main Scroll Section ---
        view.addSubview(mainScrollView)
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.backgroundColor = .clear
        NSLayoutConstraint.activate([
            // Scroll starts from TOP of trending categories box
            mainScrollView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 22),
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

        // --- Add teal background strip behind trending categories for rounded corner effect ---
        let tealStrip = UIView()
        tealStrip.backgroundColor = UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1) // #3D7C98 teal
        tealStrip.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tealStrip)
        NSLayoutConstraint.activate([
            tealStrip.topAnchor.constraint(equalTo: contentView.topAnchor),
            tealStrip.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tealStrip.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tealStrip.heightAnchor.constraint(equalToConstant: 30) // Just covers the rounded corner area
        ])

        // --- Add Trending Categories to scroll content ---
        // Setup trendingCategoriesbg styling
        trendingCategoriesbg.backgroundColor = UIColor(red: 0.83, green: 0.95, blue: 0.96, alpha: 1) // #D4F2F4
        trendingCategoriesbg.layer.cornerRadius = 20
        trendingCategoriesbg.layer.maskedCorners = [
            .layerMinXMinYCorner, // top-left
            .layerMaxXMinYCorner  // top-right
        ]
        trendingCategoriesbg.clipsToBounds = true
        trendingCategoriesbg.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(trendingCategoriesbg)
        NSLayoutConstraint.activate([
            trendingCategoriesbg.topAnchor.constraint(equalTo: contentView.topAnchor),
            trendingCategoriesbg.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trendingCategoriesbg.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

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
        categoryStackView.alignment = .top
        categoryStackView.distribution = .fillEqually
        categoryStackView.spacing = 5
        trendingCategoriesbg.addSubview(categoryStackView)
        categoryStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryStackView.topAnchor.constraint(equalTo: trendingLabel.bottomAnchor, constant: 10),
            categoryStackView.leadingAnchor.constraint(equalTo: trendingCategoriesbg.leadingAnchor, constant: 10),
            categoryStackView.trailingAnchor.constraint(equalTo: trendingCategoriesbg.trailingAnchor, constant: -10)
        ])
        // Set bottom constraint for trendingCategoriesbg height
        trendingCategoriesbg.bottomAnchor
            .constraint(equalTo: categoryStackView.bottomAnchor, constant: 25)
            .isActive = true

        // --- Categories ---
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
            v.isUserInteractionEnabled = true

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
            lbl.text = caption
            lbl.font = UIFont.systemFont(ofSize: 12)
            lbl.textAlignment = .center
            lbl.numberOfLines = 2
            lbl.isUserInteractionEnabled = false

            v.addArrangedSubview(btn)
            v.addArrangedSubview(lbl)
            categoryStackView.addArrangedSubview(v)
        }
        
        // --- Carousel ---
        contentView.addSubview(carouselScrollView)
        contentView.backgroundColor = .white
        carouselScrollView.isPagingEnabled = true
        carouselScrollView.delegate = self
        carouselScrollView.showsHorizontalScrollIndicator = false
        carouselScrollView.delaysContentTouches = false
        carouselScrollView.canCancelContentTouches = true
        carouselScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // Start carousel below trending categories
            carouselScrollView.topAnchor.constraint(equalTo: trendingCategoriesbg.bottomAnchor, constant: 20),

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
        refreshControl.addTarget(
            self,
            action: #selector(handleRefresh),
            for: .valueChanged
        )

        mainScrollView.refreshControl = refreshControl
    }
    
    @MainActor
    private func loadProducts() async {
        currentPage = 0
        hasMorePages = true
        isLoadingMore = false
        do {
            async let allDTOs = productRepository.fetchAllProducts(page: 1)
            async let popularDTOs = productRepository.fetchPopularProducts()
            async let negotiableDTOs = productRepository.fetchNegotiableProducts()

            let (all, popular, negotiable) = try await (allDTOs, popularDTOs, negotiableDTOs)

            self.allProducts = all.map(ProductMapper.toUIModel)
            self.popularProducts = popular.map(ProductMapper.toUIModel)
            self.negotiableProducts = negotiable.map(ProductMapper.toUIModel)

            self.displayedProducts = self.allProducts

            self.loader.stopAnimating()
            self.loader.removeFromSuperview()

            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
            self.updateCollectionHeight()
            refreshControl.endRefreshing()

            print("✅ Products loaded:", displayedProducts.count)

        } catch {
            print("❌ Failed to load products:", error)
        }
    }
    @MainActor
    private func loadBanners() async {
        do {
            let dtos = try await productRepository.fetchBanners()
            print("🟢 Banner DTOs:", dtos)

            self.banners = dtos.map {
                BannerUIModel(imageURL: $0.image_url)
            }

            print("🟢 Banner URLs:", banners.map { $0.imageURL })

            guard !banners.isEmpty else {
                print("❌ No banners returned from DB")
                return
            }
            // Setup carousel after banners are loaded
                        if !didSetupCarousel {
                            didSetupCarousel = true
                            setupCarousel()
                            startAutoScroll()
                        }

        } catch {
            print("❌ Failed to load banners:", error)
        }
    }
    @MainActor
    private func loadNextPage() {
        isLoadingMore = true
        currentPage += 1

        Task {
            do {
                let nextDTOs = try await productRepository.fetchAllProducts(page: currentPage)

                // If no data returned → stop pagination
                guard !nextDTOs.isEmpty else {
                    hasMorePages = false
                    isLoadingMore = false
                    return
                }

                let newProducts = nextDTOs.map(ProductMapper.toUIModel)

                allProducts.append(contentsOf: newProducts)

                // Only append if "All" segment is active
                if segmentedControl.selectedSegmentIndex == 0 {
                    displayedProducts = allProducts
                    collectionView.reloadData()
                    collectionView.layoutIfNeeded()
                    updateCollectionHeight()
                }

                isLoadingMore = false

                print("📦 Loaded page \(currentPage), total:", allProducts.count)

            } catch {
                isLoadingMore = false
                print("❌ Pagination failed:", error)
            }
        }
    }


    @objc private func segmentChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            displayedProducts = allProducts
        case 1:
            displayedProducts = popularProducts
        case 2:
            displayedProducts = negotiableProducts
        default:
            break
        }

        UIView.transition(
            with: collectionView,
            duration: 0.35,
            options: [.transitionCrossDissolve],
            animations: {
                self.collectionView.reloadData()
            },
            completion: { _ in
                self.collectionView.layoutIfNeeded() // 🔥 ADD THIS
                self.updateCollectionHeight()
            }
        )
    }



    func openCategoryPage(title: String, items: [ProductUIModel]) {
        // Preserve old API by forwarding with a default index
        openCategoryPage(title: title, items: items, categoryIndex: 0)
    }

    func openCategoryPage(title: String, items: [ProductUIModel], categoryIndex: Int) {
        let vc = CategoryPageViewController()
        vc.title = title
        vc.items = items   // Update CategoryPageViewController to use ProductUIModel

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

        let categories = [
            "Hostel Essentials",
            "Furniture",
            "Fashion",
            "Sports",
            "Gadgets"
        ]

        let selectedCategory = categories[sender.tag]

        Task {
            do {
                let dtos = try await productRepository
                    .fetchProductsByCategory(selectedCategory)

                let products = dtos.map(ProductMapper.toUIModel)

                openCategoryPage(
                    title: selectedCategory,
                    items: products,
                    categoryIndex: sender.tag
                )

            } catch {
                print("❌ Category fetch failed:", error)
            }
        }
    }
    @MainActor
    private func refreshProducts() async {
        guard !isLoadingMore else {
            refreshControl.endRefreshing()
            return
        }
        // Reset pagination state
        currentPage = 0
        hasMorePages = true
        isLoadingMore = false

        do {
            async let allDTOs = productRepository.fetchAllProducts(page: 1)
            async let popularDTOs = productRepository.fetchPopularProducts()
            async let negotiableDTOs = productRepository.fetchNegotiableProducts()

            let (all, popular, negotiable) = try await (allDTOs, popularDTOs, negotiableDTOs)

            self.allProducts = all.map(ProductMapper.toUIModel)
            self.popularProducts = popular.map(ProductMapper.toUIModel)
            self.negotiableProducts = negotiable.map(ProductMapper.toUIModel)

            // Respect current segment
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                displayedProducts = allProducts
            case 1:
                displayedProducts = popularProducts
            case 2:
                displayedProducts = negotiableProducts
            default:
                break
            }

            collectionView.reloadData()
            collectionView.layoutIfNeeded()
            updateCollectionHeight()

            refreshControl.endRefreshing()

            print("🔄 Pull-to-refresh complete")

        } catch {
            refreshControl.endRefreshing()
            print("❌ Refresh failed:", error)
        }
    }
    // MARK: Toolbar Menu Action
    @objc private func menuButtonTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

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
            let vc = NotificationsViewController()

                    // CASE 1 — If inside a NavigationController
                    if let nav = self.navigationController {
                        nav.pushViewController(vc, animated: true)
                        return
                    }

                    // CASE 2 — If presented modally
                    vc.modalPresentationStyle = .fullScreen
                    vc.modalTransitionStyle = .coverVertical
                    self.present(vc, animated: true)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = menuButton
            popover.sourceRect = menuButton.bounds
        }

        present(alert, animated: true)
    }

    // MARK: Carousel content
    private func setupCarousel() {

        carouselScrollView.subviews.forEach { $0.removeFromSuperview() }

        let cardWidth = view.bounds.width - 40
        let cardHeight: CGFloat = 140

        for (index, banner) in banners.enumerated() {

            let wrapper = UIView()
            wrapper.frame = CGRect(
                x: CGFloat(index) * (cardWidth + 20),
                y: 0,
                width: cardWidth,
                height: cardHeight
            )

            wrapper.layer.shadowColor = UIColor.black.cgColor
            wrapper.layer.shadowOpacity = 0.12
            wrapper.layer.shadowRadius = 6
            wrapper.layer.shadowOffset = CGSize(width: 0, height: 3)

            // Make wrapper tappable
            wrapper.tag = index
            wrapper.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(carouselBannerTapped(_:)))
            wrapper.addGestureRecognizer(tapGesture)

            let imageView = UIImageView()
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 16
            imageView.contentMode = .scaleAspectFill
            imageView.frame = wrapper.bounds
            imageView.isUserInteractionEnabled = false // Let wrapper handle taps

            ImageLoader.shared.load(
                banner.imageURL,
                into: imageView
            )

            wrapper.addSubview(imageView)
            carouselScrollView.addSubview(wrapper)
        }

        carouselScrollView.contentSize = CGSize(
            width: CGFloat(banners.count) * (cardWidth + 20),
            height: cardHeight
        )

        pageControl.numberOfPages = banners.count
        pageControl.currentPage = 0
    }

    @objc private func carouselBannerTapped(_ sender: UITapGestureRecognizer) {
        let vc = BrowseEventsViewController()

        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .coverVertical
            present(vc, animated: true)
        }
    }


    private func startAutoScroll() {
        timer?.invalidate()

        guard banners.count > 1 else { return }

        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            self.currentBannerIndex =
                (self.currentBannerIndex + 1) % self.banners.count

            let pageWidth = self.carouselScrollView.frame.width + 20
            let offsetX = CGFloat(self.currentBannerIndex) * pageWidth

            self.carouselScrollView.setContentOffset(
                CGPoint(x: offsetX, y: 0),
                animated: true
            )
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

        let height = collectionView.collectionViewLayout.collectionViewContentSize.height

        collectionView.constraints
            .filter { $0.firstAttribute == .height }
            .forEach { collectionView.removeConstraint($0) }

        collectionView.heightAnchor
            .constraint(equalToConstant: height)
            .isActive = true
    }
}

// MARK: - ScrollView delegate
extension LandingScreenViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        // Carousel paging (keep as-is)
        if scrollView == carouselScrollView {
            let pageWidth = view.bounds.width - 40 + 20
            let pageIndex = round(scrollView.contentOffset.x / pageWidth)
            pageControl.currentPage = Int(pageIndex)
            return
        }

        //  PAGINATION TRIGGER (main scroll view)
        guard scrollView == mainScrollView,
              hasMorePages,
              !isLoadingMore else { return }

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        // Trigger when user scrolls near bottom
        if offsetY > contentHeight - frameHeight * 1.4 {
            loadNextPage()
        }
    }

    // MARK: - Manual Scroll Handling for Carousel
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // Pause auto-scroll when user starts manual scrolling
        if scrollView == carouselScrollView {
            timer?.invalidate()
            timer = nil
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Sync index and resume auto-scroll after manual scroll ends
        if scrollView == carouselScrollView {
            let pageWidth = view.bounds.width - 40 + 20
            currentBannerIndex = Int(round(scrollView.contentOffset.x / pageWidth))
            startAutoScroll()
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // If no deceleration, sync index and resume auto-scroll immediately
        if scrollView == carouselScrollView && !decelerate {
            let pageWidth = view.bounds.width - 40 + 20
            currentBannerIndex = Int(round(scrollView.contentOffset.x / pageWidth))
            startAutoScroll()
        }
    }
}


// MARK: - CollectionView delegate
extension LandingScreenViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let selected = displayedProducts[indexPath.item]

        let vc = ItemDetailsViewController(
            nibName: "ItemDetailsViewController",
            bundle: nil
        )
        vc.product = selected

        navigationController?.pushViewController(vc, animated: true)
    }

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

        let vc = SearchResultsViewController(
            keyword: searchBar.text ?? ""
        )

        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func openEventsPage() {
        let vc = BrowseEventsViewController()

        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
            return
        }

        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true)
    }
    @objc private func handleRefresh() {
        Task {
            await refreshProducts()
        }
    }
}
final class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSString, UIImage>()

    func load(
        _ urlString: String,
        into imageView: UIImageView,
        placeholder: UIImage? = nil
    ) {
        imageView.image = placeholder
        
        if let cached = cache.object(forKey: urlString as NSString) {
            imageView.image = cached
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            self.cache.setObject(image, forKey: urlString as NSString)
            
            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
    }
}
