//
//  ChatViewController.swift
//  Unizo_iOS
//
//  Real-time chat list screen with Supabase integration
//

import UIKit
import Supabase

// MARK: - Chat Cell
private final class ChatCell: UITableViewCell {

    static let reuseId = "ChatCell"

    // Large circular avatar
    private let avatarView = UIView()
    private let avatarImageView = UIImageView()

    // Labels
    private let userNameLabel = UILabel()
    private let productNameLabel = UILabel()
    private let lastMessageLabel = UILabel()
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
        // Large circular avatar - Teal color
        avatarView.backgroundColor = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1.0)
        avatarView.layer.cornerRadius = 28
        avatarView.clipsToBounds = true

        avatarImageView.image = UIImage(systemName: "person.fill")
        avatarImageView.tintColor = .white
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true

        // User name - main title in teal
        userNameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        userNameLabel.textColor = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1.0)

        // Product name - secondary
        productNameLabel.font = .systemFont(ofSize: 14)
        productNameLabel.textColor = .label

        // Last message
        lastMessageLabel.font = .systemFont(ofSize: 14)
        lastMessageLabel.textColor = .secondaryLabel
        lastMessageLabel.numberOfLines = 1

        // Time
        timeLabel.font = .systemFont(ofSize: 14)
        timeLabel.textColor = .secondaryLabel
        timeLabel.textAlignment = .right

        // Unread badge - Teal color
        unreadBadge.font = .systemFont(ofSize: 12, weight: .semibold)
        unreadBadge.textColor = .white
        unreadBadge.backgroundColor = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1.0)
        unreadBadge.layer.cornerRadius = 10
        unreadBadge.clipsToBounds = true
        unreadBadge.textAlignment = .center

        bottomSeparator.backgroundColor = UIColor.separator

        [avatarView, userNameLabel, productNameLabel, lastMessageLabel, timeLabel, unreadBadge, bottomSeparator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        avatarView.addSubview(avatarImageView)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Large circular avatar
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 56),
            avatarView.heightAnchor.constraint(equalToConstant: 56),

            avatarImageView.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 28),
            avatarImageView.heightAnchor.constraint(equalToConstant: 28),

            // Time label (top right)
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -36),
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),

            // User name (main title)
            userNameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            userNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            userNameLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -8),

            // Product name (secondary)
            productNameLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            productNameLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 2),
            productNameLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -8),

            // Last message preview
            lastMessageLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            lastMessageLabel.topAnchor.constraint(equalTo: productNameLabel.bottomAnchor, constant: 2),
            lastMessageLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -8),

            // Unread badge
            unreadBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -36),
            unreadBadge.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 6),
            unreadBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 20),
            unreadBadge.heightAnchor.constraint(equalToConstant: 20),

            // Bottom separator
            bottomSeparator.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            bottomSeparator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 0.5),
            bottomSeparator.topAnchor.constraint(equalTo: lastMessageLabel.bottomAnchor, constant: 14),
            bottomSeparator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func configure(with conversation: ConversationUIModel) {
        // User name as main title
        let rolePrefix = conversation.isSeller ? "Buyer: " : "Seller: "
        userNameLabel.text = rolePrefix + conversation.otherUserName

        // Product name secondary
        productNameLabel.text = conversation.productTitle

        // Last message
        lastMessageLabel.text = conversation.lastMessage.isEmpty ? "Start a conversation".localized : conversation.lastMessage
        timeLabel.text = conversation.formattedTime

        // Unread badge
        if conversation.unreadCount > 0 {
            unreadBadge.isHidden = false
            unreadBadge.text = conversation.unreadCount > 99 ? "99+" : "\(conversation.unreadCount)"
        } else {
            unreadBadge.isHidden = true
        }

        // Load user avatar
        if let avatarURL = conversation.otherUserImageURL, !avatarURL.isEmpty {
            Task {
                if let url = URL(string: avatarURL),
                   let (data, _) = try? await URLSession.shared.data(from: url),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        self.avatarImageView.image = image
                        self.avatarImageView.layer.cornerRadius = 28
                        self.avatarImageView.layer.masksToBounds = true
                        // Fill the entire avatar view with the image
                        self.avatarImageView.constraints.forEach { $0.isActive = false }
                        NSLayoutConstraint.activate([
                            self.avatarImageView.topAnchor.constraint(equalTo: self.avatarView.topAnchor),
                            self.avatarImageView.bottomAnchor.constraint(equalTo: self.avatarView.bottomAnchor),
                            self.avatarImageView.leadingAnchor.constraint(equalTo: self.avatarView.leadingAnchor),
                            self.avatarImageView.trailingAnchor.constraint(equalTo: self.avatarView.trailingAnchor)
                        ])
                    }
                }
            }
        } else {
            avatarImageView.image = UIImage(systemName: "person.fill")
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = UIImage(systemName: "person.fill")
        avatarImageView.constraints.forEach { $0.isActive = false }
        NSLayoutConstraint.activate([
            avatarImageView.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 28),
            avatarImageView.heightAnchor.constraint(equalToConstant: 28)
        ])
        unreadBadge.isHidden = true
    }
}

// MARK: - Chat View Controller
final class ChatViewController: UIViewController {

    private enum Segment { case all, selling, buying }

    // MARK: - UI
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Chat".localized
        l.font = .systemFont(ofSize: 35, weight: .bold)
        return l
    }()

    private let searchContainer = UIView()
    private let searchField = UITextField()

    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["All".localized, "Selling".localized, "Buying".localized])
        sc.applyPrimarySegmentStyle()
        return sc
    }()

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let refreshControl = UIRefreshControl()

    // Empty state
    private let emptyStateView: UIView = {
        let v = UIView()
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let emptyStateImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "bubble.left.and.bubble.right")
        iv.tintColor = .tertiaryLabel
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let emptyStateLabel: UILabel = {
        let l = UILabel()
        l.text = "No conversations yet".localized
        l.font = .systemFont(ofSize: 17, weight: .medium)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let emptyStateSubtitle: UILabel = {
        let l = UILabel()
        l.text = "Start chatting with sellers\nby tapping Chat on a product".localized
        l.font = .systemFont(ofSize: 14)
        l.textColor = .tertiaryLabel
        l.textAlignment = .center
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // Loading indicator
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - Data
    private var activeSegment: Segment = .all
    private var allConversations: [ConversationUIModel] = []
    private var filteredConversations: [ConversationUIModel] = []
    private var currentUserId: UUID?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupUI()
        setupTable()
        setupEmptyState()
        setupNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchConversations()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup
    private func setupUI() {
        [titleLabel, searchContainer, segmentedControl, tableView, loadingIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        searchContainer.backgroundColor = .white
        searchContainer.layer.cornerRadius = 20

        searchField.placeholder = "Search".localized
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchContainer.addSubview(searchField)

        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        searchField.addTarget(self, action: #selector(searchChanged), for: .editingChanged)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 75),

            loadingIndicator.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            loadingIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

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

        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func setupEmptyState() {
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        emptyStateView.addSubview(emptyStateSubtitle)

        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 60),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 60),

            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 16),
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),

            emptyStateSubtitle.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 8),
            emptyStateSubtitle.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateSubtitle.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewMessage(_:)),
            name: .newChatMessageReceived,
            object: nil
        )
    }

    // MARK: - Fetch Conversations
    private func fetchConversations() {
        loadingIndicator.startAnimating()

        Task {
            do {
                // Get current user ID
                guard let userId = await AuthManager.shared.currentUserId else {
                    await MainActor.run {
                        self.loadingIndicator.stopAnimating()
                        self.refreshControl.endRefreshing()
                    }
                    return
                }

                self.currentUserId = userId

                let conversations = try await ChatManager.shared.fetchConversations()

                // Convert to UI models
                var uiModels: [ConversationUIModel] = []

                for conv in conversations {
                    let isSeller = conv.seller_id == userId
                    let otherUser = isSeller ? conv.buyer : conv.seller

                    // Get unread count for this conversation
                    let unreadCount = try await ChatRepository().getUnreadCount(conversationId: conv.id)

                    let uiModel = ConversationUIModel(
                        id: conv.id,
                        productId: conv.product_id,
                        productTitle: conv.product?.title ?? "Product",
                        productImageURL: conv.product?.image_url,
                        otherUserId: otherUser?.id ?? UUID(),
                        otherUserName: otherUser?.displayName ?? "User",
                        otherUserImageURL: otherUser?.profile_image_url,
                        lastMessage: conv.last_message?.previewText ?? "",
                        lastMessageTime: conv.last_message?.created_at,
                        unreadCount: unreadCount,
                        isSeller: isSeller
                    )
                    uiModels.append(uiModel)
                }

                // Sort by last message time
                uiModels.sort { ($0.lastMessageTime ?? Date.distantPast) > ($1.lastMessageTime ?? Date.distantPast) }

                await MainActor.run {
                    self.allConversations = uiModels
                    self.applyFilters()
                    self.loadingIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                }

            } catch {
                print("❌ Failed to fetch conversations: \(error)")
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }

    // MARK: - Actions
    @objc private func segmentChanged() {
        activeSegment = segmentedControl.selectedSegmentIndex == 1 ? .selling :
                        segmentedControl.selectedSegmentIndex == 2 ? .buying : .all
        applyFilters()
    }

    @objc private func searchChanged() {
        applyFilters()
    }

    @objc private func handleRefresh() {
        HapticFeedback.pullToRefresh()
        fetchConversations()
    }

    @objc private func handleNewMessage(_ notification: Notification) {
        // Refresh conversation list when new message arrives
        fetchConversations()
    }

    private func applyFilters() {
        var result = allConversations

        // Filter by segment
        switch activeSegment {
        case .all:
            break
        case .selling:
            result = result.filter { $0.isSeller }
        case .buying:
            result = result.filter { !$0.isSeller }
        }

        // Filter by search
        let query = searchField.text ?? ""
        if !query.isEmpty {
            result = result.filter {
                $0.productTitle.localizedCaseInsensitiveContains(query) ||
                $0.otherUserName.localizedCaseInsensitiveContains(query)
            }
        }

        filteredConversations = result
        tableView.reloadData()
        updateEmptyState()
    }

    private func updateEmptyState() {
        let isEmpty = filteredConversations.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
}

// MARK: - Table Delegate
extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredConversations.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChatCell.reuseId,
            for: indexPath
        ) as! ChatCell
        cell.configure(with: filteredConversations[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = filteredConversations[indexPath.row]
        
        let detailVC = ChatDetailViewController()
        detailVC.conversationId = conversation.id
        detailVC.chatTitle = conversation.productTitle
        detailVC.otherUserName = conversation.otherUserName
        detailVC.isSeller = conversation.isSeller
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK: - External Navigation
    /// Navigate to a specific conversation (called from other controllers like OrderDetailsViewController)
    func navigateToConversation(id conversationId: UUID) {
        // Find conversation in all loaded conversations (not just filtered)
        if let conversation = allConversations.first(where: { $0.id == conversationId }) {
            let detailVC = ChatDetailViewController()
            detailVC.conversationId = conversation.id
            detailVC.chatTitle = conversation.productTitle
            detailVC.otherUserName = conversation.otherUserName
            detailVC.isSeller = conversation.isSeller
            
            navigationController?.pushViewController(detailVC, animated: true)
        } else {
            print("Conversation not found in list, attempting direct load")
            // If not in the visible list, create detail VC directly
            let detailVC = ChatDetailViewController()
            detailVC.conversationId = conversationId
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}
