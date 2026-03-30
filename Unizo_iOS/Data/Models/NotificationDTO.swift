//
//  NotificationDTO.swift
//  Unizo_iOS
//

import Foundation

// MARK: - Notification Type (must match DB ENUM exactly)
enum NotificationType: String, Codable {
    case newOrder = "new_order"
    case orderAccepted = "order_accepted"
    case orderRejected = "order_rejected"
    case orderShipped = "order_shipped"
    case orderDelivered = "order_delivered"
}

// MARK: - Deeplink Payload
struct DeeplinkPayload: Codable {
    let route: String
    let orderId: UUID?
    let sellerId: UUID?

    enum CodingKeys: String, CodingKey {
        case route
        case orderId = "order_id"
        case sellerId = "seller_id"
    }

    init(route: String, orderId: UUID? = nil, sellerId: UUID? = nil) {
        self.route = route
        self.orderId = orderId
        self.sellerId = sellerId
    }
}

// MARK: - Notification DTO (for fetching from Supabase)
struct NotificationDTO: Codable {
    let id: UUID
    let recipient_id: UUID      // Who receives (seller or buyer)
    let sender_id: UUID         // Who triggered (buyer or seller)
    let order_id: UUID
    let type: String
    let title: String
    let message: String
    let deeplink_payload: DeeplinkPayload
    let event_key: String?
    let is_read: Bool
    let created_at: String

    // Joined sender data (optional, for display)
    var sender: UserDTO?
}

// MARK: - Insert DTO (for creating notifications)
struct NotificationInsertDTO: Encodable {
    let id: UUID
    let recipient_id: UUID
    let sender_id: UUID
    let order_id: UUID
    let type: String
    let title: String
    let message: String
    let deeplink_payload: DeeplinkPayload
    let event_key: String
}

// MARK: - UI Model (for display in views)
struct NotificationUIModel {
    let id: UUID
    let recipientId: UUID
    let senderId: UUID
    let orderId: UUID
    let type: NotificationType
    let title: String
    let message: String
    let deeplinkPayload: DeeplinkPayload
    let isRead: Bool
    let createdAt: Date
    let senderName: String?

    // Computed property for relative time display
    var timeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }

    // SF Symbol icon based on notification type
    var iconName: String {
        switch type {
        case .newOrder:
            return "cart.fill"
        case .orderAccepted:
            return "checkmark.circle.fill"
        case .orderRejected:
            return "xmark.circle.fill"
        case .orderShipped:
            return "shippingbox.fill"
        case .orderDelivered:
            return "checkmark.seal.fill"
        }
    }

    // Icon color based on notification type
    var iconColor: String {
        switch type {
        case .newOrder:
            return "systemBlue"
        case .orderAccepted:
            return "systemGreen"
        case .orderRejected:
            return "systemRed"
        case .orderShipped:
            return "systemOrange"
        case .orderDelivered:
            return "systemGreen"
        }
    }
}

// MARK: - Notification Mapper
struct NotificationMapper {

    static func toUIModel(_ dto: NotificationDTO) -> NotificationUIModel {
        // Parse ISO8601 date
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var date = dateFormatter.date(from: dto.created_at)

        // Fallback without fractional seconds
        if date == nil {
            dateFormatter.formatOptions = [.withInternetDateTime]
            date = dateFormatter.date(from: dto.created_at)
        }

        return NotificationUIModel(
            id: dto.id,
            recipientId: dto.recipient_id,
            senderId: dto.sender_id,
            orderId: dto.order_id,
            type: NotificationType(rawValue: dto.type) ?? .newOrder,
            title: dto.title,
            message: dto.message,
            deeplinkPayload: dto.deeplink_payload,
            isRead: dto.is_read,
            createdAt: date ?? Date(),
            senderName: dto.sender?.displayName
        )
    }
}
