//
//  ConversationDTO.swift
//  Unizo_iOS
//
//  Real-time chat conversation model
//

import Foundation

// MARK: - Conversation DTO
struct ConversationDTO: Codable, Identifiable {
    let id: UUID
    let product_id: UUID
    let buyer_id: UUID
    let seller_id: UUID
    let created_at: Date?

    // Joined data (optional, populated when fetching with joins)
    let product: ConversationProductInfo?
    let buyer: ConversationUserInfo?
    let seller: ConversationUserInfo?
    let last_message: LastMessageInfo?

    enum CodingKeys: String, CodingKey {
        case id
        case product_id
        case buyer_id
        case seller_id
        case created_at
        case product
        case buyer
        case seller
        case last_message = "messages"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        product_id = try container.decode(UUID.self, forKey: .product_id)
        buyer_id = try container.decode(UUID.self, forKey: .buyer_id)
        seller_id = try container.decode(UUID.self, forKey: .seller_id)
        created_at = try container.decodeIfPresent(Date.self, forKey: .created_at)
        product = try container.decodeIfPresent(ConversationProductInfo.self, forKey: .product)
        buyer = try container.decodeIfPresent(ConversationUserInfo.self, forKey: .buyer)
        seller = try container.decodeIfPresent(ConversationUserInfo.self, forKey: .seller)

        // Handle last message - it comes as an array, we take the first one
        let messagesArray = try? container.decode([LastMessageInfo].self, forKey: .last_message)
        last_message = messagesArray?.first
    }
}

// MARK: - Nested Product Info
struct ConversationProductInfo: Codable {
    let id: UUID
    let title: String
    let image_url: String?
}

// MARK: - Nested User Info
struct ConversationUserInfo: Codable {
    let id: UUID
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
    let id: UUID
    let content: String?
    let message_type: String?
    let sender_id: UUID
    let created_at: Date?

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
    let id: UUID
    let productId: UUID
    let productTitle: String
    let productImageURL: String?
    let otherUserId: UUID
    let otherUserName: String
    let otherUserImageURL: String?
    let lastMessage: String
    let lastMessageTime: Date?
    let unreadCount: Int
    let isSeller: Bool  // Is current user the seller in this conversation?

    var formattedTime: String {
        guard let time = lastMessageTime else { return "" }

        let calendar = Calendar.current
        let now = Date()

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
