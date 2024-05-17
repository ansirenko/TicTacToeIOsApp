//
//  Token.swift
//  TicTacToe
//
//  Created by Aleksandr Sirenko on 15/05/2024.
//

import Foundation

struct Token: Codable {
    var access_token: String
    let refresh_token: String?
    let token_type: String
}

struct AccessToken: Codable {
    let access_token: String
    let token_type: String
}


class TokenManager {
    static let shared = TokenManager()
    private init() {}

    func saveToken(token: Token) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(token) {
            UserDefaults.standard.set(encoded, forKey: "authToken")
        }
    }

    func saveAccessToken(accessToken: AccessToken) {
        var token = loadToken()
        token?.access_token = accessToken.access_token
        if let token = token {
            saveToken(token: token)
        }
    }

    func loadToken() -> Token? {
        if let savedTokenData = UserDefaults.standard.data(forKey: "authToken") {
            let decoder = JSONDecoder()
            if let loadedToken = try? decoder.decode(Token.self, from: savedTokenData) {
                return loadedToken
            }
        }
        return nil
    }

    func clearTokens() {
        UserDefaults.standard.removeObject(forKey: "authToken")
    }
}
