//
//  ProductService.swift
//  grace_li_hi_ios
//
//  Created by Tarun Natham 2 on 7/15/25.
//
// Will change name to DatabseService later

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
                    address: String, // you can keep this or remove if not needed
                    image: UIImage? = nil,
                    videoURL: URL? = nil,
                    completion: @escaping (Result<String, Error>) -> Void) {

        let userDocRef = db.collection("users").document(userId)
        let productsCollectionRef = userDocRef.collection("products")
        let productDocRef = productsCollectionRef.document(name)

        // Check duplicate product name for this user
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

            // Storage path for media file:
            // Example: users/userId/products/productName.jpg (or .mov)
            let storagePath = "users/\(userId)/products/\(name)"

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
                        // Save product info to Firestore
                        let productData: [String: Any] = [
                            "name": name,
                            "cost": cost,
                            "address": address,
                            "mediaURL": downloadURL.absoluteString,
                            "mediaType": "photo",
                            "dateCreated": timestamp
                        ]
                        productDocRef.setData(productData) { error in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                completion(.success(downloadURL.absoluteString))
                            }
                        }
                    }
                }

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
                            // Save product info to Firestore
                            let productData: [String: Any] = [
                                "name": name,
                                "cost": cost,
                                "address": address,
                                "mediaURL": downloadURL.absoluteString,
                                "mediaType": "video",
                                "dateCreated": timestamp
                            ]
                            productDocRef.setData(productData) { error in
                                if let error = error {
                                    completion(.failure(error))
                                } else {
                                    completion(.success(downloadURL.absoluteString))
                                }
                            }
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
}
