//
//  AuthManager.swift
//  grace_li_hi_ios
//
//  Created by Tarun Natham 2 on 7/13/25.
//


import Foundation
import FirebaseAuth
import Combine

class AuthManager: ObservableObject {
    @Published var isSignedIn = false
    
    init() {
        // Listen for auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            self?.isSignedIn = user != nil
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        isSignedIn = false
    }
}
