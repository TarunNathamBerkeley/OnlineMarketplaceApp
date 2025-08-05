import SwiftUI
import FirebaseAuth
import AVKit

// Need to make it so that media stops playing when navigating to other views
struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var cartManager: CartManager
    
    @State private var selectedTab: Tab = .forYou
    @State private var currentIndex = 0
    @State private var products: [Product] = []

    enum Tab {
        case forYou
        case nearMe
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Tabs
                    HStack {
                        Button("For You") {
                            selectedTab = .forYou
                        }
                        .foregroundColor(.white)
                        .padding(8)
                        .background(selectedTab == .forYou ? Color.gray.opacity(0.3) : Color.clear)
                        .cornerRadius(8)

                        Button("Near Me") {
                            selectedTab = .nearMe
                        }
                        .foregroundColor(.white)
                        .padding(8)
                        .background(selectedTab == .nearMe ? Color.gray.opacity(0.3) : Color.clear)
                        .cornerRadius(8)
                    }
                    .padding()

                    // Product + Add to Cart button
                    if products.indices.contains(currentIndex) {
                        VStack {
                            ProductViewCard(product: products[currentIndex])
                                .gesture(
                                    DragGesture(minimumDistance: 20)
                                        .onEnded { value in
                                            handleSwipe(value)
                                        }
                                )

                            Button(action: {
                                let product = products[currentIndex]
                                cartManager.addToCart(product)
                            }) {
                                Text("Add to Cart")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }

                    // Bottom controls
                    HStack {
                        Spacer()

                        NavigationLink(destination: ProductView(productValidator: ProductValidator())) {
                            Image(systemName: "plus")
                                .foregroundColor(.black)
                                .padding(12)
                                .background(Color.white.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                        }

                        Spacer()

                        NavigationLink(destination: ConversationsView(currentUserId: Auth.auth().currentUser?.uid ?? "")) {
                            Image(systemName: "message")
                                .foregroundColor(.black)
                                .padding(12)
                                .background(Color.white.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                        }

                        Spacer()
                        
                        // Cart Button
                        NavigationLink(destination: CartView()
                            .environmentObject((self.cartManager))) {
                            Image(systemName: "cart")
                                .foregroundColor(.black)
                                .padding(12)
                                .background(Color.white.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                        }

                        Spacer()

                        Button("Sign Out", action: signOut)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(8)

                        Spacer().frame(width: 48)
                    }
                    .padding()
                    .background(Color.black)
                }
            }
            .onAppear {
                ProductService.shared.fetchAllProducts { fetched in
                    self.products = fetched
                }
            }
        }
    }

    private func handleSwipe(_ value: DragGesture.Value) {
        let verticalAmount = value.translation.height
        if verticalAmount < -30 {
            if currentIndex < products.count - 1 {
                currentIndex += 1
            }
        } else if verticalAmount > 30 {
            if currentIndex > 0 {
                currentIndex -= 1
            }
        }
    }

    private func signOut() {
        do {
            try authManager.signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
