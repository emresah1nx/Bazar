//
//  UserViewModel.swift
//  Bazar
//
//  Created by Emre Şahin on 16.02.2025.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class UserViewModel: ObservableObject {
    @Published var userInfo: [String: (String, String?)] = [:] // userID -> (username, profilePhoto)

    private let db = Firestore.firestore()

    func fetchUserDetails(for userIds: [String]) {
        let uniqueUserIds = Set(userIds) // 🔥 Aynı kullanıcıları tekrar çekmeyi önler

        for userId in uniqueUserIds {
            if userInfo[userId] == nil { // 🔥 Eğer daha önce yüklenmemişse çek
                db.collection("users").document(userId).getDocument { document, error in
                    if let document = document, document.exists {
                        let username = document.get("username") as? String ?? "Bilinmeyen Kullanıcı"
                        let profilePhoto = document.get("profilePhoto") as? String
                        DispatchQueue.main.async {
                            self.userInfo[userId] = (username, profilePhoto)
                        }
                    }
                }
            }
        }
    }
}
