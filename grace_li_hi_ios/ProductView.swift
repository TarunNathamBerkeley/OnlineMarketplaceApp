//
//  ProductView.swift
//  grace_li_hi_ios
//
//  Created by Tarun Natham 2 on 7/18/25.
//

import SwiftUI

import SwiftUI

import Observation
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import AVKit

@Observable class ProductValidator {
    var name = ""
    var cost = ""
    var address = ""
    
    var isSubmitButtonDisabled : Bool {
        false
    }
    
    func isValidValue(string : String) -> Bool {
        let emailRegex = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/
            .ignoresCase()
        return !string.ranges(of: emailRegex).isEmpty
    }
}

struct ProductView: View {
    @Bindable var productValidator : ProductValidator
    @State private var userEmail = "Loading..."
    @State private var isShowingPhotoPicker = false
    @State private var selectedMediaURL: URL?
    @State private var selectedUIImage: UIImage?
    
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
                    TextField(text: $productValidator.cost) {
                        Text("Product cost")
                            .foregroundColor(Color.gray.opacity(0.8))
                    }
                    .lightGrayOutline()
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .keyboardType(.decimalPad)
                }
                VStack(spacing: 20) {
                    TextField(text: $productValidator.name) {
                        Text("Product address")
                            .foregroundColor(Color.gray.opacity(0.8))
                    }
                    .lightGrayOutline()
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                }
                // Need to add something that requests access to photos when opening this
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
                } label: {
                    Text("Submit product")
                }
                .foregroundColor(.white)
                            .frame(maxWidth: .infinity) // fill the button horizontally
                            .padding(12) // vertical padding for height
                            .background(Color(.black)) // dark gray background
                            .cornerRadius(8)

            }
            Spacer()
            Spacer()
        }
        .padding()
        .sheet(isPresented: $isShowingPhotoPicker) {
            PhotoPickerView(image: $selectedUIImage, videoURL: $selectedMediaURL)
        }
    }
    private func loadUserEmail() {
        if let user = Auth.auth().currentUser {
            userEmail = user.email ?? "No email available"
        } else {
            userEmail = "Not signed in"
        }
    }
}
    
#Preview {
    @Previewable @State var productValidator = ProductValidator()
    ProductView(productValidator : ProductValidator())
}

