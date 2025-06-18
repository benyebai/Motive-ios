//
//  Models.swift
//  Motive
//
//  Created by Benjamin bai on 2025-06-09.
//

import Foundation

struct Friend: Identifiable, Codable {
    let id: Int
    let friendUsername: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case friendUsername = "friend_username"
        case createdAt = "created_at"
    }
}

struct FriendRequest: Identifiable, Codable {
    let id: Int
    let fromUserUsername: String
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case fromUserUsername = "from_user_username"
        case timestamp
    }
}
