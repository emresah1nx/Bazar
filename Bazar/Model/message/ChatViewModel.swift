//
//  ChatViewModel.swift
//  Bazar
//
//  Created by Emre Şahin on 15.02.2025.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class ChatViewModel: ObservableObject {
    @Published var messages: [MessageModel] = []
    @Published var chats: [ChatModel] = []
    
    private let db = Firestore.firestore()
    
    func sendMessage(chatId: String, senderId: String, receiverId: String, text: String) {
        let newMessage = MessageModel(
            chatId: chatId,
            senderId: senderId,
            receiverId: receiverId,
            text: text,
            timestamp: Timestamp()
        )
        
        do {
            // Yeni mesajı Firestore'a ekle
            let _ = try db.collection("messages").document(chatId).collection("messages").addDocument(from: newMessage)
            
            // **Sohbetin son mesajını ve zamanını güncelle**
            db.collection("messages").document(chatId).setData([
                "userIds": [senderId, receiverId], // Kullanıcı UID'leri
                "lastMessage": text,
                "lastMessageTimestamp": Timestamp()
            ], merge: true) // Merge: Eski veriyi silmeden güncelle
            
        } catch {
            print("Mesaj gönderme hatası: \(error.localizedDescription)")
        }
    }
    
    func fetchMessages(chatId: String) {
        db.collection("messages").document(chatId).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Mesajları alma hatası: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                self.messages = documents.compactMap { try? $0.data(as: MessageModel.self) }
            }
    }
    
    func fetchChats(userId: String) {
        db.collection("messages")
            .whereField("userIds", arrayContains: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Konuşmaları alma hatası: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else {
                    print("Konuşma bulunamadı.")
                    return
                }
                self.chats = documents.compactMap { try? $0.data(as: ChatModel.self) }
                print("Firestore'dan çekilen sohbetler: \(self.chats)")
            }
    }
    
    func createChatIfNeeded(user1Id: String, user2Id: String, completion: @escaping (String) -> Void) {
        let chatId = [user1Id, user2Id].sorted().joined(separator: "_")
        
        db.collection("messages").document(chatId).getDocument { document, error in
            if let document = document, document.exists {
                completion(chatId)
            } else {
                let newChat = ChatModel(userIds: [user1Id, user2Id], lastMessage: "", lastMessageTimestamp: Timestamp())
                
                do {
                    try self.db.collection("messages").document(chatId).setData(from: newChat)
                    completion(chatId)
                } catch {
                    print("Konuşma oluşturma hatası: \(error.localizedDescription)")
                }
            }
        }
    }
}
