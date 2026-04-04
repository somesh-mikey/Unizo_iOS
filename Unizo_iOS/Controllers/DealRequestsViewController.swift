//
//  DealRequestsViewController.swift
//  Unizo_iOS
//
//  Shows pending deal requests (orders) for a specific product,
//  allowing the seller to choose who to sell to.
//

import UIKit

class DealRequestsViewController: UIViewController {

    // MARK: - Properties
    private let productId: String
    private let productTitle: String
    private let sellerDashboardRepository = SellerDashboardRepository()
    private let orderRepository = OrderRepository()
    private let userRepository = UserRepository()

    // MARK: - Data Model
    struct DealRequest {
        let orderId: String
        let buyerName: String
        let buyerEmail: String?
        let buyerPhone: String?
        let buyerAddress: String?
        let orderDate: String
        let quantity: Int
        let priceAtPurchase: Double
        let paymentMethod: String
    }

    private var dealRequests: [DealRequest] = []

    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Deal Requests".localized
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        return tv
    }()

    private let refreshControl = UIRefreshControl()

    // MARK: - Empty State
    private let emptyStateContainer: UIView = {
        let v = UIView()
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let emptyStateImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "tray")
        iv.tintColor = .tertiaryLabel
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let emptyStateLabel: UILabel = {
        let l = UILabel()
        l.text = "No deal requests yet".localized
        l.font = UIFont.preferredFont(forTextStyle: .title3)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let emptyStateSubtitle: UILabel = {
        let l = UILabel()
        l.text = "Deal requests for this product\nwill appear here".localized
        l.font = UIFont.preferredFont(forTextStyle: .subheadline)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .tertiaryLabel
        l.textAlignment = .center
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - Init
    init(productId: String, productTitle: String) {
        self.productId = productId
        self.productTitle = productTitle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        subtitleLabel.text = productTitle
        setupUI()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        (tabBarController as? MainTabBarController)?.hideFloatingTabBar()
        tabBarController?.tabBar.isHidden = true
        fetchDealRequests()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            (tabBarController as? MainTabBarController)?.showFloatingTabBar()
            tabBarController?.tabBar.isHidden = false
        }
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(tableView)
        view.addSubview(emptyStateContainer)
        view.addSubview(loadingIndicator)

        emptyStateContainer.addSubview(emptyStateImageView)
        emptyStateContainer.addSubview(emptyStateLabel)
        emptyStateContainer.addSubview(emptyStateSubtitle)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

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
            emptyStateSubtitle.bottomAnchor.constraint(equalTo: emptyStateContainer.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        // Accessibility
        titleLabel.accessibilityTraits = .header
        subtitleLabel.accessibilityTraits = .staticText
        loadingIndicator.accessibilityLabel = "Loading deal requests".localized
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DealRequestCell.self, forCellReuseIdentifier: DealRequestCell.reuseIdentifier)

        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    @objc private func handleRefresh() {
        fetchDealRequests()
    }

    // MARK: - Data Fetching
    private func fetchDealRequests() {
        loadingIndicator.startAnimating()
        print("🟪 [DealDebug] DealRequestsViewController.fetchDealRequests start productId=\(productId), productTitle=\(productTitle)")

        Task {
            do {
                let sellerOrders = try await sellerDashboardRepository.fetchSellerOrders()
                let pendingOrdersForProduct = sellerOrders
                    .filter { $0.productId == productId && $0.status == .pending }

                print("🟪 [DealDebug] DealRequestsViewController.fetchDealRequests sellerOrders=\(sellerOrders.count), pendingForProduct=\(pendingOrdersForProduct.count)")
                if !pendingOrdersForProduct.isEmpty {
                    let summary = pendingOrdersForProduct.map {
                        "orderId=\($0.id), buyerId=\($0.buyerId ?? "nil")"
                    }.joined(separator: " | ")
                    print("🟪 [DealDebug] DealRequestsViewController.pendingOrderSummary \(summary)")
                }

                var requests: [DealRequest] = []

                for sellerOrder in pendingOrdersForProduct {
                    do {
                        let order = try await orderRepository.fetchOrderWithDetails(id: sellerOrder.id)
                        let buyer = try? await userRepository.fetchUser(id: order.user_id)
                        let orderItem = (order.items ?? []).first { $0.product_id == productId } ?? order.items?.first
                        let address = order.address

                        let addressString = [address?.line1, address?.city, address?.state, address?.postal_code]
                            .compactMap { $0 }
                            .filter { !$0.isEmpty }
                            .joined(separator: ", ")

                        // Prefer the address name since it's explicitly typed during checkout
                        let buyerName = address?.name ?? buyer?.displayName ?? "Unknown Buyer".localized
                        let buyerEmail = buyer?.email

                        requests.append(DealRequest(
                            orderId: sellerOrder.id,
                            buyerName: buyerName.isEmpty ? "Unknown Buyer".localized : buyerName,
                            buyerEmail: buyerEmail,
                            buyerPhone: address?.phone,
                            buyerAddress: addressString.isEmpty ? nil : addressString,
                            orderDate: formatDate(order.created_at),
                            quantity: orderItem?.quantity ?? 1,
                            priceAtPurchase: orderItem?.price_at_purchase ?? order.total_amount,
                            paymentMethod: order.payment_method
                        ))
                        print("🟪 [DealDebug] DealRequestsViewController.appendedRequest orderId=\(sellerOrder.id), buyer=\(buyerName), qty=\(orderItem?.quantity ?? 1)")
                    } catch {
                        print("⚠️ [DealRequestsVC] Skipping invalid order \(sellerOrder.id): \(error)")
                    }
                }

                print("🟪 [DealDebug] DealRequestsViewController.fetchDealRequests finalRequests=\(requests.count)")

                await MainActor.run {
                    self.dealRequests = requests
                    self.loadingIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                    self.updateEmptyState()
                }

            } catch {
                print("❌ [DealRequestsVC] \(type(of: error)): \(error)")
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                    self.emptyStateLabel.text = "Couldn't load deal requests.\nPull to retry.".localized
                    self.updateEmptyState()
                }
            }
        }
    }

    private func updateEmptyState() {
        let isEmpty = dealRequests.isEmpty
        emptyStateContainer.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    private func formatDate(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = isoFormatter.date(from: dateString) {
            if date.timeIntervalSince1970 <= 0 { return "Unknown Date".localized }
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }

        // Fallback: try without fractional seconds
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: dateString) {
            if date.timeIntervalSince1970 <= 0 { return "Unknown Date".localized }
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }

        return dateString
    }
}

// MARK: - UITableViewDelegate & DataSource
extension DealRequestsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dealRequests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DealRequestCell.reuseIdentifier, for: indexPath) as! DealRequestCell
        let request = dealRequests[indexPath.row]
        cell.configure(with: request)
        cell.onAcceptTapped = { [weak self] in
            self?.navigateToConfirmOrder(orderId: request.orderId)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let request = dealRequests[indexPath.row]
        navigateToConfirmOrder(orderId: request.orderId)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }

    private func navigateToConfirmOrder(orderId: String) {
        let confirmVC = ConfirmOrderSellerViewController()
        confirmVC.orderId = orderId
        navigationController?.pushViewController(confirmVC, animated: true)
    }
}

// MARK: - DealRequestCell
final class DealRequestCell: UITableViewCell {

    static let reuseIdentifier = "DealRequestCell"

    var onAcceptTapped: (() -> Void)?

    // MARK: - UI
    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.cornerRadius = 12
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowRadius = 6
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let buyerIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.circle.fill")
        iv.tintColor = .brandPrimary
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let buyerNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16, weight: .semibold)
        lbl.textColor = .label
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let dateLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .caption1)
        lbl.textColor = .secondaryLabel
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let priceLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 15, weight: .bold)
        lbl.textColor = .label
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let quantityLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .caption1)
        lbl.textColor = .secondaryLabel
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let emailLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .caption2)
        lbl.textColor = .secondaryLabel
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let addressLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .caption2)
        lbl.textColor = .tertiaryLabel
        lbl.numberOfLines = 2
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let phoneLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .caption2)
        lbl.textColor = .secondaryLabel
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let paymentLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .caption1)
        lbl.textColor = .secondaryLabel
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let acceptButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("View Deal".localized, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .brandPrimary
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        btn.layer.cornerRadius = 16
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(cardView)

        cardView.addSubview(buyerIcon)
        cardView.addSubview(buyerNameLabel)
        cardView.addSubview(dateLabel)
        cardView.addSubview(emailLabel)
        cardView.addSubview(phoneLabel)
        cardView.addSubview(addressLabel)
        cardView.addSubview(priceLabel)
        cardView.addSubview(quantityLabel)
        cardView.addSubview(paymentLabel)
        cardView.addSubview(acceptButton)

        acceptButton.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            buyerIcon.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            buyerIcon.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            buyerIcon.widthAnchor.constraint(equalToConstant: 40),
            buyerIcon.heightAnchor.constraint(equalToConstant: 40),

            buyerNameLabel.topAnchor.constraint(equalTo: buyerIcon.topAnchor),
            buyerNameLabel.leadingAnchor.constraint(equalTo: buyerIcon.trailingAnchor, constant: 12),
            buyerNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: acceptButton.leadingAnchor, constant: -8),

            dateLabel.topAnchor.constraint(equalTo: buyerNameLabel.bottomAnchor, constant: 2),
            dateLabel.leadingAnchor.constraint(equalTo: buyerNameLabel.leadingAnchor),

            emailLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: buyerNameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            phoneLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 2),
            phoneLabel.leadingAnchor.constraint(equalTo: buyerNameLabel.leadingAnchor),
            phoneLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            addressLabel.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 2),
            addressLabel.leadingAnchor.constraint(equalTo: buyerNameLabel.leadingAnchor),
            addressLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            priceLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            priceLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),

            quantityLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            quantityLabel.leadingAnchor.constraint(equalTo: priceLabel.trailingAnchor, constant: 16),

            paymentLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            paymentLabel.leadingAnchor.constraint(equalTo: quantityLabel.trailingAnchor, constant: 16),

            acceptButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            acceptButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            acceptButton.widthAnchor.constraint(equalToConstant: 100),
            acceptButton.heightAnchor.constraint(equalToConstant: 32),
        ])
    }

    @objc private func acceptTapped() {
        onAcceptTapped?()
    }

    // MARK: - Configure
    func configure(with request: DealRequestsViewController.DealRequest) {
        buyerNameLabel.text = request.buyerName
        dateLabel.text = request.orderDate
        priceLabel.text = "₹\(Int(request.priceAtPurchase))"
        quantityLabel.text = String(format: "Qty: %d".localized, request.quantity)
        paymentLabel.text = request.paymentMethod
        emailLabel.text = request.buyerEmail
        phoneLabel.text = request.buyerPhone
        addressLabel.text = request.buyerAddress
        
        emailLabel.isHidden = request.buyerEmail == nil
        phoneLabel.isHidden = request.buyerPhone == nil
        addressLabel.isHidden = request.buyerAddress == nil
    }
}
