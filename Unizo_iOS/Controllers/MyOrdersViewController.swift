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
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 22
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.1
        btn.layer.shadowRadius = 8
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        return btn
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "My Orders".localized
        lbl.font = .systemFont(ofSize: 20, weight: .semibold)
        lbl.textAlignment = .center
        return lbl
    }()

    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["All".localized, "Processing".localized, "Delivered".localized])

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
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let emptyStateContainer: UIView = {
        let v = UIView()
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let emptyStateImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "bag")
        iv.tintColor = .tertiaryLabel
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let emptyStateLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "No orders yet".localized
        lbl.font = .systemFont(ofSize: 17, weight: .medium)
        lbl.textColor = .secondaryLabel
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let emptyStateSubtitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "Your orders will appear here\nonce you make a purchase".localized
        lbl.font = .systemFont(ofSize: 14)
        lbl.textColor = .tertiaryLabel
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
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
        view.addSubview(emptyStateContainer)
        emptyStateContainer.addSubview(emptyStateImageView)
        emptyStateContainer.addSubview(emptyStateLabel)
        emptyStateContainer.addSubview(emptyStateSubtitle)

        segmentedControl.addTarget(self, action: #selector(onSegmentChanged), for: .valueChanged)

        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        // Accessibility
        backButton.accessibilityLabel = "Go back".localized
        backButton.accessibilityHint = "Return to previous screen".localized
        titleLabel.accessibilityTraits = .header
        segmentedControl.accessibilityLabel = "Filter orders".localized
        loadingIndicator.accessibilityLabel = "Loading orders".localized
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
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

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

            // Empty state container
            emptyStateContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateContainer.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateContainer.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 60),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 60),

            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 16),
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateContainer.centerXAnchor),

            emptyStateSubtitle.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 8),
            emptyStateSubtitle.centerXAnchor.constraint(equalTo: emptyStateContainer.centerXAnchor),
            emptyStateSubtitle.bottomAnchor.constraint(equalTo: emptyStateContainer.bottomAnchor)
        ])
    }

    // MARK: - Fetch Orders from Backend
    private func fetchOrders() {
        guard !isLoading else { return }
        isLoading = true

        loadingIndicator.startAnimating()
        emptyStateContainer.isHidden = true
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
                    self.emptyStateLabel.text = "Failed to load orders".localized
                    self.emptyStateSubtitle.text = "Pull down to try again".localized
                    self.emptyStateImageView.image = UIImage(systemName: "exclamationmark.triangle")
                    self.emptyStateContainer.isHidden = false
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
            emptyStateLabel.text = filter == "All" ? "No orders yet".localized : "No \(filter.lowercased()) orders"
            emptyStateSubtitle.text = "Your orders will appear here\nonce you make a purchase".localized
            emptyStateImageView.image = UIImage(systemName: "bag")
            emptyStateContainer.isHidden = false
            return
        }

        emptyStateContainer.isHidden = true

        // Create cards for each order
        for order in filteredOrders {
            let card = OrderCardView()
            card.configure(with: order)
            card.onTap = { [weak self] tappedOrder in
                self?.navigateToOrderDetails(order: tappedOrder)
            }
            contentStack.addArrangedSubview(card)
        }
    }

    // MARK: - Navigate to Order Details
    private func navigateToOrderDetails(order: OrderDTO) {
        let vc = OrderDetailsViewController()
        vc.orderId = order.id
        vc.orderAddress = order.address
        vc.orderTotal = order.total_amount
        vc.orderCreatedAt = order.created_at
        vc.orderStatus = order.status
        navigationController?.pushViewController(vc, animated: true)
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

