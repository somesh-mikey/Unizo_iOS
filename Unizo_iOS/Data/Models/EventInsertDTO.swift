//
//  EventInsertDTO.swift
//  Unizo_iOS
//

import Foundation

struct EventInsertDTO: Encodable {
    let organizer_id: String
    let title: String
    let description: String
    let venue: String
    let event_date: String      // "yyyy-MM-dd"
    let event_time: String      // "HH:mm"
    let price: Double
    let is_free: Bool
    let image_url: String?
}
