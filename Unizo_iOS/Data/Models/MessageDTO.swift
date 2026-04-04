//
//  MessageDTO.swift
//  Unizo_iOS
//
//  Real-time chat message model
//

import Foundation
import FirebaseFirestore

// MARK: - Message DTO
struct MessageDTO: Codable, Identifiable {
    @DocumentID var id: String?
    let conversation_id: String
    let sender_id: String
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

    init(conversationId: String, senderId: String, content: String) {
        self.conversation_id = conversationId
        self.sender_id = senderId
        self.content = content
        self.message_type = "text"
        self.image_url = nil
    }

    init(conversationId: String, senderId: String, imageURL: String) {
        self.conversation_id = conversationId
        self.sender_id = senderId
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
    let id: String?
    let conversationId: String
    let senderId: String
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
    static func toUIModel(_ dto: MessageDTO, currentUserId: String) -> MessageUIModel {
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
