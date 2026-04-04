//
//  EventDTO.swift
//  Unizo_iOS
//

import Foundation
import FirebaseFirestore

struct EventDTO: Codable, Identifiable {
    @DocumentID var id: String?
    let title: String
    let description: String?
    let venue: String?
    let organizer_id: String?

    // Firestore may store event_date as either a Timestamp or a String.
    // We try Timestamp first (native Firestore type), then fall back to String.
    let event_date: String?
    let event_time: String?
    let price: Double?
    let is_free: Bool?
    let image_url: String?
    let is_active: Bool?
    let created_at: String?

    enum CodingKeys: String, CodingKey {
        case id, title, description, venue, organizer_id
        case event_date, event_time, price, is_free
        case image_url, is_active, created_at
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // DocumentID is handled by @DocumentID property wrapper, but for manual
        // decoding we try to get it from the container if present
        id = try container.decodeIfPresent(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        venue = try container.decodeIfPresent(String.self, forKey: .venue)
        organizer_id = try container.decodeIfPresent(String.self, forKey: .organizer_id)
        event_time = try container.decodeIfPresent(String.self, forKey: .event_time)
        price = try container.decodeIfPresent(Double.self, forKey: .price)
        is_free = try container.decodeIfPresent(Bool.self, forKey: .is_free)
        image_url = try container.decodeIfPresent(String.self, forKey: .image_url)
        is_active = try container.decodeIfPresent(Bool.self, forKey: .is_active)
        // created_at: Firestore stores this as a Timestamp (via serverTimestamp()),
        // but may also be a String in older records. Handle both.
        if let timestamp = try? container.decodeIfPresent(Timestamp.self, forKey: .created_at) {
            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withInternetDateTime]
            created_at = iso.string(from: timestamp.dateValue())
        } else {
            created_at = try? container.decodeIfPresent(String.self, forKey: .created_at)
        }

        // event_date: Try String first, then Timestamp, then nil
        if let dateString = try? container.decodeIfPresent(String.self, forKey: .event_date) {
            event_date = dateString
        } else if let timestamp = try? container.decodeIfPresent(Timestamp.self, forKey: .event_date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            event_date = formatter.string(from: timestamp.dateValue())
        } else {
            event_date = nil
        }
    }

    // Computed property for price display
    var priceDisplay: String {
        if (is_free ?? false) || (price ?? 0) == 0 {
            return "Free"
        }
        return "₹\(Int(price ?? 0))"
    }

    // Computed property for formatted date
    var formattedDate: String {
        guard let event_date = event_date else { return "TBD" }

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"

        if let date = inputFormatter.date(from: event_date) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMM d"
            return outputFormatter.string(from: date)
        }
        return event_date
    }
}
