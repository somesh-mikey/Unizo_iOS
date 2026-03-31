//
//  EventRepository.swift
//  Unizo_iOS
//

import Foundation
import FirebaseFirestore

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
        let snapshot = try await db.collection("events")
            .whereField("is_active", isEqualTo: true)
            .order(by: "event_date", descending: false)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: EventDTO.self) }
    }

    // MARK: - Fetch Featured Events
    func fetchFeaturedEvents() async throws -> [EventDTO] {
        try requireNetwork()
        let snapshot = try await db.collection("events")
            .whereField("is_active", isEqualTo: true)
            .order(by: "event_date", descending: false)
            .limit(to: 10)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: EventDTO.self) }
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
        try ref.setData(from: event)
    }
}
