import Foundation
import FirebaseFirestore

struct ViewedItem {
    let productId: String
    let ownerId: String
    let cost: Double
}

class ViewHistoryService {
    static let shared = ViewHistoryService()
    private let db = Firestore.firestore()

    private init() {}

    func recordView(userId: String, product: Product) {
        let data: [String: Any] = [
            "productId": product.id,
            "ownerId": product.ownerId,
            "cost": product.cost,
            "viewedAt": Timestamp()
        ]
        db.collection("users")
            .document(userId)
            .collection("viewHistory")
            .document(product.id)
            .setData(data, merge: true)
    }

    func fetchViewHistory(userId: String, completion: @escaping ([ViewedItem]) -> Void) {
        db.collection("users")
            .document(userId)
            .collection("viewHistory")
            .order(by: "viewedAt", descending: true)
            .limit(to: 50)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching view history: \(error.localizedDescription)")
                    completion([])
                    return
                }
                let items: [ViewedItem] = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    guard
                        let productId = data["productId"] as? String,
                        let ownerId   = data["ownerId"]   as? String,
                        let cost      = data["cost"]      as? Double
                    else { return nil }
                    return ViewedItem(productId: productId, ownerId: ownerId, cost: cost)
                } ?? []
                completion(items)
            }
    }
}
