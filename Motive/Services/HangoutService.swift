import Foundation

class HangoutService {
    static let shared = HangoutService()
    private let baseURL = "http://127.0.0.1:8000/api"
    private init() {}
    
    func fetchHangoutEvents(token: String) async throws -> [HangoutEvent] {
        NSLog("🔄 MOTIVE: HangoutService.fetchHangoutEvents called")
        guard let url = URL(string: "\(baseURL)/hangouts/") else {
            NSLog("❌ MOTIVE: Invalid URL")
            throw URLError(.badURL)
        }
        
        NSLog("🔄 MOTIVE: URL: \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        NSLog("🔄 MOTIVE: About to make network request")
        let (data, response) = try await URLSession.shared.data(for: request)
        NSLog("🔄 MOTIVE: Network request completed")
        
        // Debug: Print the response
        if let httpResponse = response as? HTTPURLResponse {
            NSLog("🔄 MOTIVE: Response status: \(httpResponse.statusCode)")
        }
        
        // Debug: Print the response data
        if let responseString = String(data: data, encoding: .utf8) {
            NSLog("🔄 MOTIVE: Response data: \(responseString)")
        }
        
        NSLog("🔄 MOTIVE: About to decode JSON")
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
            let events = try decoder.decode([HangoutEvent].self, from: data)
            NSLog("✅ MOTIVE: Successfully decoded \(events.count) events")
            return events
        } catch {
            NSLog("❌ MOTIVE: JSON Decoding Error: \(error)")
            NSLog("❌ MOTIVE: Error details: \(error.localizedDescription)")
            throw error
        }
    }
    
    func createHangoutEvent(title: String, description: String, attendeeCount: Int, dateTime: Date, token: String) async throws -> HangoutEvent {
        guard let url = URL(string: "\(baseURL)/hangouts/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dateFormatter = ISO8601DateFormatter()
        let body = [
            "title": title,
            "description": description,
            "attendee_count": attendeeCount,
            "date_time": dateFormatter.string(from: dateTime)
        ] as [String : Any]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Debug: Print the response
        if let httpResponse = response as? HTTPURLResponse {
            print("POST Response status: \(httpResponse.statusCode)")
        }
        
        // Debug: Print the response data
        if let responseString = String(data: data, encoding: .utf8) {
            print("POST Response data: \(responseString)")
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
            return try decoder.decode(HangoutEvent.self, from: data)
        } catch {
            print("JSON Decoding Error: \(error)")
            print("Error details: \(error.localizedDescription)")
            throw error
        }
    }
    
    func deleteHangoutEvent(eventId: Int, token: String) async throws {
        NSLog("🔄 MOTIVE: deleteHangoutEvent called with ID: \(eventId)")
        guard let url = URL(string: "\(baseURL)/hangouts/\(eventId)/delete/") else {
            NSLog("❌ MOTIVE: Invalid delete URL")
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        NSLog("🔄 MOTIVE: About to delete hangout event")
        let (data, response) = try await URLSession.shared.data(for: request)
        NSLog("🔄 MOTIVE: Delete request completed")
        
        if let httpResponse = response as? HTTPURLResponse {
            NSLog("🔄 MOTIVE: Delete response status: \(httpResponse.statusCode)")
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
            NSLog("🔄 MOTIVE: Delete response data: \(responseString)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            NSLog("❌ MOTIVE: Delete failed with status: \(response)")
            throw URLError(.badServerResponse)
        }
        
        NSLog("✅ MOTIVE: Successfully deleted hangout event")
    }
} 