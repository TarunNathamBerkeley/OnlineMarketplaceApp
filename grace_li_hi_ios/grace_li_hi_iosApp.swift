//
//  grace_li_hi_iosApp.swift
//  grace_li_hi_ios
//
//  Created by Tarun Natham 2 on 7/4/25.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct grace_li_hi_iosApp: App {
    @State var userValidator = UserValidator()
    
    var body: some Scene {
        WindowGroup {
            LoginView(userValidator : userValidator)
        }
    }
}
