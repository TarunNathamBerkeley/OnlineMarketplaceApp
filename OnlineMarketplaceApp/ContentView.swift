import SwiftUI
import FirebaseAuth
import AVKit

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var cartManager: CartManager

    @State private var selectedTab: Tab = .forYou
    @State private var currentIndex = 0
    @State private var products: [Product] = []
    @State private var isLoadingFeed = true

    private var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    enum Tab {
        case forYou
        case nearMe
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Button("For You") {
                            selectedTab = .forYou
                            loadFeed()
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

                    if isLoadingFeed {
                        Spacer()
                        ProgressView()
                            .tint(.white)
                        Spacer()
                    } else if products.isEmpty {
                        Spacer()
                        Text("No products yet")
                            .foregroundColor(.gray)
                        Spacer()
                    } else {
                        TabView(selection: $currentIndex) {
                            ForEach(products.indices, id: \.self) { index in
                                VStack(spacing: 0) {
                                    ProductViewCard(
                                        product: products[index],
                                        isActive: index == currentIndex
                                    )
                                    .tag(index)

                                    Button(action: {
                                        cartManager.addToCart(products[index])
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
                                    .padding(.bottom, 4)
                                }
                                .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .onChange(of: currentIndex) { _, newIndex in
                            guard newIndex < products.count else { return }
                            ViewHistoryService.shared.recordView(
                                userId: currentUserId,
                                product: products[newIndex]
                            )
                        }
                    }

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

                        NavigationLink(
                            destination: ConversationsView(currentUserId: currentUserId)
                        ) {
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

                        NavigationLink(destination: CartView().environmentObject(cartManager)) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "cart")
                                    .foregroundColor(.black)
                                    .padding(12)
                                    .background(Color.white.opacity(0.7))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                    )
                                if !cartManager.items.isEmpty {
                                    Text("\(cartManager.items.count)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 16, height: 16)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 4, y: -4)
                                }
                            }
                        }

                        Spacer()

                        Button("Sign Out", action: signOut)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(8)

                        Spacer().frame(width: 8)
                    }
                    .padding(.vertical, 8)
                    .background(Color.black)
                }
            }
            .onAppear {
                loadFeed()
            }
        }
    }

    private func loadFeed() {
        isLoadingFeed = true
        currentIndex = 0

        guard !currentUserId.isEmpty else {
            ProductService.shared.fetchAllProducts { fetched in
                self.products = fetched
                self.isLoadingFeed = false
            }
            return
        }

        RecommendationService.shared.fetchRecommendedFeed(userId: currentUserId) { ranked in
            if ranked.isEmpty {
                ProductService.shared.fetchAllProducts { fetched in
                    self.products = fetched
                    self.isLoadingFeed = false
                }
            } else {
                self.products = ranked
                self.isLoadingFeed = false

                if let first = ranked.first {
                    ViewHistoryService.shared.recordView(
                        userId: self.currentUserId,
                        product: first
                    )
                }
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
