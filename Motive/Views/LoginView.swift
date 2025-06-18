//
//  LoginView.swift
//  Motive
//
//  Created by Benjamin bai on 2025-06-08.
//

import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @EnvironmentObject var authVM: AuthViewModel // <- use shared VM
    
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Login").font(.largeTitle)

            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            Button("Log In") {
                isLoading = true
                Task {
                    await authVM.login(username: username, password: password)
                    isLoading = false
                }
            }
            
            if isLoading {
                ProgressView() // built in spinner
            }

//          if let token = authVM.token {
//              Text("Logged in!").foregroundColor(.green)
//          }
//          you were correct this wont actually do jackshit

            if let error = authVM.errorMessage {
                Text(error).foregroundColor(.red)
            }
        }
        .padding()
    }
}
