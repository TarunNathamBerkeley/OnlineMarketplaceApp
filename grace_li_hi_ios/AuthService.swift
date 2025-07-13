//
//  AuthService.swift
//  grace_li_hi_ios
//
//  Created by Tarun Natham 2 on 7/13/25.
//


import FirebaseAuth
import GoogleSignIn
import SwiftUI

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
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
    
    // Add error handling
    enum AuthError: Error {
        case noRootViewController
        case noIDToken
        case unknownError
    }
}
