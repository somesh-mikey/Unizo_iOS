//
//  ChatRepository.swift
//  Unizo_iOS
//
//  Repository for chat/messaging operations with Supabase
//

import Foundation
import Supabase

final class ChatRepository {

    // MARK: - Properties
    private let client: SupabaseClient

    // Select fields for conversations with joins
    // Messages are ordered by created_at DESC to get the latest message first
    private let conversationSelectFields = "id,product_id,buyer_id,seller_id,created_at,product:products!product_id(id,title,image_url),buyer:users!buyer_id(id,first_name,last_name,profile_image_url),seller:users!seller_id(id,first_name,last_name,profile_image_url),messages(id,content,message_type,sender_id,created_at)"

    // MARK: - Init
    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }

    // MARK: - Get Current User ID
    private func getCurrentUserId() async throws -> UUID {
        guard let userId = await AuthManager.shared.currentUserId else {
            throw ChatError.notAuthenticated
        }
        return userId
    }

    // MARK: - Fetch User's Conversations
    /// Fetches all conversations for the current user (as buyer or seller)
    func fetchConversations() async throws -> [ConversationDTO] {
        let userId = try await getCurrentUserId()

        // Fetch conversations where user is buyer or seller
        // Order by most recent message
        let response = try await client
            .from("conversations")
            .select(conversationSelectFields)
            .or("buyer_id.eq.\(userId.uuidString),seller_id.eq.\(userId.uuidString)")
            .order("created_at", ascending: false)
            .execute()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode([ConversationDTO].self, from: response.data)
    }

    // MARK: - Fetch or Create Conversation
    /// Gets existing conversation or creates a new one for a product
    func getOrCreateConversation(productId: UUID, sellerId: UUID) async throws -> ConversationDTO {
        let buyerId = try await getCurrentUserId()

        // Don't allow chatting with yourself
        guard buyerId != sellerId else {
            throw ChatError.cannotChatWithSelf
        }

        // Check if conversation already exists
        let existingResponse = try await client
            .from("conversations")
            .select(conversationSelectFields)
            .eq("product_id", value: productId.uuidString)
            .eq("buyer_id", value: buyerId.uuidString)
            .limit(1)
            .execute()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let existing = try decoder.decode([ConversationDTO].self, from: existingResponse.data)

        if let conversation = existing.first {
            return conversation
        }

        // Create new conversation
        let insertDTO = ConversationInsertDTO(
            product_id: productId.uuidString,
            buyer_id: buyerId.uuidString,
            seller_id: sellerId.uuidString
        )

        let createResponse = try await client
            .from("conversations")
            .insert(insertDTO)
            .select(conversationSelectFields)
            .single()
            .execute()

        return try decoder.decode(ConversationDTO.self, from: createResponse.data)
    }

    // MARK: - Fetch Messages
    /// Fetches all messages for a conversation
    func fetchMessages(conversationId: UUID) async throws -> [MessageDTO] {
        let _ = try await getCurrentUserId()

        let response = try await client
            .from("messages")
            .select()
            .eq("conversation_id", value: conversationId.uuidString)
            .order("created_at", ascending: true)
            .execute()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode([MessageDTO].self, from: response.data)
    }

    // MARK: - Send Text Message
    func sendMessage(conversationId: UUID, content: String) async throws -> MessageDTO {
        let senderId = try await getCurrentUserId()

        let messageDTO = MessageInsertDTO(
            conversationId: conversationId,
            senderId: senderId,
            content: content
        )

        let response = try await client
            .from("messages")
            .insert(messageDTO)
            .select()
            .single()
            .execute()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(MessageDTO.self, from: response.data)
    }

    // MARK: - Send Image Message
    func sendImageMessage(conversationId: UUID, imageURL: String) async throws -> MessageDTO {
        let senderId = try await getCurrentUserId()

        let messageDTO = MessageInsertDTO(
            conversationId: conversationId,
            senderId: senderId,
            imageURL: imageURL
        )

        let response = try await client
            .from("messages")
            .insert(messageDTO)
            .select()
            .single()
            .execute()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(MessageDTO.self, from: response.data)
    }

    // MARK: - Upload Chat Image
    func uploadChatImage(_ imageData: Data, conversationId: UUID) async throws -> String {
        let fileName = "\(conversationId.uuidString)_\(Int(Date().timeIntervalSince1970)).jpg"
        let filePath = "chat-images/\(fileName)"

        do {
            try await client.storage
                .from("product-images")
                .upload(filePath, data: imageData, options: .init(upsert: true))
        } catch {
            // Handle Supabase iOS SDK bug workaround
            let nsError = error as NSError
            if nsError.domain != NSURLErrorDomain || nsError.code != -1017 {
                throw error
            }
        }

        // Get public URL
        let publicURL = try client.storage
            .from("product-images")
            .getPublicURL(path: filePath)

        return publicURL.absoluteString
    }

    // MARK: - Mark Messages as Read
    /// Marks all unread messages from the other user as read
    func markMessagesAsRead(conversationId: UUID) async throws {
        // Temporarily disabled until read_at column is properly set up
        // TODO: Re-enable when read_at column exists in messages table
        return

        /*
        let currentUserId = try await getCurrentUserId()

        try await client
            .from("messages")
            .update(MarkMessagesReadDTO())
            .eq("conversation_id", value: conversationId.uuidString)
            .neq("sender_id", value: currentUserId.uuidString)
            .is("read_at", value: nil)
            .execute()
        */
    }

    // MARK: - Get Unread Count for Conversation
    func getUnreadCount(conversationId: UUID) async throws -> Int {
        // Temporarily return 0 until read_at column is properly set up
        // TODO: Re-enable when read_at column exists in messages table
        return 0

        /*
        let currentUserId = try await getCurrentUserId()

        let response = try await client
            .from("messages")
            .select("id", head: true, count: .exact)
            .eq("conversation_id", value: conversationId.uuidString)
            .neq("sender_id", value: currentUserId.uuidString)
            .is("read_at", value: nil)
            .execute()

        return response.count ?? 0
        */
    }

    // MARK: - Get Total Unread Count
    /// Gets total unread message count across all conversations
    func getTotalUnreadCount() async throws -> Int {
        // Temporarily return 0 until read_at column is properly set up
        // TODO: Re-enable when read_at column exists in messages table
        return 0

        /*
        let currentUserId = try await getCurrentUserId()

        // Get all conversation IDs where user is participant
        let conversationsResponse = try await client
            .from("conversations")
            .select("id")
            .or("buyer_id.eq.\(currentUserId.uuidString),seller_id.eq.\(currentUserId.uuidString)")
            .execute()

        struct ConversationId: Codable {
            let id: UUID
        }

        let conversations = try JSONDecoder().decode([ConversationId].self, from: conversationsResponse.data)

        guard !conversations.isEmpty else { return 0 }

        // Get unread messages count
        let conversationIds = conversations.map { $0.id.uuidString }

        let response = try await client
            .from("messages")
            .select("id", head: true, count: .exact)
            .in("conversation_id", values: conversationIds)
            .neq("sender_id", value: currentUserId.uuidString)
            .is("read_at", value: nil)
            .execute()

        return response.count ?? 0
        */
    }

    // MARK: - Fetch Single Conversation
    func fetchConversation(id: UUID) async throws -> ConversationDTO? {
        let _ = try await getCurrentUserId()

        let response = try await client
            .from("conversations")
            .select(conversationSelectFields)
            .eq("id", value: id.uuidString)
            .single()
            .execute()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(ConversationDTO.self, from: response.data)
    }
}

// MARK: - Chat Errors
enum ChatError: LocalizedError {
    case notAuthenticated
    case cannotChatWithSelf
    case conversationNotFound
    case messageSendFailed

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be logged in to chat"
        case .cannotChatWithSelf:
            return "You cannot chat with yourself"
        case .conversationNotFound:
            return "Conversation not found"
        case .messageSendFailed:
            return "Failed to send message"
        }
    }
}
