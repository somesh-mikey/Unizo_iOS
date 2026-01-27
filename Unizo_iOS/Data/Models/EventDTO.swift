//
//  EventDTO.swift
//  Unizo_iOS
//

import Foundation

struct EventDTO: Codable {
    let id: UUID
    let title: String
    let description: String?
    let venue: String
    let event_date: String
    let event_time: String
    let price: Double
    let is_free: Bool
    let image_url: String?
    let is_active: Bool?
    let created_at: String?

    // Computed property for price display
    var priceDisplay: String {
        if is_free || price == 0 {
            return "Free"
        }
        return "₹\(Int(price))"
    }

    // Computed property for formatted date
    var formattedDate: String {
        // Parse the date string and format it
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
