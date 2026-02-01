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
    private var allNotifications: [NotificationUIModel] = []
    private var buyingNotifications: [NotificationUIModel] = []
    private var sellingNotifications: [NotificationUIModel] = []
    private var currentData: [NotificationUIModel] = []
    private var isLoading = false

    // MARK: - Segmented Control Wrapper
    private let segmentBackground: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.92, green: 0.93, blue: 0.96, alpha: 1)
        v.layer.cornerRadius = 22
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["All", "Buying", "Selling"])
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
        lbl.text = "No notifications yet"
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
        title = "Notifications"
        navigationController?.navigationBar.prefersLargeTitles = false

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backPressed)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "checkmark.circle"),
            style: .plain,
            target: self,
            action: #selector(markAllRead)
        )
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
                }
            } catch {
                print("Failed to load notifications: \(error)")
                await MainActor.run {
                    self.refreshControl.endRefreshing()
                    self.loadingIndicator.stopAnimating()
                    self.isLoading = false
                    self.emptyStateLabel.text = "Failed to load notifications"
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
                if let index = self.allNotifications.firstIndex(where: { $0.id == notification.id }) {
                    // We can't mutate directly, just reload
                }
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }

        // Navigate based on deeplink payload
        let payload = notification.deeplinkPayload

        switch payload.route {
        case "confirm_order_seller":
            guard let orderId = payload.orderId else { return }
            let vc = ConfirmOrderSellerViewController()
            vc.orderId = orderId

            if let nav = navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }

        default:
            // Default: open ConfirmOrderSellerVC if it's an order-related notification
            let vc = ConfirmOrderSellerViewController()
            vc.orderId = notification.orderId

            if let nav = navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
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

            unreadDot.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 6),
            unreadDot.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            unreadDot.widthAnchor.constraint(equalToConstant: 8),
            unreadDot.heightAnchor.constraint(equalToConstant: 8),

            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),

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
