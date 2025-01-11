//
//  TestSayfaViewModel.swift
//  Bazar
//
//  Created by Emre Şahin on 12.01.2025.
//

import SwiftUI
import FirebaseFirestore

class TestSayfaViewModel: ObservableObject {
    @Published var ads: [TestSayfaModel] = []

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

            let fetchedAds = documents.compactMap { doc -> TestSayfaModel? in
                let data = doc.data()
                guard let photo = data["foto"] as? [String],
                      let uid = data["uid"] as? String,
                      let title = data["title"] as? String,
                      let price = data["price"] as? Double else { return nil }

                return TestSayfaModel(id: doc.documentID, foto: photo, uid: uid, title: title, price: price)
            }

            DispatchQueue.main.async {
                self?.ads = fetchedAds.shuffled() // Rastgele sırala
            }
        }
    }
}

