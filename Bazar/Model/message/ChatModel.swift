//
//  ChatModel.swift
//  Bazar
//
//  Created by Emre Şahin on 15.02.2025.
//

import Foundation
import FirebaseFirestore

struct ChatModel: Identifiable, Codable {
    @DocumentID var id: String?
    let userIds: [String] // Konuşmadaki iki kullanıcının UID'leri
    let lastMessage: String
    let lastMessageTimestamp: Timestamp
    
    enum CodingKeys: String, CodingKey {
        case id
        case userIds
        case lastMessage
        case lastMessageTimestamp
    }
    // Kullanıcının karşı tarafın UID’sini bulmasını sağlar
    func otherUserId(currentUserId: String) -> String {
        return userIds.first { $0 != currentUserId } ?? "Bilinmeyen Kullanıcı"
    }
}
