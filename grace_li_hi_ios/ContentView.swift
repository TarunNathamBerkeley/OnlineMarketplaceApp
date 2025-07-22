import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedTab: Tab = .forYou
    @State private var color1 = 1
    @State private var color2 = 2
    @State var productValidator = ProductValidator()

    enum Tab {
        case forYou
        case nearMe
    }

    let colors: [Color] = [.red, .blue, .green, .yellow]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Tab buttons
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
                    
                    // Swipeable content
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
                    
                    // Bottom bar with Sign Out and "+" button
                    HStack {
                        Spacer()
                        // Probably have to change this to something that isnt a NavigationLink
                        // Maybe have a variable that changes to render a certain view
                        NavigationLink(destination: ProductView(productValidator: productValidator)) {
                            Image(systemName: "plus")
                                .foregroundColor(.black)
                                .padding(12)
                                .background(Color.white.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                        }
                        Spacer()
                        
                        Button(action: signOut) {
                            Text("Sign Out")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.red.opacity(0.7))
                                .cornerRadius(8)
                        }
                        Spacer()
                            .frame(width: 48) // To balance layout since Sign Out isn't centered
                    }
                    .padding()
                    .background(Color.black)
                }
            }
        }
    }

    private func handleSwipe(value: DragGesture.Value, isForYouTab: Bool) {
        let verticalAmount = value.translation.height
        if verticalAmount < -30 {
            if isForYouTab {
                color1 = (color1 + 1) % colors.count
            } else {
                color2 = (color2 + 1) % colors.count
            }
        } else if verticalAmount > 30 {
            if isForYouTab {
                color1 = (color1 - 1 + colors.count) % colors.count
            } else {
                color2 = (color2 - 1 + colors.count) % colors.count
            }
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
