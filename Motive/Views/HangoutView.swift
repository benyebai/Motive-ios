import SwiftUI

struct HangoutView: View {
    @StateObject private var vm = HangoutViewModel()
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showingCreateEvent = false
    
    var body: some View {
        NavigationView {
            List {
                if vm.hangoutEvents.isEmpty {
                    Text("No hangout events yet")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(vm.hangoutEvents) { event in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(event.title)
                                    .font(.headline)
                                Spacer()
                                Text("\(event.attendeeCount) people")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            
                            Text(event.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text(event.dateTime, style: .date)
                                    .font(.caption)
                                Text(event.dateTime, style: .time)
                                    .font(.caption)
                                Spacer()
                                Text("by \(event.createdBy)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            // Show delete button only for events created by current user
                            if event.createdBy == authVM.username {
                                HStack {
                                    Spacer()
                                    Button("Delete") {
                                        Task {
                                            await vm.deleteHangoutEvent(eventId: event.id ?? 0, token: authVM.token ?? "")
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.red)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { indexSet in
                        // Handle swipe-to-delete
                        for index in indexSet {
                            let event = vm.hangoutEvents[index]
                            if event.createdBy == authVM.username {
                                Task {
                                    await vm.deleteHangoutEvent(eventId: event.id ?? 0, token: authVM.token ?? "")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Hangouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateEvent = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateEvent) {
                CreateHangoutView(vm: vm, authVM: authVM)
            }
            .overlay {
                if vm.isLoading {
                    ProgressView()
                }
            }
            .alert("Error", isPresented: .constant(vm.errorMessage != nil)) {
                Button("OK") {
                    vm.errorMessage = nil
                }
            } message: {
                if let error = vm.errorMessage {
                    Text(error)
                }
            }
        }
        .task {
            if let token = authVM.token {
                await vm.loadHangoutEvents(token: token)
            }
        }
    }
}

struct CreateHangoutView: View {
    @ObservedObject var vm: HangoutViewModel
    @ObservedObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var attendeeCount = 2
    @State private var dateTime = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Event Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Event Info") {
                    Stepper("Attendees: \(attendeeCount)", value: $attendeeCount, in: 1...50)
                    DatePicker("Date & Time", selection: $dateTime, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("Create Hangout")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Create") {
                    Task {
                        await vm.createHangoutEvent(
                            title: title,
                            description: description,
                            attendeeCount: attendeeCount,
                            dateTime: dateTime,
                            token: authVM.token ?? ""
                        )
                        dismiss()
                    }
                }
                .disabled(title.isEmpty || description.isEmpty)
            )
        }
    }
}

#Preview {
    HangoutView()
        .environmentObject(AuthViewModel())
} 