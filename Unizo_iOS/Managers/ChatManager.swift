//
//  ChatManager.swift
//  Unizo_iOS
//
//  Real-time chat manager using Supabase Realtime
//

import Foundation
import UIKit
import Supabase
import UserNotifications

// MARK: - Chat Manager Delegate
protocol ChatManagerDelegate: AnyObject {
    func chatManager(_ manager: ChatManager, didReceiveMessage message: MessageDTO, inConversation conversationId: UUID)
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

    private let client = SupabaseManager.shared.client
    private let repository = ChatRepository()

    // Active conversation subscriptions
    private var conversationChannels: [UUID: RealtimeChannelV2] = [:]
    private var conversationBuyerChannel: RealtimeChannelV2?
    private var conversationSellerChannel: RealtimeChannelV2?
    private var currentUserId: UUID?
    private var isListening = false

    // Track which conversation is currently being viewed (to suppress notifications)
    var activeConversationId: UUID?

    // Cache conversation info for notifications
    private var conversationCache: [UUID: ConversationDTO] = [:]

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
        guard !isListening else {
            print("ChatManager: Already listening")
            return
        }

        guard let userId = await AuthManager.shared.currentUserId else {
            print("ChatManager: User not authenticated, skipping")
            return
        }

        currentUserId = userId
        isListening = true

        // Fetch initial unread count
        await refreshUnreadCount()

        // Subscribe to all messages for this user's conversations
        await subscribeToGlobalMessages(userId: userId)
        await subscribeToNewConversations(userId: userId)

        print("ChatManager: Started listening for user \(userId)")
    }

    // MARK: - Stop Listening (Call on Logout)
    func stopListening() async {
        guard isListening else { return }

        // Remove all conversation channels
        for (_, channel) in conversationChannels {
            await client.realtimeV2.removeChannel(channel)
        }
        conversationChannels.removeAll()

        // Remove conversation insert channels
        if let channel = conversationBuyerChannel {
            await client.realtimeV2.removeChannel(channel)
            conversationBuyerChannel = nil
        }
        if let channel = conversationSellerChannel {
            await client.realtimeV2.removeChannel(channel)
            conversationSellerChannel = nil
        }

        currentUserId = nil
        isListening = false
        totalUnreadCount = 0

        print("ChatManager: Stopped listening")
    }

    // MARK: - Subscribe to Global Messages
    /// Subscribes to all new messages in user's conversations
    private func subscribeToGlobalMessages(userId: UUID) async {
        // First get all conversation IDs for this user
        do {
            let conversations = try await repository.fetchConversations()
            let conversationIds = conversations.map { $0.id }

            // Subscribe to each conversation
            for conversationId in conversationIds {
                await subscribeToConversation(conversationId)
            }

        } catch {
            print("ChatManager: Failed to fetch conversations for subscription: \(error)")
        }
    }

    // MARK: - Subscribe to New Conversations
    private func subscribeToNewConversations(userId: UUID) async {
        let buyerChannel = client.realtimeV2.channel("chat-conversations-buyer-\(userId.uuidString)")
        let buyerInsertions = buyerChannel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "conversations",
            filter: "buyer_id=eq.\(userId.uuidString)"
        )

        Task {
            for await insertion in buyerInsertions {
                await self.handleConversationInserted(insertion)
            }
        }

        await buyerChannel.subscribe()
        conversationBuyerChannel = buyerChannel

        let sellerChannel = client.realtimeV2.channel("chat-conversations-seller-\(userId.uuidString)")
        let sellerInsertions = sellerChannel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "conversations",
            filter: "seller_id=eq.\(userId.uuidString)"
        )

        Task {
            for await insertion in sellerInsertions {
                await self.handleConversationInserted(insertion)
            }
        }

        await sellerChannel.subscribe()
        conversationSellerChannel = sellerChannel

        print("ChatManager: Subscribed to new conversation inserts")
    }

    private func handleConversationInserted(_ insertion: InsertAction) async {
        struct ConversationInsertRecord: Decodable {
            let id: UUID
        }

        do {
            let data = try JSONEncoder().encode(insertion.record)
            let record = try JSONDecoder().decode(ConversationInsertRecord.self, from: data)
            await subscribeToConversation(record.id)
        } catch {
            print("ChatManager: Failed to decode new conversation insert: \(error)")
        }
    }

    // MARK: - Subscribe to Specific Conversation
    func subscribeToConversation(_ conversationId: UUID) async {
        // Prevent duplicate subscriptions
        guard conversationChannels[conversationId] == nil else {
            print("ChatManager: Already subscribed to conversation \(conversationId)")
            return
        }

        let channel = client.realtimeV2.channel("chat-\(conversationId.uuidString)")

        let insertions = channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "messages",
            filter: "conversation_id=eq.\(conversationId.uuidString)"
        )

        // Handle new messages
        Task {
            for await insertion in insertions {
                await handleNewMessage(insertion, conversationId: conversationId)
            }
        }

        await channel.subscribe()
        conversationChannels[conversationId] = channel

        print("ChatManager: Subscribed to conversation \(conversationId)")
    }

    // MARK: - Unsubscribe from Conversation
    func unsubscribeFromConversation(_ conversationId: UUID) async {
        guard let channel = conversationChannels[conversationId] else { return }

        await client.realtimeV2.removeChannel(channel)
        conversationChannels.removeValue(forKey: conversationId)

        print("ChatManager: Unsubscribed from conversation \(conversationId)")
    }

    // MARK: - Handle New Message
    private func handleNewMessage(_ insertion: InsertAction, conversationId: UUID) async {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(insertion.record)

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let message = try decoder.decode(MessageDTO.self, from: data)

            print("ChatManager: Received message - \(message.content ?? "image")")

            // Only process if message is from someone else
            guard let currentUserId = currentUserId, message.sender_id != currentUserId else {
                return
            }

            // Post notification for observers
            await MainActor.run {
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
            }

        } catch {
            print("ChatManager: Failed to decode message: \(error)")
        }
    }

    // MARK: - Schedule Local Push Notification
    private func scheduleLocalNotification(message: MessageDTO, conversationId: UUID) async {
        // Get conversation info for sender name
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
            "conversationId": conversationId.uuidString
        ]

        let request = UNNotificationRequest(
            identifier: "chat-\(message.id.uuidString)",
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
    func openChatFromNotification(conversationId: UUID) {
        navigateToChat(conversationId: conversationId)
    }

    private func navigateToChat(conversationId: UUID) {
        Task { @MainActor in
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first(where: { $0.isKeyWindow }),
                  let rootVC = window.rootViewController else {
                return
            }

            // Find the navigation controller
            var navController: UINavigationController?

            if let tabBar = rootVC as? MainTabBarController {
                navController = tabBar.selectedViewController as? UINavigationController
            } else if let nav = rootVC as? UINavigationController {
                navController = nav
            }

            // Get conversation info from cache or fetch
            let conversation: ConversationDTO?
            if let cached = conversationCache[conversationId] {
                conversation = cached
            } else {
                conversation = try? await repository.fetchConversation(id: conversationId)
            }

            let chatVC = ChatDetailViewController()
            chatVC.conversationId = conversationId
            chatVC.chatTitle = conversation?.product?.title ?? "Chat"

            if let conv = conversation, let currentUserId = self.currentUserId {
                chatVC.isSeller = conv.seller_id == currentUserId
                if chatVC.isSeller {
                    chatVC.otherUserName = conv.buyer?.displayName ?? "Buyer"
                } else {
                    chatVC.otherUserName = conv.seller?.displayName ?? "Seller"
                }
            }

            if let nav = navController {
                nav.pushViewController(chatVC, animated: true)
            } else {
                let nav = UINavigationController(rootViewController: chatVC)
                nav.modalPresentationStyle = .fullScreen
                rootVC.present(nav, animated: true)
            }
        }
    }

    // MARK: - Refresh Unread Count
    func refreshUnreadCount() async {
        do {
            let count = try await repository.getTotalUnreadCount()
            await MainActor.run {
                self.totalUnreadCount = count
            }
        } catch {
            print("ChatManager: Failed to fetch unread count: \(error)")
        }
    }

    // MARK: - Mark Conversation as Read
    func markConversationAsRead(_ conversationId: UUID) async {
        do {
            try await repository.markMessagesAsRead(conversationId: conversationId)
            await refreshUnreadCount()
        } catch {
            print("ChatManager: Failed to mark as read: \(error)")
        }
    }

    // MARK: - Send Message (with optimistic UI support)
    func sendMessage(conversationId: UUID, content: String) async throws -> MessageDTO {
        let message = try await repository.sendMessage(conversationId: conversationId, content: content)
        return message
    }

    // MARK: - Send Image Message
    func sendImageMessage(conversationId: UUID, imageData: Data) async throws -> MessageDTO {
        // Upload image first
        let imageURL = try await repository.uploadChatImage(imageData, conversationId: conversationId)

        // Send message with image URL
        let message = try await repository.sendImageMessage(conversationId: conversationId, imageURL: imageURL)
        return message
    }

    // MARK: - Get or Create Conversation
    func getOrCreateConversation(productId: UUID, sellerId: UUID) async throws -> ConversationDTO {
        let conversation = try await repository.getOrCreateConversation(productId: productId, sellerId: sellerId)

        // Subscribe to the new conversation
        await subscribeToConversation(conversation.id)

        return conversation
    }

    // MARK: - Fetch Messages
    func fetchMessages(conversationId: UUID) async throws -> [MessageDTO] {
        return try await repository.fetchMessages(conversationId: conversationId)
    }

    // MARK: - Fetch Conversations
    func fetchConversations() async throws -> [ConversationDTO] {
        return try await repository.fetchConversations()
    }
}
