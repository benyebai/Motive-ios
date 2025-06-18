//
//  Models.swift
//  Motive
//
//  Created by Benjamin bai on 2025-06-09.
//

import Foundation

struct Friend: Identifiable, Codable {
    let id: Int
    let username: String
}

struct FriendRequest: Identifiable, Codable {
    let id: Int
    let fromUserUsername: String
    let toUserId: Int
}
