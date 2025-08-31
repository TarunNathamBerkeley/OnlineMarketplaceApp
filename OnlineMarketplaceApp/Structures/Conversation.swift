//
//  Conversation.swift
//  grace_li_hi_ios
//
//  Created by Tarun Natham 2 on 7/24/25.
//

import Foundation


struct Conversation: Identifiable {
    var id: String
    var otherUserId: String
    var otherUserEmail: String
    var lastMessage: String
    var timestamp: Date
}
