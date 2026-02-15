//
//  MessageDTO.swift
//  Unizo_iOS
//
//  Real-time chat message model
//

import Foundation

// MARK: - Message DTO
struct MessageDTO: Codable, Identifiable {
    let id: UUID
    let conversation_id: UUID
    let sender_id: UUID
    let content: String?
    let message_type: String  // "text" or "image"
    let image_url: String?
    let read_at: Date?
    let created_at: Date?

    var isRead: Bool {
        return read_at != nil
    }

    var isImage: Bool {
        return message_type == "image"
    }
}

// MARK: - Message Insert DTO
struct MessageInsertDTO: Encodable {
    let conversation_id: String
    let sender_id: String
    let content: String?
    let message_type: String
    let image_url: String?

    init(conversationId: UUID, senderId: UUID, content: String) {
        self.conversation_id = conversationId.uuidString
        self.sender_id = senderId.uuidString
        self.content = content
        self.message_type = "text"
        self.image_url = nil
    }

    init(conversationId: UUID, senderId: UUID, imageURL: String) {
        self.conversation_id = conversationId.uuidString
        self.sender_id = senderId.uuidString
        self.content = nil
        self.message_type = "image"
        self.image_url = imageURL
    }
}

// MARK: - Mark Messages Read DTO
struct MarkMessagesReadDTO: Encodable {
    let read_at: Date

    init() {
        self.read_at = Date()
    }
}

// MARK: - Message UI Model
struct MessageUIModel: Identifiable, Equatable {
    let id: UUID
    let conversationId: UUID
    let senderId: UUID
    let content: String?
    let messageType: MessageType
    let imageURL: String?
    let isRead: Bool
    let createdAt: Date

    var isMine: Bool = false  // Set based on current user

    enum MessageType: String {
        case text
        case image
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: createdAt)
    }

    var displayContent: String {
        if messageType == .image {
            return "📷 Photo"
        }
        return content ?? ""
    }

    static func == (lhs: MessageUIModel, rhs: MessageUIModel) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Message Mapper
enum MessageMapper {
    static func toUIModel(_ dto: MessageDTO, currentUserId: UUID) -> MessageUIModel {
        return MessageUIModel(
            id: dto.id,
            conversationId: dto.conversation_id,
            senderId: dto.sender_id,
            content: dto.content,
            messageType: MessageUIModel.MessageType(rawValue: dto.message_type) ?? .text,
            imageURL: dto.image_url,
            isRead: dto.isRead,
            createdAt: dto.created_at ?? Date(),
            isMine: dto.sender_id == currentUserId
        )
    }
}
