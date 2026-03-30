//
//  ChatDetailViewController.swift
//  Unizo_iOS
//
//  Real-time chat detail screen with Supabase integration
//

import UIKit
import Supabase
import PhotosUI

class ChatDetailViewController: UIViewController {

    // MARK: - Inputs from previous screen
    var conversationId: UUID!
    var chatTitle: String = ""
    var otherUserName: String = ""
    var isSeller: Bool = true
    var productStatus: String = "available"
    var otherUserImageURL: String?
    var productId: UUID?

    // MARK: - Data
    private var messages: [MessageUIModel] = []
    private var currentUserId: UUID?
    private var currentUserImageURL: String?
    private var isLoadingMessages = false

    // MARK: - UI ELEMENTS

    // BACK BUTTON
    private let backButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        b.tintColor = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1.0) // Teal
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // PROFILE ICON - Teal circular
    private let profileCircle: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1.0) // Teal
        v.layer.cornerRadius = 22
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        v.transform = .identity
        return v
    }()

    private let profileIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "person.fill"))
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let roleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        l.textColor = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1.0) // Teal
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

    // TABLEVIEW
    private let tableView: UITableView = {
        let t = UITableView()
        t.separatorStyle = .none
        t.backgroundColor = .systemGray6
        t.translatesAutoresizingMaskIntoConstraints = false
        t.showsVerticalScrollIndicator = false
        t.allowsSelection = false
        t.keyboardDismissMode = .interactive
        return t
    }()

    // Loading indicator
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // INPUT BAR
    private let inputContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .systemGray6
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let addButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "photo"), for: .normal)
        b.tintColor = .gray
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let inputField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Type a message...".localized
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 20
        tf.layer.borderWidth = 0.5
        tf.layer.borderColor = UIColor.systemGray4.cgColor
        tf.setLeftPadding(16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let sendButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1) // Teal send button
        b.layer.cornerRadius = 18
        b.setImage(UIImage(systemName: "arrow.up"), for: .normal)
        b.tintColor = .white
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // Keyboard handling
    private var inputContainerBottomConstraint: NSLayoutConstraint!

    // Sold banner (shown when product is sold)
    private let soldBannerView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemGray4
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()

    // Deal button (shown for buyers only)
    private let dealButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Deal".localized, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1.0)
        b.layer.cornerRadius = 16
        b.translatesAutoresizingMaskIntoConstraints = false
        b.isHidden = true
        return b
    }()

    private let soldBannerLabel: UILabel = {
        let l = UILabel()
        l.text = "This product has been sold".localized
        l.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        l.textColor = .darkGray
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGray6

        setupHeader()
        setupTable()
        setupInputBar()
        setupKeyboardObservers()
        setupNotifications()

        // Remove nav bar completely
        navigationController?.setNavigationBarHidden(true, animated: false)

        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addPhotoTapped), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)

        titleLabel.text = chatTitle
        roleLabel.text = isSeller ? "Buyer".localized : "Seller".localized

        // TASK-15: Load other user's profile image if available
        if let imageURL = otherUserImageURL, !imageURL.isEmpty {
            profileIcon.loadImage(from: imageURL)
            profileIcon.contentMode = .scaleAspectFill
            profileIcon.clipsToBounds = true
            profileIcon.layer.cornerRadius = 22 // Matches constraints (44x44)
            profileCircle.backgroundColor = .clear
        }

        // TASK-20: Disable chat if product is sold
        if productStatus == "sold" {
            inputContainer.isHidden = true
            setupSoldBanner()
        }

        // Fetch current user and messages
        fetchCurrentUser()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true

        // Set active conversation to suppress notifications for this chat
        ChatManager.shared.activeConversationId = conversationId

        // Mark messages as read when entering
        markMessagesAsRead()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
        stopPolling()

        // Clear active conversation so notifications can show again
        ChatManager.shared.activeConversationId = nil
    }

    deinit {
        stopPolling()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup
    private func fetchCurrentUser() {
        Task { [weak self] in
            guard let self = self else { return }
            // Fetch current user details including avatar
            self.currentUserId = await AuthManager.shared.currentUserId
            
            if let user = try? await UserRepository().fetchCurrentUser() {
                self.currentUserImageURL = user.profile_image_url
            }

            // Fetch product status if we have a productId (ensures sold banner / deal button are accurate)
            if let productId = self.productId {
                await self.fetchProductStatus(productId: productId)
            }

            await self.fetchMessages()
        }
    }

    private func fetchProductStatus(productId: UUID) async {
        do {
            struct ProductStatusResult: Decodable {
                let status: String?
            }
            let result: ProductStatusResult = try await SupabaseManager.shared.client
                .from("products")
                .select("status")
                .eq("id", value: productId.uuidString)
                .single()
                .execute()
                .value

            if let status = result.status {
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.productStatus = status
                    if status == "sold" {
                        self.inputContainer.isHidden = true
                        self.dealButton.isHidden = true
                        self.setupSoldBanner()
                    }
                }
            }
        } catch {
            print("Failed to fetch product status: \(error)")
        }
    }

    private func fetchMessages() async {
        guard let conversationId = conversationId else { return }

        await MainActor.run {
            self.loadingIndicator.startAnimating()
        }

        do {
            let messageDTOs = try await ChatManager.shared.fetchMessages(conversationId: conversationId)

            guard let userId = currentUserId else { return }

            let uiModels = messageDTOs.map { MessageMapper.toUIModel($0, currentUserId: userId) }

            await MainActor.run {
                self.messages = uiModels
                self.tableView.reloadData()
                self.scrollToBottom(animated: false)
                self.loadingIndicator.stopAnimating()
            }

            // Subscribe to real-time updates for this conversation
            await ChatManager.shared.subscribeToConversation(conversationId)

        } catch {
            print("❌ Failed to fetch messages: \(error)")
            await MainActor.run {
                self.loadingIndicator.stopAnimating()
            }
        }
    }

    private func markMessagesAsRead() {
        guard let conversationId = conversationId else { return }
        Task {
            await ChatManager.shared.markConversationAsRead(conversationId)
        }
    }

    // MARK: - Notifications & Polling
    private var pollingTimer: Timer?

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewMessage(_:)),
            name: .newChatMessageReceived,
            object: nil
        )

        // Start polling for new messages as fallback (every 3 seconds)
        startPolling()
    }

    private func startPolling() {
        pollingTimer?.invalidate()
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.pollForNewMessages()
        }
    }

    private func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }

    private func pollForNewMessages() {
        guard let conversationId = conversationId else { return }

        Task { [weak self] in
            do {
                let messageDTOs = try await ChatManager.shared.fetchMessages(conversationId: conversationId)

                guard let self = self, let userId = self.currentUserId else { return }

                let newMessages = messageDTOs.map { MessageMapper.toUIModel($0, currentUserId: userId) }

                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    let currentCount = self.messages.count
                    if newMessages.count > currentCount {
                        self.messages = newMessages
                        self.tableView.reloadData()
                        self.scrollToBottom(animated: true)
                    }
                }
            } catch {
                // Silently fail - polling is a fallback
            }
        }
    }

    @objc private func handleNewMessage(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let message = userInfo["message"] as? MessageDTO,
              let convId = userInfo["conversationId"] as? UUID,
              convId == conversationId,
              let userId = currentUserId else {
            return
        }

        // Convert to UI model and add to messages
        let uiModel = MessageMapper.toUIModel(message, currentUserId: userId)

        // Check if message already exists (avoid duplicates)
        guard !messages.contains(where: { $0.id == uiModel.id }) else { return }

        messages.append(uiModel)
        tableView.reloadData()
        scrollToBottom(animated: true)

        // Mark as read if message is from other user
        if !uiModel.isMine {
            markMessagesAsRead()
        }
    }

    // MARK: - HEADER
    private func setupHeader() {
        view.addSubview(backButton)
        view.addSubview(profileCircle)
        profileCircle.addSubview(profileIcon)
        view.addSubview(roleLabel)
        view.addSubview(titleLabel)
        view.addSubview(dealButton)

        dealButton.addTarget(self, action: #selector(dealTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            profileCircle.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 4),
            profileCircle.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            profileCircle.widthAnchor.constraint(equalToConstant: 44),
            profileCircle.heightAnchor.constraint(equalToConstant: 44),

            profileIcon.centerXAnchor.constraint(equalTo: profileCircle.centerXAnchor),
            profileIcon.centerYAnchor.constraint(equalTo: profileCircle.centerYAnchor),
            profileIcon.widthAnchor.constraint(equalToConstant: 44),
            profileIcon.heightAnchor.constraint(equalToConstant: 44),

            roleLabel.leadingAnchor.constraint(equalTo: profileCircle.trailingAnchor, constant: 10),
            roleLabel.topAnchor.constraint(equalTo: profileCircle.topAnchor, constant: 4),

            titleLabel.leadingAnchor.constraint(equalTo: roleLabel.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: dealButton.leadingAnchor, constant: -8),

            dealButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dealButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            dealButton.widthAnchor.constraint(equalToConstant: 70),
            dealButton.heightAnchor.constraint(equalToConstant: 32)
        ])

        // Show Deal button only for buyers when product is available
        if !isSeller && productStatus != "sold" {
            dealButton.isHidden = false
        }

        // Accessibility
        backButton.accessibilityLabel = "Go back".localized
        backButton.accessibilityHint = "Return to conversations list".localized
        titleLabel.accessibilityTraits = .header
        roleLabel.accessibilityTraits = .staticText
        dealButton.accessibilityLabel = "Make a deal".localized
        dealButton.accessibilityHint = "Place an order for this product".localized
    }

    // MARK: - TABLE
    private func setupTable() {
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChatBubbleCell.self, forCellReuseIdentifier: "ChatBubbleCell")
        tableView.register(ChatImageCell.self, forCellReuseIdentifier: "ChatImageCell")

        // NOTE: tableView.bottom is pinned to inputContainer.top in setupInputBar()
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: profileCircle.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            loadingIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }

    // MARK: - INPUT BAR
    private func setupInputBar() {
        view.addSubview(inputContainer)
        inputContainer.addSubview(addButton)
        inputContainer.addSubview(inputField)
        inputContainer.addSubview(sendButton)

        inputContainerBottomConstraint = inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

        NSLayoutConstraint.activate([
            // Pin tableView bottom dynamically to input bar top
            tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor, constant: -4),

            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerBottomConstraint,
            inputContainer.heightAnchor.constraint(equalToConstant: 56),

            addButton.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 16),
            addButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 28),
            addButton.heightAnchor.constraint(equalToConstant: 28),

            inputField.leadingAnchor.constraint(equalTo: addButton.trailingAnchor, constant: 12),
            inputField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -12),
            inputField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            inputField.heightAnchor.constraint(equalToConstant: 36),

            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 36),
            sendButton.heightAnchor.constraint(equalToConstant: 36)
        ])

        // Accessibility
        addButton.accessibilityLabel = "Attach photo".localized
        addButton.accessibilityHint = "Select a photo to send".localized
        inputField.accessibilityLabel = "Message input".localized
        sendButton.accessibilityLabel = "Send message".localized
        sendButton.accessibilityHint = "Send the typed message".localized

        // Update send button state based on text
        inputField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        updateSendButtonState()
    }

    // MARK: - Sold Banner (TASK-20)
    private func setupSoldBanner() {
        view.addSubview(soldBannerView)
        soldBannerView.addSubview(soldBannerLabel)
        soldBannerView.isHidden = false

        NSLayoutConstraint.activate([
            soldBannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            soldBannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            soldBannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            soldBannerView.heightAnchor.constraint(equalToConstant: 44),

            soldBannerLabel.centerXAnchor.constraint(equalTo: soldBannerView.centerXAnchor),
            soldBannerLabel.centerYAnchor.constraint(equalTo: soldBannerView.centerYAnchor)
        ])

        soldBannerView.accessibilityLabel = "This product has been sold".localized
    }

    // MARK: - Keyboard Handling
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom

        UIView.animate(withDuration: duration) {
            self.inputContainerBottomConstraint.constant = -keyboardHeight
            self.view.layoutIfNeeded()
        }

        scrollToBottom(animated: true)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        UIView.animate(withDuration: duration) {
            self.inputContainerBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Actions
    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Deal Action
    @objc private func dealTapped() {
        guard let productId = productId else {
            let alert = UIAlertController(
                title: "Error".localized,
                message: "Product information not available".localized,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
            present(alert, animated: true)
            return
        }

        let alert = UIAlertController(
            title: "Make a Deal".localized,
            message: String(format: "Would you like to place an order for %@?".localized, chatTitle),
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: "Place Order".localized, style: .default) { [weak self] _ in
            self?.fetchProductAndNavigateToOrder(productId: productId)
        })

        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))
        present(alert, animated: true)
    }

    private func fetchProductAndNavigateToOrder(productId: UUID) {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let product: ProductDTO = try await SupabaseManager.shared.client
                    .from("products")
                    .select("*, users!products_seller_id_fkey(first_name, last_name)")
                    .eq("id", value: productId.uuidString)
                    .single()
                    .execute()
                    .value

                let uiModel = ProductMapper.toUIModel(product)
                let orderItem = OrderItem(product: uiModel, quantity: 1)

                await MainActor.run { [weak self] in
                    let confirmVC = ConfirmOrderViewController()
                    confirmVC.orderItems = [orderItem]
                    self?.navigationController?.pushViewController(confirmVC, animated: true)
                }
            } catch {
                print("Failed to fetch product for deal: \(error)")
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    let alert = UIAlertController(
                        title: "Error".localized,
                        message: "Failed to load product details".localized,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    @objc private func addPhotoTapped() {
        guard productStatus != "sold" else { return }

        HapticFeedback.selection()

        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func sendTapped() {
        guard let text = inputField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty,
              let conversationId = conversationId else {
            return
        }

        HapticFeedback.send()

        // Clear input immediately for better UX
        let messageText = text
        inputField.text = ""
        updateSendButtonState()

        // Create optimistic message immediately for instant feedback
        if let userId = currentUserId {
            let optimisticMessage = MessageUIModel(
                id: UUID(), // Temporary ID
                conversationId: conversationId,
                senderId: userId,
                content: messageText,
                messageType: .text,
                imageURL: nil,
                isRead: false,
                createdAt: Date(),
                isMine: true
            )
            messages.append(optimisticMessage)
            tableView.reloadData()
            scrollToBottom(animated: true)
        }

        // Send message to server
        Task {
            do {
                let _ = try await ChatManager.shared.sendMessage(conversationId: conversationId, content: messageText)
                print("✅ Message sent successfully")

                // Refresh messages to get the real message from server
                await fetchMessages()

            } catch {
                print("❌ Failed to send message: \(error)")
                await MainActor.run {
                    // Remove optimistic message and restore text on error
                    if let lastMessage = self.messages.last, lastMessage.content == messageText {
                        self.messages.removeLast()
                        self.tableView.reloadData()
                    }
                    self.inputField.text = messageText
                    self.updateSendButtonState()
                    HapticFeedback.error()
                }
            }
        }
    }

    @objc private func textFieldDidChange() {
        updateSendButtonState()
    }

    private func updateSendButtonState() {
        let hasText = !(inputField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        sendButton.isEnabled = hasText
        sendButton.alpha = hasText ? 1.0 : 0.5
    }

    private func scrollToBottom(animated: Bool) {
        guard !messages.isEmpty else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }

    // MARK: - Send Image
    private func sendImage(_ image: UIImage) {
        guard let conversationId = conversationId,
              let imageData = image.jpegData(compressionQuality: 0.7) else {
            return
        }

        // Show loading state
        let loadingAlert = UIAlertController(title: nil, message: "Sending photo...".localized, preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.startAnimating()
        loadingAlert.view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingAlert.view.centerXAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: loadingAlert.view.bottomAnchor, constant: -20)
        ])

        present(loadingAlert, animated: true)

        Task {
            do {
                let message = try await ChatManager.shared.sendImageMessage(conversationId: conversationId, imageData: imageData)

                if let userId = currentUserId {
                    let uiModel = MessageMapper.toUIModel(message, currentUserId: userId)

                    await MainActor.run {
                        loadingAlert.dismiss(animated: true)

                        if !self.messages.contains(where: { $0.id == uiModel.id }) {
                            self.messages.append(uiModel)
                            self.tableView.reloadData()
                            self.scrollToBottom(animated: true)
                        }

                        HapticFeedback.send()
                    }
                }

            } catch {
                print("❌ Failed to send image: \(error)")
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        let alert = UIAlertController(
                            title: "Failed to Send".localized,
                            message: "Could not send the photo. Please try again.".localized,
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
                        self.present(alert, animated: true)
                    }
                    HapticFeedback.error()
                }
            }
        }
    }
}

// MARK: - TableView DataSource & Delegate
extension ChatDetailViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = messages[indexPath.row]

        let imageURL = msg.isMine ? currentUserImageURL : otherUserImageURL

        if msg.messageType == .image {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatImageCell", for: indexPath) as! ChatImageCell
            cell.configure(with: msg, otherUserImageURL: imageURL)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatBubbleCell", for: indexPath) as! ChatBubbleCell
            cell.configure(isMine: msg.isMine, text: msg.content ?? "", time: msg.formattedTime, otherUserImageURL: imageURL)
            return cell
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
extension ChatDetailViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let result = results.first else { return }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let image = object as? UIImage else { return }

            DispatchQueue.main.async {
                self?.sendImage(image)
            }
        }
    }
}

// MARK: - CHAT BUBBLE CELL (Text)
final class ChatBubbleCell: UITableViewCell {

    private let bubble = UIView()
    private let label = UILabel()
    private let timeLabel = UILabel()
    private let avatarImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .clear

        bubble.layer.cornerRadius = 18
        bubble.translatesAutoresizingMaskIntoConstraints = false

        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false

        timeLabel.font = UIFont.systemFont(ofSize: 11)
        timeLabel.textColor = .gray
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 14
        avatarImageView.backgroundColor = .systemGray4
        avatarImageView.image = UIImage(systemName: "person.fill")
        avatarImageView.tintColor = .white
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(avatarImageView)
        contentView.addSubview(bubble)
        contentView.addSubview(timeLabel)
        bubble.addSubview(label)
    }

    required init?(coder: NSCoder) { fatalError("") }

    func configure(isMine: Bool, text: String, time: String, otherUserImageURL: String?) {

        // Teal for sender, grey for receiver
        bubble.backgroundColor = isMine
            ? UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1)
            : UIColor(white: 0.92, alpha: 1)

        label.textColor = isMine ? .white : .black
        label.text = text
        timeLabel.text = time

        avatarImageView.isHidden = false
        if let imageURL = otherUserImageURL, !imageURL.isEmpty {
            avatarImageView.loadImage(from: imageURL)
        } else {
            avatarImageView.image = UIImage(systemName: "person.fill")
        }

        // Remove old constraints before applying new
        bubble.removeConstraints(bubble.constraints)
        timeLabel.removeConstraints(timeLabel.constraints)
        avatarImageView.removeFromSuperview()
        bubble.removeFromSuperview()
        timeLabel.removeFromSuperview()
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(bubble)
        contentView.addSubview(timeLabel)
        bubble.addSubview(label)

        let horizontalPadding: CGFloat = 70

        if isMine {
            NSLayoutConstraint.activate([
                avatarImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                avatarImageView.bottomAnchor.constraint(equalTo: bubble.bottomAnchor),
                avatarImageView.widthAnchor.constraint(equalToConstant: 28),
                avatarImageView.heightAnchor.constraint(equalToConstant: 28),

                bubble.trailingAnchor.constraint(equalTo: avatarImageView.leadingAnchor, constant: -8),
                bubble.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: horizontalPadding),
                bubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),

                label.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -16),
                label.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 12),
                label.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -12),

                timeLabel.topAnchor.constraint(equalTo: bubble.bottomAnchor, constant: 4),
                timeLabel.trailingAnchor.constraint(equalTo: bubble.trailingAnchor),
                timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
            ])

        } else {
            NSLayoutConstraint.activate([
                avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                avatarImageView.bottomAnchor.constraint(equalTo: bubble.bottomAnchor),
                avatarImageView.widthAnchor.constraint(equalToConstant: 28),
                avatarImageView.heightAnchor.constraint(equalToConstant: 28),

                bubble.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
                bubble.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -horizontalPadding),
                bubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),

                label.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -16),
                label.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 12),
                label.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -12),

                timeLabel.topAnchor.constraint(equalTo: bubble.bottomAnchor, constant: 4),
                timeLabel.leadingAnchor.constraint(equalTo: bubble.leadingAnchor),
                timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
            ])
        }
    }
}

// MARK: - CHAT IMAGE CELL
final class ChatImageCell: UITableViewCell {

    private let bubble = UIView()
    private let chatImageView = UIImageView()
    private let timeLabel = UILabel()
    private let avatarImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .clear

        bubble.layer.cornerRadius = 18
        bubble.clipsToBounds = true
        bubble.translatesAutoresizingMaskIntoConstraints = false

        chatImageView.contentMode = .scaleAspectFill
        chatImageView.clipsToBounds = true
        chatImageView.layer.cornerRadius = 14
        chatImageView.backgroundColor = .systemGray5
        chatImageView.translatesAutoresizingMaskIntoConstraints = false

        timeLabel.font = UIFont.systemFont(ofSize: 11)
        timeLabel.textColor = .gray
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 14
        avatarImageView.backgroundColor = .systemGray4
        avatarImageView.image = UIImage(systemName: "person.fill")
        avatarImageView.tintColor = .white
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(avatarImageView)
        contentView.addSubview(bubble)
        contentView.addSubview(timeLabel)
        bubble.addSubview(chatImageView)
    }

    required init?(coder: NSCoder) { fatalError("") }

    func configure(with message: MessageUIModel, otherUserImageURL: String?) {
        let isMine = message.isMine

        // Teal for sender, grey for receiver
        bubble.backgroundColor = isMine
            ? UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1)
            : UIColor(white: 0.92, alpha: 1)

        timeLabel.text = message.formattedTime

        // Load image
        if let imageURL = message.imageURL {
            chatImageView.loadImage(from: imageURL)
        }

        avatarImageView.isHidden = false
        if let imgURL = otherUserImageURL, !imgURL.isEmpty {
            avatarImageView.loadImage(from: imgURL)
        } else {
            avatarImageView.image = UIImage(systemName: "person.fill")
        }

        // Remove old constraints
        avatarImageView.removeFromSuperview()
        bubble.removeFromSuperview()
        timeLabel.removeFromSuperview()
        contentView.addSubview(avatarImageView)
        contentView.addSubview(bubble)
        contentView.addSubview(timeLabel)
        bubble.addSubview(chatImageView)

        let horizontalPadding: CGFloat = 100

        if isMine {
            NSLayoutConstraint.activate([
                avatarImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                avatarImageView.bottomAnchor.constraint(equalTo: bubble.bottomAnchor),
                avatarImageView.widthAnchor.constraint(equalToConstant: 28),
                avatarImageView.heightAnchor.constraint(equalToConstant: 28),

                bubble.trailingAnchor.constraint(equalTo: avatarImageView.leadingAnchor, constant: -8),
                bubble.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: horizontalPadding),
                bubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),

                chatImageView.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 4),
                chatImageView.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -4),
                chatImageView.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 4),
                chatImageView.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -4),
                chatImageView.widthAnchor.constraint(equalToConstant: 200),
                chatImageView.heightAnchor.constraint(equalToConstant: 200),

                timeLabel.topAnchor.constraint(equalTo: bubble.bottomAnchor, constant: 4),
                timeLabel.trailingAnchor.constraint(equalTo: bubble.trailingAnchor),
                timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
            ])
        } else {
            NSLayoutConstraint.activate([
                avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                avatarImageView.bottomAnchor.constraint(equalTo: bubble.bottomAnchor),
                avatarImageView.widthAnchor.constraint(equalToConstant: 28),
                avatarImageView.heightAnchor.constraint(equalToConstant: 28),

                bubble.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
                bubble.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -horizontalPadding),
                bubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),

                chatImageView.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 4),
                chatImageView.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -4),
                chatImageView.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 4),
                chatImageView.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -4),
                chatImageView.widthAnchor.constraint(equalToConstant: 200),
                chatImageView.heightAnchor.constraint(equalToConstant: 200),

                timeLabel.topAnchor.constraint(equalTo: bubble.bottomAnchor, constant: 4),
                timeLabel.leadingAnchor.constraint(equalTo: bubble.leadingAnchor),
                timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
            ])
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        chatImageView.image = nil
    }
}

// MARK: - UITextField Padding Helper
extension UITextField {
    func setLeftPadding(_ value: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: value, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
