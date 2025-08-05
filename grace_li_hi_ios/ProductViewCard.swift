import SwiftUI
import AVKit
import FirebaseFirestore

struct ProductViewCard: View {
    let product: Product
    @State private var sellerEmail: String = ""

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                // Media
                if product.mediaType == "video", let url = URL(string: product.mediaURL) {
                    LoopingVideoPlayer(videoURL: url)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else if let url = URL(string: product.mediaURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Color.gray
                }

                // Overlay with product info
                VStack(alignment: .leading, spacing: 8) {
                    Text(product.name)
                        .font(.title2)
                        .bold()
                    Text(String(format: "$%.2f", product.cost))
                        .font(.headline)
                    Text(product.address)
                        .font(.subheadline)
                    if !sellerEmail.isEmpty {
                        Text("By: \(sellerEmail)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
        .ignoresSafeArea()
        .onAppear {
            fetchSellerEmail()
        }
    }

    private func fetchSellerEmail() {
        let db = Firestore.firestore()
        db.collection("users").document(product.ownerId).getDocument { snapshot, error in
            if let data = snapshot?.data(), let email = data["email"] as? String {
                sellerEmail = email
            }
        }
    }
}
