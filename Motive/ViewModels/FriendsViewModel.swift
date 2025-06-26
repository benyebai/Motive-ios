//
//  FriendsViewModel.swift
//  Motive
//
//  Created by Benjamin bai on 2025-06-09.
//

import Foundation
import Combine

@MainActor
class FriendsViewModel: ObservableObject {
    @Published var friends: [Friend] = []
    @Published var incomingRequests: [FriendRequest] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    func loadData(token: String) async {
        NSLog("🔄 MOTIVE: FriendsViewModel.loadData called")
        isLoading = true
        do {
            NSLog("🔄 MOTIVE: Starting to fetch friends and requests")
            async let friendsTask = FriendsService.shared.fetchFriends(token: token)
            async let requestsTask = FriendsService.shared.fetchPendingRequests(token: token)
            
            NSLog("🔄 MOTIVE: Waiting for both tasks to complete")
            let (fetchedFriends, fetchedRequests) = try await (friendsTask, requestsTask)
            
            NSLog("🔄 MOTIVE: Successfully got friends: \(fetchedFriends.count), requests: \(fetchedRequests.count)")
            self.friends = fetchedFriends
            self.incomingRequests = fetchedRequests
            self.errorMessage = nil
        } catch {
            NSLog("❌ MOTIVE: Error loading friends data: \(error)")
            self.errorMessage = "Failed to load friends data"
        }
        NSLog("🔄 MOTIVE: Setting isLoading to false")
        isLoading = false
    }
    
    func sendFriendRequest(toUsername: String, token: String) async {
        isLoading = true
        do {
            try await FriendsService.shared.sendFriendRequest(toUsername: toUsername, token: token)
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Failed to send friend request"
            print("Error sending friend request:", error)
        }
        isLoading = false
    }
    
    func acceptFriendRequest(requestId: Int, token: String) async {
        isLoading = true
        do {
            try await FriendsService.shared.acceptFriendRequest(requestId: requestId, token: token)
            // Remove the accepted request from the list
            incomingRequests.removeAll { $0.id == requestId }
            // Reload friends list to show the new friend
            await loadData(token: token)
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Failed to accept friend request"
            print("Error accepting friend request:", error)
        }
        isLoading = false
    }
}
