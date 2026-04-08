//
//  EventRepository.swift
//  Unizo_iOS
//

import Foundation
import FirebaseFirestore

enum EventRepositoryError: LocalizedError {
    case eventIdNotFound

    var errorDescription: String? {
        switch self {
        case .eventIdNotFound:
            return "Unable to resolve event id for registration."
        }
    }
}

final class EventRepository {

    private let db = Firestore.firestore()

    init() {}

    // MARK: - Network Guard
    private func requireNetwork() throws {
        guard NetworkMonitor.shared.isReachable() else {
            throw NetworkError.noConnection
        }
    }

    // MARK: - Fetch All Active Events
    func fetchEvents() async throws -> [EventDTO] {
        try requireNetwork()

        do {
            let snapshot = try await db.collection("events")
                .whereField("is_active", isEqualTo: true)
                .order(by: "event_date", descending: false)
                .getDocuments()

            let events = snapshot.documents.compactMap { doc -> EventDTO? in
                do {
                    return try doc.data(as: EventDTO.self)
                } catch {
                    print("⚠️ EventRepository: Failed to decode event \(doc.documentID): \(error)")
                    return nil
                }
            }

            if !events.isEmpty {
                return events
            }
            print("⚠️ fetchEvents: Primary query decoded 0 events from \(snapshot.documents.count) documents")
        } catch {
            print("⚠️ fetchEvents primary query failed: \(error.localizedDescription)")
            print("⚠️ Full error: \(error)")
        }

        // Fallback: no orderBy, no whereField — just get all events
        print("⚠️ fetchEvents: Trying fallback query (no filter, no order)")
        let fallbackSnapshot = try await db.collection("events").getDocuments()

        let fallbackEvents = fallbackSnapshot.documents.compactMap { doc -> EventDTO? in
            do {
                return try doc.data(as: EventDTO.self)
            } catch {
                print("⚠️ EventRepository fallback: Failed to decode event \(doc.documentID): \(error)")
                return nil
            }
        }

        if fallbackEvents.isEmpty {
            print("❌ fetchEvents: Both primary and fallback returned 0 events (\(fallbackSnapshot.documents.count) raw docs)")
        } else {
            print("✅ fetchEvents fallback: Decoded \(fallbackEvents.count) events")
        }

        return fallbackEvents
    }

    // MARK: - Fetch Featured Events
    func fetchFeaturedEvents() async throws -> [EventDTO] {
        try requireNetwork()

        do {
            let snapshot = try await db.collection("events")
                .whereField("is_active", isEqualTo: true)
                .order(by: "event_date", descending: false)
                .limit(to: 20)
                .getDocuments()

            let events = snapshot.documents.compactMap { doc -> EventDTO? in
                do {
                    return try doc.data(as: EventDTO.self)
                } catch {
                    print("⚠️ EventRepository: Failed to decode event \(doc.documentID): \(error)")
                    return nil
                }
            }

            if !events.isEmpty {
                return events
            }
            print("⚠️ fetchFeaturedEvents: Primary query decoded 0 events from \(snapshot.documents.count) documents")
        } catch {
            print("⚠️ fetchFeaturedEvents primary query failed: \(error.localizedDescription)")
            print("⚠️ Full error (may contain index creation URL): \(error)")
        }

        // Fallback: no orderBy — avoids composite index requirement
        print("⚠️ fetchFeaturedEvents: Trying fallback query (no order)")
        do {
            let fallbackSnapshot = try await db.collection("events")
                .whereField("is_active", isEqualTo: true)
                .getDocuments()

            let fallbackEvents = fallbackSnapshot.documents.compactMap { doc -> EventDTO? in
                do {
                    return try doc.data(as: EventDTO.self)
                } catch {
                    print("⚠️ EventRepository fallback: Failed to decode event \(doc.documentID): \(error)")
                    return nil
                }
            }

            if !fallbackEvents.isEmpty {
                print("✅ fetchFeaturedEvents fallback: Decoded \(fallbackEvents.count) events")
                return fallbackEvents
            }
            print("⚠️ fetchFeaturedEvents: Fallback also returned 0 events (\(fallbackSnapshot.documents.count) raw docs)")
        } catch {
            print("❌ fetchFeaturedEvents fallback also failed: \(error)")
        }

        // Last resort: get ALL documents without any filter
        print("⚠️ fetchFeaturedEvents: Last resort — fetching ALL documents without filter")
        let lastResort = try await db.collection("events").getDocuments()

        let lastResortEvents = lastResort.documents.compactMap { doc -> EventDTO? in
            do {
                return try doc.data(as: EventDTO.self)
            } catch {
                print("⚠️ EventRepository last-resort: Failed to decode event \(doc.documentID): \(error)")
                return nil
            }
        }

        if lastResortEvents.isEmpty {
            print("❌ fetchFeaturedEvents: ALL queries returned 0 events from \(lastResort.documents.count) raw documents")
        }

        return lastResortEvents
    }

    // MARK: - Fetch Event by ID
    func fetchEvent(id: String) async throws -> EventDTO {
        try requireNetwork()
        let document = try await db.collection("events").document(id).getDocument()
        return try document.data(as: EventDTO.self)
    }

    // MARK: - Insert Event
    func insertEvent(_ event: EventInsertDTO) async throws {
        try requireNetwork()
        let ref = db.collection("events").document()
        var data = try Firestore.Encoder().encode(event)
        // Always include created_at as a server timestamp
        data["created_at"] = FieldValue.serverTimestamp()
        try await ref.setData(data)
        print("✅ EventRepository: Event inserted with ID \(ref.documentID)")
    }

    // MARK: - Register/Book Event Response
    @discardableResult
    func submitEventResponse(event: EventDTO, userId: String) async throws -> Bool {
        try requireNetwork()

        guard let eventId = try await resolveEventId(for: event) else {
            throw EventRepositoryError.eventIdNotFound
        }

        let responseType = (event.is_free ?? false) ? "register" : "book"
        let status = (event.is_free ?? false) ? "registered" : "booking_requested"
        let docId = "\(eventId)_\(userId)"
        let docRef = db.collection("event_registrations").document(docId)

        let existing = try await docRef.getDocument()
        let baseData: [String: Any] = [
            "event_id": eventId,
            "event_title": event.title,
            "organizer_id": event.organizer_id as Any,
            "user_id": userId,
            "event_date": event.event_date as Any,
            "event_time": event.event_time as Any,
            "venue": event.venue as Any,
            "price": event.price ?? 0,
            "is_free": event.is_free ?? false,
            "response_type": responseType,
            "status": status,
            "updated_at": FieldValue.serverTimestamp()
        ]

        if existing.exists {
            try await docRef.setData(baseData, merge: true)
            print("ℹ️ EventRepository: Updated existing event response \(docId)")
            return false
        } else {
            var payload = baseData
            payload["created_at"] = FieldValue.serverTimestamp()
            try await docRef.setData(payload)
            print("✅ EventRepository: Stored new event response \(docId)")
            return true
        }
    }

    private func resolveEventId(for event: EventDTO) async throws -> String? {
        if let id = event.id, !id.isEmpty {
            return id
        }

        let snapshot = try await db.collection("events")
            .whereField("title", isEqualTo: event.title)
            .limit(to: 10)
            .getDocuments()

        if snapshot.documents.isEmpty {
            return nil
        }

        let matched = snapshot.documents.first { doc in
            let data = doc.data()

            if let venue = event.venue,
               let dataVenue = data["venue"] as? String,
               dataVenue != venue {
                return false
            }

            if let organizer = event.organizer_id,
               let dataOrganizer = data["organizer_id"] as? String,
               dataOrganizer != organizer {
                return false
            }

            if let eventTime = event.event_time,
               let dataTime = data["event_time"] as? String,
               dataTime != eventTime {
                return false
            }

            return true
        }

        return matched?.documentID ?? snapshot.documents.first?.documentID
    }
}
