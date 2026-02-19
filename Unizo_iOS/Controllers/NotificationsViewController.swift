//
//  NotificationsViewController.swift
//  Unizo_iOS
//

import UIKit

final class NotificationsViewController: UIViewController {

    // MARK: - Colors
    private let bgColor = UIColor(red: 0.94, green: 0.95, blue: 0.98, alpha: 1)

    // MARK: - Data
    private let repository = NotificationRepository()
    private let orderRepository = OrderRepository()
    private var allNotifications: [NotificationUIModel] = []
    private var buyingNotifications: [NotificationUIModel] = []
    private var sellingNotifications: [NotificationUIModel] = []
    private var currentData: [NotificationUIModel] = []
    private var isLoading = false

    // MARK: - Custom Navigation
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
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Notifications".localized
        lbl.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let clearAllButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Clear All".localized, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btn.setTitleColor(UIColor(red: 0.96, green: 0.42, blue: 0.42, alpha: 1.0), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Segmented Control Wrapper
    private let segmentBackground: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.92, green: 0.93, blue: 0.96, alpha: 1)
        v.layer.cornerRadius = 22
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["All".localized, "Buying".localized, "Selling".localized])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.applyPrimarySegmentStyle()
        return sc
    }()

    // MARK: - Table
    private let tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.separatorStyle = .none
        t.backgroundColor = .clear
        t.estimatedRowHeight = 70
        t.rowHeight = UITableView.automaticDimension
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()

    // MARK: - Loading & Empty State
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let emptyStateLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "No notifications yet".localized
        lbl.font = .systemFont(ofSize: 16)
        lbl.textColor = .secondaryLabel
        lbl.textAlignment = .center
        lbl.isHidden = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // MARK: - Refresh Control
    private let refreshControl = UIRefreshControl()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor

        setupNavigation()
        setupSegment()
        setupTable()
        setupLoadingState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        loadNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Navigation Bar
    private func setupNavigation() {
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(clearAllButton)

        backButton.addTarget(self, action: #selector(backPressed), for: .touchUpInside)
        clearAllButton.addTarget(self, action: #selector(clearAllTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 16),

            clearAllButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            clearAllButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @objc private func backPressed() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func markAllRead() {
        Task {
            await NotificationManager.shared.markAllAsRead()
            await loadNotifications()
        }
    }

    @objc private func clearAllTapped() {
        let alert = UIAlertController(
            title: "Clear All Notifications".localized,
            message: "Are you sure you want to clear all notifications? This action cannot be undone.".localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear All".localized, style: .destructive) { [weak self] _ in
            self?.performClearAll()
        })
        present(alert, animated: true)
    }

    private func performClearAll() {
        loadingIndicator.startAnimating()
        Task {
            do {
                try await repository.deleteAllNotifications()
                await MainActor.run {
                    self.allNotifications.removeAll()
                    self.buyingNotifications.removeAll()
                    self.sellingNotifications.removeAll()
                    self.currentData.removeAll()
                    self.tableView.reloadData()
                    self.loadingIndicator.stopAnimating()
                    self.emptyStateLabel.isHidden = false
                    // Reset badge count
                    NotificationManager.shared.resetUnreadCount()
                }
            } catch {
                print("Failed to clear notifications: \(error)")
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                }
            }
        }
    }

    // MARK: - Setup Loading State
    private func setupLoadingState() {
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Load Notifications from Backend
    private func loadNotifications() {
        guard !isLoading else { return }
        isLoading = true

        if !refreshControl.isRefreshing {
            loadingIndicator.startAnimating()
        }
        emptyStateLabel.isHidden = true

        Task {
            do {
                let notifications = try await repository.fetchNotifications()
                let mapped = notifications.map { NotificationMapper.toUIModel($0) }

                await MainActor.run {
                    self.allNotifications = mapped

                    // Filter by type for segments
                    // Selling: new orders (seller receives)
                    self.sellingNotifications = mapped.filter {
                        $0.type == .newOrder
                    }

                    // Buying: order status updates (buyer receives)
                    self.buyingNotifications = mapped.filter {
                        $0.type == .orderAccepted ||
                        $0.type == .orderRejected ||
                        $0.type == .orderShipped ||
                        $0.type == .orderDelivered
                    }

                    self.updateCurrentData()
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.loadingIndicator.stopAnimating()
                    self.isLoading = false

                    // Show empty state if needed
                    self.emptyStateLabel.isHidden = !self.currentData.isEmpty
                    self.clearAllButton.isHidden = self.allNotifications.isEmpty
                }
            } catch {
                print("Failed to load notifications: \(error)")
                await MainActor.run {
                    self.refreshControl.endRefreshing()
                    self.loadingIndicator.stopAnimating()
                    self.isLoading = false
                    self.emptyStateLabel.text = "Failed to load notifications".localized
                    self.emptyStateLabel.isHidden = false
                }
            }
        }
    }

    // MARK: - Segmented Control
    private func setupSegment() {
        view.addSubview(segmentBackground)
        segmentBackground.addSubview(segmentedControl)

        segmentedControl.addTarget(
            self,
            action: #selector(segmentChanged),
            for: .valueChanged
        )

        NSLayoutConstraint.activate([
            segmentBackground.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16),
            segmentBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            segmentBackground.heightAnchor.constraint(equalToConstant: 45),

            segmentedControl.leadingAnchor.constraint(equalTo: segmentBackground.leadingAnchor, constant: 4),
            segmentedControl.trailingAnchor.constraint(equalTo: segmentBackground.trailingAnchor, constant: -4),
            segmentedControl.topAnchor.constraint(equalTo: segmentBackground.topAnchor, constant: 4),
            segmentedControl.bottomAnchor.constraint(equalTo: segmentBackground.bottomAnchor, constant: -4)
        ])
    }

    @objc private func segmentChanged() {
        updateCurrentData()
        tableView.reloadData()
        emptyStateLabel.isHidden = !currentData.isEmpty
    }

    private func updateCurrentData() {
        switch segmentedControl.selectedSegmentIndex {
        case 0: currentData = allNotifications
        case 1: currentData = buyingNotifications
        case 2: currentData = sellingNotifications
        default: break
        }
    }

    // MARK: - Table
    private func setupTable() {
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.reuseId)

        // Pull to refresh
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentBackground.bottomAnchor, constant: 15),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @objc private func handleRefresh() {
        isLoading = false // Reset to allow new load
        loadNotifications()
    }
}

// MARK: - UITableViewDataSource / Delegate
extension NotificationsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentData.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationCell.reuseId,
            for: indexPath
        ) as! NotificationCell

        cell.configure(with: currentData[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = currentData[indexPath.row]

        // Mark as read
        Task {
            await NotificationManager.shared.markAsRead(notificationId: notification.id)

            // Update local data
            await MainActor.run {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }

        // Determine the order ID from deeplink or notification
        let orderId = notification.deeplinkPayload.orderId ?? notification.orderId

        // For seller "new order" notifications, check current order status
        // If order is already accepted/rejected, navigate to OrderDetails instead of ConfirmOrder
        if notification.type == .newOrder || notification.deeplinkPayload.route == "confirm_order_seller" {
            Task {
                do {
                    let order = try await orderRepository.fetchOrder(id: orderId)
                    await MainActor.run {
                        if order.status == "pending" {
                            // Order still pending — seller can accept/reject
                            let vc = ConfirmOrderSellerViewController()
                            vc.orderId = orderId
                            self.pushOrPresent(vc)
                        } else {
                            // Order already accepted/rejected — show details only
                            let vc = OrderDetailsViewController()
                            vc.orderId = orderId
                            self.pushOrPresent(vc)
                        }
                    }
                } catch {
                    // On error, fallback to ConfirmOrderSellerViewController
                    await MainActor.run {
                        let vc = ConfirmOrderSellerViewController()
                        vc.orderId = orderId
                        self.pushOrPresent(vc)
                    }
                }
            }
        } else {
            // Buyer notifications (accepted, rejected, shipped, delivered) → order details
            let vc = OrderDetailsViewController()
            vc.orderId = orderId
            pushOrPresent(vc)
        }
    }

    private func pushOrPresent(_ vc: UIViewController) {
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
}

// MARK: - Notification Cell
final class NotificationCell: UITableViewCell {

    static let reuseId = "NotificationCell"

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let timeLabel = UILabel()
    private let unreadDot = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .clear

        iconView.tintColor = UIColor(red: 0.07, green: 0.33, blue: 0.42, alpha: 1.0)
        iconView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .darkGray
        subtitleLabel.numberOfLines = 2
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .gray
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        unreadDot.backgroundColor = UIColor(red: 0.07, green: 0.33, blue: 0.42, alpha: 1.0)
        unreadDot.layer.cornerRadius = 4
        unreadDot.translatesAutoresizingMaskIntoConstraints = false
        unreadDot.isHidden = true

        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(unreadDot)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),

            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),

            // Unread dot on the right side, below the time label
            unreadDot.centerXAnchor.constraint(equalTo: timeLabel.centerXAnchor),
            unreadDot.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
            unreadDot.widthAnchor.constraint(equalToConstant: 8),
            unreadDot.heightAnchor.constraint(equalToConstant: 8),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: timeLabel.leadingAnchor, constant: -8),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -10),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with model: NotificationUIModel) {
        iconView.image = UIImage(systemName: model.iconName)
        titleLabel.text = model.title
        timeLabel.text = model.timeString
        subtitleLabel.text = model.message

        // Unread styling
        if !model.isRead {
            unreadDot.isHidden = false
            titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
            backgroundColor = UIColor.systemBlue.withAlphaComponent(0.05)
        } else {
            unreadDot.isHidden = true
            titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
            backgroundColor = .clear
        }
    }
}
