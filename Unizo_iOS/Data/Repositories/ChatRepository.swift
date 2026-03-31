//
//  ChatRepository.swift
//  Unizo_iOS
//
//  Repository for chat/messaging operations with Firebase Firestore.
//  Conversations are top-level documents, and messages are subcollections 
//  `conversations/{conversationId}/messages`. Joins are handled client-side.
//  Firebase Storage is natively imported for image uploads.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

final class ChatRepository {

    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private let iso8601WithFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    private let iso8601WithoutFractionalSeconds = ISO8601DateFormatter()

    init() { }

    private func parseDate(_ value: Any?) -> Date? {
        if let timestamp = value as? Timestamp {
            return timestamp.dateValue()
        }

        if let date = value as? Date {
            return date
        }

        if let string = value as? String {
            return iso8601WithFractionalSeconds.date(from: string) ?? iso8601WithoutFractionalSeconds.date(from: string)
        }

        return nil
    }

    private func decodeLastMessage(from data: [String: Any], fallbackId: String? = nil) -> LastMessageInfo? {
        guard let senderId = data["sender_id"] as? String else {
            return nil
        }

        return LastMessageInfo(
            id: fallbackId,
            content: data["content"] as? String,
            message_type: data["message_type"] as? String,
            sender_id: senderId,
            created_at: parseDate(data["created_at"])
        )
    }

    private func decodeConversation(from document: DocumentSnapshot) -> ConversationDTO? {
        if var conversation = try? document.data(as: ConversationDTO.self) {
            if conversation.id == nil {
                conversation.id = document.documentID
            }
            return conversation
        }

        guard let data = document.data(),
              let productId = data["product_id"] as? String,
              let buyerId = data["buyer_id"] as? String,
              let sellerId = data["seller_id"] as? String else {
            print("🟥 [ChatDebug] decodeConversation failed for docId=\(document.documentID)")
            return nil
        }

        let fallback = ConversationDTO(
            id: document.documentID,
            product_id: productId,
            buyer_id: buyerId,
            seller_id: sellerId,
            created_at: parseDate(data["created_at"]),
            last_message: (data["last_message"] as? [String: Any]).flatMap { decodeLastMessage(from: $0) }
        )

        print("🟨 [ChatDebug] decodeConversation fallback used for docId=\(document.documentID)")
        return fallback
    }

    private func attachLastMessages(to conversations: inout [ConversationDTO]) async {
        for index in conversations.indices {
            if conversations[index].last_message != nil {
                continue
            }

            guard let conversationId = conversations[index].id, !conversationId.isEmpty else {
                continue
            }

            do {
                let orderedSnapshot = try await db.collection("conversations")
                    .document(conversationId)
                    .collection("messages")
                    .order(by: "created_at", descending: true)
                    .limit(to: 1)
                    .getDocuments()

                if let doc = orderedSnapshot.documents.first,
                   let message = decodeLastMessage(from: doc.data(), fallbackId: doc.documentID) {
                    conversations[index].last_message = message
                    continue
                }

                // Fallback for legacy messages without created_at
                let fallbackSnapshot = try await db.collection("conversations")
                    .document(conversationId)
                    .collection("messages")
                    .getDocuments()

                let latest = fallbackSnapshot.documents
                    .compactMap { decodeLastMessage(from: $0.data(), fallbackId: $0.documentID) }
                    .sorted { ($0.created_at ?? .distantPast) > ($1.created_at ?? .distantPast) }
                    .first

                conversations[index].last_message = latest
            } catch {
                print("⚠️ [ChatDebug] attachLastMessages failed for conversationId=\(conversationId): \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Get Current User ID
    private func getCurrentUserId() async throws -> String {
        guard let userId = await AuthManager.shared.currentUserId else {
            throw ChatError.notAuthenticated
        }
        return userId
    }

    // MARK: - Network Guard
    private func requireNetwork() throws {
        guard NetworkMonitor.shared.isReachable() else {
            throw NetworkError.noConnection
        }
    }

    // MARK: - Attach Joins Helper
    private func attachJoins(to conversations: inout [ConversationDTO]) async throws {
        let uniqueUserIds = Set(conversations.flatMap { [$0.buyer_id, $0.seller_id] })
        let uniqueProductIds = Set(conversations.map { $0.product_id })
        
        var usersMap: [String: UserDTO] = [:]
        var productsMap: [String: ProductDTO] = [:]

        // Fetch Users manually (to simulate Users Join)
        if !uniqueUserIds.isEmpty {
            let chunks = Array(uniqueUserIds).chunked(into: 10)
            for chunk in chunks {
                let snapshot = try await db.collection("users").whereField(FieldPath.documentID(), in: chunk).getDocuments()
                for doc in snapshot.documents {
                    if let user = try? doc.data(as: UserDTO.self) {
                        usersMap[doc.documentID] = user
                    }
                }
            }
        }
        
        // Fetch Products manually (to simulate Products Join)
        if !uniqueProductIds.isEmpty {
            let chunks = Array(uniqueProductIds).chunked(into: 10)
            for chunk in chunks {
                let snapshot = try await db.collection("products").whereField(FieldPath.documentID(), in: chunk).getDocuments()
                for doc in snapshot.documents {
                    if let product = try? doc.data(as: ProductDTO.self) {
                        productsMap[doc.documentID] = product
                    }
                }
            }
        }
        
        for i in 0..<conversations.count {
            let bId = conversations[i].buyer_id
            let sId = conversations[i].seller_id
            let pId = conversations[i].product_id

            if let user = usersMap[bId] {
                conversations[i].buyer = ConversationUserInfo(
                    id: user.id,
                    first_name: user.first_name,
                    last_name: user.last_name,
                    profile_image_url: user.profile_image_url
                )
            }

            if let user = usersMap[sId] {
                conversations[i].seller = ConversationUserInfo(
                    id: user.id,
                    first_name: user.first_name,
                    last_name: user.last_name,
                    profile_image_url: user.profile_image_url
                )
            }

            if let product = productsMap[pId] {
                conversations[i].product = ConversationProductInfo(
                    id: product.id,
                    title: product.title,
                    image_url: product.imageUrl,
                    status: product.status?.rawValue
                )
            }
        }
    }

    // MARK: - Fetch User's Conversations
    func fetchConversations() async throws -> [ConversationDTO] {
        try requireNetwork()
        let userId = try await getCurrentUserId()

        // Firestore does not natively allow OR queries across different fields seamlessly if you want to sort.
        // We will execute two queries: buyer == userId and seller == userId, then merge and sort.
        
        async let buyerSnapshot = db.collection("conversations")
            .whereField("buyer_id", isEqualTo: userId)
            .getDocuments()
            
        async let sellerSnapshot = db.collection("conversations")
            .whereField("seller_id", isEqualTo: userId)
            .getDocuments()

        let (bDocs, sDocs) = try await (buyerSnapshot.documents, sellerSnapshot.documents)
        let allDocs = bDocs + sDocs
        
        // Ensure no duplicates just in case
        var uniqueDocs: [String: DocumentSnapshot] = [:]
        for doc in allDocs { uniqueDocs[doc.documentID] = doc }
        
        var conversations = uniqueDocs.values.compactMap { decodeConversation(from: $0) }
        
        // Sort effectively relies on local memory because of the dual query limitations
        conversations.sort { ($0.created_at ?? Date.distantPast) > ($1.created_at ?? Date.distantPast) }
        
        try await attachJoins(to: &conversations)
        await attachLastMessages(to: &conversations)
        return conversations
    }

    // MARK: - Fetch or Create Conversation
    func getOrCreateConversationId(productId: String, sellerId: String) async throws -> String {
        try requireNetwork()
        let buyerId = try await getCurrentUserId()

        print("🟦 [ChatDebug] ChatRepository.getOrCreateConversationId buyerId=\(buyerId), sellerId=\(sellerId), productId=\(productId)")

        guard buyerId != sellerId else { throw ChatError.cannotChatWithSelf }

        let snapshot = try await db.collection("conversations")
            .whereField("product_id", isEqualTo: productId)
            .whereField("buyer_id", isEqualTo: buyerId)
            .limit(to: 1)
            .getDocuments()

        if let existingDoc = snapshot.documents.first {
            print("🟩 [ChatDebug] Existing conversationId found=\(existingDoc.documentID)")
            return existingDoc.documentID
        }

        let ref = db.collection("conversations").document()
        let insertDTO = ConversationInsertDTO(
            product_id: productId,
            buyer_id: buyerId,
            seller_id: sellerId
        )

        var data = try Firestore.Encoder().encode(insertDTO)
        data["created_at"] = FieldValue.serverTimestamp()
        try await ref.setData(data)
        print("🟩 [ChatDebug] Created new conversationId=\(ref.documentID)")
        return ref.documentID
    }

    func getOrCreateConversation(productId: String, sellerId: String) async throws -> ConversationDTO {
        try requireNetwork()
        let buyerId = try await getCurrentUserId()

        print("🟦 [ChatDebug] ChatRepository.getOrCreateConversation buyerId=\(buyerId), sellerId=\(sellerId), productId=\(productId)")

        guard buyerId != sellerId else { throw ChatError.cannotChatWithSelf }

        let snapshot = try await db.collection("conversations")
            .whereField("product_id", isEqualTo: productId)
            .whereField("buyer_id", isEqualTo: buyerId)
            .limit(to: 1)
            .getDocuments()

        if let doc = snapshot.documents.first, let existing = decodeConversation(from: doc) {
            print("🟩 [ChatDebug] Existing conversation found docId=\(doc.documentID), decodedId=\(existing.id ?? "nil")")
            return existing
        }

        // Create new
        let ref = db.collection("conversations").document()
        let insertDTO = ConversationInsertDTO(
            product_id: productId,
            buyer_id: buyerId,
            seller_id: sellerId
        )

        var data = try Firestore.Encoder().encode(insertDTO)
        data["created_at"] = FieldValue.serverTimestamp()
        try await ref.setData(data)
        print("🟦 [ChatDebug] Created new conversation document docId=\(ref.documentID)")
        
        guard let newConvo = try await fetchConversation(id: ref.documentID) else {
            print("🟥 [ChatDebug] fetchConversation returned nil for docId=\(ref.documentID)")
            throw ChatError.conversationNotFound
        }
        print("🟩 [ChatDebug] New conversation decoded id=\(newConvo.id ?? "nil")")
        return newConvo
    }

    // MARK: - Fetch Messages
    func fetchMessages(conversationId: String) async throws -> [MessageDTO] {
        try requireNetwork()
        let _ = try await getCurrentUserId()

        let orderedSnapshot = try await db.collection("conversations").document(conversationId).collection("messages")
            .order(by: "created_at", descending: false)
            .getDocuments()

        var orderedMessages = orderedSnapshot.documents.compactMap { try? $0.data(as: MessageDTO.self) }

        if orderedMessages.isEmpty {
            // Fallback for older messages written before created_at was populated.
            let fallbackSnapshot = try await db.collection("conversations")
                .document(conversationId)
                .collection("messages")
                .getDocuments()

            orderedMessages = fallbackSnapshot.documents
                .compactMap { try? $0.data(as: MessageDTO.self) }
                .sorted { ($0.created_at ?? .distantPast) < ($1.created_at ?? .distantPast) }

            print("🟨 [ChatDebug] fetchMessages fallback used for conversationId=\(conversationId), count=\(orderedMessages.count)")
        } else {
            print("🟩 [ChatDebug] fetchMessages ordered count=\(orderedMessages.count) for conversationId=\(conversationId)")
        }

        return orderedMessages
    }

    // MARK: - Send Text Message
    func sendMessage(conversationId: String, content: String) async throws -> MessageDTO {
        try requireNetwork()
        let senderId = try await getCurrentUserId()

        let ref = db.collection("conversations").document(conversationId).collection("messages").document()
        let messageDTO = MessageInsertDTO(
            conversationId: conversationId,
            senderId: senderId,
            content: content
        )

        var data = try Firestore.Encoder().encode(messageDTO)
        data["created_at"] = FieldValue.serverTimestamp()
        try await ref.setData(data)

        // Ensure the conversation timestamp is updated so it floats to the top of inbox
        let lastMessagePayload: [String: Any] = [
            "content": content,
            "message_type": "text",
            "sender_id": senderId,
            "created_at": FieldValue.serverTimestamp()
        ]

        try await db.collection("conversations").document(conversationId).updateData([
            "created_at": FieldValue.serverTimestamp(),
            "last_message": lastMessagePayload
        ])

        let snapshot = try await ref.getDocument()
        return try snapshot.data(as: MessageDTO.self)
    }

    // MARK: - Send Image Message
    func sendImageMessage(conversationId: String, imageURL: String) async throws -> MessageDTO {
        try requireNetwork()
        let senderId = try await getCurrentUserId()

        let ref = db.collection("conversations").document(conversationId).collection("messages").document()
        let messageDTO = MessageInsertDTO(
            conversationId: conversationId,
            senderId: senderId,
            imageURL: imageURL
        )

        var data = try Firestore.Encoder().encode(messageDTO)
        data["created_at"] = FieldValue.serverTimestamp()
        try await ref.setData(data)
        
        let lastMessagePayload: [String: Any] = [
            "content": "",
            "message_type": "image",
            "sender_id": senderId,
            "created_at": FieldValue.serverTimestamp()
        ]

        try await db.collection("conversations").document(conversationId).updateData([
            "created_at": FieldValue.serverTimestamp(),
            "last_message": lastMessagePayload
        ])

        let snapshot = try await ref.getDocument()
        return try snapshot.data(as: MessageDTO.self)
    }

    // MARK: - Upload Chat Image
    func uploadChatImage(_ imageData: Data, conversationId: String) async throws -> String {
        try requireNetwork()
        let fileName = "\(conversationId)_\(Int(Date().timeIntervalSince1970)).jpg"
        let storageRef = storage.reference().child("chat-images").child(fileName)
        
        _ = try await storageRef.putDataAsync(imageData)
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL.absoluteString
    }

    // MARK: - Mark Messages as Read
    func markMessagesAsRead(conversationId: String) async throws {
        try requireNetwork()
        let userId = try await getCurrentUserId()

        let snapshot = try await db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .getDocuments()

        let batch = db.batch()
        var updates = 0

        for doc in snapshot.documents {
            let data = doc.data()
            let senderId = data["sender_id"] as? String
            let readAt = data["read_at"]

            if senderId != userId && (readAt == nil || readAt is NSNull) {
                batch.updateData(["read_at": FieldValue.serverTimestamp()], forDocument: doc.reference)
                updates += 1
            }
        }

        if updates > 0 {
            try await batch.commit()
        }
    }

    // MARK: - Get Unread Count for Conversation
    func getUnreadCount(conversationId: String) async throws -> Int {
        try requireNetwork()
        let userId = try await getCurrentUserId()

        let snapshot = try await db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .getDocuments()

        return snapshot.documents.reduce(into: 0) { count, doc in
            let data = doc.data()
            let senderId = data["sender_id"] as? String
            let readAt = data["read_at"]
            if senderId != userId && (readAt == nil || readAt is NSNull) {
                count += 1
            }
        }
    }

    // MARK: - Get Total Unread Count
    func getTotalUnreadCount() async throws -> Int {
        let conversations = try await fetchConversations()
        var total = 0
        for convo in conversations {
            guard let conversationId = convo.id else { continue }
            total += try await getUnreadCount(conversationId: conversationId)
        }
        return total
    }

    // MARK: - Fetch Single Conversation
    func fetchConversation(id: String) async throws -> ConversationDTO? {
        try requireNetwork()
        let _ = try await getCurrentUserId()

        let snapshot = try await db.collection("conversations").document(id).getDocument()
        guard snapshot.exists, let convo = decodeConversation(from: snapshot) else { return nil }
        
        var convos = [convo]
        try await attachJoins(to: &convos)
        return convos.first
    }
}

// MARK: - Chat Errors
enum ChatError: LocalizedError {
    case notAuthenticated
    case cannotChatWithSelf
    case conversationNotFound
    case messageSendFailed

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be logged in to chat"
        case .cannotChatWithSelf:
            return "You cannot chat with yourself"
        case .conversationNotFound:
            return "Conversation not found"
        case .messageSendFailed:
            return "Failed to send message"
        }
    }
}
