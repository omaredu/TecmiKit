//
//  ChatResponse.swift
//  TecmiKit
//
//  Created by Omar Sánchez on 18/06/25.
//

import Foundation

struct ChatResponse: Codable {
    let status: String
    let chatId: UUID
    let answer: String

    enum CodingKeys: String, CodingKey {
        case status
        case chatId = "chat_id"
        case answer
    }
}
