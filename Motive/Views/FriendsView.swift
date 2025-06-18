//
//  FriendsView.swift
//  Motive
//
//  Created by Benjamin bai on 2025-06-09.
//

import SwiftUI

struct FriendsView: View {
    @StateObject private var vm = FriendsViewModel()
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showingSendRequest = false
    @State private var newFriendUsername = ""
    
    var body: some View {
        NavigationView {
            List {
                if !vm.incomingRequests.isEmpty {
                    Section("Friend Requests") {
                        ForEach(vm.incomingRequests) { request in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(request.fromUserUsername)
                                        .font(.headline)
                                    Text("Sent \(request.timestamp, style: .relative)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Button("Accept") {
                                    Task {
                                        await vm.acceptFriendRequest(requestId: request.id, token: authVM.token ?? "")
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    }
                }
                
                Section("Friends") {
                    if vm.friends.isEmpty {
                        Text("No friends yet")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(vm.friends) { friend in
                            HStack {
                                Text(friend.friendUsername)
                                Spacer()
                                Text("Friends since \(friend.createdAt, style: .date)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Friends")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSendRequest = true }) {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingSendRequest) {
                NavigationView {
                    Form {
                        Section {
                            TextField("Username", text: $newFriendUsername)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                    }
                    .navigationTitle("Add Friend")
                    .navigationBarItems(
                        leading: Button("Cancel") {
                            showingSendRequest = false
                        },
                        trailing: Button("Send") {
                            Task {
                                await vm.sendFriendRequest(toUsername: newFriendUsername, token: authVM.token ?? "")
                                showingSendRequest = false
                                newFriendUsername = ""
                            }
                        }
                        .disabled(newFriendUsername.isEmpty)
                    )
                }
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
                await vm.loadData(token: token)
            }
        }
    }
}

#Preview {
    FriendsView()
        .environmentObject(AuthViewModel())
}
