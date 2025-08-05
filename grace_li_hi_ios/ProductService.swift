import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import UIKit

class ProductService {
    static let shared = ProductService()
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    func addProduct(userId: String,
                    name: String,
                    cost: Double,
                    address: String,
                    image: UIImage? = nil,
                    videoURL: URL? = nil,
                    completion: @escaping (Result<String, Error>) -> Void) {
        
        let userDocRef = db.collection("users").document(userId)
        let productsCollectionRef = userDocRef.collection("products")
        let productDocRef = productsCollectionRef.document(name) // using name as ID (be careful)

        productDocRef.getDocument { docSnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if docSnapshot?.exists == true {
                completion(.failure(NSError(domain: "", code: 409, userInfo: [NSLocalizedDescriptionKey: "Product with this name already exists."])))
                return
            }

            let timestamp = Timestamp(date: Date())
            let storagePath = "users/\(userId)/products/\(name)"

            let saveProductToFirestore = { (mediaURLString: String, mediaType: String) in
                let productData: [String: Any] = [
                    "name": name,
                    "cost": cost,
                    "address": address,
                    "mediaURL": mediaURLString,
                    "mediaType": mediaType,
                    "dateCreated": timestamp,
                    "ownerId": userId  // Add ownerId for allProducts
                ]

                // Save to user's products subcollection
                productDocRef.setData(productData) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    // Save to allProducts collection
                    self.db.collection("allProducts").document(productDocRef.documentID).setData(productData) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(mediaURLString))
                        }
                    }
                }
            }

            // Upload image
            if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
                let mediaRef = self.storage.reference(withPath: "\(storagePath).jpg")
                mediaRef.putData(imageData, metadata: nil) { _, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    mediaRef.downloadURL { url, error in
                        guard let downloadURL = url else {
                            completion(.failure(error ?? NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Download URL not found."])))
                            return
                        }
                        saveProductToFirestore(downloadURL.absoluteString, "photo")
                    }
                }

            // Upload video
            } else if let videoURL = videoURL {
                let mediaRef = self.storage.reference(withPath: "\(storagePath).mov")

                do {
                    let videoData = try Data(contentsOf: videoURL)
                    mediaRef.putData(videoData, metadata: nil) { _, error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        mediaRef.downloadURL { url, error in
                            guard let downloadURL = url else {
                                completion(.failure(error ?? NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Download URL not found."])))
                                return
                            }
                            saveProductToFirestore(downloadURL.absoluteString, "video")
                        }
                    }
                } catch {
                    completion(.failure(error))
                }

            } else {
                completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "No media provided."])))
            }
        }
    }
    
    func fetchAllProducts(completion: @escaping ([Product]) -> Void) {
        db.collection("allProducts")
            .order(by: "dateCreated", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching allProducts: \(error.localizedDescription)")
                    completion([])
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }

                let products: [Product] = documents.compactMap { doc in
                    let data = doc.data()
                    return Product(
                        id: doc.documentID,
                        name: data["name"] as? String ?? "",
                        cost: data["cost"] as? Double ?? 0.0,
                        address: data["address"] as? String ?? "",
                        mediaURL: data["mediaURL"] as? String ?? "",
                        mediaType: data["mediaType"] as? String ?? "",
                        dateCreated: (data["dateCreated"] as? Timestamp)?.dateValue() ?? Date(),
                        ownerId: data["ownerId"] as? String ?? ""
                    )
                }

                completion(products)
            }
    }

}
