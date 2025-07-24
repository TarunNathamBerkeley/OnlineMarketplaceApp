//
//  Message.swift
//  grace_li_hi_ios
//
//  Created by Tarun Natham 2 on 7/24/25.
//

import Foundation
import FirebaseFirestoreSwift

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var text: String
    var senderId: String
    var recipientId: String
    var timestamp: Date
}
