//
//  FriendsService.swift
//  Motive
//
//  Created by Benjamin bai on 2025-06-09.
//

import Foundation

class FriendsService {
    static let shared = FriendsService()
    private init() {}

    func fetchFriends(token: String) async throws -> [Friend] {
        guard let url = URL(string: "https://yourdomain.com/api/friends/") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        let friends = try JSONDecoder().decode([Friend].self, from: data)
        return friends
    }
}
