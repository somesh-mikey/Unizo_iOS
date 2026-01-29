//
//  NotificationsViewController.swift
//  Unizo_iOS
//

import UIKit

// MARK: - Model
struct NotificationItem {
    let icon: String
    let title: String
    let subtitle: String
    let time: String
}

final class NotificationsViewController: UIViewController {

    // MARK: - Colors
    private let bgColor = UIColor(red: 0.94, green: 0.95, blue: 0.98, alpha: 1)

    // MARK: - Custom Navigation Buttons
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
        lbl.text = "Notifications"
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let heartButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "heart"), for: .normal)
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
        sc.applyPrimarySegmentStyle() // ✅ GLOBAL STYLE
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

    // MARK: - Data
    private var allData: [NotificationItem] = []
    private var buyingData: [NotificationItem] = []
    private var sellingData: [NotificationItem] = []
    private var currentData: [NotificationItem] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor

        setupNavigation()
        loadData()
        setupSegment()
        setupTable()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Navigation Bar
    private func setupNavigation() {
        // Hide the system navigation bar
        navigationController?.setNavigationBarHidden(true, animated: false)

        // Add custom header elements
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(heartButton)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            heartButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            heartButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            heartButton.widthAnchor.constraint(equalToConstant: 44),
            heartButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
        ])

        backButton.addTarget(self, action: #selector(backPressed), for: .touchUpInside)
        heartButton.addTarget(self, action: #selector(heartPressed), for: .touchUpInside)
    }

    @objc private func backPressed() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func heartPressed() {
        let vc = WishlistViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Data
    private func loadData() {

        allData = [
            .init(icon: "cart",
                  title: "Jiya",
                  subtitle: "wants to place order for\nHostel Table Lamp.",
                  time: "16:04"),

            .init(icon: "cart",
                  title: "Arjun",
                  subtitle: "wants to place order for\nUnder Armour Cap.",
                  time: "15:38"),

            .init(icon: "gift",
                  title: "Order Confirmed!",
                  subtitle: "Your order for Slip Jeans Medium\nhas been confirmed.",
                  time: "14:23"),

            .init(icon: "indianrupeesign.circle",
                  title: "Payment Received",
                  subtitle: "The payment for your recent sale\nhas been successfully processed.",
                  time: "13:02")
        ]

        buyingData = [
            allData[2],
            allData[3]
        ]

        sellingData = [
            allData[0],
            allData[1]
        ]

        currentData = allData
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
        switch segmentedControl.selectedSegmentIndex {
        case 0: currentData = allData
        case 1: currentData = buyingData
        case 2: currentData = sellingData
        default: break
        }
        tableView.reloadData()
    }

    // MARK: - Table
    private func setupTable() {
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.reuseId)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentBackground.bottomAnchor, constant: 15),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
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

        let vc = ConfirmOrderSellerViewController()

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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .clear

        iconView.tintColor = .black
        iconView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .darkGray
        subtitleLabel.numberOfLines = 2
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        timeLabel.font = .systemFont(ofSize: 13)
        timeLabel.textColor = .gray
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(timeLabel)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 26),
            iconView.heightAnchor.constraint(equalToConstant: 26),

            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -10),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with item: NotificationItem) {

        iconView.image = UIImage(systemName: item.icon)
        titleLabel.text = item.title
        timeLabel.text = item.time

        let attributed = NSMutableAttributedString(
            string: item.subtitle,
            attributes: [
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor.darkGray
            ]
        )

        let highlights = ["Hostel Table Lamp", "Under Armour Cap"]

        for text in highlights {
            let range = (item.subtitle as NSString).range(of: text)
            if range.location != NSNotFound {
                attributed.addAttributes(
                    [
                        .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
                        .foregroundColor: UIColor.black
                    ],
                    range: range
                )
            }
        }

        subtitleLabel.attributedText = attributed
    }
}
