//
//  MainAppView.swift
//  Motive
//
//  Created by Benjamin bai on 2025-06-08.
//

import SwiftUI

struct MainAppView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            FriendsView()
                .tabItem {
                    Label("Friends", systemImage: "person.2.fill")
                }
                .tag(1)
        }
        .tint(.blue) // This sets the accent color for the tab bar
    }
}

#Preview {
    MainAppView()
        .environmentObject(AuthViewModel())
}
