//
//  ChatViewController.swift
//  Unizo_iOS
//
//  Programmatic Chat screen (modified — removed fake top tab, made rows tappable,
//  tightened spacing above search, ensured segmented selected pill is rounded + shadow).
//
//  Paste/replace this entire file in your Controllers folder.
//

import UIKit

// MARK: - Model
private struct ChatItem {
    enum Role { case seller, buyer }
    let role: Role
    let title: String
    let time: String
    let unreadCount: Int
}

// MARK: - Chat Cell
private final class ChatCell: UITableViewCell {

    static let reuseId = "ChatCell"

    private let avatarView = UIView()
    private let avatarImageView = UIImageView(image: UIImage(systemName: "person.fill"))
    private let roleLabel = UILabel()
    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    private let unreadBadge = UILabel()
    private let bottomSeparator = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        avatarView.backgroundColor = UIColor(white: 0.92, alpha: 1)
        avatarView.layer.cornerRadius = 22

        avatarImageView.tintColor = .systemGray
        avatarImageView.contentMode = .scaleAspectFit

        roleLabel.font = .systemFont(ofSize: 11)
        roleLabel.textColor = .systemGray

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)

        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .systemGray
        timeLabel.textAlignment = .right

        unreadBadge.font = .systemFont(ofSize: 12, weight: .semibold)
        unreadBadge.textColor = .white
        unreadBadge.backgroundColor = UIColor(red: 0.02, green: 0.55, blue: 0.65, alpha: 1)
        unreadBadge.layer.cornerRadius = 12
        unreadBadge.clipsToBounds = true
        unreadBadge.textAlignment = .center

        bottomSeparator.backgroundColor = UIColor(white: 0.88, alpha: 1)

        [avatarView, roleLabel, titleLabel, timeLabel, unreadBadge, bottomSeparator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        avatarView.addSubview(avatarImageView)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            avatarView.widthAnchor.constraint(equalToConstant: 44),
            avatarView.heightAnchor.constraint(equalToConstant: 44),

            avatarImageView.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 24),
            avatarImageView.heightAnchor.constraint(equalToConstant: 24),

            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -36),
            timeLabel.centerYAnchor.constraint(equalTo: roleLabel.centerYAnchor),

            unreadBadge.trailingAnchor.constraint(equalTo: timeLabel.trailingAnchor),
                unreadBadge.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 2),
                unreadBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 24),
                unreadBadge.heightAnchor.constraint(equalToConstant: 24),

            roleLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            roleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),

            titleLabel.leadingAnchor.constraint(equalTo: roleLabel.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -44),

            bottomSeparator.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bottomSeparator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 1),
            bottomSeparator.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            bottomSeparator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2)
        ])
    }

    func configure(with item: ChatItem) {
        roleLabel.text = item.role == .seller ? "Seller" : "Buyer"
        titleLabel.text = item.title
        timeLabel.text = item.time
        unreadBadge.isHidden = item.unreadCount == 0
        unreadBadge.text = "\(item.unreadCount)"
    }
}

// MARK: - Chat View Controller
final class ChatViewController: UIViewController {

    private enum Segment { case all, selling, buying }

    // MARK: UI
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Chat"
        l.font = .systemFont(ofSize: 35, weight: .bold)
        return l
    }()

    private let searchContainer = UIView()
    private let searchField = UITextField()

    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["All", "Selling", "Buying"])
        sc.applyPrimarySegmentStyle()
        return sc
    }()

    private let tableView = UITableView(frame: .zero, style: .plain)

    // MARK: Data
    private var activeSegment: Segment = .all
    private var allItems: [ChatItem] = [
        .init(role: .seller, title: "Under Armour Cap", time: "16:04", unreadCount: 8),
        .init(role: .buyer, title: "Pink Bicycle", time: "13:02", unreadCount: 1),
        .init(role: .seller, title: "Cricket Bat", time: "12:56", unreadCount: 0)
    ]

    private var filteredItems: [ChatItem] = []

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupUI()
        setupTable()
        refreshData()
    }

    // MARK: Setup
    private func setupUI() {
        [titleLabel, searchContainer, segmentedControl, tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        searchContainer.backgroundColor = .white
        searchContainer.layer.cornerRadius = 20

        searchField.placeholder = "Search"
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchContainer.addSubview(searchField)

        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        searchField.addTarget(self, action: #selector(searchChanged), for: .editingChanged)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 75),

            searchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            searchContainer.heightAnchor.constraint(equalToConstant: 44),

            searchField.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor, constant: 12),
            searchField.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor, constant: -12),
            searchField.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),

            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentedControl.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: 12),
            segmentedControl.heightAnchor.constraint(equalToConstant: 35),

            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupTable() {
        tableView.register(ChatCell.self, forCellReuseIdentifier: ChatCell.reuseId)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
    }

    // MARK: Actions
    @objc private func segmentChanged() {
        activeSegment = segmentedControl.selectedSegmentIndex == 1 ? .selling :
                        segmentedControl.selectedSegmentIndex == 2 ? .buying : .all
        refreshData()
    }

    @objc private func searchChanged() {
        refreshData()
    }

    private func refreshData() {
        let base: [ChatItem]
        switch activeSegment {
        case .all: base = allItems
        case .selling: base = allItems.filter { $0.role == .seller }
        case .buying: base = allItems.filter { $0.role == .buyer }
        }

        let query = searchField.text ?? ""
        filteredItems = query.isEmpty ? base : base.filter {
            $0.title.localizedCaseInsensitiveContains(query)
        }
        tableView.reloadData()
    }
}

// MARK: - Table Delegate
extension ChatViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredItems.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChatCell.reuseId,
            for: indexPath
        ) as! ChatCell
        cell.configure(with: filteredItems[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = filteredItems[indexPath.row]
        let detailVC = ChatDetailViewController()
        detailVC.chatTitle = item.title
        detailVC.isSeller = (item.role == .seller)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

