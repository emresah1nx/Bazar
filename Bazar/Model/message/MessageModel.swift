//
//  MessageModel.swift
//  Bazar
//
//  Created by Emre Şahin on 15.02.2025.
//

import Foundation
import FirebaseFirestore

struct MessageModel: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    let chatId: String
    let senderId: String
    let receiverId: String
    let text: String
    let timestamp: Timestamp
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatId
        case senderId
        case receiverId
        case text
        case timestamp
    }
}
