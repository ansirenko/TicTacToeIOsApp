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
    
    let baseURL = "http://your-backend-url"

    func getGameStatus(completion: @escaping (Result<String, Error>) -> Void) {
        let url = "\(baseURL)/game/status"
        AF.request(url).responseString { response in
            switch response.result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
