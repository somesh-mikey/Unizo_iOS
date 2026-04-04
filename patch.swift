extension OrderRepository {
    func getActiveOrderId(for productId: String) async throws -> String? {
        let itemsSnapshot = try await db.collection("order_items")
            .whereField("product_id", isEqualTo: productId)
            .getDocuments()
        for doc in itemsSnapshot.documents {
            if let orderId = doc.data()["order_id"] as? String {
                let orderDoc = try await db.collection("orders").document(orderId).getDocument()
                if let statusString = orderDoc.data()?["status"] as? String,
                   let status = OrderStatus(rawValue: statusString) {
                    if status != .cancelled {
                        return orderId
                    }
                }
            }
        }
        return nil
    }
}
