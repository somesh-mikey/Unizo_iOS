//
//  NotificationsViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 20/11/25.
//

import UIKit

struct NotificationItem {
    let icon: String
    let title: String
    let subtitle: String
    let time: String
}

class NotificationsViewController: UIViewController {

    private let darkTeal = UIColor(red: 0.07, green: 0.33, blue: 0.42, alpha: 1.0)

    // segmented control wrapper
    private let segmentBackground = UIView()
    private var segmentedControl: UISegmentedControl!

    private let tableView = UITableView(frame: .zero, style: .plain)

    // DATA
    private var allData: [NotificationItem] = []
    private var buyingData: [NotificationItem] = []
    private var sellingData: [NotificationItem] = []

    private var currentData: [NotificationItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.98, alpha: 1)

        setupNav()
        loadData()
        setupSegment()
        setupTable()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false

        // Restore floating tab bar height & position
        if let mainTab = tabBarController as? MainTabBarController {
        }
    }


    // MARK: NAV BAR
    private func setupNav() {
        title = "Notifications"
        navigationController?.navigationBar.prefersLargeTitles = false

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backPressed)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: nil,
            action: nil
        )
    }

    @objc private func backPressed() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: LOAD DATA (Figma exact)
    private func loadData() {

        allData = [
            NotificationItem(
                icon: "cart",
                title: "Jiya",
                subtitle: "wants to place order for\nHostel Table Lamp.",
                time: "16:04"
            ),
            NotificationItem(
                icon: "cart",
                title: "Arjun",
                subtitle: "wants to place order for\nUnder Armour Cap.",
                time: "15:38"
            ),
            NotificationItem(
                icon: "gift",
                title: "Order Confirmed!",
                subtitle: "Your order for Slip Jeans Medium\nhas been confirmed.",
                time: "14:23"
            ),
            NotificationItem(
                icon: "indianrupeesign.circle",
                title: "Payment Received",
                subtitle: "The payment for your recent sale\nhas been successfully processed.",
                time: "13:02"
            )
        ]

        buyingData = [
            NotificationItem(
                icon: "gift",
                title: "Order Confirmed!",
                subtitle: "Your order for Slip Jeans Medium\nhas been confirmed.",
                time: "14:23"
            ),
            NotificationItem(
                icon: "indianrupeesign.circle",
                title: "Payment Received",
                subtitle: "The payment for your recent sale\nhas been successfully processed.",
                time: "13:02"
            )
        ]

        sellingData = [
            NotificationItem(
                icon: "cart",
                title: "Jiya",
                subtitle: "wants to place order for\nHostel Table Lamp.",
                time: "16:04"
            ),
            NotificationItem(
                icon: "cart",
                title: "Arjun",
                subtitle: "wants to place order for\nUnder Armour Cap.",
                time: "15:38"
            )
        ]

        currentData = allData
    }

    // MARK: SEGMENT
    private func setupSegment() {

        segmentBackground.backgroundColor = UIColor(red: 0.92, green: 0.93, blue: 0.96, alpha: 1)
        segmentBackground.layer.cornerRadius = 22
        segmentBackground.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentBackground)

        segmentedControl = UISegmentedControl(items: ["All", "Buying", "Selling"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .clear
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.darkGray], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentBackground.addSubview(segmentedControl)

        NSLayoutConstraint.activate([
            segmentBackground.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
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

    // MARK: TABLE
    private func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NotificationCell.self, forCellReuseIdentifier: "NotificationCell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentBackground.bottomAnchor, constant: 15),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - TABLE DATASOURCE
extension NotificationsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        cell.configure(with: currentData[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ConfirmOrderSellerViewController()

        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .coverVertical
            present(vc, animated: true)
        }
    }
}

// MARK: CUSTOM CELL (Figma exact)
class NotificationCell: UITableViewCell {

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let timeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)

        selectionStyle = .none
        backgroundColor = .clear

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .black

        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        subtitleLabel.textColor = .darkGray
        subtitleLabel.numberOfLines = 2
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        timeLabel.font = UIFont.systemFont(ofSize: 13)
        timeLabel.textColor = .gray
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

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

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with item: NotificationItem) {
        iconView.image = UIImage(systemName: item.icon)
        titleLabel.text = item.title
        timeLabel.text = item.time

        // Highlight product names inside subtitle
        let fullText = item.subtitle as NSString
        let attributed = NSMutableAttributedString(
            string: item.subtitle,
            attributes: [
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor.darkGray
            ]
        )

        // List of product names to highlight (you can expand this)
        let productsToBold = [
            "Hostel Table Lamp",
            "Under Armour Cap"
        ]

        for product in productsToBold {
            let range = fullText.range(of: product)
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
