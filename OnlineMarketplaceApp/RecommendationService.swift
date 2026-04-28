import Foundation
import FirebaseFirestore

class RecommendationService {
    static let shared = RecommendationService()
    private let db = Firestore.firestore()

    private init() {}

    func fetchRecommendedFeed(userId: String, completion: @escaping ([Product]) -> Void) {
        ViewHistoryService.shared.fetchViewHistory(userId: userId) { history in
            self.db.collection("allProducts")
                .order(by: "dateCreated", descending: true)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching products for feed: \(error.localizedDescription)")
                        completion([])
                        return
                    }
                    guard let documents = snapshot?.documents else {
                        completion([])
                        return
                    }

                    let products: [Product] = documents.compactMap { doc in
                        let data = doc.data()
                        guard
                            let name      = data["name"]      as? String,
                            let cost      = data["cost"]      as? Double,
                            let address   = data["address"]   as? String,
                            let mediaURL  = data["mediaURL"]  as? String,
                            let mediaType = data["mediaType"] as? String,
                            let ownerId   = data["ownerId"]   as? String
                        else { return nil }

                        return Product(
                            id: doc.documentID,
                            name: name,
                            cost: cost,
                            address: address,
                            mediaURL: mediaURL,
                            mediaType: mediaType,
                            dateCreated: (data["dateCreated"] as? Timestamp)?.dateValue() ?? Date(),
                            ownerId: ownerId
                        )
                    }

                    let ranked = self.rankProducts(products, history: history, currentUserId: userId)
                    completion(ranked)
                }
        }
    }

    private func rankProducts(_ products: [Product], history: [ViewedItem], currentUserId: String) -> [Product] {
        let viewedIds = Set(history.map { $0.productId })

        var ownerFrequency: [String: Int] = [:]
        for item in history {
            ownerFrequency[item.ownerId, default: 0] += 1
        }

        let avgPrice: Double = history.isEmpty ? 0 : history.map { $0.cost }.reduce(0, +) / Double(history.count)

        let scored: [(Product, Double)] = products.compactMap { product in
            if product.ownerId == currentUserId { return nil }

            var score = 0.0

            if let count = ownerFrequency[product.ownerId] {
                score += Double(count) * 3.0
            }

            if avgPrice > 0 {
                let ratio = abs(product.cost - avgPrice) / avgPrice
                if ratio < 0.25 {
                    score += 2.0
                } else if ratio < 0.5 {
                    score += 1.0
                }
            }

            if viewedIds.contains(product.id) {
                score -= 8.0
            }

            return (product, score)
        }

        return scored
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
    }
}
