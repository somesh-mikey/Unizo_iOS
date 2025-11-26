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

    private let avatarView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.92, alpha: 1)
        v.layer.cornerRadius = 22
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "person.fill"))
        iv.tintColor = UIColor(white: 0.55, alpha: 1)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let roleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        l.textColor = UIColor.systemGray
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .black
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let timeLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12)
        l.textColor = UIColor.systemGray
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .right
        return l
    }()

    private let unreadBadge: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .white
        l.backgroundColor = UIColor(red: 0.02, green: 0.55, blue: 0.65, alpha: 1)
        l.layer.cornerRadius = 12
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        l.clipsToBounds = true
        return l
    }()

    private let bottomSeparator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.88, alpha: 1)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // layout init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none // keeps the cell visually consistent, selection still works
        accessoryType = .disclosureIndicator
        contentView.addSubview(avatarView)
        avatarView.addSubview(avatarImageView)
        contentView.addSubview(roleLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(unreadBadge)
        contentView.addSubview(bottomSeparator)
        setupConstraints()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

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
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            timeLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 70),

            unreadBadge.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -8),
            unreadBadge.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            unreadBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 24),
            unreadBadge.heightAnchor.constraint(equalToConstant: 24),

            roleLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            roleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            roleLabel.trailingAnchor.constraint(lessThanOrEqualTo: unreadBadge.leadingAnchor, constant: -12),

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
        if item.unreadCount > 0 {
            unreadBadge.isHidden = false
            unreadBadge.text = "\(item.unreadCount)"
        } else {
            unreadBadge.isHidden = true
        }
    }
}

// MARK: - Chat View Controller
class ChatViewController: UIViewController {

    // MARK: - UI
    private let navTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Chat"
        l.font = UIFont.systemFont(ofSize: 38, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let searchContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.94, alpha: 1)
        v.layer.cornerRadius = 20
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let searchIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        iv.tintColor = UIColor(white: 0.6, alpha: 1)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let searchTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Search"
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.borderStyle = .none
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let segmentedContainer: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 18
        v.backgroundColor = UIColor(white: 0.95, alpha: 1)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.clipsToBounds = false
        return v
    }()

    private let segmentAll = UIButton(type: .system)
    private let segmentSelling = UIButton(type: .system)
    private let segmentBuying = UIButton(type: .system)
    private var segmentButtons: [UIButton] { [segmentAll, segmentSelling, segmentBuying] }

    private let tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.separatorStyle = .none
        t.translatesAutoresizingMaskIntoConstraints = false
        t.showsVerticalScrollIndicator = false
        t.allowsSelection = true
        return t
    }()

    // MARK: - Data
    private var allItems: [ChatItem] = [
        .init(role: .seller, title: "Under Armour Cap", time: "16:04", unreadCount: 8),
        .init(role: .seller, title: "Zebronics Headphones", time: "15:38", unreadCount: 2),
        .init(role: .buyer, title: "Pink Bicycle", time: "13:02", unreadCount: 1),
        .init(role: .seller, title: "Willow Cricket Bat", time: "12:56", unreadCount: 0),
        .init(role: .buyer, title: "Prestige Electric Kettle", time: "12:30", unreadCount: 0),
        .init(role: .buyer, title: "Slip Jeans", time: "11:10", unreadCount: 0),
        .init(role: .seller, title: "Table Lamp", time: "10:00", unreadCount: 0),
        .init(role: .seller, title: "Football Posters", time: "09:00", unreadCount: 0),
        .init(role: .buyer, title: "MacBook Pro 2021", time: "08:45", unreadCount: 0),
        .init(role: .seller, title: "Nike Backpack", time: "08:10", unreadCount: 0),
        .init(role: .buyer, title: "Bluetooth Speaker", time: "07:50", unreadCount: 0)
    ]

    private var filteredItems: [ChatItem] = []
    private enum Segment { case all, selling, buying }
    private var activeSegment: Segment = .all {
        didSet { refreshForSegment() }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.98, alpha: 1)
        setupViews()
        setupTable()
        applySegmentVisuals()
        activeSegment = .all
        searchTextField.addTarget(self, action: #selector(searchChanged), for: .editingChanged)
    }

    // MARK: - Setup
    private func setupViews() {
        // top title
        view.addSubview(navTitleLabel)
        NSLayoutConstraint.activate([
            navTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            // keep a tight top like your Figma screenshot
            navTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12)
        ])

        // search
        view.addSubview(searchContainer)
        searchContainer.addSubview(searchIcon)
        searchContainer.addSubview(searchTextField)
        NSLayoutConstraint.activate([
            searchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            // tightened gap above the search bar to match Figma
            searchContainer.topAnchor.constraint(equalTo: navTitleLabel.bottomAnchor, constant: 4),
            searchContainer.heightAnchor.constraint(equalToConstant: 44),

            searchIcon.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor, constant: 12),
            searchIcon.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            searchIcon.widthAnchor.constraint(equalToConstant: 20),
            searchIcon.heightAnchor.constraint(equalToConstant: 20),

            searchTextField.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: 8),
            searchTextField.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor, constant: -12),
            searchTextField.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            searchTextField.heightAnchor.constraint(equalToConstant: 36)
        ])

        // segmented control (custom pill)
        view.addSubview(segmentedContainer)
        segmentedContainer.addSubview(segmentAll)
        segmentedContainer.addSubview(segmentSelling)
        segmentedContainer.addSubview(segmentBuying)

        // configure buttons
        let titles = ["All", "Selling", "Buying"]
        let btns = segmentButtons
        for (i, b) in btns.enumerated() {
            b.setTitle(titles[i], for: .normal)
            b.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            b.translatesAutoresizingMaskIntoConstraints = false
            b.layer.cornerRadius = 16
            b.clipsToBounds = false // allow shadow outside if applied
            b.addTarget(self, action: #selector(segmentTapped(_:)), for: .touchUpInside)
        }

        NSLayoutConstraint.activate([
            segmentedContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentedContainer.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: 12),
            segmentedContainer.heightAnchor.constraint(equalToConstant: 36),

            segmentAll.leadingAnchor.constraint(equalTo: segmentedContainer.leadingAnchor, constant: 4),
            segmentAll.topAnchor.constraint(equalTo: segmentedContainer.topAnchor, constant: 4),
            segmentAll.bottomAnchor.constraint(equalTo: segmentedContainer.bottomAnchor, constant: -4),

            segmentSelling.leadingAnchor.constraint(equalTo: segmentAll.trailingAnchor, constant: 6),
            segmentSelling.topAnchor.constraint(equalTo: segmentAll.topAnchor),
            segmentSelling.bottomAnchor.constraint(equalTo: segmentAll.bottomAnchor),

            segmentBuying.leadingAnchor.constraint(equalTo: segmentSelling.trailingAnchor, constant: 6),
            segmentBuying.topAnchor.constraint(equalTo: segmentAll.topAnchor),
            segmentBuying.bottomAnchor.constraint(equalTo: segmentAll.bottomAnchor),
            segmentBuying.trailingAnchor.constraint(equalTo: segmentedContainer.trailingAnchor, constant: -4),

            // widths: allow equal widths
            segmentAll.widthAnchor.constraint(equalTo: segmentSelling.widthAnchor),
            segmentSelling.widthAnchor.constraint(equalTo: segmentBuying.widthAnchor)
        ])

        // table
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentedContainer.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // no fake bottom tab - use safeArea bottom
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func setupTable() {
        tableView.register(ChatCell.self, forCellReuseIdentifier: ChatCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 92
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelection = true
    }

    // MARK: - Actions
    @objc private func segmentTapped(_ sender: UIButton) {
        if sender == segmentAll { activeSegment = .all }
        else if sender == segmentSelling { activeSegment = .selling }
        else { activeSegment = .buying }
        applySegmentVisuals()
    }

    private func applySegmentVisuals() {
        // Reset
        for b in segmentButtons {
            b.backgroundColor = .clear
            b.setTitleColor(UIColor(white: 0.2, alpha: 1), for: .normal)
            // remove previous shadow
            b.layer.shadowOpacity = 0
        }

        // active styling: white rounded pill with shadow like figma
        let selectedButton: UIButton
        switch activeSegment {
            case .all: selectedButton = segmentAll
            case .selling: selectedButton = segmentSelling
            case .buying: selectedButton = segmentBuying
        }

        selectedButton.backgroundColor = .white
        selectedButton.setTitleColor(UIColor(red: 0.02, green: 0.46, blue: 0.58, alpha: 1), for: .normal)

        // rounded + shadow — keep cornerRadius and show shadow
        selectedButton.layer.cornerRadius = 16
        selectedButton.layer.masksToBounds = false
        selectedButton.layer.shadowColor = UIColor.black.cgColor
        selectedButton.layer.shadowOpacity = 0.06
        selectedButton.layer.shadowRadius = 6
        selectedButton.layer.shadowOffset = CGSize(width: 0, height: 3)
    }

    @objc private func searchChanged() {
        filterBySearch()
    }

    // MARK: - Filtering
    private func refreshForSegment() {
        switch activeSegment {
            case .all:
                filteredItems = allItems
            case .selling:
                filteredItems = allItems.filter { $0.role == .seller }
            case .buying:
                filteredItems = allItems.filter { $0.role == .buyer }
        }
        filterBySearch()
    }

    private func filterBySearch() {
        let q = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if q.isEmpty {
            // keep filteredItems for segment
            tableView.reloadData()
            return
        }
        filteredItems = filteredItems.filter { $0.title.localizedCaseInsensitiveContains(q) }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource / Delegate
extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.reuseId, for: indexPath) as? ChatCell else {
            return UITableViewCell()
        }
        let item = filteredItems[indexPath.row]
        cell.configure(with: item)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = filteredItems[indexPath.row]

        // Push ChatDetailViewController with the selected item's title & role
        let vc = ChatDetailViewController()
        vc.chatTitle = item.title
        vc.isSeller = (item.role == .seller)

        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
}
