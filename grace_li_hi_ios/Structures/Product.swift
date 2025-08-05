//
//  Product.swift
//  grace_li_hi_ios
//
//  Created by Tarun Natham 2 on 8/3/25.
//

import Foundation

struct Product: Identifiable {
    var id: String
    var name: String
    var cost: Double
    var address: String
    var mediaURL: String
    var mediaType: String
    var dateCreated: Date
    var ownerId: String
}
