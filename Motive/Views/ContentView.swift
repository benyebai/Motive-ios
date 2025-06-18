//
//  ContentView.swift
//  Motive
//
//  Created by Benjamin bai on 2025-06-08.
//

import SwiftUI


struct ContentView: View {
    @StateObject private var authVM = AuthViewModel()

    var body: some View {
        Group {
            if authVM.token != nil {
                MainAppView()
            } else {
                LoginView()
            }
        }
        .environmentObject(authVM) // Pass the shared instance down
    }
}

#Preview {
    ContentView()
}
