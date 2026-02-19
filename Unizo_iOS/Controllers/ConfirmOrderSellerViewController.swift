//
//  ConfirmOrderViewSellerController.swift
//  Unizo_iOS
//
//  Created by Somesh on 21/11/25.
//

import UIKit
import Supabase

class ConfirmOrderSellerViewController: UIViewController {

    // MARK: - Order Data (passed from notification)
    var orderId: UUID?

    // MARK: - Fetched Data
    private let orderRepository = OrderRepository()
    private let notificationRepository = NotificationRepository()
    private let chatRepository = ChatRepository()
    private let productRepository = ProductRepository(supabase: supabase)
    private var orderDetails: OrderDTO?
    private var sellerItems: [OrderItemDTO] = []
    private var buyerAddress: AddressDTO?
    private var isLoading = false

    // MARK: - Loading Indicator
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - Toolbar
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
        lbl.text = "Confirm Order".localized
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        lbl.textAlignment = .center
        return lbl
    }()

    private let toolbarBackground: UIView = {
        let v = UIView()
        v.backgroundColor = .systemGray6      // match grey background
        return v
    }()



    // MARK: - Product Section

    private let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "photo")  // Placeholder image
        iv.tintColor = .lightGray
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = .white
        iv.layer.shadowColor = UIColor.black.cgColor
        iv.layer.shadowOpacity = 0.1
        iv.layer.shadowRadius = 8
        iv.layer.shadowOffset = CGSize(width: 0, height: 2)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let categoryLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Loading...".localized
        lbl.font = .systemFont(ofSize: 15)
        lbl.textColor = .systemGray
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // Product title and price
    private let titleText: UILabel = {
        let lbl = UILabel()
        lbl.text = "Loading...".localized
        lbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let priceLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "₹—"
        lbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()


    // MARK: - Product Properties (Aligned)

    private func makeTitleLabel(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: 16)
        lbl.textColor = .systemGray
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }

    private func makeValueLabel(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: 16, weight: .medium)
        lbl.textAlignment = .right
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }

    private lazy var colourTitleLabel = makeTitleLabel("Colour".localized)
    private lazy var sizeTitleLabel = makeTitleLabel("Size".localized)
    private lazy var conditionTitleLabel = makeTitleLabel("Condition".localized)

    private lazy var colourValueLabel = makeValueLabel("—")
    private lazy var sizeValueLabel = makeValueLabel("—")
    private lazy var conditionValueLabel = makeValueLabel("—")


    // MARK: - Buyer Card

    private let buyerCard: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.2)
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let buyerTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Buyer".localized
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let buyerNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Loading...".localized
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let buyerAddressLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Loading address...".localized
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = .systemGray
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let qtyTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Qty".localized
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let qtyValueLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "1"
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()


    // MARK: - Chat Button
    private let chatButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Chat with Buyer".localized, for: .normal)
        btn.backgroundColor = .white
        btn.setTitleColor(UIColor(red: 0.02, green: 0.27, blue: 0.37, alpha: 1.0), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.layer.cornerRadius = 12
        btn.layer.borderWidth = 2
        btn.layer.borderColor = UIColor(red: 0.02, green: 0.27, blue: 0.37, alpha: 1.0).cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()


    // MARK: - Bottom Buttons (now in contentView)
    private let rejectButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Decline".localized, for: .normal)
        btn.backgroundColor = UIColor(red: 0.95, green: 0.45, blue: 0.45, alpha: 1.0) // Softer red
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.layer.cornerRadius = 28
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let acceptButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Accept".localized, for: .normal)
        btn.backgroundColor = UIColor(red: 0.02, green: 0.27, blue: 0.37, alpha: 1.0) // #04445F
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.layer.cornerRadius = 28
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLoadingIndicator()
        self.title = "Confirm Order".localized
        navigationItem.backButtonTitle = ""
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            image: UIImage(systemName: "heart"),
//            style: .plain,
//            target: self,
//            action: #selector(heartTapped)
//        )
        rejectButton.addTarget(self, action: #selector(openRejectedPage), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(openAcceptedPage), for: .touchUpInside)
        chatButton.addTarget(self, action: #selector(chatTapped), for: .touchUpInside)

        // Load real order data if orderId is provided
        if let orderId = orderId {
            loadOrderDetails(orderId: orderId)
        }
    }

    // MARK: - Setup Loading Indicator
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Load Order Details
    private func loadOrderDetails(orderId: UUID) {
        guard !isLoading else { return }
        isLoading = true
        loadingIndicator.startAnimating()

        Task {
            do {
                // Fetch full order with items and address
                let order = try await orderRepository.fetchOrderWithDetails(id: orderId)
                self.orderDetails = order
                self.buyerAddress = order.address

                // Get current seller ID
                guard let currentSellerId = await AuthManager.shared.currentUserId else {
                    await MainActor.run {
                        self.isLoading = false
                        self.loadingIndicator.stopAnimating()
                        self.showErrorAlert(message: "Not authenticated".localized)
                    }
                    return
                }

                // Filter items for THIS seller only
                self.sellerItems = order.items?.filter { item in
                    item.product?.seller?.id == currentSellerId
                } ?? []

                await MainActor.run {
                    self.isLoading = false
                    self.loadingIndicator.stopAnimating()
                    self.updateUIWithOrderData()
                }
            } catch {
                print("Failed to load order: \(error)")
                await MainActor.run {
                    self.isLoading = false
                    self.loadingIndicator.stopAnimating()
                    self.showErrorAlert(message: "Failed to load order details".localized)
                }
            }
        }
    }

    // MARK: - Update UI with Real Data
    private func updateUIWithOrderData() {
        guard let order = orderDetails else { return }

        // Update buyer info
        if let address = buyerAddress {
            buyerNameLabel.text = address.name
            buyerAddressLabel.text = "\(address.line1), \(address.city), \(address.state) \(address.postal_code)"
        }

        // Display first seller item (or summary if multiple)
        if let firstItem = sellerItems.first, let product = firstItem.product {
            titleText.text = product.title
            priceLabel.text = "₹\(Int(firstItem.price_at_purchase))"
            categoryLabel.text = product.category ?? "General".localized
            colourValueLabel.text = firstItem.colour ?? "-"
            sizeValueLabel.text = firstItem.size ?? "-"
            conditionValueLabel.text = product.condition ?? "-"

            // Load product image
            if let imageURL = product.imageUrl, !imageURL.isEmpty {
                productImageView.loadImage(from: imageURL)
            }

            // Show quantity
            if sellerItems.count == 1 {
                qtyTitleLabel.text = "Qty".localized
                qtyValueLabel.text = "\(firstItem.quantity)"
            } else {
                let totalQty = sellerItems.reduce(0) { $0 + $1.quantity }
                qtyTitleLabel.text = "Items".localized
                qtyValueLabel.text = "\(totalQty)"
            }
        }
    }

    // MARK: - Show Error Alert
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error".localized, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
        present(alert, animated: true)
    }

    // MARK: - Get Seller Display Name
    private func getSellerDisplayName() async -> String {
        // Try to get seller name from the product's seller info
        if let seller = sellerItems.first?.product?.seller {
            let firstName = seller.first_name ?? ""
            let lastName = seller.last_name ?? ""
            let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
            if !fullName.isEmpty {
                return fullName
            }
            if let email = seller.email, !email.isEmpty {
                return email.components(separatedBy: "@").first ?? "Seller".localized
            }
        }
        return "Seller".localized
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = false
    }
}


extension ConfirmOrderSellerViewController {

    func setupUI() {
        view.backgroundColor = UIColor.systemGray6

        // MARK: - ScrollView Setup
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Start scroll below toolbar (64pt from safe area top)
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 64),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
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

        // Top toolbar (keeps it outside scroll)
        view.addSubview(toolbarBackground)
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        toolbarBackground.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            toolbarBackground.topAnchor.constraint(equalTo: view.topAnchor),
            toolbarBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbarBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // bottom anchored to backButton so it fits tool area
            toolbarBackground.bottomAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 10),

            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
        ])


        // MARK: - Scroll Items
        let scrollItems: [UIView] = [
            categoryLabel,
            productImageView,
            titleText,
            priceLabel
        ]

        scrollItems.forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }


        // MARK: - Product Layout (LARGER IMAGE with proper spacing from top)
        NSLayoutConstraint.activate([
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            productImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            productImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7),
            productImageView.heightAnchor.constraint(equalTo: productImageView.widthAnchor, multiplier: 1.0),

            categoryLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 20),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            titleText.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 6),
            titleText.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            priceLabel.centerYAnchor.constraint(equalTo: titleText.centerYAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])


        // MARK: - Property Rows
        let colourRow = UIStackView(arrangedSubviews: [colourTitleLabel, colourValueLabel])
        let sizeRow = UIStackView(arrangedSubviews: [sizeTitleLabel, sizeValueLabel])
        let conditionRow = UIStackView(arrangedSubviews: [conditionTitleLabel, conditionValueLabel])

        [colourRow, sizeRow, conditionRow].forEach {
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let detailsStack = UIStackView(arrangedSubviews: [colourRow, sizeRow, conditionRow])
        detailsStack.axis = .vertical
        detailsStack.spacing = 10
        detailsStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(detailsStack)

        NSLayoutConstraint.activate([
            detailsStack.topAnchor.constraint(equalTo: titleText.bottomAnchor, constant: 16),
            detailsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            detailsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])


        // MARK: - Buyer Card
        contentView.addSubview(buyerCard)

        let buyerStack = UIStackView(arrangedSubviews: [buyerTitleLabel, buyerNameLabel, buyerAddressLabel])
        buyerStack.axis = .vertical
        buyerStack.spacing = 2
        buyerStack.translatesAutoresizingMaskIntoConstraints = false

        let qtyStack = UIStackView(arrangedSubviews: [qtyTitleLabel, qtyValueLabel])
        qtyStack.axis = .vertical
        qtyStack.spacing = 2
        qtyStack.alignment = .center
        qtyStack.translatesAutoresizingMaskIntoConstraints = false

        buyerCard.addSubview(buyerStack)
        buyerCard.addSubview(qtyStack)

        NSLayoutConstraint.activate([
            buyerCard.topAnchor.constraint(equalTo: detailsStack.bottomAnchor, constant: 20),
            buyerCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buyerCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            buyerStack.topAnchor.constraint(equalTo: buyerCard.topAnchor, constant: 16),
            buyerStack.leadingAnchor.constraint(equalTo: buyerCard.leadingAnchor, constant: 16),
            buyerStack.trailingAnchor.constraint(lessThanOrEqualTo: qtyStack.leadingAnchor, constant: -12),
            buyerStack.bottomAnchor.constraint(equalTo: buyerCard.bottomAnchor, constant: -16),

            qtyStack.centerYAnchor.constraint(equalTo: buyerCard.centerYAnchor),
            qtyStack.trailingAnchor.constraint(equalTo: buyerCard.trailingAnchor, constant: -20),
            qtyStack.widthAnchor.constraint(equalToConstant: 50)
        ])


        // MARK: - Chat Button
        contentView.addSubview(chatButton)

        NSLayoutConstraint.activate([
            chatButton.topAnchor.constraint(equalTo: buyerCard.bottomAnchor, constant: 24),
            chatButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            chatButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            chatButton.heightAnchor.constraint(equalToConstant: 50)
        ])


        // MARK: - Bottom Buttons (inside contentView, so they scroll)
        contentView.addSubview(rejectButton)
        contentView.addSubview(acceptButton)

        
        rejectButton.translatesAutoresizingMaskIntoConstraints = false
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // reject (left) - BIGGER BUTTONS
            rejectButton.topAnchor.constraint(equalTo: chatButton.bottomAnchor, constant: 24),
            rejectButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            rejectButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.42),
            rejectButton.heightAnchor.constraint(equalToConstant: 56),

            // accept (right) - BIGGER BUTTONS
            acceptButton.topAnchor.constraint(equalTo: rejectButton.topAnchor),
            acceptButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            acceptButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.42),
            acceptButton.heightAnchor.constraint(equalToConstant: 56),

            // bottom anchor so contentView has intrinsic height for scrolling
            acceptButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])

        // optional: add actions
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        rejectButton.addTarget(self, action: #selector(didTapReject), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(didTapAccept), for: .touchUpInside)
    }
}


// MARK: - Actions
private extension ConfirmOrderSellerViewController {
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc func didTapReject() {
        // Handled by openRejectedPage
    }

    @objc func didTapAccept() {
        // Handled by openAcceptedPage
    }

    @objc private func openAcceptedPage() {
        guard let orderId = orderId else {
            // Fallback for hardcoded demo
            let vc = OrderAcceptedViewController()
            if let nav = navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
            return
        }

        // Disable buttons while processing
        acceptButton.isEnabled = false
        rejectButton.isEnabled = false
        loadingIndicator.startAnimating()

        Task {
            do {
                print("🛒 Seller accepting order: \(orderId.uuidString)")

                // Update order status to confirmed
                try await orderRepository.updateOrderStatus(orderId: orderId, status: .confirmed)

                print("✅ Order status update completed")

                // Mark all seller's items in this order as sold
                for item in sellerItems {
                    if let productId = item.product?.id {
                        do {
                            try await productRepository.markProductAsSold(
                                productId: productId,
                                quantitySold: item.quantity
                            )
                            print("✅ Product \(productId) marked as sold (qty: \(item.quantity))")
                        } catch {
                            print("⚠️ Failed to mark product \(productId) as sold: \(error)")
                            // Continue with other items even if one fails
                        }
                    }
                }

                // Notify the buyer that their order was accepted
                if let order = orderDetails,
                   let currentSellerId = await AuthManager.shared.currentUserId {

                    // Get seller name for notification
                    let sellerName = await getSellerDisplayName()

                    // Get product name for message
                    let productName = sellerItems.first?.product?.title ?? "your item".localized

                    // Create notification for buyer
                    let deeplinkPayload = DeeplinkPayload(
                        route: "order_details",
                        orderId: orderId,
                        sellerId: currentSellerId
                    )

                    try await notificationRepository.createNotification(
                        recipientId: order.user_id,  // Buyer receives
                        senderId: currentSellerId,    // Seller triggered
                        orderId: orderId,
                        type: .orderAccepted,
                        title: sellerName,
                        message: "accepted your order for".localized + " \(productName).",
                        deeplinkPayload: deeplinkPayload
                    )
                }

                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    let vc = OrderAcceptedViewController()
                    vc.orderId = orderId  // Pass orderId for navigation to OrderDetailsVC
                    vc.buyerName = self.buyerAddress?.name  // Pass buyer name for display
                    if let nav = self.navigationController {
                        nav.pushViewController(vc, animated: true)
                    } else {
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                    }
                }
            } catch {
                print("Failed to accept order: \(error)")
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.acceptButton.isEnabled = true
                    self.rejectButton.isEnabled = true
                    self.showErrorAlert(message: "Failed to accept order".localized)
                }
            }
        }
    }

    @objc private func openRejectedPage() {
        guard let orderId = orderId else {
            // Fallback for hardcoded demo
            let vc = OrderRejectedViewController()
            if let nav = navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
            return
        }

        // Disable buttons while processing
        acceptButton.isEnabled = false
        rejectButton.isEnabled = false
        loadingIndicator.startAnimating()

        Task {
            do {
                // Update order status to cancelled
                try await orderRepository.updateOrderStatus(orderId: orderId, status: .cancelled)

                // Notify the buyer that their order was rejected
                if let order = orderDetails,
                   let currentSellerId = await AuthManager.shared.currentUserId {

                    // Get seller name for notification
                    let sellerName = await getSellerDisplayName()

                    // Get product name for message
                    let productName = sellerItems.first?.product?.title ?? "your item".localized

                    // Create notification for buyer
                    let deeplinkPayload = DeeplinkPayload(
                        route: "order_details",
                        orderId: orderId,
                        sellerId: currentSellerId
                    )

                    try await notificationRepository.createNotification(
                        recipientId: order.user_id,  // Buyer receives
                        senderId: currentSellerId,    // Seller triggered
                        orderId: orderId,
                        type: .orderRejected,
                        title: sellerName,
                        message: "rejected your order for".localized + " \(productName).",
                        deeplinkPayload: deeplinkPayload
                    )
                }

                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    let vc = OrderRejectedViewController()
                    vc.buyerName = self.buyerAddress?.name  // Pass buyer name for display
                    if let nav = self.navigationController {
                        nav.pushViewController(vc, animated: true)
                    } else {
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                    }
                }
            } catch {
                print("Failed to reject order: \(error)")
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.acceptButton.isEnabled = true
                    self.rejectButton.isEnabled = true
                    self.showErrorAlert(message: "Failed to reject order".localized)
                }
            }
        }
    }
}


// MARK: - Chat
extension ConfirmOrderSellerViewController {
    @objc private func chatTapped() {
        // Get the first order item to initiate chat
        guard let firstItem = orderDetails?.items?.first,
              let product = firstItem.product else {
            self.showErrorAlert(message: "No product available for chat. Please try again.".localized)
            return
        }

        let productId = product.id

        // Disable button to prevent multiple taps
        chatButton.isEnabled = false

        Task {
            do {
                // Get the current user's ID (seller)
                let currentUserId = try await supabase.auth.session.user.id

                // Get or create conversation with buyer
                let conversation = try await chatRepository.getOrCreateConversation(
                    productId: productId,
                    sellerId: currentUserId
                )

                // Navigate to chat
                await MainActor.run {
                    self.navigateToChatConversation(conversationId: conversation.id)
                    self.chatButton.isEnabled = true
                }
            } catch {
                await MainActor.run {
                    self.showErrorAlert(message: "Unable to start conversation. Please try again.".localized)
                    self.chatButton.isEnabled = true
                }
            }
        }
    }
    
    private func navigateToChatConversation(conversationId: UUID) {
        // Switch to Chat tab (index 1) and navigate to specific conversation
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 1 // Chat tab
            
            // Get the ChatViewController from the tab
            if let navigationController = tabBarController.viewControllers?[1] as? UINavigationController,
               let chatViewController = navigationController.viewControllers.first as? ChatViewController {
                chatViewController.navigateToConversation(id: conversationId)
            }
        }
    }
}

// MARK: - Padding Extension
extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        // note: frame.height may be zero at creation — set a container with the width only
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 1))
        leftView = paddingView
        leftViewMode = .always
    }
    
}
