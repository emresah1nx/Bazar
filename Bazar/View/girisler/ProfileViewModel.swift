//
//  ProfileViewModel.swift
//  Bazar
//
//  Created by Emre Şahin on 30.01.2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class ProfileViewModel: ObservableObject {
    @Published var userProducts: [Product] = [] // Kullanıcıya ait ilanları tutacak
    
    func fetchUserProducts() {
        guard let userId = Auth.auth().currentUser?.uid else { return } // Kullanıcı giriş yapmış mı kontrol et
        
        let db = Firestore.firestore()
        db.collection("products")
            .whereField("uid", isEqualTo: userId) // Kullanıcının UID’sine göre filtreleme
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Hata: \(error.localizedDescription)")
                    return
                }
                
                DispatchQueue.main.async {
                    self.userProducts = snapshot?.documents.compactMap { doc in
                        let data = doc.data()
                        return Product(
                            id: doc.documentID,
                            title: data["title"] as? String ?? "Bilinmeyen",
                            description: data["description"] as? String ?? "",
                            price: data["price"] as? Double ?? 0,
                            imageUrls: data["foto"] as? [String] ?? [], // Array olarak al
                            uid: data["uid"] as? String ?? ""
                        )
                    } ?? []
                }
            }
    }
}
