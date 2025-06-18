//
//  FriendsViewModel.swift
//  Motive
//
//  Created by Benjamin bai on 2025-06-09.
//

import Foundation
import Combine

class FriendsViewModel: ObservableObject {
    @Published var friends: [Friend] = []
    @Published var incomingRequests: [FriendRequest] = []

    func loadData(token: String) async {
        do {
            let fetchedFriends = try await FriendsService.shared.fetchFriends(token: token)
            await MainActor.run {
                self.friends = fetchedFriends
            }
        } catch {
            print("Error fetching friends:", error)
        }
    }
}
