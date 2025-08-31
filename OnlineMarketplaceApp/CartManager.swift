//
//  CartManager.swift
//  grace_li_hi_ios
//
//  Created by Tarun Natham 2 on 8/3/25.
//


import Foundation

class CartManager: ObservableObject {
    @Published var items: [Product] = []
    
    func addToCart(_ product: Product) {
        // Avoid duplicates if needed, or just append
        if !items.contains(where: { $0.id == product.id }) {
            items.append(product)
        }
    }
    
    func removeFromCart(_ product: Product) {
        items.removeAll { $0.id == product.id }
    }
    
    func clearCart() {
        items.removeAll()
    }
}
