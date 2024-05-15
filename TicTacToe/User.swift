//
//  User.swift
//  TicTacToe
//
//  Created by Aleksandr Sirenko on 15/05/2024.
//

import Foundation

struct Game: Codable {
    let id: Int
    let player1_id: Int
    let player2_id: Int
    let player1_score: Int
    let player2_score: Int
    let result: String
}

struct User: Codable {
    let id: Int
    let username: String
    let email: String
    let wins: Int
    let losses: Int
    let draws: Int
    let games: [Game]
}


