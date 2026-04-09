//
//  ChatViewController.swift
//  Unizo_iOS
//
//  Real-time chat list screen.
//

import UIKit

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
            avatarImageView.widthAnchor.constraint(equalTo: avatarView.widthAnchor),
            avatarImageView.heightAnchor.constraint(equalTo: avatarView.heightAnchor),

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

    func configure(with conversation: ConversationUIModel, dimmed: Bool = false) {
        // User name as main title
        let rolePrefix = conversation.isSeller ? "Buyer: " : "Seller: "
        userNameLabel.text = rolePrefix + conversation.otherUserName

        // Product name secondary
        productNameLabel.text = conversation.productTitle

        // Last message
        lastMessageLabel.text = conversation.lastMessage.isEmpty ? "Start a conversation".localized : conversation.lastMessage
        timeLabel.text = conversation.formattedTime

        // Dimmed style for archived conversations
        contentView.alpha = dimmed ? 0.65 : 1.0

        if dimmed {
            // Show "Deal Closed" badge instead of unread count
            unreadBadge.isHidden = false
            unreadBadge.text = "  ✅ Closed  "
            unreadBadge.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.8)
        } else {
            unreadBadge.backgroundColor = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1.0)
            if conversation.unreadCount > 0 {
                unreadBadge.isHidden = false
                unreadBadge.text = conversation.unreadCount > 99 ? "99+" : "\(conversation.unreadCount)"
            } else {
                unreadBadge.isHidden = true
            }
        }

        // Load user avatar
        if let avatarURL = conversation.otherUserImageURL, !avatarURL.isEmpty {
            Task {
                if let url = URL(string: avatarURL),
                   let (data, _) = try? await URLSession.shared.data(from: url),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        self.avatarImageView.image = image
                        // Update to not override parent constraints, since we fixed the cell default constraints
                        self.avatarImageView.layer.cornerRadius = 28
                        self.avatarImageView.layer.masksToBounds = true
                    }
                }
            }
        } else {
            avatarImageView.image = UIImage(systemName: "person.fill")
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.alpha = 1.0
        avatarImageView.image = UIImage(systemName: "person.fill")
        // Reset specific styling flags
        unreadBadge.isHidden = true
        unreadBadge.backgroundColor = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1.0)
    }
}

// MARK: - Archived Section Header View
private final class ArchivedSectionHeaderView: UIView {

    var onToggle: (() -> Void)?

    private let iconImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "archivebox"))
        iv.tintColor = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Archived – Deals Closed"
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1.0)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let countBadge: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .white
        l.backgroundColor = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1.0)
        l.layer.cornerRadius = 10
        l.clipsToBounds = true
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private(set) var chevronView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.down"))
        iv.tintColor = .secondaryLabel
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor.systemGray5
        setupUI()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        [iconImageView, titleLabel, countBadge, chevronView].forEach { addSubview($0) }
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            countBadge.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            countBadge.centerYAnchor.constraint(equalTo: centerYAnchor),
            countBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 22),
            countBadge.heightAnchor.constraint(equalToConstant: 20),
            chevronView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            chevronView.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 14),
            chevronView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }

    func configure(count: Int, isExpanded: Bool) {
        countBadge.text = "  \(count)  "
        countBadge.isHidden = count == 0
        UIView.animate(withDuration: 0.2) {
            self.chevronView.transform = isExpanded
                ? .identity
                : CGAffineTransform(rotationAngle: -(.pi / 2))
        }
    }

    @objc private func handleTap() { onToggle?() }
}

// MARK: - Chat View Controller
final class ChatViewController: UIViewController {

    private enum Segment { case all, selling, buying }
    private enum Section: Int, CaseIterable { case active = 0; case archived = 1 }

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

    private lazy var archivedHeaderView: ArchivedSectionHeaderView = {
        let v = ArchivedSectionHeaderView()
        v.onToggle = { [weak self] in self?.toggleArchivedSection() }
        return v
    }()

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

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - Data
    private var activeSegment: Segment = .all
    private var allConversations: [ConversationUIModel] = []
    private var activeConversations: [ConversationUIModel] = []
    private var archivedConversations: [ConversationUIModel] = []
    private var isArchivedExpanded = false
    private var currentUserId: String?
    private var keyboardBottomInset: CGFloat = 0
    private var tableViewBottomConstraint: NSLayoutConstraint?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupUI()
        setupTable()
        setupEmptyState()
        setupNotifications()
        setupKeyboardHandling()
        setupDismissKeyboardGesture()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchConversations()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - Setup
    private func setupUI() {
        [titleLabel, searchContainer, segmentedControl, tableView, loadingIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        searchContainer.backgroundColor = .white
        searchContainer.layer.cornerRadius = 20
        searchField.placeholder = "Search".localized
        searchField.returnKeyType = .search
        searchField.clearButtonMode = .whileEditing
        searchField.delegate = self
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchContainer.addSubview(searchField)
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        searchField.addTarget(self, action: #selector(searchChanged), for: .editingChanged)
        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

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
            tableViewBottomConstraint!
        ])
        titleLabel.accessibilityTraits = .header
        searchField.accessibilityLabel = "Search conversations".localized
        segmentedControl.accessibilityLabel = "Filter conversations".localized
    }

    private func setupTable() {
        tableView.register(ChatCell.self, forCellReuseIdentifier: ChatCell.reuseId)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
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
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewMessage(_:)),
                                               name: .newChatMessageReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleProductDeleted(_:)),
                                               name: .productDeleted, object: nil)
    }

    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }

    @objc private func handleBackgroundTap() {
        view.endEditing(true)
    }

    @objc private func handleKeyboardWillHide(_ notification: Notification) {
        applyKeyboardInset(0, notification: notification)
    }

    @objc private func handleKeyboardWillChangeFrame(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let endFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {
            return
        }

        let endFrameInView = view.convert(endFrameValue.cgRectValue, from: nil)
        let overlap = max(0, view.bounds.maxY - endFrameInView.minY - view.safeAreaInsets.bottom)
        applyKeyboardInset(overlap, notification: notification)
    }

    private func applyKeyboardInset(_ inset: CGFloat, notification: Notification) {
        let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let curveRaw = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue
            ?? UInt(UIView.AnimationCurve.easeInOut.rawValue)
        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)

        keyboardBottomInset = max(0, inset)

        UIView.animate(withDuration: duration, delay: 0, options: [options, .beginFromCurrentState]) {
            self.tableViewBottomConstraint?.constant = -self.keyboardBottomInset
            self.tableView.contentInset.bottom = 0
            var indicatorInsets = self.tableView.verticalScrollIndicatorInsets
            indicatorInsets.bottom = 0
            self.tableView.verticalScrollIndicatorInsets = indicatorInsets
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Fetch
    private func fetchConversations() {
        loadingIndicator.startAnimating()
        Task {
            do {
                guard let userId = await AuthManager.shared.currentUserId else {
                    await MainActor.run {
                        self.loadingIndicator.stopAnimating()
                        self.refreshControl.endRefreshing()
                    }
                    return
                }
                self.currentUserId = userId
                let conversations = try await ChatManager.shared.fetchConversations()
                var uiModels: [ConversationUIModel] = []
                for conv in conversations {
                    guard let conversationId = conv.id else {
                        print("🟥 [ChatDebug] ChatView dropped conversation with nil id product_id=\(conv.product_id)")
                        continue
                    }
                    let isSeller = conv.seller_id == userId
                    let otherUser = isSeller ? conv.buyer : conv.seller
                    let unreadCount = try await ChatRepository().getUnreadCount(conversationId: conversationId)
                    let uiModel = ConversationUIModel(
                        id: conversationId,
                        productId: conv.product_id,
                        productTitle: conv.product?.title ?? "Product",
                        productImageURL: conv.product?.image_url,
                        otherUserId: otherUser?.id ?? "",
                        otherUserName: otherUser?.displayName ?? "User",
                        otherUserImageURL: otherUser?.profile_image_url,
                        lastMessage: conv.last_message?.previewText ?? "",
                        lastMessageTime: conv.last_message?.created_at,
                        unreadCount: unreadCount,
                        isSeller: isSeller,
                        productStatus: conv.product?.status
                    )
                    uiModels.append(uiModel)
                }
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

    // MARK: - Archived Toggle
    private func toggleArchivedSection() {
        isArchivedExpanded.toggle()
        archivedHeaderView.configure(count: archivedConversations.count, isExpanded: isArchivedExpanded)
        tableView.reloadSections(IndexSet(integer: Section.archived.rawValue), with: .fade)
        HapticFeedback.selection()
    }

    // MARK: - Actions
    @objc private func segmentChanged() {
        activeSegment = segmentedControl.selectedSegmentIndex == 1 ? .selling :
                        segmentedControl.selectedSegmentIndex == 2 ? .buying : .all
        applyFilters()
    }

    private func previewText(for message: MessageDTO) -> String {
        message.message_type == "image" ? "📷 Photo" : (message.content ?? "")
    }

    @discardableResult
    private func applyIncomingMessageToList(message: MessageDTO, conversationId: String) -> Bool {
        guard let index = allConversations.firstIndex(where: { $0.id == conversationId }) else {
            return false
        }

        let existing = allConversations[index]
        let isIncomingForCurrentUser = message.sender_id != currentUserId
        let isChatCurrentlyOpen = ChatManager.shared.activeConversationId == conversationId
        let shouldIncrementUnread = isIncomingForCurrentUser && !isChatCurrentlyOpen

        let updated = ConversationUIModel(
            id: existing.id,
            productId: existing.productId,
            productTitle: existing.productTitle,
            productImageURL: existing.productImageURL,
            otherUserId: existing.otherUserId,
            otherUserName: existing.otherUserName,
            otherUserImageURL: existing.otherUserImageURL,
            lastMessage: previewText(for: message),
            lastMessageTime: message.created_at ?? Date(),
            unreadCount: existing.unreadCount + (shouldIncrementUnread ? 1 : 0),
            isSeller: existing.isSeller,
            productStatus: existing.productStatus
        )

        allConversations[index] = updated
        allConversations.sort { ($0.lastMessageTime ?? Date.distantPast) > ($1.lastMessageTime ?? Date.distantPast) }
        applyFilters()
        return true
    }

    @objc private func searchChanged() { applyFilters() }
    @objc private func handleRefresh() { HapticFeedback.pullToRefresh(); fetchConversations() }
    @objc private func handleNewMessage(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let message = userInfo["message"] as? MessageDTO,
              let conversationId = userInfo["conversationId"] as? String else {
            fetchConversations()
            return
        }

        let updatedImmediately = applyIncomingMessageToList(message: message, conversationId: conversationId)
        if !updatedImmediately {
            // New conversation may not exist in-memory yet.
            fetchConversations()
            return
        }

        // Keep local optimistic update in sync with server unread counts.
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 700_000_000)
            self?.fetchConversations()
        }
    }
    @objc private func handleProductDeleted(_ notification: Notification) {
        guard let productId = notification.userInfo?["productId"] as? String else { return }
        allConversations.removeAll { $0.productId == productId }
        applyFilters()
    }

    private func applyFilters() {
        var result = allConversations
        switch activeSegment {
        case .all:      break
        case .selling:  result = result.filter { $0.isSeller }
        case .buying:   result = result.filter { !$0.isSeller }
        }
        let query = searchField.text ?? ""
        if !query.isEmpty {
            result = result.filter {
                $0.productTitle.localizedCaseInsensitiveContains(query) ||
                $0.otherUserName.localizedCaseInsensitiveContains(query)
            }
        }
        activeConversations   = result.filter { !$0.isArchived }
        archivedConversations = result.filter {  $0.isArchived }
        archivedHeaderView.configure(count: archivedConversations.count, isExpanded: isArchivedExpanded)
        tableView.reloadData()
        updateEmptyState()
    }

    private func updateEmptyState() {
        let isEmpty = activeConversations.isEmpty && archivedConversations.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    private func openConversation(_ conversation: ConversationUIModel) {
        view.endEditing(true)
        guard let conversationId = conversation.id else { return }
        let detailVC = ChatDetailViewController()
        detailVC.conversationIdString = conversationId
        detailVC.chatTitle = conversation.productTitle
        detailVC.otherUserName = conversation.otherUserName
        detailVC.isSeller = conversation.isSeller
        detailVC.productIdString = conversation.productId
        detailVC.otherUserImageURL = conversation.otherUserImageURL
        detailVC.productStatus = conversation.productStatus ?? "available"
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Table DataSource & Delegate
extension ChatViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return archivedConversations.isEmpty ? 1 : Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .active:   return activeConversations.count
        case .archived: return isArchivedExpanded ? archivedConversations.count : 0
        case .none:     return 0
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChatCell.reuseId,
            for: indexPath
        ) as! ChatCell
        switch Section(rawValue: indexPath.section) {
        case .active:   cell.configure(with: activeConversations[indexPath.row])
        case .archived: cell.configure(with: archivedConversations[indexPath.row], dimmed: true)
        case .none:     break
        }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard Section(rawValue: section) == .archived, !archivedConversations.isEmpty else { return nil }
        return archivedHeaderView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard Section(rawValue: section) == .archived, !archivedConversations.isEmpty else { return 0 }
        return 44
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section) {
        case .active:   openConversation(activeConversations[indexPath.row])
        case .archived: openConversation(archivedConversations[indexPath.row])
        case .none:     break
        }
    }

    // MARK: - External Navigation
    func navigateToConversation(id conversationId: UUID) {
        let allVisible = activeConversations + archivedConversations
        if let conversation = allVisible.first(where: { UUID(uuidString: $0.id ?? "") == conversationId }) {
            openConversation(conversation)
        } else {
            let detailVC = ChatDetailViewController()
            detailVC.conversationId = conversationId
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    func navigateToConversation(id conversationId: String) {
        print("🟦 [ChatDebug] ChatView.navigateToConversation(id: String) requested conversationId=\(conversationId)")
        let allVisible = activeConversations + archivedConversations
        if let conversation = allVisible.first(where: { $0.id == conversationId }) {
            print("🟩 [ChatDebug] Conversation found in list; opening existing row")
            openConversation(conversation)
        } else {
            print("🟨 [ChatDebug] Conversation not found in current list; opening detail directly")
            let detailVC = ChatDetailViewController()
            detailVC.conversationIdString = conversationId
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

