//
//  MainAppView.swift
//  Motive
//
//  Created by Benjamin bai on 2025-06-08.
//

import SwiftUI

struct MainAppView: View {
    var body: some View {
        
        TabView {
            
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            FriendsView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Friends")
                }
            
        }
    }
}

#Preview {
    MainAppView()
}
