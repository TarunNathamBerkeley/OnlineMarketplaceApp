// This ContentView is temporary

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedTab: Tab = .forYou
    @State private var color1 = 1
    @State private var color2 = 2
    
    // User email state
    @State private var userEmail: String = "Loading..."
    
    enum Tab {
        case forYou
        case nearMe
    }
    
    let colors: [Color] = [.red, .blue, .green, .yellow]
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                // User email and sign out button at top
                HStack {
                    Text(userEmail)
                        .foregroundColor(.white)
                        .padding(.leading)
                    
                    Spacer()
                    
                    Button(action: signOut) {
                        Text("Sign Out")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(8)
                    }
                    .padding(.trailing)
                }
                .padding(.top)
                
                // Your existing tab buttons
                HStack {
                    Button(action: {
                        selectedTab = .forYou
                    }) {
                        Text("For You")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(selectedTab == .forYou ? Color.gray.opacity(0.3) : Color.clear)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        selectedTab = .nearMe
                    }) {
                        Text("Near Me")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(selectedTab == .nearMe ? Color.gray.opacity(0.3) : Color.clear)
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                // Your existing color views
                if selectedTab == .forYou {
                    Rectangle()
                        .fill(colors[color1])
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .gesture(
                            DragGesture(minimumDistance: 20)
                                .onEnded { value in
                                    handleSwipe(value: value, isForYouTab: true)
                                }
                        )
                } else {
                    Rectangle()
                        .fill(colors[color2])
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .gesture(
                            DragGesture(minimumDistance: 20)
                                .onEnded { value in
                                    handleSwipe(value: value, isForYouTab: false)
                                }
                        )
                }
            }
        }
        .onAppear {
            loadUserEmail()
        }
    }
    
    private func handleSwipe(value: DragGesture.Value, isForYouTab: Bool) {
        let verticalAmount = value.translation.height
        if verticalAmount < -30 {
            // Swipe up
            if isForYouTab {
                color1 = (color1 + 1) % colors.count
            } else {
                color2 = (color2 + 1) % colors.count
            }
        } else if verticalAmount > 30 {
            // Swipe down
            if isForYouTab {
                color1 = (color1 - 1 + colors.count) % colors.count
            } else {
                color2 = (color2 - 1 + colors.count) % colors.count
            }
        }
    }
    
    private func loadUserEmail() {
        if let user = Auth.auth().currentUser {
            userEmail = user.email ?? "No email available"
        } else {
            userEmail = "Not signed in"
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

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
