//
//  ContentView.swift
//  TicTacToe
//
//  Created by Aleksandr Sirenko on 15/05/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var token: Token?
    @State private var loginError: String?
    @State private var isLoggedIn = false
    @State private var showRegisterView = false
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            if isLoggedIn {
                UserProfileView()
            } else {
                VStack {
                    Text("Login")
                        .font(.largeTitle)
                        .padding()
                    
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .padding(.horizontal, 24)
                    
                    SecureField("Password", text: $password)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                    
                    Button(action: {
                        NetworkService.shared.login(username: username, password: password) { result in
                            switch result {
                            case .success(let token):
                                self.token = token
                                self.isLoggedIn = true
                                saveToken(token: token)
                            case .failure(let error):
                                self.loginError = error.localizedDescription
                                self.showAlert = true
                            }
                        }
                    }) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 24)
                    
                    HStack {
                        NavigationLink(destination: RegisterView()) {
                            Text("Register")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        NavigationLink(destination: ForgotPasswordView()) {
                            Text("Forgot Password?")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 24)
                }
            }
        }
        .onAppear {
            if let savedToken = loadToken() {
                self.token = savedToken
                NetworkService.shared.getUserProfile { result in
                    switch result {
                    case .success:
                        self.isLoggedIn = true
                    case .failure:
                        self.isLoggedIn = false
                    }
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Login Error"),
                message: Text(loginError ?? "Unknown error"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
