//
//  ChatService.swift
//  grace_li_hi_ios
//
//  Created by Tarun Natham 2 on 7/24/25.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import Combine

class ChatService: ObservableObject {
    @Published var messages: [Message] = []
    @Published var conversations: [Conversation] = []
    private var db = Firestore.firestore()
    
    func listenForConversations(currentUserId: String) {
        db.collection("conversations")
            .whereField("participants", arrayContains: currentUserId)
            .order(by: "lastTimestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                guard let documents = snapshot?.documents else {
                    print("Error fetching conversations: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                var tempConversations: [Conversation] = []
                let group = DispatchGroup()

                for doc in documents {
                    let data = doc.data()

                    guard
                        let participants = data["participants"] as? [String],
                        let lastMessage = data["lastMessage"] as? String,
                        let timestamp = (data["lastTimestamp"] as? Timestamp)?.dateValue()
                    else {
                        continue
                    }

                    guard let otherUserId = participants.first(where: { $0 != currentUserId }) else {
                        continue
                    }

                    group.enter()
                    self.db.collection("users").document(otherUserId).getDocument { userSnapshot, error in
                        defer { group.leave() }

                        guard let userData = userSnapshot?.data(),
                              let otherUserEmail = userData["email"] as? String else {
                            return
                        }

                        let conversation = Conversation(
                            id: doc.documentID,
                            otherUserId: otherUserId,
                            otherUserEmail: otherUserEmail,
                            lastMessage: lastMessage,
                            timestamp: timestamp
                        )

                        tempConversations.append(conversation)
                    }
                }

                group.notify(queue: .main) {
                    self.conversations = tempConversations.sorted { $0.timestamp > $1.timestamp }
                }
            }
    }

    func fetchConversations() {
            db.collection("conversations").order(by: "timestamp", descending: false)
                .addSnapshotListener { snapshot, error in
                    guard let documents = snapshot?.documents else {
                        print("Error fetching conversations: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    self.messages = documents.compactMap { doc in
                        try? doc.data(as: Message.self)
                    }
                }
        }
    
    func fetchMessages(senderId: String, recipientId: String) {
        let convoId = conversationIdFor(senderId, recipientId)

        db.collection("conversations")
            .document(convoId)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                guard let documents = snapshot?.documents else {
                    print("No messages or error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                var loadedMessages: [Message] = []

                for doc in documents {
                    let data = doc.data()
                    guard
                        let text = data["text"] as? String,
                        let senderId = data["senderId"] as? String,
                        let recipientId = data["recipientId"] as? String,
                        let timestamp = (data["timestamp"] as? Timestamp)?.dateValue()
                    else {
                        continue
                    }

                    let message = Message(
                        id: doc.documentID,
                        text: text,
                        senderId: senderId,
                        recipientId: recipientId,
                        timestamp: timestamp
                    )

                    loadedMessages.append(message)
                }

                DispatchQueue.main.async {
                    self.messages = loadedMessages
                }
            }
    }
        
        // Send a message
        func sendMessage(text: String, senderId: String, recipientId: String) {
            guard let senderEmail = Auth.auth().currentUser?.email else { return }

            let message = Message(
                text: text,
                senderId: senderId,
                recipientId: recipientId,
                timestamp: Date()
            )
            
            var messageDict: [String: Any]
            do {
                messageDict = try Firestore.Encoder().encode(message)
            } catch {
                print("Encoding error: \(error)")
                return
            }

            messageDict["senderEmail"] = senderEmail
            
            let conversationMetadata: [String: Any] = [
                "participants": [senderId, recipientId],
                "lastMessage": text,
                "lastTimestamp": Timestamp(),
            ]
            
            let conversationId = conversationIdFor(senderId, recipientId)
            db.collection("conversations")
              .document(conversationId)
              .setData(conversationMetadata, merge: true)
            
            db.collection("conversations")
              .document(conversationId)
              .collection("messages")
              .addDocument(data: messageDict)
            }
    
    func getIdFromEmail(email: String, completion: @escaping (String?) -> Void) {
        let emailLowercased = email.lowercased()
        db.collection("users")
            .whereField("email", isEqualTo: emailLowercased)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching user ID: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let documents = snapshot?.documents, let firstDoc = documents.first else {
                    print("No user found with email: \(emailLowercased)")
                    completion(nil)
                    return
                }
                
                let userId = firstDoc.documentID
                completion(userId)
            }
    }
    
    func getEmailFromId(id: String, completion: @escaping(String?) -> Void) {
        db.collection("users").document(id).getDocument { (document, error) in
                if let error = error {
                    print("Error fetching user: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let document = document, document.exists,
                      let data = document.data(),
                      let email = data["email"] as? String else {
                    completion(nil)
                    return
                }
                
                completion(email)
            }
    }
    
    func conversationIdFor(_ user1: String, _ user2: String) -> String {
        return [user1, user2].sorted().joined(separator: "_")
    }
}
