//
//  CartView.swift
//  grace_li_hi_ios
//
//  Created by Tarun Natham 2 on 8/3/25.
//


import SwiftUI

// Need to add image thumbnails for each product
struct CartView: View {
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        NavigationStack {
            // Removed the ScrollView from here
            VStack {
                if cartManager.items.isEmpty {
                    // Empty cart view
                    VStack {
                        Spacer()
                        Text("Your cart is empty")
                            .foregroundColor(.gray)
                            .font(.title2)
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Cart with items
                    List {
                        ForEach(cartManager.items, id: \.id) { product in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(product.name)
                                        .font(.headline)
                                        .foregroundColor(Color.white)
                                    Text("$\(product.cost, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .foregroundColor(Color.white)
                                }
                                Spacer()
                                Button(action: {
                                    cartManager.removeFromCart(product)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .listRowBackground(Color.black)
                            .padding(.vertical, 8)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.black)
                    
                    Button(action: {
                        cartManager.clearCart()
                    }) {
                        Text("Clear Cart")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                            .padding()
                    }
                }
            }
            .frame(maxWidth: .infinity) // Ensure full width
            .navigationTitle("Shopping Cart")
            .background(Color.black.ignoresSafeArea())
        }
    }
}
