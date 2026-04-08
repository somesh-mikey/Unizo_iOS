//
//  ConversationDTO.swift
//  Unizo_iOS
//
//  Real-time chat conversation model
//

import Foundation
import FirebaseFirestore

// MARK: - Conversation DTO
struct ConversationDTO: Codable, Identifiable {
    @DocumentID var id: String?
    let product_id: String
    let buyer_id: String
    let seller_id: String
    let created_at: Date?

    // Joined data (optional, populated when fetching with joins)
    var product: ConversationProductInfo?
    var buyer: ConversationUserInfo?
    var seller: ConversationUserInfo?
    var last_message: LastMessageInfo?

    enum CodingKeys: String, CodingKey {
        case product_id
        case buyer_id
        case seller_id
        case created_at
        case product
        case buyer
        case seller
        case last_message = "last_message"
    }

    init(
        id: String? = nil,
        product_id: String,
        buyer_id: String,
        seller_id: String,
        created_at: Date? = nil,
        product: ConversationProductInfo? = nil,
        buyer: ConversationUserInfo? = nil,
        seller: ConversationUserInfo? = nil,
        last_message: LastMessageInfo? = nil
    ) {
        self.id = id
        self.product_id = product_id
        self.buyer_id = buyer_id
        self.seller_id = seller_id
        self.created_at = created_at
        self.product = product
        self.buyer = buyer
        self.seller = seller
        self.last_message = last_message
    }
}

// MARK: - Nested Product Info
struct ConversationProductInfo: Codable {
    @DocumentID var id: String?
    let title: String
    let image_url: String?
    let status: String?  // "available", "sold", etc.
}

// MARK: - Nested User Info
struct ConversationUserInfo: Codable {
    @DocumentID var id: String?
    let first_name: String?
    let last_name: String?
    let profile_image_url: String?

    var displayName: String {
        let first = first_name ?? ""
        let last = last_name ?? ""
        let full = "\(first) \(last)".trimmingCharacters(in: .whitespaces)
        return full.isEmpty ? "User" : full
    }
}

// MARK: - Last Message Info (for conversation list preview)
struct LastMessageInfo: Codable {
    var id: String?
    let content: String?
    let message_type: String?
    let sender_id: String
    let created_at: Date?

    init(
        id: String? = nil,
        content: String? = nil,
        message_type: String? = nil,
        sender_id: String,
        created_at: Date? = nil
    ) {
        self.id = id
        self.content = content
        self.message_type = message_type
        self.sender_id = sender_id
        self.created_at = created_at
    }

    var previewText: String {
        if message_type == "image" {
            return "📷 Photo"
        }
        return content ?? ""
    }
}

// MARK: - Conversation Insert DTO
struct ConversationInsertDTO: Encodable {
    let product_id: String
    let buyer_id: String
    let seller_id: String
}

// MARK: - Conversation UI Model
struct ConversationUIModel: Identifiable {
    let id: String?
    let productId: String
    let productTitle: String
    let productImageURL: String?
    let otherUserId: String
    let otherUserName: String
    let otherUserImageURL: String?
    let lastMessage: String
    let lastMessageTime: Date?
    let unreadCount: Int
    let isSeller: Bool  // Is current user the seller in this conversation?
    let productStatus: String?  // e.g. "available", "sold"

    /// True when the linked product has been sold — conversation moves to Archived section
    var isArchived: Bool { productStatus == "sold" }

    var formattedTime: String {
        guard let time = lastMessageTime else { return "" }

        let calendar = Calendar.current

        if calendar.isDateInToday(time) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: time)
        } else if calendar.isDateInYesterday(time) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM"
            return formatter.string(from: time)
        }
    }
}
