//
//  ChatView.swift
//  grace_li_hi_ios
//
//  Created by Tarun Natham 2 on 7/22/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

struct ChatView: View {
    @StateObject var chatService = ChatService()
    @State private var messageText = ""
    @State private var recipientEmail: String = ""
    let currentUserId: String
    let recipientId: String
    
    var body: some View {
        VStack {
            Text("Chat with \(recipientEmail)")
                        .font(.headline)
                        .padding(.top)
            
            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(chatService.messages) { message in
                            HStack {
                                if message.senderId == currentUserId {
                                    Spacer()
                                    Text(message.text)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                        .foregroundColor(.white)
                                } else {
                                    Text(message.text)
                                        .padding()
                                        .background(Color.gray)
                                        .cornerRadius(10)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                HStack {
                    TextField("Type a message", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Send") {
                        chatService.sendMessage(text: messageText, senderId: currentUserId, recipientId: recipientId)
                        messageText = ""
                        print("Message sent successfully")
                    }
                }
                .padding()
            }
            .onAppear {
                chatService.fetchMessages(senderId: currentUserId, recipientId: recipientId)
                chatService.getEmailFromId(id: recipientId) { email in
                    if let email = email {
                        recipientEmail = email
                    } else {
                        recipientEmail = "Unknown User"
                    }
                }
            }
        }
    }
}

#Preview {
    ChatView(currentUserId : "bob", recipientId: "bob")
}
