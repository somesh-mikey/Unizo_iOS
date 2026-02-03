//
//  OrderDetailsViewController.swift
//  Unizo_iOS
//

import UIKit

class OrderDetailsViewController: UIViewController {

    // MARK: - Order Data (passed from OrderPlacedViewController)
    var orderId: UUID?
    var orderAddress: AddressDTO?
    var orderTotal: Double = 0
    var orderCreatedAt: String?  // ISO8601 timestamp
    var orderStatus: String = "pending"

    // MARK: - Fetched Data
    private var orderItems: [OrderItemDTO] = []
    private let orderRepository = OrderRepository()

    // MARK: - Colors
    private let bgColor = UIColor(red: 0.96, green: 0.97, blue: 1.00, alpha: 1.0)
    private let darkTeal = UIColor(red: 0.07, green: 0.33, blue: 0.42, alpha: 1.0)
    private let accentTeal = UIColor(red: 0.00, green: 0.62, blue: 0.71, alpha: 1.0)
    private let lightGrayText = UIColor(white: 0.55, alpha: 1.0)

    // MARK: - Top Bar
    private let topBar = UIView()
    private let backButton = UIButton(type: .system)
    private let navTitleLabel = UILabel()
    private let heartButton = UIButton(type: .system)

    // MARK: - Scroll + Content
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - Status Card
    private let statusCard = UIView()
    private let statusCircle = UIView()
    private let statusCheck = UIImageView()
    private let statusTitleLabel = UILabel()
    private let statusTimeLabel = UILabel()
    private let orderIdLabel = UILabel()
    private let totalAmountLabel = UILabel()

    // MARK: - Timeline
    private let timelineLabel = UILabel()
    private let timelineStack = UIStackView()

    // MARK: - Items Section
    private let orderItemsTitle = UILabel()
    private var itemsStackView = UIStackView()

    // MARK: - Delivery Info
    private let deliveryTitle = UILabel()
    private let deliveryNameLabel = UILabel()
    private let deliveryAddressLabel = UILabel()

    // MARK: - Order Summary
    private let orderSummaryTitle = UILabel()
    private let summaryCard = UIView()
    private let summarySubtotalValue = UILabel()
    private let summaryTotalValue = UILabel()

    // MARK: - Bottom Buttons
    private let bottomButtonsContainer = UIStackView()
    private let rateButton = UIButton(type: .system)
    private let helpButton = UIButton(type: .system)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor

        setupTopBar()
        setupScrollHierarchy()
        setupStatusCard()
        setupTimeline()
        setupItemsSection()
        setupDeliveryInfo()
        setupOrderSummary()
        setupBottomButtons()

        // If we have minimal data (from notification), fetch full order details
        if orderAddress == nil && orderId != nil {
            fetchFullOrderDetails()
        } else {
            // Update UI with provided data
            updateUIWithOrderData()
            fetchOrderItems()
        }
    }

    // MARK: - Hide Nav + Tab Bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = true

        // Always refresh order status when view appears (in case seller accepted/rejected)
        if orderId != nil {
            refreshOrderStatus()
        }
    }

    // MARK: - Refresh Order Status
    private func refreshOrderStatus() {
        guard let id = orderId else { return }

        print("🔄 Refreshing order status for order: \(id.uuidString)")

        Task {
            do {
                let order = try await orderRepository.fetchOrderWithDetails(id: id)
                await MainActor.run {
                    print("🔄 Fetched order status: \(order.status)")

                    // Only update if status changed
                    if self.orderStatus != order.status {
                        print("🔄 Status changed from '\(self.orderStatus)' to '\(order.status)' - updating UI")
                        self.orderStatus = order.status
                        self.updateTimelineForStatus()
                    } else {
                        print("🔄 Status unchanged: \(self.orderStatus)")
                    }
                }
            } catch {
                print("❌ Failed to refresh order status: \(error)")
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: - Update UI with Order Data
    private func updateUIWithOrderData() {
        // Update status card with real data
        if let id = orderId {
            let shortId = String(id.uuidString.prefix(8)).uppercased()
            orderIdLabel.text = "#ORD-\(shortId)"
        }
        totalAmountLabel.text = "₹\(Int(orderTotal))"

        // Update delivery info with real address
        if let address = orderAddress {
            deliveryNameLabel.text = "\(address.name)  \(address.phone)"
            deliveryAddressLabel.text = "\(address.line1),\n\(address.city), \(address.state) \(address.postal_code)"
        }

        // Format actual order creation time for status card
        statusTimeLabel.text = formatTimelineDate(orderCreatedAt)

        // Update order summary with real values
        summarySubtotalValue.text = "₹\(Int(orderTotal))"
        summaryTotalValue.text = "₹\(Int(orderTotal))"
    }

    // MARK: - Fetch Full Order Details (when navigating from notification)
    private func fetchFullOrderDetails() {
        guard let id = orderId else { return }

        Task {
            do {
                let order = try await orderRepository.fetchOrderWithDetails(id: id)
                await MainActor.run {
                    // Update local properties with fetched data
                    self.orderAddress = order.address
                    self.orderTotal = order.total_amount
                    self.orderCreatedAt = order.created_at
                    self.orderStatus = order.status
                    self.orderItems = order.items ?? []

                    // Update UI with real data
                    self.updateUIWithOrderData()
                    self.updateItemsUI()
                    self.updateTimelineForStatus()
                }
            } catch {
                print("❌ Failed to fetch order details:", error)
            }
        }
    }

    // MARK: - Fetch Order Items
    private func fetchOrderItems() {
        guard let id = orderId else { return }

        Task {
            do {
                let items = try await orderRepository.fetchOrderItems(orderId: id)
                await MainActor.run {
                    self.orderItems = items
                    self.updateItemsUI()
                }
            } catch {
                print("❌ Failed to fetch order items:", error)
            }
        }
    }

    private func updateItemsUI() {
        // Clear existing items
        itemsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Add item cards for each order item
        for item in orderItems {
            let card = makeItemCard(for: item)
            itemsStackView.addArrangedSubview(card)
        }
    }

    private func makeItemCard(for item: OrderItemDTO) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.shadowOpacity = 0.05
        card.layer.shadowRadius = 6
        card.layer.shadowOffset = CGSize(width: 0, height: 2)

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // Load product image
        if let product = item.product, let imageURL = product.imageUrl, !imageURL.isEmpty {
            if imageURL.hasPrefix("http") {
                imageView.loadImage(from: imageURL)
            } else {
                imageView.image = UIImage(named: imageURL)
            }
        }

        let categoryLabel = UILabel()
        categoryLabel.text = item.product?.category ?? "General"
        categoryLabel.font = .systemFont(ofSize: 12)
        categoryLabel.textColor = .gray
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = item.product?.title ?? "Product"
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let priceValue = UILabel()
        priceValue.text = "₹\(Int(item.price_at_purchase))"
        priceValue.font = .systemFont(ofSize: 15, weight: .semibold)
        priceValue.textColor = .black

        let colourLabel = smallTeal(text: "Colour")
        let sizeLabel = smallTeal(text: "Size")
        let qtyLabel = smallTeal(text: "Quantity")

        let colourValue = smallValue(text: item.colour ?? "—")
        let sizeValue = smallValue(text: item.size ?? "—")
        let qtyValue = smallValue(text: "\(item.quantity)")

        func row(_ left: UIView, _ right: UIView) -> UIStackView {
            let r = UIStackView(arrangedSubviews: [left, right])
            r.axis = .horizontal
            r.alignment = .center
            r.distribution = .equalSpacing
            return r
        }

        let rows = UIStackView(arrangedSubviews: [
            categoryLabel,
            row(titleLabel, priceValue),
            row(colourLabel, colourValue),
            row(sizeLabel, sizeValue),
            row(qtyLabel, qtyValue)
        ])
        rows.axis = .vertical
        rows.spacing = 6
        rows.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(imageView)
        card.addSubview(rows)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),

            imageView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            imageView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),

            rows.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            rows.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            rows.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            rows.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])

        return card
    }

    // MARK: - Top Bar UI
    private func setupTopBar() {
        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBar)

        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .black
        backButton.backgroundColor = .white
        backButton.layer.cornerRadius = 22
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOpacity = 0.1
        backButton.layer.shadowRadius = 8
        backButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backPressed), for: .touchUpInside)

        heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        heartButton.tintColor = .black
        heartButton.backgroundColor = .white
        heartButton.layer.cornerRadius = 22
        heartButton.layer.shadowColor = UIColor.black.cgColor
        heartButton.layer.shadowOpacity = 0.1
        heartButton.layer.shadowRadius = 8
        heartButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        heartButton.translatesAutoresizingMaskIntoConstraints = false

        navTitleLabel.text = "Order Details"
        navTitleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        navTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        topBar.addSubview(backButton)
        topBar.addSubview(navTitleLabel)
        topBar.addSubview(heartButton)

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 56),

            backButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            heartButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -16),
            heartButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            heartButton.widthAnchor.constraint(equalToConstant: 44),
            heartButton.heightAnchor.constraint(equalToConstant: 44),

            navTitleLabel.centerXAnchor.constraint(equalTo: topBar.centerXAnchor),
            navTitleLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor)
        ])
    }

    // MARK: - Scroll + Content Layout
    private func setupScrollHierarchy() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    // MARK: - Status Card
    private func setupStatusCard() {
        statusCard.translatesAutoresizingMaskIntoConstraints = false
        statusCard.backgroundColor = darkTeal
        statusCard.layer.cornerRadius = 14
        contentView.addSubview(statusCard)

        statusCircle.translatesAutoresizingMaskIntoConstraints = false
        statusCircle.layer.cornerRadius = 22
        statusCircle.backgroundColor = darkTeal

        statusCheck.image = UIImage(systemName: "checkmark")
        statusCheck.tintColor = .white
        statusCheck.translatesAutoresizingMaskIntoConstraints = false

        statusCircle.addSubview(statusCheck)

        statusTitleLabel.text = "Order Confirmed"
        statusTitleLabel.textColor = .white
        statusTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        statusTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        statusTimeLabel.text = "Today, 2:30 PM"
        statusTimeLabel.font = UIFont.systemFont(ofSize: 12)
        statusTimeLabel.textColor = .white
        statusTimeLabel.translatesAutoresizingMaskIntoConstraints = false

        orderIdLabel.text = "#ORD-2024-1156"
        orderIdLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        orderIdLabel.textColor = .white
        orderIdLabel.translatesAutoresizingMaskIntoConstraints = false

        totalAmountLabel.text = "₹500"
        totalAmountLabel.textColor = .white
        totalAmountLabel.font = .systemFont(ofSize: 18, weight: .bold)
        totalAmountLabel.translatesAutoresizingMaskIntoConstraints = false

        statusCard.addSubview(statusCircle)
        statusCard.addSubview(statusTitleLabel)
        statusCard.addSubview(statusTimeLabel)
        statusCard.addSubview(orderIdLabel)
        statusCard.addSubview(totalAmountLabel)

        NSLayoutConstraint.activate([
            statusCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            statusCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusCard.heightAnchor.constraint(equalToConstant: 110),

            statusCircle.leadingAnchor.constraint(equalTo: statusCard.leadingAnchor, constant: 12),
            statusCircle.centerYAnchor.constraint(equalTo: statusCard.centerYAnchor),
            statusCircle.widthAnchor.constraint(equalToConstant: 44),
            statusCircle.heightAnchor.constraint(equalToConstant: 44),

            statusCheck.centerXAnchor.constraint(equalTo: statusCircle.centerXAnchor),
            statusCheck.centerYAnchor.constraint(equalTo: statusCircle.centerYAnchor),

            statusTitleLabel.leadingAnchor.constraint(equalTo: statusCircle.trailingAnchor, constant: 12),
            statusTitleLabel.topAnchor.constraint(equalTo: statusCard.topAnchor, constant: 20),

            statusTimeLabel.leadingAnchor.constraint(equalTo: statusTitleLabel.leadingAnchor),
            statusTimeLabel.topAnchor.constraint(equalTo: statusTitleLabel.bottomAnchor, constant: 2),

            totalAmountLabel.trailingAnchor.constraint(equalTo: statusCard.trailingAnchor, constant: -12),
            totalAmountLabel.centerYAnchor.constraint(equalTo: statusCard.centerYAnchor),

            orderIdLabel.leadingAnchor.constraint(equalTo: statusCircle.trailingAnchor, constant: 12),
            orderIdLabel.bottomAnchor.constraint(equalTo: statusCard.bottomAnchor, constant: -14)
        ])
    }

    // MARK: - Timeline
    private func setupTimeline() {
        timelineLabel.text = "Order Timeline"
        timelineLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        timelineLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(timelineLabel)

        timelineStack.axis = .vertical
        timelineStack.spacing = 12
        timelineStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(timelineStack)

        NSLayoutConstraint.activate([
            timelineLabel.topAnchor.constraint(equalTo: statusCard.bottomAnchor, constant: 14),
            timelineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            timelineStack.topAnchor.constraint(equalTo: timelineLabel.bottomAnchor, constant: 12),
            timelineStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            timelineStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])

        // Build initial timeline based on current status
        buildTimelineForCurrentStatus()
    }

    // MARK: - Build Timeline for Current Status
    private func buildTimelineForCurrentStatus() {
        // Clear existing timeline rows
        timelineStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let status = OrderStatus(rawValue: orderStatus) ?? .pending
        let orderTime = formatTimelineDate(orderCreatedAt)

        print("📊 Building timeline for status: \(orderStatus) -> parsed as: \(status)")

        // Timeline shows: Placed → Confirmed → Delivered (3 states)
        // Or for declined: Placed ✓ → Declined ✗
        switch status {
        case .cancelled:
            // Declined flow: Order Placed ✓ then Order Declined ✗
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Declined", subtitle: orderTime, completed: false, isDeclined: true))
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Placed", subtitle: orderTime, completed: true))

        case .delivered:
            // All 3 states completed
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Delivered", subtitle: orderTime, completed: true))
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Confirmed", subtitle: orderTime, completed: true))
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Placed", subtitle: orderTime, completed: true))

        case .confirmed, .shipped:
            // Confirmed state (shipped is treated same as confirmed for 3-state timeline)
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Delivered", subtitle: "Pending", completed: false))
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Confirmed", subtitle: orderTime, completed: true))
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Placed", subtitle: orderTime, completed: true))

        case .pending:
            // Order placed, awaiting seller confirmation
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Delivered", subtitle: "Pending", completed: false))
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Confirmed", subtitle: "Awaiting seller", completed: false))
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Placed", subtitle: orderTime, completed: true))
        }
    }

    // MARK: - Update Timeline for Status (after fetching order)
    private func updateTimelineForStatus() {
        // Rebuild timeline with current status
        buildTimelineForCurrentStatus()

        // Update status card based on current status
        let status = OrderStatus(rawValue: orderStatus) ?? .pending

        switch status {
        case .cancelled:
            statusTitleLabel.text = "Order Declined"
            statusCircle.backgroundColor = .systemRed
            statusCheck.image = UIImage(systemName: "xmark")

        case .delivered:
            statusTitleLabel.text = "Order Delivered"
            statusCircle.backgroundColor = darkTeal
            statusCheck.image = UIImage(systemName: "checkmark")

        case .shipped, .confirmed:
            statusTitleLabel.text = "Order Confirmed"
            statusCircle.backgroundColor = darkTeal
            statusCheck.image = UIImage(systemName: "checkmark")

        case .pending:
            statusTitleLabel.text = "Order Placed"
            statusCircle.backgroundColor = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0) // Orange for pending
            statusCheck.image = UIImage(systemName: "clock")
        }
    }

    // MARK: - Format Timeline Date
    private func formatTimelineDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "—" }

        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var date: Date?
        date = inputFormatter.date(from: dateString)

        // Fallback: try without fractional seconds
        if date == nil {
            inputFormatter.formatOptions = [.withInternetDateTime]
            date = inputFormatter.date(from: dateString)
        }

        guard let parsedDate = date else { return dateString }

        let outputFormatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(parsedDate) {
            outputFormatter.dateFormat = "'Today,' h:mm a"
        } else if calendar.isDateInYesterday(parsedDate) {
            outputFormatter.dateFormat = "'Yesterday,' h:mm a"
        } else {
            outputFormatter.dateFormat = "MMM d, h:mm a"
        }

        return outputFormatter.string(from: parsedDate)
    }

    private func makeTimelineRow(title: String, subtitle: String, completed: Bool, isDeclined: Bool = false) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 48).isActive = true

        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.layer.cornerRadius = 14

        // Set dot color based on state
        if isDeclined {
            dot.backgroundColor = .systemRed
        } else if completed {
            dot.backgroundColor = darkTeal
        } else {
            dot.backgroundColor = UIColor(white: 0.78, alpha: 1.0)
        }

        // Set icon based on state
        let iconName = isDeclined ? "xmark" : "checkmark"
        let check = UIImageView(image: UIImage(systemName: iconName))
        check.tintColor = .white
        check.translatesAutoresizingMaskIntoConstraints = false

        dot.addSubview(check)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = isDeclined ? .systemRed : .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .darkGray
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(dot)
        row.addSubview(titleLabel)
        row.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            dot.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            dot.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 28),
            dot.heightAnchor.constraint(equalToConstant: 28),

            check.centerXAnchor.constraint(equalTo: dot.centerXAnchor),
            check.centerYAnchor.constraint(equalTo: dot.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: row.topAnchor, constant: 6),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2)
        ])

        return row
    }

    // MARK: - Items Section
    private func setupItemsSection() {
        orderItemsTitle.text = "Order Items"
        orderItemsTitle.font = .systemFont(ofSize: 18, weight: .semibold)
        orderItemsTitle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(orderItemsTitle)

        itemsStackView.axis = .vertical
        itemsStackView.spacing = 12
        itemsStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(itemsStackView)

        NSLayoutConstraint.activate([
            orderItemsTitle.topAnchor.constraint(equalTo: timelineStack.bottomAnchor, constant: 18),
            orderItemsTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            itemsStackView.topAnchor.constraint(equalTo: orderItemsTitle.bottomAnchor, constant: 12),
            itemsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            itemsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])

        // Add placeholder card (will be replaced when items are fetched)
        let placeholderCard = makePlaceholderItemCard()
        itemsStackView.addArrangedSubview(placeholderCard)
    }

    private func makePlaceholderItemCard() -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.shadowOpacity = 0.05
        card.layer.shadowRadius = 6
        card.layer.shadowOffset = CGSize(width: 0, height: 2)

        let loadingLabel = UILabel()
        loadingLabel.text = "Loading order items..."
        loadingLabel.textColor = .gray
        loadingLabel.font = .systemFont(ofSize: 14)
        loadingLabel.textAlignment = .center
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(loadingLabel)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 80),
            loadingLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            loadingLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])

        return card
    }

    private func smallTeal(text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = accentTeal
        return l
    }

    private func smallValue(text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 13)
        l.textColor = .darkGray
        return l
    }

    // MARK: - Delivery Info
    private func setupDeliveryInfo() {
        deliveryTitle.text = "Delivery Information"
        deliveryTitle.font = .systemFont(ofSize: 18, weight: .semibold)
        deliveryTitle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(deliveryTitle)

        deliveryNameLabel.text = "Jonathan (+91) 90078 91599"
        deliveryNameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        deliveryNameLabel.textColor = .darkGray
        deliveryNameLabel.translatesAutoresizingMaskIntoConstraints = false

        deliveryAddressLabel.text = "4517 Washington Ave,\nManchester, Kentucky 39495"
        deliveryAddressLabel.font = .systemFont(ofSize: 13)
        deliveryAddressLabel.numberOfLines = 0
        deliveryAddressLabel.textColor = lightGrayText
        deliveryAddressLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(deliveryNameLabel)
        contentView.addSubview(deliveryAddressLabel)

        NSLayoutConstraint.activate([
            deliveryTitle.topAnchor.constraint(equalTo: itemsStackView.bottomAnchor, constant: 16),
            deliveryTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            deliveryNameLabel.topAnchor.constraint(equalTo: deliveryTitle.bottomAnchor, constant: 12),
            deliveryNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            deliveryAddressLabel.topAnchor.constraint(equalTo: deliveryNameLabel.bottomAnchor, constant: 8),
            deliveryAddressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            deliveryAddressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Order Summary
    private func setupOrderSummary() {
        orderSummaryTitle.text = "Order Summary"
        orderSummaryTitle.font = .systemFont(ofSize: 18, weight: .semibold)
        orderSummaryTitle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(orderSummaryTitle)

        NSLayoutConstraint.activate([
            orderSummaryTitle.topAnchor.constraint(equalTo: deliveryAddressLabel.bottomAnchor, constant: 18),
            orderSummaryTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])

        summaryCard.translatesAutoresizingMaskIntoConstraints = false
        summaryCard.backgroundColor = .white
        summaryCard.layer.cornerRadius = 12
        summaryCard.layer.shadowOpacity = 0.03
        summaryCard.layer.shadowRadius = 6
        summaryCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.addSubview(summaryCard)

        let subLabel = UILabel()
        subLabel.text = "Subtotal"
        subLabel.font = UIFont.systemFont(ofSize: 14)

        summarySubtotalValue.text = "₹\(Int(orderTotal))"
        summarySubtotalValue.font = UIFont.systemFont(ofSize: 14, weight: .semibold)

        let negotiLabel = UILabel()
        negotiLabel.text = "Negotiation Discount"
        negotiLabel.font = UIFont.systemFont(ofSize: 14)

        let negotiValue = UILabel()
        negotiValue.text = "₹0"
        negotiValue.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        negotiValue.textColor = UIColor(red: 0.86, green: 0.33, blue: 0.33, alpha: 1.0)

        let divider = UIView()
        divider.backgroundColor = UIColor(white: 0.92, alpha: 1.0)
        divider.translatesAutoresizingMaskIntoConstraints = false

        let totalLabel = UILabel()
        totalLabel.text = "Total"
        totalLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        summaryTotalValue.text = "₹\(Int(orderTotal))"
        summaryTotalValue.font = UIFont.systemFont(ofSize: 16, weight: .bold)

        [subLabel, summarySubtotalValue, negotiLabel, negotiValue, divider, totalLabel, summaryTotalValue].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            summaryCard.addSubview($0)
        }

        NSLayoutConstraint.activate([
            summaryCard.topAnchor.constraint(equalTo: orderSummaryTitle.bottomAnchor, constant: 12),
            summaryCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            summaryCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            summaryCard.heightAnchor.constraint(equalToConstant: 160),

            subLabel.topAnchor.constraint(equalTo: summaryCard.topAnchor, constant: 18),
            subLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 16),

            summarySubtotalValue.centerYAnchor.constraint(equalTo: subLabel.centerYAnchor),
            summarySubtotalValue.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -16),

            negotiLabel.topAnchor.constraint(equalTo: subLabel.bottomAnchor, constant: 14),
            negotiLabel.leadingAnchor.constraint(equalTo: subLabel.leadingAnchor),

            negotiValue.centerYAnchor.constraint(equalTo: negotiLabel.centerYAnchor),
            negotiValue.trailingAnchor.constraint(equalTo: summarySubtotalValue.trailingAnchor),

            divider.topAnchor.constraint(equalTo: negotiLabel.bottomAnchor, constant: 16),
            divider.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 12),
            divider.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -12),
            divider.heightAnchor.constraint(equalToConstant: 1),

            totalLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 14),
            totalLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 16),

            summaryTotalValue.centerYAnchor.constraint(equalTo: totalLabel.centerYAnchor),
            summaryTotalValue.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Bottom Buttons
    private func setupBottomButtons() {
        bottomButtonsContainer.axis = .horizontal
        bottomButtonsContainer.spacing = 12
        bottomButtonsContainer.distribution = .fillEqually
        bottomButtonsContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomButtonsContainer)

        rateButton.setTitle("Rate Order", for: .normal)
        rateButton.setTitleColor(darkTeal, for: .normal)
        rateButton.layer.cornerRadius = 12
        rateButton.layer.borderWidth = 2
        rateButton.layer.borderColor = darkTeal.cgColor
        rateButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        rateButton.addTarget(self, action: #selector(rateTapped), for: .touchUpInside)

        helpButton.setTitle("Get Help", for: .normal)
        helpButton.setTitleColor(darkTeal, for: .normal)
        helpButton.layer.cornerRadius = 12
        helpButton.layer.borderWidth = 2
        helpButton.layer.borderColor = darkTeal.cgColor
        helpButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        helpButton.addTarget(self, action: #selector(helpTapped), for: .touchUpInside)

        bottomButtonsContainer.addArrangedSubview(rateButton)
        bottomButtonsContainer.addArrangedSubview(helpButton)

        NSLayoutConstraint.activate([
            bottomButtonsContainer.topAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: 18),
            bottomButtonsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bottomButtonsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bottomButtonsContainer.heightAnchor.constraint(equalToConstant: 54),

            contentView.bottomAnchor.constraint(equalTo: bottomButtonsContainer.bottomAnchor, constant: 24)
        ])
    }

    // MARK: - Actions
    @objc private func rateTapped() {
        print("Rate tapped")
    }

    @objc private func helpTapped() {
        print("Help tapped")
    }

    // FINAL → ALWAYS GO TO HOME TAB
    @objc private func backPressed() {
        navigationController?.popViewController(animated: true)

        // Normal case → replace root
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {

            let tab = MainTabBarController()
            tab.selectedIndex = 0

            window.rootViewController = tab
            window.makeKeyAndVisible()
            return
        }

        // Fallback
        let tab = MainTabBarController()
        tab.selectedIndex = 0
        tab.modalPresentationStyle = .fullScreen
        present(tab, animated: true)
    }
}
