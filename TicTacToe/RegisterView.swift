//
//  RegisterView.swift
//  TicTacToe
//
//  Created by Aleksandr Sirenko on 15/05/2024.
//

import SwiftUI

struct RegisterView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var registrationError: String?
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToLogin = false
    @State private var showAlert = false
    @State private var invalidEmail = false
    @State private var passwordsMismatch = false
    
    var body: some View {
        VStack {
            Text("Register")
                .font(.largeTitle)
                .padding()
            
            TextField("Username", text: $username)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal, 24)
                .autocapitalization(.none)
                .textContentType(.username)
            
            TextField("Email", text: $email)
                .padding()
                .background(invalidEmail ? Color.red.opacity(0.3) : Color(.secondarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .autocapitalization(.none)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .onChange(of: email) { _, newEmail in
                    invalidEmail = false
                    registrationError = nil
                }
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .autocapitalization(.none)
                .textContentType(.newPassword)
                .onChange(of: password) { _, newPassword in
                    passwordsMismatch = false
                    registrationError = nil
                }
            
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(passwordsMismatch ? Color.red.opacity(0.3) : Color(.secondarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .autocapitalization(.none)
                .textContentType(.newPassword)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(passwordsMismatch ? Color.red : Color.clear, lineWidth: 2)
                )
                .onChange(of: confirmPassword) { _, newConfirmPassword in
                    passwordsMismatch = false
                    registrationError = nil
                }
            
            Button(action: {
                // Reset error states
                invalidEmail = false
                passwordsMismatch = false
                
                // Validate email
                if !isValidEmail(email) {
                    registrationError = "Invalid email format"
                    invalidEmail = true
                    showAlert = true
                    return
                }
                
                // Check if passwords match
                if password != confirmPassword {
                    registrationError = "Passwords do not match"
                    passwordsMismatch = true
                    showAlert = true
                    return
                }
                
                NetworkService.shared.register(username: username, email: email, password: password) { result in
                    switch result {
                    case .success(let user):
                        print("Registration successful: \(user.username)")
                        self.navigateToLogin = true
                    case .failure(let error):
                        self.registrationError = error.localizedDescription
                        showAlert = true
                        print("Registration failed: \(error.localizedDescription)")
                    }
                }
            }) {
                Text("Register")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 24)
            
            if let registrationError = registrationError {
                Text("Error: \(registrationError)")
                    .foregroundColor(.red)
                    .padding(.top, 16)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Registration Error"),
                message: Text(registrationError ?? "Unknown error"),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationTitle("Register")
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
            Text("Back")
        })
        .navigationDestination(isPresented: $navigateToLogin) {
            ContentView()
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "(?:[a-zA-Z0-9!#$%\\&'*+/=?^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
