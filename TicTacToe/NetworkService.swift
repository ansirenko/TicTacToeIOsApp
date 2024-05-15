//
//  NetworkService.swift
//  TicTacToe
//
//  Created by Aleksandr Sirenko on 15/05/2024.
//

import Foundation
import Alamofire

struct LogoutResponse: Codable {
    let msg: String
}

struct ErrorResponse: Codable {
    let detail: String
}

struct UserCreate: Codable {
    let username: String
    let email: String
    let password: String
}

class NetworkService {
    static let shared = NetworkService()
    private init() {}
    
    let baseURL = "http://localhost:8000"
    
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
                    completion(.success(token))
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
    
    func logout(completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = loadToken()?.access_token else {
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
                    completion(.success(logoutResponse.msg))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func getUserProfile(completion: @escaping (Result<User, Error>) -> Void) {
        guard let token = loadToken()?.access_token else {
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
                completion(.failure(error))
            }
        }
    }
}

func saveToken(token: Token) {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(token) {
        UserDefaults.standard.set(encoded, forKey: "authToken")
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
