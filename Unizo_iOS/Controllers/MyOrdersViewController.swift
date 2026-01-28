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

    // MARK: - Data
    private let orderRepository = OrderRepository()
    private var allOrders: [OrderDTO] = []
    private var isLoading = false

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

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let emptyStateLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "No orders yet"
        lbl.font = .systemFont(ofSize: 16)
        lbl.textColor = .secondaryLabel
        lbl.textAlignment = .center
        lbl.isHidden = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGray6

        setupUI()
        setupConstraints()
        fetchOrders()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the floating tab bar
        tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show again when leaving
        tabBarController?.tabBar.isHidden = false
        
        // Restore floating pill shape + position
        if let mainTab = tabBarController as? MainTabBarController {
        }
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false

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
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateLabel)

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
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            // Empty state label
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Fetch Orders from Backend
    private func fetchOrders() {
        guard !isLoading else { return }
        isLoading = true

        loadingIndicator.startAnimating()
        emptyStateLabel.isHidden = true
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        Task {
            do {
                let orders = try await orderRepository.fetchUserOrdersWithItems()
                await MainActor.run {
                    self.allOrders = orders
                    self.isLoading = false
                    self.loadingIndicator.stopAnimating()
                    self.displayOrders(filter: "All")
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.loadingIndicator.stopAnimating()
                    self.emptyStateLabel.text = "Failed to load orders"
                    self.emptyStateLabel.isHidden = false
                    print("❌ Error fetching orders: \(error)")
                }
            }
        }
    }

    // MARK: - Display Orders with Filter
    private func displayOrders(filter: String) {
        // Remove old cards
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Filter orders based on selected segment
        let filteredOrders: [OrderDTO]
        switch filter {
        case "Processing":
            // Processing includes: pending, confirmed, shipped
            filteredOrders = allOrders.filter { order in
                let status = OrderStatus(rawValue: order.status)
                return status == .pending || status == .confirmed || status == .shipped
            }
        case "Delivered":
            filteredOrders = allOrders.filter { order in
                OrderStatus(rawValue: order.status) == .delivered
            }
        default: // "All"
            filteredOrders = allOrders
        }

        // Show empty state if no orders
        if filteredOrders.isEmpty {
            emptyStateLabel.text = filter == "All" ? "No orders yet" : "No \(filter.lowercased()) orders"
            emptyStateLabel.isHidden = false
            return
        }

        emptyStateLabel.isHidden = true

        // Create cards for each order
        for order in filteredOrders {
            let card = OrderCardView()
            card.configure(with: order)
            contentStack.addArrangedSubview(card)
        }
    }

    // MARK: - Actions

    @objc private func onSegmentChanged() {
        let selected = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex) ?? "All"
        displayOrders(filter: selected)
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

