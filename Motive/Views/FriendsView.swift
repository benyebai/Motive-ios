//
//  FriendsView.swift
//  Motive
//
//  Created by Benjamin bai on 2025-06-09.
//

import SwiftUI

struct FriendsView: View {
    @StateObject private var vm = FriendsViewModel()
    @State private var showingSendRequest = false

    var body: some View {
        NavigationView {
            List {
                // Incoming requests & friends UI here (like before)
            }
            .navigationTitle("Friends")
        }
    }
}

#Preview {
    FriendsView()
}
