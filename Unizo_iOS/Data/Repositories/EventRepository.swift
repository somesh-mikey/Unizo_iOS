//
//  EventRepository.swift
//  Unizo_iOS
//

import Foundation
import Supabase

final class EventRepository {

    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }

    // MARK: - Fetch All Active Events
    func fetchEvents() async throws -> [EventDTO] {
        let response = try await client
            .from("events")
            .select("""
                id,
                title,
                description,
                venue,
                event_date,
                event_time,
                price,
                is_free,
                image_url,
                is_active,
                created_at
            """)
            .eq("is_active", value: true)
            .order("event_date", ascending: true)
            .execute()

        return try JSONDecoder().decode([EventDTO].self, from: response.data)
    }

    // MARK: - Fetch Featured Events
    func fetchFeaturedEvents() async throws -> [EventDTO] {
        let response = try await client
            .from("events")
            .select("""
                id,
                title,
                description,
                venue,
                event_date,
                event_time,
                price,
                is_free,
                image_url,
                is_active,
                created_at
            """)
            .eq("is_active", value: true)
            .order("event_date", ascending: true)
            .limit(10)
            .execute()

        return try JSONDecoder().decode([EventDTO].self, from: response.data)
    }

    // MARK: - Fetch Event by ID
    func fetchEvent(id: UUID) async throws -> EventDTO {
        let response: EventDTO = try await client
            .from("events")
            .select("""
                id,
                title,
                description,
                venue,
                event_date,
                event_time,
                price,
                is_free,
                image_url,
                is_active,
                created_at
            """)
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value

        return response
    }
}
