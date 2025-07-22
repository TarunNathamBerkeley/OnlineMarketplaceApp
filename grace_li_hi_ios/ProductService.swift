//
//  ProductService.swift
//  grace_li_hi_ios
//
//  Created by Tarun Natham 2 on 7/15/25.
//
// Will change name to DatabseService later

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class ProductService {
    static let shared = ProductService()
        
    // Initialize db as a property of the singleton
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    private init() {}
    
    func addProducts(userId: String, name: String, cost: Double, address: String, videoURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        let userProductsRef = db.collection("users").document(userId).collection("products")
        // 1. Create a unique storage path
        let videoRef = storage.reference()
            .child("users/\(userId)/products/\(UUID().uuidString).mp4")
        
        // 2. Upload the video
        videoRef.putFile(from: videoURL, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
        // 3. Get download URL after upload completes
        videoRef.downloadURL { url, error in
            guard let downloadURL = url else {
                completion(.failure(error ?? URLError(.badServerResponse)))
                return
            }
            // 4. Save product data with video reference
            let productData: [String: Any] = [
                "name": name,
                "cost": cost,
                "address": address,
                "videoURL": downloadURL.absoluteString, // Store the public URL
                "createdAt": FieldValue.serverTimestamp()
            ]
                
            // Add the new product document
            self.db.collection("users").document(userId)
                .collection("products").addDocument(data: productData) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(downloadURL.absoluteString))
                    }
                }
            }
        }
    }
}
