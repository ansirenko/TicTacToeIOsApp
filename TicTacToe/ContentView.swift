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
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .padding(.horizontal, 24)
                    
                    SecureField("Password", text: $password)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
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
                                print("Login successful: \(token.access_token)")
                            case .failure(let error):
                                self.loginError = error.localizedDescription
                                print("Login failed: \(error.localizedDescription)")
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
                    
                    if let loginError = loginError {
                        Text("Error: \(loginError)")
                            .foregroundColor(.red)
                            .padding(.top, 16)
                    }
                    
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
            // Проверяем, есть ли сохраненный токен
            if let savedToken = loadToken() {
                // Временный способ проверки токена
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
