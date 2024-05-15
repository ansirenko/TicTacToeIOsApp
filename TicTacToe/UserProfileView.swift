//
//  UserProfileView.swift
//  TicTacToe
//
//  Created by Aleksandr Sirenko on 15/05/2024.
//

import SwiftUI

struct UserProfileView: View {
    @State private var user: User?
    @State private var loadingError: String?
    @State private var opponentUsername: String = ""
    
    var body: some View {
        VStack {
            if let user = user {
                Text("Hello, \(user.username)!")
                    .font(.largeTitle)
                    .padding()
                
                VStack(alignment: .leading) {
                    Text("Game Stats:")
                        .font(.title2)
                        .padding(.top)
                    
                    Text("Wins: \(user.wins)")
                    Text("Losses: \(user.losses)")
                    Text("Draws: \(user.draws)")
                }
                .padding()
                
                Button(action: {
                    // Implement start game action
                }) {
                    Text("Start Game")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 24)
                
                VStack(alignment: .leading) {
                    Text("Play with Opponent:")
                        .font(.headline)
                        .padding(.top)
                    
                    TextField("Opponent's Username", text: $opponentUsername)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .padding(.horizontal, 24)
                    
                    Button(action: {
                        // Implement play with opponent action
                    }) {
                        Text("Play")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 24)
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    logout()
                }) {
                    Text("Logout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200, height: 50)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.bottom, 24)
            } else if let loadingError = loadingError {
                Text("Error: \(loadingError)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                ProgressView("Loading...")
                    .padding()
            }
        }
        .onAppear {
            NetworkService.shared.getUserProfile { result in
                switch result {
                case .success(let user):
                    self.user = user
                case .failure(let error):
                    self.loadingError = error.localizedDescription
                }
            }
        }
    }
    
    func logout() {
        NetworkService.shared.logout { result in
            switch result {
            case .success:
                UserDefaults.standard.removeObject(forKey: "authToken")
                user = nil
                loadingError = nil
                opponentUsername = ""
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    if let window = windowScene.windows.first {
                        window.rootViewController = UIHostingController(rootView: ContentView())
                        window.makeKeyAndVisible()
                    }
                }
            case .failure(let error):
                self.loadingError = error.localizedDescription
            }
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
