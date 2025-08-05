//
//  grace_li_hi_iosApp.swift
//  grace_li_hi_ios
//
//  Created by Tarun Natham 2 on 7/4/25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn  // Add this import

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    // ADD THIS METHOD FOR GOOGLE SIGN-IN URL HANDLING
    func application(_ app: UIApplication,
                   open url: URL,
                   options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct grace_li_hi_iosApp: App {
    // Register the AppDelegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authManager = AuthManager()
    @StateObject var cartManager = CartManager()
    @State var userValidator = UserValidator()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if authManager.isSignedIn {
                    ContentView()
                        .environmentObject(authManager)
                        .environmentObject(cartManager)
                        .transition(.opacity)
                } else {
                    LoginView(userValidator: userValidator)
                        .environmentObject(authManager)
                        .transition(.opacity)
                }
            }
            .animation(.default, value: authManager.isSignedIn)
        }
    }
}
