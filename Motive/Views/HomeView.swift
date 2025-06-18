//
//  HomeView.swift
//  Motive
//
//  Created by Benjamin bai on 2025-06-09.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Text("Hello, world!")
                .font(.title)
                .foregroundColor(.blue)

            Text("This is a VStack example.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

#Preview {
    HomeView()
}
