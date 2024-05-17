//
//  NetworkService.swift
//  TicTacToe
//
//  Created by Aleksandr Sirenko on 15/05/2024.
//

import Foundation
import Alamofire

class NetworkService {
    static let shared = NetworkService()
    private init() {}
    
    let baseURL = "http://localhost:8000"
    
    func login(username: String, password: String, completion: @escaping (Result<Token, Error>) -> Void) {
        let url = "\(baseURL)/token"
        let parameters: [String: String] = [
            "username": username,
            "password": password
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default)
            .responseDecodable(of: Token.self) { response in
                switch response.result {
                case .success(let token):
                    TokenManager.shared.saveToken(token: token)
                    completion(.success(token))
                case .failure:
                    if let data = response.data {
                        let responseDataString = String(data: data, encoding: .utf8)
                        if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                            completion(.failure(NSError(domain: "", code: response.response?.statusCode ?? 400, userInfo: [NSLocalizedDescriptionKey: errorResponse.detail])))
                        } else {
                            completion(.failure(NSError(domain: "", code: response.response?.statusCode ?? 400, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
                        }
                    } else {
                        completion(.failure(NSError(domain: "", code: response.response?.statusCode ?? 400, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
                    }
                }
            }
    }
    
    func refreshAccessToken(completion: @escaping (Result<AccessToken, Error>) -> Void) {
        guard let refreshToken = TokenManager.shared.loadToken()?.refresh_token else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "No refresh token found"])))
            return
        }
        
        let url = "\(baseURL)/token/refresh"
        let parameters: [String: String] = [
            "refresh_token": refreshToken
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default)
            .responseDecodable(of: AccessToken.self) { response in
                switch response.result {
                case .success(let accessToken):
                    print("Access token refreshed: \(accessToken)") // Debug output
                    TokenManager.shared.saveAccessToken(accessToken: accessToken)
                    completion(.success(accessToken))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func getUserProfile(completion: @escaping (Result<User, Error>) -> Void) {
        guard let token = TokenManager.shared.loadToken()?.access_token else {
            completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
            return
        }
        
        let url = "\(baseURL)/users/me"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        AF.request(url, method: .get, headers: headers).responseDecodable(of: User.self) { response in
            switch response.result {
            case .success(let user):
                completion(.success(user))
            case .failure(let error):
                if response.response?.statusCode == 401 {
                    self.refreshAccessToken { result in
                        switch result {
                        case .success(let newToken):
                            let newHeaders: HTTPHeaders = [
                                "Authorization": "Bearer \(newToken.access_token)"
                            ]
                            AF.request(url, method: .get, headers: newHeaders).responseDecodable(of: User.self) { retryResponse in
                                switch retryResponse.result {
                                case .success(let user):
                                    completion(.success(user))
                                case .failure(let retryError):
                                    completion(.failure(retryError))
                                }
                            }
                        case .failure(let refreshError):
                            completion(.failure(refreshError))
                        }
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func logout(completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = TokenManager.shared.loadToken()?.access_token else {
            completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
            return
        }
        
        let url = "\(baseURL)/logout"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        AF.request(url, method: .post, headers: headers)
            .responseDecodable(of: LogoutResponse.self) { response in
                switch response.result {
                case .success(let logoutResponse):
                    TokenManager.shared.clearTokens()
                    completion(.success(logoutResponse.msg))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func register(username: String, email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        let url = "\(baseURL)/register/"
        let parameters = UserCreate(username: username, email: email, password: password)
        
        AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
            .responseDecodable(of: User.self) { response in
                switch response.result {
                case .success(let user):
                    completion(.success(user))
                case .failure:
                    if let data = response.data {
                        if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                            completion(.failure(NSError(domain: "", code: response.response?.statusCode ?? 400, userInfo: [NSLocalizedDescriptionKey: errorResponse.detail])))
                        } else {
                            completion(.failure(NSError(domain: "", code: response.response?.statusCode ?? 400, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
                        }
                    } else {
                        completion(.failure(NSError(domain: "", code: response.response?.statusCode ?? 400, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
                    }
                }
            }
    }
}

struct ErrorResponse: Codable {
    let detail: String
}

struct LogoutResponse: Codable {
    let msg: String
}

struct UserCreate: Codable {
    let username: String
    let email: String
    let password: String
}
