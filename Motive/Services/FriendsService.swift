//
//  FriendsService.swift
//  Motive
//
//  Created by Benjamin bai on 2025-06-09.
//

import Foundation

class FriendsService {
    static let shared = FriendsService()
    private let baseURL = "http://127.0.0.1:8000/api"
    private init() {}
    
    func fetchFriends(token: String) async throws -> [Friend] {
        guard let url = URL(string: "\(baseURL)/friends/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([Friend].self, from: data)
    }
    
    func fetchPendingRequests(token: String) async throws -> [FriendRequest] {
        guard let url = URL(string: "\(baseURL)/friend-request/pending/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([FriendRequest].self, from: data)
    }
    
    func sendFriendRequest(toUsername: String, token: String) async throws {
        guard let url = URL(string: "\(baseURL)/friend-request/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["to_user": toUsername]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }
    }
    
    func acceptFriendRequest(requestId: Int, token: String) async throws {
        guard let url = URL(string: "\(baseURL)/friend-request/\(requestId)/accept/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
}
