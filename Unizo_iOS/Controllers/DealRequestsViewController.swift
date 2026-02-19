//
//  DealRequestsViewController.swift
//  Unizo_iOS
//
//  Shows pending deal requests (orders) for a specific product,
//  allowing the seller to choose who to sell to.
//

import UIKit
import Supabase

class DealRequestsViewController: UIViewController {

    // MARK: - Properties
    private let productId: UUID
    private let productTitle: String
    private let supabase = SupabaseManager.shared.client

    // MARK: - Data Model
    struct DealRequest {
        let orderId: UUID
        let buyerName: String
        let buyerEmail: String?
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
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - Init
    init(productId: UUID, productTitle: String) {
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
        fetchDealRequests()
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

        Task {
            do {
                // Decode response model matching Supabase join
                struct OrderItemResponse: Decodable {
                    let product_id: UUID
                    let quantity: Int
                    let price_at_purchase: Double

                    struct OrderInfo: Decodable {
                        let id: UUID
                        let status: String
                        let user_id: UUID
                        let created_at: String
                        let payment_method: String
                        let total_amount: Double

                        struct UserInfo: Decodable {
                            let id: UUID
                            let first_name: String?
                            let last_name: String?
                            let email: String?
                        }
                        let users: UserInfo
                    }
                    let orders: OrderInfo
                }

                let response = try await supabase
                    .from("order_items")
                    .select("product_id, quantity, price_at_purchase, orders!inner(id, status, user_id, created_at, payment_method, total_amount, users!inner(id, first_name, last_name, email))")
                    .eq("product_id", value: productId.uuidString)
                    .execute()

                let items = try JSONDecoder().decode([OrderItemResponse].self, from: response.data)

                // Filter for pending orders only
                let pendingItems = items.filter { $0.orders.status == "pending" }

                let requests = pendingItems.map { item -> DealRequest in
                    let firstName = item.orders.users.first_name ?? ""
                    let lastName = item.orders.users.last_name ?? ""
                    let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)

                    return DealRequest(
                        orderId: item.orders.id,
                        buyerName: fullName.isEmpty ? "Unknown Buyer".localized : fullName,
                        buyerEmail: item.orders.users.email,
                        orderDate: formatDate(item.orders.created_at),
                        quantity: item.quantity,
                        priceAtPurchase: item.price_at_purchase,
                        paymentMethod: item.orders.payment_method
                    )
                }

                await MainActor.run {
                    self.dealRequests = requests
                    self.loadingIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                    self.updateEmptyState()
                }

            } catch {
                print("❌ Failed to fetch deal requests:", error)
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
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
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }

        // Fallback: try without fractional seconds
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: dateString) {
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }

    private func navigateToConfirmOrder(orderId: UUID) {
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

            priceLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 12),
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
    }
}
