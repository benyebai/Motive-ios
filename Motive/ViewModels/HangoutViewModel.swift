import Foundation
import Combine

@MainActor
class HangoutViewModel: ObservableObject {
    @Published var hangoutEvents: [HangoutEvent] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    func loadHangoutEvents(token: String) async {
        NSLog("🔄 MOTIVE: Starting to load hangout events...")
        NSLog("🔄 MOTIVE: Token: \(token.prefix(20))...")
        isLoading = true
        do {
            NSLog("🔄 MOTIVE: About to call HangoutService.fetchHangoutEvents")
            let events = try await HangoutService.shared.fetchHangoutEvents(token: token)
            NSLog("🔄 MOTIVE: Successfully got events from service, count: \(events.count)")
            self.hangoutEvents = events
            self.errorMessage = nil
            NSLog("✅ MOTIVE: Successfully loaded \(events.count) hangout events")
        } catch {
            NSLog("❌ MOTIVE: Error loading hangout events: \(error)")
            NSLog("❌ MOTIVE: Error type: \(type(of: error))")
            NSLog("❌ MOTIVE: Error description: \(error.localizedDescription)")
            self.errorMessage = "Failed to load hangout events"
        }
        NSLog("🔄 MOTIVE: Setting isLoading to false")
        isLoading = false
    }
    
    func createHangoutEvent(title: String, description: String, attendeeCount: Int, dateTime: Date, token: String) async {
        isLoading = true
        do {
            let newEvent = try await HangoutService.shared.createHangoutEvent(
                title: title,
                description: description,
                attendeeCount: attendeeCount,
                dateTime: dateTime,
                token: token
            )
            self.hangoutEvents.insert(newEvent, at: 0)
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Failed to create hangout event"
            print("Error creating hangout event:", error)
        }
        isLoading = false
    }
    
    func deleteHangoutEvent(eventId: Int, token: String) async {
        NSLog("🔄 MOTIVE: HangoutViewModel.deleteHangoutEvent called")
        isLoading = true
        do {
            try await HangoutService.shared.deleteHangoutEvent(eventId: eventId, token: token)
            // Remove the event from the local array
            self.hangoutEvents.removeAll { $0.id == eventId }
            self.errorMessage = nil
            NSLog("✅ MOTIVE: Successfully deleted hangout event from view model")
        } catch {
            self.errorMessage = "Failed to delete hangout event"
            NSLog("❌ MOTIVE: Error deleting hangout event: \(error)")
        }
        isLoading = false
    }
} 