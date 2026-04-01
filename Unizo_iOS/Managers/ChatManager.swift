//
//  ChatManager.swift
//  Unizo_iOS
//
//  Real-time chat manager using Firebase Firestore Subcollections
//

import Foundation
import UIKit
import FirebaseFirestore
import UserNotifications

// MARK: - Chat Manager Delegate
protocol ChatManagerDelegate: AnyObject {
    func chatManager(_ manager: ChatManager, didReceiveMessage message: MessageDTO, inConversation conversationId: String)
    func chatManager(_ manager: ChatManager, didUpdateUnreadCount count: Int)
}

// MARK: - Notification Names
extension Notification.Name {
    static let chatUnreadCountChanged = Notification.Name("chatUnreadCountChanged")
    static let newChatMessageReceived = Notification.Name("newChatMessageReceived")
    static let productDeleted = Notification.Name("productDeleted")
}

// MARK: - Chat Manager
final class ChatManager {

    static let shared = ChatManager()

    private let db = Firestore.firestore()
    private let repository = ChatRepository()

    // Active conversation subscriptions
    private var conversationMessageListeners: [String: ListenerRegistration] = [:]
    
    // Listeners for tracking when new conversations are created for this user
    private var buyerConversationsListener: ListenerRegistration?
    private var sellerConversationsListener: ListenerRegistration?
    
    private var currentUserId: String?
    private var isListening = false

    /// Tracks whether each snapshot listener has received its initial Firestore
    /// snapshot. Firestore fires ALL existing docs as `.added` on first attach;
    /// we skip that batch to avoid false notifications.
    private var didReceiveInitialConversationsSnapshot = false
    private var conversationInitialSnapshotReceived: Set<String> = []

    // Track which conversation is currently being viewed (to suppress notifications)
    var activeConversationId: String?

    // Cache conversation info for notifications
    private var conversationCache: [String: ConversationDTO] = [:]

    weak var delegate: ChatManagerDelegate?

    // Published unread count
    private(set) var totalUnreadCount: Int = 0 {
        didSet {
            delegate?.chatManager(self, didUpdateUnreadCount: totalUnreadCount)
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .chatUnreadCountChanged,
                    object: nil,
                    userInfo: ["count": self.totalUnreadCount]
                )
            }
        }
    }

    private init() {}

    // MARK: - Start Listening (Call on Login)
    func startListening() async {
        guard !isListening else { return }

        guard let userId = await AuthManager.shared.currentUserId else {
            print("ChatManager: User not authenticated, skipping")
            return
        }

        currentUserId = userId
        isListening = true

        // Reset snapshot tracking for new session
        didReceiveInitialConversationsSnapshot = false
        conversationInitialSnapshotReceived.removeAll()

        // Fetch initial unread count
        await refreshUnreadCount()

        // Subscribe to New Conversations (which handles subscribing to messages)
        subscribeToNewConversations(userId: userId)

        print("ChatManager: ✅ Fully started for user \(userId)")
    }

    // MARK: - Stop Listening (Call on Logout)
    func stopListening() async {
        guard isListening else { return }

        // Remove all conversation message channels
        for (_, listener) in conversationMessageListeners {
            listener.remove()
        }
        conversationMessageListeners.removeAll()

        buyerConversationsListener?.remove()
        buyerConversationsListener = nil
        
        sellerConversationsListener?.remove()
        sellerConversationsListener = nil

        currentUserId = nil
        isListening = false
        didReceiveInitialConversationsSnapshot = false
        conversationInitialSnapshotReceived.removeAll()
        totalUnreadCount = 0

        print("ChatManager: ✅ Stopped")
    }

    // MARK: - Subscribe to New Conversations
    private func subscribeToNewConversations(userId: String) {
        
        // Listen where User is Buyer
        buyerConversationsListener = db.collection("conversations")
            .whereField("buyer_id", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let docs = snapshot?.documentChanges else { return }
                for diff in docs {
                    if diff.type == .added {
                        self.subscribeToConversation(diff.document.documentID)
                    }
                }
            }

        // Listen where User is Seller
        sellerConversationsListener = db.collection("conversations")
            .whereField("seller_id", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let docs = snapshot?.documentChanges else { return }
                for diff in docs {
                    if diff.type == .added {
                        self.subscribeToConversation(diff.document.documentID)
                    }
                }
            }

        print("ChatManager: Subscribed to new conversation inserts")
    }

    // MARK: - Subscribe to Specific Conversation
    func subscribeToConversation(_ conversationId: String) {
        // Prevent duplicate subscriptions
        guard conversationMessageListeners[conversationId] == nil else {
            return
        }

        // Mark that the initial message snapshot hasn't been received yet
        conversationInitialSnapshotReceived.remove(conversationId)

        let listener = db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "created_at", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let docs = snapshot?.documentChanges else { return }
                
                // Skip the initial snapshot — it contains all existing messages
                guard self.conversationInitialSnapshotReceived.contains(conversationId) else {
                    self.conversationInitialSnapshotReceived.insert(conversationId)
                    return
                }

                for diff in docs where diff.type == .added {
                    if let message = try? diff.document.data(as: MessageDTO.self) {
                        Task { await self.handleNewMessage(message, conversationId: conversationId) }
                    }
                }
            }

        conversationMessageListeners[conversationId] = listener
        print("ChatManager: Subscribed to conversation \(conversationId)")
    }

    // MARK: - Unsubscribe from Conversation
    func unsubscribeFromConversation(_ conversationId: String) async {
        guard let listener = conversationMessageListeners[conversationId] else { return }
        listener.remove()
        conversationMessageListeners.removeValue(forKey: conversationId)
        print("ChatManager: Unsubscribed from conversation \(conversationId)")
    }

    // MARK: - Handle New Message
    private func handleNewMessage(_ message: MessageDTO, conversationId: String) async {
        print("ChatManager: Received message - \(message.content ?? "image")")

        // Only process if message is from someone else
        guard let currentUserId = currentUserId, message.sender_id != currentUserId else { return }

        // Post notification for observers
        await MainActor.run {
            self.delegate?.chatManager(self, didReceiveMessage: message, inConversation: conversationId)
            NotificationCenter.default.post(
                name: .newChatMessageReceived,
                object: nil,
                userInfo: [
                    "message": message,
                    "conversationId": conversationId
                ]
            )
        }

        // Show in-app banner if user is NOT in this conversation
        if activeConversationId != conversationId {
            await scheduleLocalNotification(message: message, conversationId: conversationId)
            // Ensure unread count drifts up safely
            await MainActor.run { self.totalUnreadCount += 1 }
        }
    }

    // MARK: - Schedule Local Push Notification
    private func scheduleLocalNotification(message: MessageDTO, conversationId: String) async {
        var senderName = "New message"
        
        if let cached = conversationCache[conversationId] {
            if message.sender_id == cached.buyer_id {
                senderName = cached.buyer?.displayName ?? "Buyer"
            } else {
                senderName = cached.seller?.displayName ?? "Seller"
            }
        } else if let conv = try? await repository.fetchConversation(id: conversationId) {
            conversationCache[conversationId] = conv
            if message.sender_id == conv.buyer_id {
                senderName = conv.buyer?.displayName ?? "Buyer"
            } else {
                senderName = conv.seller?.displayName ?? "Seller"
            }
        }

        let content = UNMutableNotificationContent()
        content.title = senderName
        content.body = message.message_type == "image" ? "Sent a photo" : ((message.content?.isEmpty == false) ? (message.content ?? "") : "New message")
        content.sound = .default
        content.userInfo = [
            "type": "chat",
            "conversationId": conversationId
        ]

        let request = UNNotificationRequest(
            identifier: "chat-\(message.id ?? UUID().uuidString)",
            content: content,
            trigger: nil
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("ChatManager: Failed to schedule local notification: \(error)")
        }
    }

    // MARK: - Navigate to Chat
    @MainActor
    func openChatFromNotification(conversationId: String) {
        // Assume root view logic handles the navigation string
    }

    // MARK: - Refresh Unread Count
    func refreshUnreadCount() async {
        do {
            let count = try await repository.getTotalUnreadCount()
            await MainActor.run {
                self.totalUnreadCount = count
            }
        } catch {
            print("ChatManager: Failed to fetch unread count")
        }
    }

    // MARK: - Mark Conversation as Read
    func markConversationAsRead(_ conversationId: String) async {
        do {
            try await repository.markMessagesAsRead(conversationId: conversationId)
            await refreshUnreadCount()
        } catch {
            print("ChatManager: Failed to mark as read")
        }
    }

    // MARK: - Core Interactions

    func sendMessage(conversationId: String, content: String) async throws -> MessageDTO {
        return try await repository.sendMessage(conversationId: conversationId, content: content)
    }

    func sendImageMessage(conversationId: String, imageData: Data) async throws -> MessageDTO {
        let imageURL = try await repository.uploadChatImage(imageData, conversationId: conversationId)
        return try await repository.sendImageMessage(conversationId: conversationId, imageURL: imageURL)
    }

    func getOrCreateConversationId(productId: String, sellerId: String) async throws -> String {
        print("🟦 [ChatDebug] ChatManager.getOrCreateConversationId start productId=\(productId), sellerId=\(sellerId)")
        let conversationId = try await repository.getOrCreateConversationId(productId: productId, sellerId: sellerId)
        print("🟩 [ChatDebug] ChatManager.getOrCreateConversationId success conversationId=\(conversationId)")
        subscribeToConversation(conversationId)
        return conversationId
    }

    func getOrCreateConversation(productId: String, sellerId: String) async throws -> ConversationDTO {
        print("🟦 [ChatDebug] ChatManager.getOrCreateConversation start productId=\(productId), sellerId=\(sellerId)")
        let conversation = try await repository.getOrCreateConversation(productId: productId, sellerId: sellerId)
        guard let conversationId = conversation.id, !conversationId.isEmpty else {
            print("🟥 [ChatDebug] ChatManager.getOrCreateConversation returned nil/empty conversation id")
            throw ChatError.conversationNotFound
        }

        print("🟩 [ChatDebug] ChatManager.getOrCreateConversation success conversationId=\(conversationId)")
        subscribeToConversation(conversationId)
        return conversation
    }

    func fetchMessages(conversationId: String) async throws -> [MessageDTO] {
        return try await repository.fetchMessages(conversationId: conversationId)
    }

    func fetchConversations() async throws -> [ConversationDTO] {
        return try await repository.fetchConversations()
    }
}
