//
//  ConversationsView.swift
//  grace_li_hi_ios
//
//  Created by Tarun Natham 2 on 7/24/25.
//
import SwiftUI

struct ConversationsView: View {
    @StateObject var chatService = ChatService()
    let currentUserId: String
    @State private var recipientEmail = ""
    @State private var messageText = ""

    var body: some View {
        NavigationView {
            List(chatService.conversations) { conversation in
                NavigationLink(destination: ChatView(currentUserId: currentUserId, recipientId: conversation.otherUserId)) {
                    Text(conversation.otherUserEmail)
                }
            }
            .navigationTitle("Messages")
            .onAppear {
                chatService.listenForConversations(currentUserId: currentUserId)
            }
        }
        VStack(alignment: .leading) {
            Text("Send Message Manually").font(.headline)

            TextField("Recipient Email", text: $recipientEmail)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Your Message", text: $messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: {
                chatService.getIdFromEmail(email: recipientEmail) { userId in
                    if let userId = userId {
                        chatService.sendMessage(text: messageText, senderId: currentUserId, recipientId: userId)
                        chatService.listenForConversations(currentUserId: currentUserId)
                        messageText = ""
                        // use userId here
                    }
                }
            }) {
                Text("Send")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()

    }
}


#Preview {
    ConversationsView(currentUserId: "bob")
}
