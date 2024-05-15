//
//  ForgotPasswordView.swift
//  TicTacToe
//
//  Created by Aleksandr Sirenko on 15/05/2024.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var username: String = ""
    
    var body: some View {
        VStack {
            Text("Forgot Password")
                .font(.largeTitle)
                .padding()
            
            TextField("Username", text: $username)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal, 24)
            
            Button(action: {
                // Implement password recovery action
            }) {
                Text("Recover Password")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 24)
        }
        .navigationBarTitle("Forgot Password", displayMode: .inline)
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}

