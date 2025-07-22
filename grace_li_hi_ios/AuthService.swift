//
//  AuthService.swift
//  grace_li_hi_ios
//
//  Created by Tarun Natham 2 on 7/13/25.
//


import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import FirebaseFirestore
import SwiftUI

class AuthService {
    static let shared = AuthService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func checkAndHandleNewUser(user: FirebaseAuth.User) async throws -> Bool {
        let userRef = db.collection("users").document(user.uid)
        let document = try await userRef.getDocument()
        
        if !document.exists {
            try await createNewUser(user: user)
            return true // Is new user
        }
        return false // Existing user
    }
    
    private func createNewUser(user: FirebaseAuth.User) async throws {
            let userData: [String: Any] = [
                "uid": user.uid,
                "email": user.email ?? "",
                "createdAt": FieldValue.serverTimestamp(),
                "lastLogin": FieldValue.serverTimestamp()
            ]
            try await db.collection("users").document(user.uid).setData(userData)
        }
    
    func signInWithGoogle() async throws -> AuthDataResult {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            throw AuthError.noRootViewController
        }
        
        // Start the Google sign in flow
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        let user = result.user
        
        // Get the ID token
        guard let idToken = user.idToken?.tokenString else {
            throw AuthError.noIDToken
        }
        
        // Create Firebase credential
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: user.accessToken.tokenString
        )
        
        // Sign in with Firebase
        return try await Auth.auth().signIn(with: credential)
    }
    
    func signInWithApple(idTokenString: String, nonce: String?) async throws -> AuthDataResult {
            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: nil
            )
            return try await Auth.auth().signIn(with: credential)
        }
        
        // Helper for Apple Sign-In
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. Error: \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
        
    enum AuthError: Error {
        case noRootViewController
        case noIDToken
        case userCancelledSignIn
        case appleSignInFailed
        case invalidAppleToken
        case unknownError
    }
}
