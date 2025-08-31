//
//  ProductView.swift
//  grace_li_hi_ios
//
//  Created by Tarun Natham 2 on 7/18/25.
//

import SwiftUI
import Observation
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import AVKit
import CoreLocation

@Observable class ProductValidator {
    var name = ""
    var cost: Double = 0.0
    var address = ""
    
    var isSubmitButtonDisabled : Bool {
        return name.isEmpty || cost == 0.0 || address.isEmpty
    }
}

class AddressValidator {
    private let geocoder = CLGeocoder()
    
    func isValidAddress(_ address: String, completion: @escaping (Bool) -> Void) {
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let _ = error {
                completion(false)
                return
            }
            completion(placemarks?.first != nil)
        }
    }
}

struct ProductView: View {
    @Bindable var productValidator : ProductValidator
    @State private var userEmail = "Loading..."
    @State private var isShowingPhotoPicker = false
    @State private var selectedMediaURL: URL?
    @State private var selectedUIImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    @State private var isAddressValid = true
    private let addressValidator = AddressValidator()
    
    var body: some View {
        VStack {
            Text("BaiBai")
                .font(.system(size: 24))
                .fontWeight(.bold)
                .padding(.top, 60)

            Spacer()
            // Pushes everything below down

            VStack(spacing: 30) {
                VStack {
                    Text("Enter your product information")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                }

                VStack(spacing: 20) {
                    TextField(text: $productValidator.name) {
                        Text("Product name")
                            .foregroundColor(Color.gray.opacity(0.8))
                    }
                    .lightGrayOutline()
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                }
                VStack(spacing: 20) {
                    // Formatting does not work properly for dollars
                    // NEED TO FIX THIS ASAP
                    TextField(value: $productValidator.cost, format: .number.precision(.fractionLength(2))) {
                        Text("Product cost")
                            .foregroundColor(Color.gray.opacity(0.8))
                    }
                    .lightGrayOutline()
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .keyboardType(.decimalPad)
                }
                VStack(spacing: 20) {
                    TextField(text: $productValidator.address) {
                        Text("Product address")
                            .foregroundColor(Color.gray.opacity(0.8))
                    }
                    .lightGrayOutline()
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                }
                Button("Upload from Photos") {
                    isShowingPhotoPicker = true
                }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.purple)
                    .cornerRadius(8)
                if let image = selectedUIImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(8)
                        .padding(.top)
                }
                if let videoURL = selectedMediaURL {
                    VideoPlayer(player: AVPlayer(url: videoURL))
                        .frame(height: 200)
                        .cornerRadius(8)
                }

                Button {
                    submitProduct()
                } label: {
                    Text("Submit product")
                }
                .foregroundColor(productValidator.isSubmitButtonDisabled ? .white.opacity(0.7) : .white)
                            .frame(maxWidth: .infinity) // fill the button horizontally
                            .padding(12) // vertical padding for height
                            .background(
                                        productValidator.isSubmitButtonDisabled ? Color.gray : Color.black) // dark gray background
                            .cornerRadius(8)
                .disabled(productValidator.isSubmitButtonDisabled)
            }
            Spacer()
            Spacer()
        }
        .padding()
        .sheet(isPresented: $isShowingPhotoPicker) {
            PhotoPickerView(image: Binding(
                get: { selectedUIImage },
                set: { newImage in
                    // Clear video if image is selected
                    if newImage != nil {
                        selectedMediaURL = nil
                    }
                    selectedUIImage = newImage
                }
            ), videoURL: Binding(
                get: { selectedMediaURL },
                set: { newURL in
                    // Clear image if video is selected
                    if newURL != nil {
                        selectedUIImage = nil
                    }
                    selectedMediaURL = newURL
                }
            ))
        }
    }
    private func loadUserEmail() {
        if let user = Auth.auth().currentUser {
            userEmail = user.email ?? "No email available"
        } else {
            userEmail = "Not signed in"
        }
    }
    private func submitProduct() {
        guard let user = Auth.auth().currentUser else {
            print("User not authenticated")
            return
        }

        guard (selectedMediaURL != nil) != (selectedUIImage != nil) else {
            print("Please select either a photo or video, not both.")
            return
        }

        // Address validation step
        addressValidator.isValidAddress(productValidator.address) { isValid in
            DispatchQueue.main.async {
                self.isAddressValid = isValid
                if !isValid {
                    print("Invalid address. Please enter a real location.")
                    return
                }

                let cost = productValidator.cost

                ProductService.shared.addProduct(
                    userId: user.uid,
                    name: productValidator.name,
                    cost: cost,
                    address: productValidator.address,
                    image: selectedUIImage,
                    videoURL: selectedMediaURL
                ) { result in
                    switch result {
                    case .success(let urlString):
                        print("Upload success! URL: \(urlString)")
                        dismiss()
                    case .failure(let error):
                        print("Upload failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
    
#Preview {
    @Previewable @State var productValidator = ProductValidator()
    ProductView(productValidator : ProductValidator())
}

