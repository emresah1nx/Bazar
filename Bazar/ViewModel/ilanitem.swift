//
//  ilanitem.swift
//  Bazar
//
//  Created by Emre Şahin on 10.01.2025.
//

import SwiftUI
import FirebaseFirestore

class ilanItem: ObservableObject {
    @Published var ads: [ilanlar] = []

    private var db = Firestore.firestore()

    func fetchAds() {
        db.collection("products").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Hata: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("Veri yok!")
                return
            }
            print("Dokümanlar: \(documents)")

            let fetchedAds = documents.compactMap { doc -> ilanlar? in
                let data = doc.data()
                guard let imageUrl = data["foto"] as? [String],
                      let userId = data["uid"] as? String,
                      let title = data["title"] as? String,
                      let price = data["price"] as? Double,
                      let createdAt = data["createdAt"] as? Timestamp,
                      let description = data["description"] as? String else { return nil }
                      

                return ilanlar(id: doc.documentID, imageUrl: imageUrl, userId: userId, title: title, price: price, createdAt: createdAt, description: description)
            }

            DispatchQueue.main.async {
                self?.ads = fetchedAds.shuffled() // Rastgele sırala
                print("Veriler başarıyla yüklendi: \(self?.ads ?? [])")
            }
        }
    }
}
