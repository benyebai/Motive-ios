//
//  AuthViewModel.swift
//  Motive
//
//  Created by Benjamin bai on 2025-06-08.
//

import Foundation

struct TokenResponse: Codable {
    let token: String
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var token: String?
    @Published var username: String?
    @Published var errorMessage: String?

    func login(username: String, password: String) async {
        guard let url = URL(string: "http://127.0.0.1:8000/api/token/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["username": username, "password": password]
        request.httpBody = try? JSONEncoder().encode(body)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(TokenResponse.self, from: data)
            self.token = decoded.token
            self.username = username
        } catch {
            self.errorMessage = "Login failed"
        }
    }
}
