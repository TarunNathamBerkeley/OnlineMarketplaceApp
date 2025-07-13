import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .forYou
    @State private var color1 = 1
    @State private var color2 = 2

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
                // Top buttons
                HStack {
                    Button(action: {
                        selectedTab = .forYou
                    }) {
                        Text("For You")
                            .padding(2)
                            .background(selectedTab == .forYou ? Color.gray.opacity(0.3) : Color.clear)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        selectedTab = .nearMe
                    }) {
                        Text("Near Me")
                            .padding(2)
                            .background(selectedTab == .nearMe ? Color.gray.opacity(0.3) : Color.clear)
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                
                
                // Switching views
                if selectedTab == .forYou {
                    Rectangle()
                        .fill(colors[color1])
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Rectangle()
                        .fill(colors[color2])
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .gesture(
                        DragGesture(minimumDistance: 20)
                            .onEnded { value in
                                let verticalAmount = value.translation.height
                                if selectedTab == .forYou {
                                    if verticalAmount < -30 {
                                        color1 = (color1 + 1) % colors.count
                                    } else if verticalAmount > 30 {
                                        color1 = (color1 - 1) % colors.count
                                    }
                                } else {
                                    if verticalAmount < -30 {
                                        color2 = (color2 + 1) % colors.count
                                    } else if verticalAmount > 30 {
                                        color2 = (color2 - 1) % colors.count
                                    }
                                    color2 = min(color2, 3)
                                    color2 = max(color2, 0)
                                }
                                // can probably clean up these if statements
                                /* rn the code will rotate through all the colors.
                                 */
                            }
                    )
        }
    }
}

#Preview {
    ContentView()
}


