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
        NSLog("🔄 MOTIVE: FriendsService.fetchFriends called")
        guard let url = URL(string: "\(baseURL)/friends/") else {
            NSLog("❌ MOTIVE: Invalid friends URL")
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        NSLog("🔄 MOTIVE: About to fetch friends")
        let (data, response) = try await URLSession.shared.data(for: request)
        NSLog("🔄 MOTIVE: Friends fetch completed")
        
        if let httpResponse = response as? HTTPURLResponse {
            NSLog("🔄 MOTIVE: Friends response status: \(httpResponse.statusCode)")
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
            NSLog("🔄 MOTIVE: Friends response data: \(responseString)")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // Try different date formats
            let iso8601Formatter = ISO8601DateFormatter()
            if let date = iso8601Formatter.date(from: dateString) {
                return date
            }
            
            let microsecondFormatter = DateFormatter()
            microsecondFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
            microsecondFormatter.timeZone = TimeZone(abbreviation: "UTC")
            if let date = microsecondFormatter.date(from: dateString) {
                return date
            }
            
            let standardFormatter = DateFormatter()
            standardFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            standardFormatter.timeZone = TimeZone(abbreviation: "UTC")
            if let date = standardFormatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
        
        do {
            let friends = try decoder.decode([Friend].self, from: data)
            NSLog("✅ MOTIVE: Successfully decoded \(friends.count) friends")
            return friends
        } catch {
            NSLog("❌ MOTIVE: Error decoding friends: \(error)")
            throw error
        }
    }
    
    func fetchPendingRequests(token: String) async throws -> [FriendRequest] {
        NSLog("🔄 MOTIVE: FriendsService.fetchPendingRequests called")
        guard let url = URL(string: "\(baseURL)/friend-request/pending/") else {
            NSLog("❌ MOTIVE: Invalid pending requests URL")
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        NSLog("🔄 MOTIVE: About to fetch pending requests")
        let (data, response) = try await URLSession.shared.data(for: request)
        NSLog("🔄 MOTIVE: Pending requests fetch completed")
        
        if let httpResponse = response as? HTTPURLResponse {
            NSLog("🔄 MOTIVE: Pending requests response status: \(httpResponse.statusCode)")
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
            NSLog("🔄 MOTIVE: Pending requests response data: \(responseString)")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // Try different date formats
            let iso8601Formatter = ISO8601DateFormatter()
            if let date = iso8601Formatter.date(from: dateString) {
                return date
            }
            
            let microsecondFormatter = DateFormatter()
            microsecondFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
            microsecondFormatter.timeZone = TimeZone(abbreviation: "UTC")
            if let date = microsecondFormatter.date(from: dateString) {
                return date
            }
            
            let standardFormatter = DateFormatter()
            standardFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            standardFormatter.timeZone = TimeZone(abbreviation: "UTC")
            if let date = standardFormatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
        
        do {
            let requests = try decoder.decode([FriendRequest].self, from: data)
            NSLog("✅ MOTIVE: Successfully decoded \(requests.count) pending requests")
            return requests
        } catch {
            NSLog("❌ MOTIVE: Error decoding pending requests: \(error)")
            throw error
        }
    }
    
    func sendFriendRequest(toUsername: String, token: String) async throws {
        NSLog("🔄 MOTIVE: sendFriendRequest called with username: \(toUsername)")
        guard let url = URL(string: "\(baseURL)/friend-request/") else {
            NSLog("❌ MOTIVE: Invalid URL")
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["to_user": toUsername]
        NSLog("🔄 MOTIVE: Request body: \(body)")
        request.httpBody = try JSONEncoder().encode(body)
        
        NSLog("🔄 MOTIVE: About to make network request")
        let (data, response) = try await URLSession.shared.data(for: request)
        NSLog("🔄 MOTIVE: Network request completed")
        
        if let httpResponse = response as? HTTPURLResponse {
            NSLog("🔄 MOTIVE: Response status: \(httpResponse.statusCode)")
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
            NSLog("🔄 MOTIVE: Response data: \(responseString)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            NSLog("❌ MOTIVE: No HTTP response")
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode != 201 {
            NSLog("❌ MOTIVE: Bad response status: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                NSLog("❌ MOTIVE: Error response: \(responseString)")
            }
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
