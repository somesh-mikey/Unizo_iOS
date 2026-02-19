//
//  OrderDetailsViewController.swift
//  Unizo_iOS
//

import UIKit
import Supabase

class OrderDetailsViewController: UIViewController {

    // MARK: - Order Data (passed from OrderPlacedViewController)
    var orderId: UUID?
    var orderAddress: AddressDTO?
    var orderTotal: Double = 0
    var orderCreatedAt: String?  // ISO8601 timestamp
    var orderStatus: String = "pending"

    // MARK: - Fetched Data
    private var orderItems: [OrderItemDTO] = []
    private var handoffCode: String?
    private var orderBuyerId: UUID?
    private let orderRepository = OrderRepository()
    private let notificationRepository = NotificationRepository()
    private let chatRepository = ChatRepository()

    // MARK: - Role Detection
    private var currentUserId: UUID?
    private var currentUserIsSeller: Bool = false

    // MARK: - Colors
    private let bgColor = UIColor(red: 0.96, green: 0.97, blue: 1.00, alpha: 1.0)
    private let darkTeal = UIColor(red: 0.07, green: 0.33, blue: 0.42, alpha: 1.0)
    private let accentTeal = UIColor(red: 0.00, green: 0.62, blue: 0.71, alpha: 1.0)
    private let lightGrayText = UIColor(white: 0.55, alpha: 1.0)

    // MARK: - Top Bar
    private let topBar = UIView()
    private let backButton = UIButton(type: .system)
    private let navTitleLabel = UILabel()

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

    // MARK: - Handoff UI
    private let handoffCard = UIView()
    private let handoffCodeLabel = UILabel()
    private let handoffInstructionLabel = UILabel()
    private let codeTextField = UITextField()
    private let codeErrorLabel = UILabel()
    private let loadingSpinner = UIActivityIndicatorView(style: .medium)
    private var handoffCardHeightConstraint: NSLayoutConstraint?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor

        // Get current user ID for role detection
        currentUserId = AuthManager.shared.currentUserIdSync

        setupTopBar()
        setupScrollHierarchy()
        setupStatusCard()
        setupTimeline()
        setupItemsSection()
        setupDeliveryInfo()
        setupOrderSummary()
        setupHandoffCard()
        setupBottomButtons()
        setupKeyboardHandling()

        // Listen for realtime order status changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRealtimeOrderUpdate(_:)),
            name: .orderStatusDidChange,
            object: nil
        )

        // If we have minimal data (from notification), fetch full order details
        if orderAddress == nil && orderId != nil {
            fetchFullOrderDetails()
        } else {
            // Update UI with provided data
            updateUIWithOrderData()
            fetchOrderItems()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .orderStatusDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - Hide Nav + Tab Bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = true

        // Subscribe to realtime updates for this order
        if let id = orderId {
            Task {
                await OrderRealtimeManager.shared.subscribeToOrder(id)
            }
            // Also do a one-time refresh in case status changed while away
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

                    // Always update handoff code if present
                    if let code = order.handoff_code {
                        self.handoffCode = code
                    }
                    self.orderBuyerId = order.user_id
                    self.orderItems = order.items ?? self.orderItems
                    self.detectUserRole()

                    // Don't downgrade status (due to replication lag)
                    // Status hierarchy: pending < confirmed < shipped < delivered
                    let shouldUpdateStatus = self.shouldUpdateStatus(from: self.orderStatus, to: order.status)
                    
                    if shouldUpdateStatus {
                        print("🔄 Status changed from '\(self.orderStatus)' to '\(order.status)' - updating UI")
                        self.orderStatus = order.status
                        self.updateTimelineForStatus()
                    } else if self.orderStatus != order.status {
                        print("⚠️ Status update blocked: local='\(self.orderStatus)' is later than fetched='\(order.status)'")
                    } else {
                        print("🔄 Status unchanged: \(self.orderStatus)")
                    }

                    self.updateHandoffUI()
                }
            } catch {
                print("❌ Failed to refresh order status: \(error)")
            }
        }
    }

    /// Check if we should update from local status to fetched status
    /// Prevents downgrading status due to database replication lag
    private func shouldUpdateStatus(from local: String, to fetched: String) -> Bool {
        let statusHierarchy: [String] = [
            OrderStatus.pending.rawValue,      // 0
            OrderStatus.confirmed.rawValue,    // 1
            OrderStatus.shipped.rawValue,      // 2
            OrderStatus.delivered.rawValue,    // 3
            OrderStatus.cancelled.rawValue     // 4 (final state)
        ]
        
        guard let localIndex = statusHierarchy.firstIndex(of: local),
              let fetchedIndex = statusHierarchy.firstIndex(of: fetched) else {
            // If we can't find the status, default to updating
            return local != fetched
        }
        
        // Only update if fetched status is same or later in hierarchy
        // This prevents overwriting with stale data due to replication lag
        return fetchedIndex >= localIndex
    }

    // MARK: - Keyboard Handling
    private func setupKeyboardHandling() {
        // Text field delegates
        codeTextField.delegate = self
        
        // Keyboard notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        // Tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        var inset = scrollView.contentInset
        inset.bottom = keyboardHeight + 20
        
        UIView.animate(withDuration: 0.3) {
            self.scrollView.contentInset = inset
            self.scrollView.scrollIndicatorInsets = inset
        }
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.scrollView.contentInset = UIEdgeInsets.zero
            self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: false)
        dismissKeyboard()

        // Unsubscribe from realtime updates when leaving
        if let id = orderId {
            Task {
                await OrderRealtimeManager.shared.unsubscribeFromOrder(id)
            }
        }
    }

    // MARK: - Realtime Order Update Handler
    @objc private func handleRealtimeOrderUpdate(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let updatedOrderId = userInfo["orderId"] as? UUID,
              updatedOrderId == orderId,
              let newStatus = userInfo["newStatus"] as? String else {
            return
        }

        let newHandoffCode = userInfo["handoffCode"] as? String

        print("⚡ Realtime update: order \(updatedOrderId.uuidString.prefix(8)) → \(newStatus)")

        // Update local state and UI
        if self.orderStatus != newStatus {
            self.orderStatus = newStatus
            if let code = newHandoffCode {
                self.handoffCode = code
            }
            self.updateTimelineForStatus()
        }
        // Always refresh handoff UI (handoff code may have changed)
        if let code = newHandoffCode, code != self.handoffCode {
            self.handoffCode = code
        }
        self.updateHandoffUI()
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
                    self.handoffCode = order.handoff_code
                    self.orderBuyerId = order.user_id

                    // Detect if current user is the seller
                    self.detectUserRole()

                    // Update UI with real data
                    self.updateUIWithOrderData()
                    self.updateItemsUI()
                    self.updateTimelineForStatus()
                    self.updateHandoffUI()
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
                    self.detectUserRole()
                    self.updateItemsUI()
                    self.updateHandoffUI()
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

        let colourLabel = smallTeal(text: "Colour".localized)
        let sizeLabel = smallTeal(text: "Size".localized)
        let qtyLabel = smallTeal(text: "Quantity".localized)

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

        navTitleLabel.text = "Order Details".localized
        navTitleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        navTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        topBar.addSubview(backButton)
        topBar.addSubview(navTitleLabel)

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 56),

            backButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

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

        statusTitleLabel.text = "Order Confirmed".localized
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
        timelineLabel.text = "Order Timeline".localized
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
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Declined".localized, subtitle: orderTime, completed: false, isDeclined: true))
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Placed".localized, subtitle: orderTime, completed: true))

        case .delivered:
            // All 3 states completed
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Delivered".localized, subtitle: orderTime, completed: true))
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Confirmed".localized, subtitle: orderTime, completed: true))
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Placed".localized, subtitle: orderTime, completed: true))

        case .confirmed:
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Delivered".localized, subtitle: "Awaiting handoff".localized, completed: false))
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Confirmed".localized, subtitle: orderTime, completed: true))
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Placed".localized, subtitle: orderTime, completed: true))

        case .shipped:
            let deliverySubtitle = currentUserIsSeller ? "Enter handoff code".localized : "Share code with seller".localized
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Delivered".localized, subtitle: deliverySubtitle, completed: false))
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Confirmed".localized, subtitle: orderTime, completed: true))
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Placed".localized, subtitle: orderTime, completed: true))

        case .pending:
            // Order placed, awaiting seller confirmation
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Delivered".localized, subtitle: "Pending".localized, completed: false))
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Confirmed".localized, subtitle: "Awaiting seller".localized, completed: false))
            timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Placed".localized, subtitle: orderTime, completed: true))
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
            statusTitleLabel.text = "Order Declined".localized
            statusCircle.backgroundColor = .systemRed
            statusCheck.image = UIImage(systemName: "xmark")

        case .delivered:
            statusTitleLabel.text = "Order Delivered".localized
            statusCircle.backgroundColor = darkTeal
            statusCheck.image = UIImage(systemName: "checkmark")

        case .confirmed:
            statusTitleLabel.text = "Order Confirmed".localized
            statusCircle.backgroundColor = darkTeal
            statusCheck.image = UIImage(systemName: "checkmark")

        case .shipped:
            statusTitleLabel.text = "Ready for Handoff".localized
            statusCircle.backgroundColor = UIColor(red: 0.0, green: 0.62, blue: 0.71, alpha: 1.0)
            statusCheck.image = UIImage(systemName: "hand.raised.fill")

        case .pending:
            statusTitleLabel.text = "Order Placed".localized
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
        orderItemsTitle.text = "Order Items".localized
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
        loadingLabel.text = "Loading order items...".localized
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
        deliveryTitle.text = "Delivery Information".localized
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
        orderSummaryTitle.text = "Order Summary".localized
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
        subLabel.text = "Subtotal".localized
        subLabel.font = UIFont.systemFont(ofSize: 14)

        summarySubtotalValue.text = "₹\(Int(orderTotal))"
        summarySubtotalValue.font = UIFont.systemFont(ofSize: 14, weight: .semibold)

        let negotiLabel = UILabel()
        negotiLabel.text = "Negotiation Discount".localized
        negotiLabel.font = UIFont.systemFont(ofSize: 14)

        let negotiValue = UILabel()
        negotiValue.text = "₹0"
        negotiValue.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        negotiValue.textColor = UIColor(red: 0.86, green: 0.33, blue: 0.33, alpha: 1.0)

        let divider = UIView()
        divider.backgroundColor = UIColor(white: 0.92, alpha: 1.0)
        divider.translatesAutoresizingMaskIntoConstraints = false

        let totalLabel = UILabel()
        totalLabel.text = "Total".localized
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

    // MARK: - Handoff Card (hidden by default, shown based on status + role)
    private var instructionTopToBuyerCode: NSLayoutConstraint?
    private var instructionTopToSellerField: NSLayoutConstraint?

    private func setupHandoffCard() {
        handoffCard.translatesAutoresizingMaskIntoConstraints = false
        handoffCard.backgroundColor = .white
        handoffCard.layer.cornerRadius = 14
        handoffCard.clipsToBounds = true
        handoffCard.isHidden = true
        contentView.addSubview(handoffCard)

        // Large code display (for buyer)
        handoffCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        handoffCodeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 36, weight: .bold)
        handoffCodeLabel.textAlignment = .center
        handoffCodeLabel.textColor = darkTeal
        handoffCodeLabel.isHidden = true
        handoffCard.addSubview(handoffCodeLabel)

        // Code input field (for seller)
        codeTextField.translatesAutoresizingMaskIntoConstraints = false
        codeTextField.placeholder = "Enter 6-digit code".localized
        codeTextField.font = UIFont.monospacedDigitSystemFont(ofSize: 24, weight: .semibold)
        codeTextField.textAlignment = .center
        codeTextField.keyboardType = .numberPad
        codeTextField.layer.cornerRadius = 12
        codeTextField.layer.borderWidth = 2
        codeTextField.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).cgColor
        codeTextField.isHidden = true
        handoffCard.addSubview(codeTextField)

        // Instruction text
        handoffInstructionLabel.translatesAutoresizingMaskIntoConstraints = false
        handoffInstructionLabel.font = .systemFont(ofSize: 14)
        handoffInstructionLabel.textColor = .gray
        handoffInstructionLabel.textAlignment = .center
        handoffInstructionLabel.numberOfLines = 0
        handoffInstructionLabel.isHidden = true
        handoffCard.addSubview(handoffInstructionLabel)

        // Error label
        codeErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        codeErrorLabel.font = .systemFont(ofSize: 13)
        codeErrorLabel.textColor = .systemRed
        codeErrorLabel.textAlignment = .center
        codeErrorLabel.isHidden = true
        handoffCard.addSubview(codeErrorLabel)

        // Loading spinner
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        loadingSpinner.hidesWhenStopped = true
        handoffCard.addSubview(loadingSpinner)

        // Two alternate top constraints for instruction label
        instructionTopToBuyerCode = handoffInstructionLabel.topAnchor.constraint(equalTo: handoffCodeLabel.bottomAnchor, constant: 10)
        instructionTopToSellerField = handoffInstructionLabel.topAnchor.constraint(equalTo: codeTextField.bottomAnchor, constant: 10)

        NSLayoutConstraint.activate([
            handoffCard.topAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: 18),
            handoffCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            handoffCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Buyer code label
            handoffCodeLabel.topAnchor.constraint(equalTo: handoffCard.topAnchor, constant: 20),
            handoffCodeLabel.leadingAnchor.constraint(equalTo: handoffCard.leadingAnchor, constant: 16),
            handoffCodeLabel.trailingAnchor.constraint(equalTo: handoffCard.trailingAnchor, constant: -16),

            // Seller code text field
            codeTextField.topAnchor.constraint(equalTo: handoffCard.topAnchor, constant: 20),
            codeTextField.leadingAnchor.constraint(equalTo: handoffCard.leadingAnchor, constant: 32),
            codeTextField.trailingAnchor.constraint(equalTo: handoffCard.trailingAnchor, constant: -32),
            codeTextField.heightAnchor.constraint(equalToConstant: 52),

            // Instruction label (horizontal only; top set dynamically)
            handoffInstructionLabel.leadingAnchor.constraint(equalTo: handoffCard.leadingAnchor, constant: 16),
            handoffInstructionLabel.trailingAnchor.constraint(equalTo: handoffCard.trailingAnchor, constant: -16),
            handoffInstructionLabel.bottomAnchor.constraint(equalTo: handoffCard.bottomAnchor, constant: -20),

            // Error label
            codeErrorLabel.topAnchor.constraint(equalTo: codeTextField.bottomAnchor, constant: 6),
            codeErrorLabel.leadingAnchor.constraint(equalTo: handoffCard.leadingAnchor, constant: 16),
            codeErrorLabel.trailingAnchor.constraint(equalTo: handoffCard.trailingAnchor, constant: -16),

            // Loading spinner
            loadingSpinner.centerXAnchor.constraint(equalTo: handoffCard.centerXAnchor),
            loadingSpinner.topAnchor.constraint(equalTo: handoffInstructionLabel.bottomAnchor, constant: 8)
        ])

        // Zero-height constraint for when card is hidden
        handoffCardHeightConstraint = handoffCard.heightAnchor.constraint(equalToConstant: 0)
        handoffCardHeightConstraint?.isActive = true
    }

    // MARK: - Bottom Buttons
    private func setupBottomButtons() {
        bottomButtonsContainer.axis = .horizontal
        bottomButtonsContainer.spacing = 12
        bottomButtonsContainer.distribution = .fillEqually
        bottomButtonsContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomButtonsContainer)

        rateButton.setTitle("Rate Order".localized, for: .normal)
        rateButton.setTitleColor(darkTeal, for: .normal)
        rateButton.layer.cornerRadius = 12
        rateButton.layer.borderWidth = 2
        rateButton.layer.borderColor = darkTeal.cgColor
        rateButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        rateButton.addTarget(self, action: #selector(rateTapped), for: .touchUpInside)

        helpButton.setTitle("Chat".localized, for: .normal)
        helpButton.setTitleColor(darkTeal, for: .normal)
        helpButton.layer.cornerRadius = 12
        helpButton.layer.borderWidth = 2
        helpButton.layer.borderColor = darkTeal.cgColor
        helpButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        helpButton.addTarget(self, action: #selector(chatTapped), for: .touchUpInside)

        bottomButtonsContainer.addArrangedSubview(rateButton)
        bottomButtonsContainer.addArrangedSubview(helpButton)

        NSLayoutConstraint.activate([
            bottomButtonsContainer.topAnchor.constraint(equalTo: handoffCard.bottomAnchor, constant: 18),
            bottomButtonsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bottomButtonsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bottomButtonsContainer.heightAnchor.constraint(equalToConstant: 54),

            contentView.bottomAnchor.constraint(equalTo: bottomButtonsContainer.bottomAnchor, constant: 24)
        ])
    }

    // MARK: - Detect User Role
    private func detectUserRole() {
        guard let userId = currentUserId else {
            currentUserIsSeller = false
            return
        }

        // Check if current user is the seller of any item in this order
        for item in orderItems {
            if let sellerId = item.product?.seller?.id, sellerId == userId {
                currentUserIsSeller = true
                return
            }
        }
        currentUserIsSeller = false
    }

    // MARK: - Update Handoff UI
    private func hideHandoffCard() {
        handoffCard.isHidden = true
        handoffCardHeightConstraint?.isActive = true
        handoffCodeLabel.isHidden = true
        codeTextField.isHidden = true
        handoffInstructionLabel.isHidden = true
        codeErrorLabel.isHidden = true
        instructionTopToBuyerCode?.isActive = false
        instructionTopToSellerField?.isActive = false
    }

    private func resetHelpButton() {
        helpButton.setTitle("Chat".localized, for: .normal)
        helpButton.setTitleColor(darkTeal, for: .normal)
        helpButton.backgroundColor = .clear
        helpButton.layer.borderWidth = 2
        helpButton.layer.borderColor = darkTeal.cgColor
        helpButton.removeTarget(nil, action: nil, for: .touchUpInside)
        helpButton.addTarget(self, action: #selector(chatTapped), for: .touchUpInside)
    }

    private func updateHandoffUI() {
        let status = OrderStatus(rawValue: orderStatus) ?? .pending

        switch status {
        case .confirmed where currentUserIsSeller:
            // Seller sees "Get Code" button replacing "Chat"
            hideHandoffCard()
            helpButton.setTitle("Get Code".localized, for: .normal)
            helpButton.setTitleColor(.white, for: .normal)
            helpButton.backgroundColor = darkTeal
            helpButton.layer.borderWidth = 0
            helpButton.removeTarget(nil, action: nil, for: .touchUpInside)
            helpButton.addTarget(self, action: #selector(readyToMeetTapped), for: .touchUpInside)
            rateButton.isEnabled = false
            rateButton.alpha = 0.4

        case .shipped where !currentUserIsSeller:
            // Buyer sees the handoff code
            handoffCard.isHidden = false
            handoffCardHeightConstraint?.isActive = false

            // Show buyer code, hide seller field
            handoffCodeLabel.isHidden = false
            codeTextField.isHidden = true
            codeErrorLabel.isHidden = true
            handoffInstructionLabel.isHidden = false

            // Anchor instruction below code label
            instructionTopToSellerField?.isActive = false
            instructionTopToBuyerCode?.isActive = true

            let codeText = handoffCode ?? "------"
            handoffCodeLabel.attributedText = NSAttributedString(
                string: codeText,
                attributes: [.kern: 8]
            )
            handoffInstructionLabel.text = "Show this code to the seller when you meet to confirm delivery.".localized

            resetHelpButton()
            rateButton.isEnabled = false
            rateButton.alpha = 0.4

        case .shipped where currentUserIsSeller:
            // Seller sees code input
            handoffCard.isHidden = false
            handoffCardHeightConstraint?.isActive = false

            // Show seller field, hide buyer code
            handoffCodeLabel.isHidden = true
            codeTextField.isHidden = false
            handoffInstructionLabel.isHidden = false
            codeErrorLabel.isHidden = true

            // Anchor instruction below text field
            instructionTopToBuyerCode?.isActive = false
            instructionTopToSellerField?.isActive = true

            handoffInstructionLabel.text = "Enter the code the buyer shows you to confirm delivery.".localized

            helpButton.setTitle("Verify Code".localized, for: .normal)
            helpButton.setTitleColor(.white, for: .normal)
            helpButton.backgroundColor = darkTeal
            helpButton.layer.borderWidth = 0
            helpButton.removeTarget(nil, action: nil, for: .touchUpInside)
            helpButton.addTarget(self, action: #selector(verifyCodeTapped), for: .touchUpInside)
            rateButton.isEnabled = false
            rateButton.alpha = 0.4

        case .delivered:
            // Both see original buttons
            hideHandoffCard()
            resetHelpButton()
            rateButton.isEnabled = true
            rateButton.alpha = 1.0

        default:
            // pending, cancelled, or confirmed (buyer) -- keep defaults
            hideHandoffCard()
            resetHelpButton()
            rateButton.isEnabled = true
            rateButton.alpha = 1.0
        }

        view.layoutIfNeeded()
    }

    // MARK: - Actions
    @objc private func rateTapped() {
        let ratingVC = OrderRatingViewController()
        ratingVC.orderId = self.orderId
        ratingVC.currentUserId = self.currentUserId
        ratingVC.ratedUserId = self.currentUserIsSeller ? self.orderBuyerId : (self.orderItems.first?.product?.seller?.id)
        ratingVC.orderRepository = self.orderRepository
        ratingVC.onRatingSuccess = { [weak self] in
            // Dismiss rating and refresh button state
            self?.rateButton.isEnabled = false
            self?.rateButton.alpha = 0.5
            self?.rateButton.setTitle("Rated".localized, for: .normal)
        }
        
        let navController = UINavigationController(rootViewController: ratingVC)
        navController.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }
        }
        self.present(navController, animated: true)
    }

    @objc private func chatTapped() {
        // Get the first order item to initiate chat
        guard let firstItem = orderItems.first,
              let product = firstItem.product else {
            print("No product available for chat")
            return
        }

        let productId = product.id

        // Determine which user to chat with based on current user's role
        let otherUserId: UUID?
        if currentUserIsSeller {
            // If current user is seller, chat with buyer (who placed the order)
            otherUserId = orderBuyerId
        } else {
            // If current user is buyer, chat with seller
            otherUserId = product.seller?.id
        }

        guard let otherUserId = otherUserId else {
            print("Unable to determine chat partner")
            return
        }

        // Disable button to prevent multiple taps
        helpButton.isEnabled = false

        Task {
            do {
                // Get or create conversation
                let conversation = try await chatRepository.getOrCreateConversation(
                    productId: productId,
                    sellerId: product.seller?.id ?? otherUserId
                )

                // Navigate to Chat tab
                await navigateToChatConversation(conversationId: conversation.id)

                // Re-enable button
                DispatchQueue.main.async {
                    self.helpButton.isEnabled = true
                }
            } catch {
                print("Error initiating chat: \(error)")
                DispatchQueue.main.async {
                    self.helpButton.isEnabled = true
                    // Optionally show error alert
                    let alert = UIAlertController(
                        title: "Chat Error".localized,
                        message: "Unable to start conversation. Please try again.".localized,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    private func navigateToChatConversation(conversationId: UUID) async {
        DispatchQueue.main.async {
            // Get the main tab bar controller
            guard let tabBarController = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?
                .windows
                .first?
                .rootViewController as? MainTabBarController else {
                return
            }

            // Set Chat tab (index 1) as active
            tabBarController.selectedIndex = 1

            // Get the Chat navigation controller
            guard let navController = tabBarController.viewControllers?[1] as? UINavigationController,
                  let chatVC = navController.viewControllers.first as? ChatViewController else {
                return
            }

            // Wait for ChatViewController to load conversations
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Find the conversation in the chat list and navigate to detail
                chatVC.navigateToConversation(id: conversationId)
            }
        }
    }

    // MARK: - Get Code (Seller generates handoff code)
    @objc private func readyToMeetTapped() {
        guard let orderId = orderId else { return }

        helpButton.isEnabled = false
        loadingSpinner.startAnimating()

        // Generate 6-digit code
        let code = String(format: "%06d", Int.random(in: 0...999999))

        Task {
            do {
                // Save to DB
                try await orderRepository.markReadyForHandoff(orderId: orderId, handoffCode: code)

                // Send notification to buyer
                if let currentUserId = currentUserId {
                    let sellerName = try await fetchSellerDisplayName()
                    let order = try await orderRepository.fetchOrder(id: orderId)

                    let deeplinkPayload = DeeplinkPayload(
                        route: "order_details",
                        orderId: orderId,
                        sellerId: currentUserId
                    )

                    try await notificationRepository.createNotification(
                        recipientId: order.user_id,
                        senderId: currentUserId,
                        orderId: orderId,
                        type: .orderShipped,
                        title: sellerName,
                        message: "is ready to hand off your order. Your handoff code: \(code)",
                        deeplinkPayload: deeplinkPayload
                    )
                }

                await MainActor.run {
                    self.loadingSpinner.stopAnimating()
                    self.helpButton.isEnabled = true
                    self.orderStatus = OrderStatus.shipped.rawValue
                    self.handoffCode = code
                    self.updateTimelineForStatus()
                    self.updateHandoffUI()
                }
            } catch {
                print("❌ Failed to mark ready for handoff: \(error)")
                await MainActor.run {
                    self.loadingSpinner.stopAnimating()
                    self.helpButton.isEnabled = true
                }
            }
        }
    }

    // MARK: - Verify Handoff Code (Seller enters buyer's code)
    @objc private func verifyCodeTapped() {
        guard let orderId = orderId else { return }
        let enteredCode = codeTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""

        guard enteredCode.count == 6 else {
            codeErrorLabel.text = "Please enter the full 6-digit code.".localized
            codeErrorLabel.isHidden = false
            return
        }

        codeErrorLabel.isHidden = true
        helpButton.isEnabled = false
        loadingSpinner.startAnimating()

        Task {
            do {
                let isValid = try await orderRepository.verifyHandoffCode(orderId: orderId, enteredCode: enteredCode)

                if isValid {
                    // Send delivery notifications to both parties
                    if let currentUserId = currentUserId {
                        let sellerName = try await fetchSellerDisplayName()
                        let order = try await orderRepository.fetchOrder(id: orderId)
                        let buyerName = try await fetchBuyerName(buyerId: order.user_id)

                        let deeplinkPayload = DeeplinkPayload(
                            route: "order_details",
                            orderId: orderId,
                            sellerId: currentUserId
                        )

                        // Notify buyer
                        try await notificationRepository.createNotification(
                            recipientId: order.user_id,
                            senderId: currentUserId,
                            orderId: orderId,
                            type: .orderDelivered,
                            title: sellerName,
                            message: "has delivered your order. Enjoy!",
                            deeplinkPayload: deeplinkPayload
                        )

                        // Notify seller (self)
                        try await notificationRepository.createNotification(
                            recipientId: currentUserId,
                            senderId: order.user_id,
                            orderId: orderId,
                            type: .orderDelivered,
                            title: buyerName,
                            message: "confirmed receiving the order. Delivery complete!",
                            deeplinkPayload: deeplinkPayload
                        )
                    }

                    await MainActor.run {
                        self.loadingSpinner.stopAnimating()
                        self.helpButton.isEnabled = true
                        self.orderStatus = OrderStatus.delivered.rawValue
                        self.updateTimelineForStatus()
                        self.updateHandoffUI()
                        self.codeTextField.resignFirstResponder()
                    }
                } else {
                    await MainActor.run {
                        self.loadingSpinner.stopAnimating()
                        self.helpButton.isEnabled = true
                        self.codeErrorLabel.text = "Incorrect code. Please try again.".localized
                        self.codeErrorLabel.isHidden = false
                        self.codeTextField.layer.borderColor = UIColor.systemRed.cgColor
                    }
                }
            } catch {
                print("❌ Failed to verify handoff code: \(error)")
                await MainActor.run {
                    self.loadingSpinner.stopAnimating()
                    self.helpButton.isEnabled = true
                    self.codeErrorLabel.text = "Something went wrong. Please try again.".localized
                    self.codeErrorLabel.isHidden = false
                }
            }
        }
    }

    // MARK: - Helper: Fetch Seller Display Name
    private func fetchSellerDisplayName() async throws -> String {
        guard let userId = currentUserId else { return "Seller" }

        struct UserName: Codable {
            let first_name: String?
            let last_name: String?
        }

        let user: UserName = try await SupabaseManager.shared.client
            .from("users")
            .select("first_name, last_name")
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value

        let name = [user.first_name, user.last_name]
            .compactMap { $0 }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? "Seller" : name
    }

    // MARK: - Helper: Fetch Buyer Name
    private func fetchBuyerName(buyerId: UUID) async throws -> String {
        struct UserName: Codable {
            let first_name: String?
            let last_name: String?
        }

        let user: UserName = try await SupabaseManager.shared.client
            .from("users")
            .select("first_name, last_name")
            .eq("id", value: buyerId.uuidString)
            .single()
            .execute()
            .value

        let name = [user.first_name, user.last_name]
            .compactMap { $0 }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? "Buyer" : name
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

// MARK: - UITextFieldDelegate
extension OrderDetailsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == codeTextField else { return true }
        
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        let allowedLength = 6
        
        // Only allow digits and limit to 6 characters
        let isNumeric = string.isEmpty || string.allSatisfy { $0.isNumber }
        let isWithinLimit = currentText.count <= allowedLength
        
        return isNumeric && isWithinLimit
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == codeTextField {
            codeTextField.resignFirstResponder()
            return true
        }
        return false
    }
}
