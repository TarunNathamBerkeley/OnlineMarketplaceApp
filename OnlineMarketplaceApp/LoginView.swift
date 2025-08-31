//
//  LoginView.swift
//  grace_li_hi_ios
//
//  Created by Tarun Natham 2 on 7/13/25.
//

import SwiftUI

import Observation
import AuthenticationServices
import CryptoKit

extension View {
    func lightGrayOutline() -> some View {
        self
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius : 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
    
    func darkGrayForeground() -> some View {
        self
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius : 8)
                    .fill(Color.black)
            )
    }
}

// This class is pretty much useless since only Google/Apple sign-in is allowed
@Observable class UserValidator {
    var email = ""
    var password = ""
    
    var isSubmitButtonDisabled : Bool {
        email.isEmpty || password.count < 8 || !isValidEmail(string : email)
    }
    
    // Change this to check if valid email or phone number
    func isValidEmail(string : String) -> Bool {
        let emailRegex = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/
            .ignoresCase()
        return !string.ranges(of: emailRegex).isEmpty
    }
}

struct LoginView: View {
    @State private var isLoading = false
    @EnvironmentObject var authManager: AuthManager
    @State private var currentNonce: String?
    
    @Bindable var userValidator : UserValidator
    
    var body: some View {
        VStack {
            Text("BaiBai")
                .font(.system(size: 24))
                .fontWeight(.bold)
                .padding(.top, 60)

            Spacer()
            // Pushes everything below down

            /* Need to remove the stuff abt creating account with an email
             because we're just doing Google/Apple sign-in
             */
            VStack(spacing: 30) {
                VStack {
                    Text("Create an account")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                    Text("Enter your email to sign up for this app")
                }

                VStack(spacing: 20) {
                    TextField(text: $userValidator.email) {
                        Text("email\u{200B}@domain.com")
                            .foregroundColor(Color.gray.opacity(0.8))
                    }
                    .lightGrayOutline()
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)

                    SecureField(text: $userValidator.password) {
                        Text("Password")
                            .foregroundColor(Color.gray.opacity(0.8))
                    }
                    .lightGrayOutline()

                    Button {
                        print("Email: \(userValidator.email), Password \(userValidator.password)")
                    } label: {
                        Text("Create account")
                    }
                    .disabled(userValidator.isSubmitButtonDisabled)
                    .foregroundColor(.white)
                                .frame(maxWidth: .infinity) // fill the button horizontally
                                .padding(12) // vertical padding for height
                                .background(Color(.black)) // dark gray background
                                .cornerRadius(8)
                    
                    
                    Button(action: handleGoogleSignIn) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.black)
                            } else {
                                Image("GoogleLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            }
                            Text("Continue with Google")
                        }
                        .disabled(isLoading)
                    }
                    .foregroundColor(.black)
                                .frame(maxWidth: .infinity) // fill the button horizontally
                                .padding(12) // vertical padding for height
                                .background(Color(.gray.opacity(0.3))) // dark gray background
                                .cornerRadius(8)
                    
                    
                    /* Figure out how AppCheck works, maybe get debug
                     token or something to prevent the annoying error.
                     */
                    SignInWithAppleButton(.signIn) { request in
                        let nonce = AuthService.shared.randomNonceString()
                        currentNonce = nonce
                        request.requestedScopes = [.fullName, .email]
                        request.nonce = sha256(nonce)
                    } onCompletion: { result in
                        Task {
                            do {
                                if case .success(let auth) = result,
                                   let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential,
                                   let idTokenData = appleIDCredential.identityToken,
                                   let idTokenString = String(data: idTokenData, encoding: .utf8) {
                                    
                                    let authResult = try await AuthService.shared.signInWithApple(
                                        idTokenString: idTokenString,
                                        nonce: currentNonce
                                    )
                                    try await AuthService.shared.checkAndHandleNewUser(user: authResult.user)
                                    authManager.isSignedIn = true
                                }
                            } catch {
                                print("Apple Sign-In failed: \(error)")
                            }
                        }
                    }
                    .signInWithAppleButtonStyle(.black) // or .white
                    .frame(height: 50)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
            }

            Spacer()
            Spacer()
            Spacer()
        }
        .padding()
    }
    
    private func handleGoogleSignIn() {
            Task {
                isLoading = true
                
                do {
                    let result = try await AuthService.shared.signInWithGoogle()
                    
                    try await AuthService.shared.checkAndHandleNewUser(user: result.user)
                    // Handle successful login
                    print("User signed in: \(result.user.uid)")
                    authManager.isSignedIn = true
                    // Navigate to home screen or update app state
                    
                } catch {
                    print("Google Sign-In failed: \(error)")
                }
                
                isLoading = false
            }
        }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
    }
}

#Preview {
    @Previewable @State var userValidator = UserValidator()
    LoginView(userValidator: UserValidator())
            .environmentObject(AuthManager())
}
