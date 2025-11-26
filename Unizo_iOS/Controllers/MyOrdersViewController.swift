//
//  MyOrdersViewController.swift
//  Unizo_iOS
//
//  Created by Somesh on 25/11/25.
//

import UIKit

class MyOrdersViewController: UIViewController {
    
    struct OrderItem {
        let imageName: String
        let title: String
        let detail: String
        let price: String
    }

    struct Order {
        let orderID: String
        let date: String
        let status: String
        let statusColor: UIColor
        let items: [OrderItem]
    }

    // MARK: - UI Components (private lets)

    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        btn.tintColor = .black
        return btn
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "My Orders"
        lbl.font = .systemFont(ofSize: 20, weight: .semibold)
        lbl.textAlignment = .center
        return lbl
    }()

    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["All", "Processing", "Delivered"])

        // Initial Selection
        sc.selectedSegmentIndex = 0

        // Selected segment background color (#3D7C98)
        sc.selectedSegmentTintColor = UIColor(
            red: 0.239, green: 0.486, blue: 0.596, alpha: 1
        )

        // UNSELECTED text color
        sc.setTitleTextAttributes([
            .foregroundColor: UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1),
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)

        // SELECTED text color
        sc.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)

        return sc
    }()


    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGray6

        setupUI()
        setupConstraints()
        loadOrders(filter: "All")
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: - Setup UI
    private func setupUI() {
        // StackView Setup
        contentStack.axis = .vertical
        contentStack.spacing = 20

        // Add subviews
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(segmentedControl)
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        segmentedControl.addTarget(self, action: #selector(onSegmentChanged), for: .valueChanged)

        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }

    // MARK: - Constraints
    private func setupConstraints() {

        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            // Back Button
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),

            // Title Label
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            // Segmented Control
            segmentedControl.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 40),

            // ScrollView
            scrollView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content Stack inside scrollView
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            // Very important for vertical scrolling
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    // MARK: - Load Cards
    private func loadOrders(filter: String) {

        // remove old cards
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Demo data
        let sampleOrders: [Order] = [

            // ORDER 1 — 1 product
            Order(
                orderID: "10001",
                date: "Oct 18, 2024",
                status: "Delivered",
                statusColor: .systemGreen,
                items: [
                    OrderItem(
                        imageName: "cap",
                        title: "Under Armour Cap",
                        detail: "Color: Black • One Size",
                        price: "₹500"
                    )
                ]
            ),

            // ORDER 2 — 2 products
            Order(
                orderID: "10002",
                date: "Oct 17, 2024",
                status: "Shipped",
                statusColor: .systemBlue,
                items: [
                    OrderItem(
                        imageName: "electrickettle",
                        title: "Prestige Electric Kettle",
                        detail: "Steel • 1.5L",
                        price: "₹649"
                    ),
                    OrderItem(
                        imageName: "lamp",
                        title: "Table Lamp",
                        detail: "Color: White • LED",
                        price: "₹500"
                    )
                ]
            ),

            // ORDER 3 — 3 products
            Order(
                orderID: "10003",
                date: "Oct 16, 2024",
                status: "Processing",
                statusColor: .systemOrange,
                items: [
                    OrderItem(
                        imageName: "ergonomicmeshchair",
                        title: "Ergonomic Mesh Office Chair",
                        detail: "Color: Black",
                        price: "₹1299"
                    ),
                    OrderItem(
                        imageName: "studytable",
                        title: "Study Table",
                        detail: "Compact • Wooden",
                        price: "₹699"
                    ),
                    OrderItem(
                        imageName: "helmet",
                        title: "Helmet",
                        detail: "ISI Certified",
                        price: "₹579"
                    )
                ]
            ),

            // ORDER 4 — 2 products
            Order(
                orderID: "10004",
                date: "Oct 15, 2024",
                status: "Delivered",
                statusColor: .systemGreen,
                items: [
                    OrderItem(
                        imageName: "SSbat",
                        title: "SS Size 5 Bat",
                        detail: "Willow: Grade-1",
                        price: "₹1299"
                    ),
                    OrderItem(
                        imageName: "tabletennis",
                        title: "Table Tennis Bat",
                        detail: "Standard Size",
                        price: "₹999"
                    )
                ]
            ),

            // ORDER 5 — 1 product
            Order(
                orderID: "10005",
                date: "Oct 14, 2024",
                status: "Delivered",
                statusColor: .systemGreen,
                items: [
                    OrderItem(
                        imageName: "NYcap",
                        title: "NY Cap",
                        detail: "Navy Blue • One Size",
                        price: "₹499"
                    )
                ]
            ),

            // ORDER 6 — 3 products
            Order(
                orderID: "10006",
                date: "Oct 13, 2024",
                status: "Shipped",
                statusColor: .systemBlue,
                items: [
                    OrderItem(
                        imageName: "ptronheadphones",
                        title: "pTron Headphones",
                        detail: "Wireless • Black",
                        price: "₹1000"
                    ),
                    OrderItem(
                        imageName: "boultprobassheadphones",
                        title: "Boult ProBass",
                        detail: "Bass Boosted",
                        price: "₹1100"
                    ),
                    OrderItem(
                        imageName: "leafbasswireless",
                        title: "Leaf Bass Wireless",
                        detail: "20hr Playback",
                        price: "₹1400"
                    )
                ]
            ),

            // ORDER 7 — 2 products
            Order(
                orderID: "10007",
                date: "Oct 12, 2024",
                status: "Processing",
                statusColor: .systemOrange,
                items: [
                    OrderItem(
                        imageName: "studytable",
                        title: "Study Table",
                        detail: "Brown • Compact",
                        price: "₹699"
                    ),
                    OrderItem(
                        imageName: "paddedofficechair",
                        title: "Padded Chair",
                        detail: "Cushioned • Grey",
                        price: "₹899"
                    )
                ]
            ),

            // ORDER 8 — 1 product
            Order(
                orderID: "10008",
                date: "Oct 11, 2024",
                status: "Delivered",
                statusColor: .systemGreen,
                items: [
                    OrderItem(
                        imageName: "pinkbicycle",
                        title: "Pink Bicycle",
                        detail: "Kids • 16 inch",
                        price: "₹8900"
                    )
                ]
            ),

            // ORDER 9 — 2 products
            Order(
                orderID: "10009",
                date: "Oct 10, 2024",
                status: "Shipped",
                statusColor: .systemBlue,
                items: [
                    OrderItem(
                        imageName: "rollerskates",
                        title: "Roller Skates",
                        detail: "Adjustable • Pink",
                        price: "₹650"
                    ),
                    OrderItem(
                        imageName: "footballspikes",
                        title: "Football Spikes",
                        detail: "Size 8 • Rubber Studs",
                        price: "₹399"
                    )
                ]
            ),

            // ORDER 10 — 3 products
            Order(
                orderID: "10010",
                date: "Oct 09, 2024",
                status: "Delivered",
                statusColor: .systemGreen,
                items: [
                    OrderItem(
                        imageName: "badmintonracket",
                        title: "Badminton Racket",
                        detail: "Carbon Fiber",
                        price: "₹550"
                    ),
                    OrderItem(
                        imageName: "carromboard",
                        title: "Carrom Board",
                        detail: "Wooden • Full Size",
                        price: "₹700"
                    ),
                    OrderItem(
                        imageName: "cricketpads",
                        title: "Cricket Pads",
                        detail: "Senior Size",
                        price: "₹599"
                    )
                ]
            )
        ]



        for order in sampleOrders {

            if filter != "All" && order.status != filter { continue }

            let card = OrderCardView()
            card.configure(order: order)

            contentStack.addArrangedSubview(card)
        }

    }

    // MARK: - Actions

    @objc private func onSegmentChanged() {
        let selected = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex) ?? "All"
        loadOrders(filter: selected)
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

