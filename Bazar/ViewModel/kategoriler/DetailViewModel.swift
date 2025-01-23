//
//  DetailViewModel.swift
//  Bazar
//
//  Created by Emre Şahin on 23.01.2025.
//

import SwiftUI
import FirebaseFirestore

class DetailViewModel: ObservableObject {
    @Published var details: [Detail] = []  // Detayları tutacak
    private var db = Firestore.firestore()

    // Detayları çek
    func fetchDetails(for categoryId: String, subcategoryId: String, completion: @escaping () -> Void) {
        db.collection("categories")
            .document(categoryId)
            .collection("subcategories")
            .document(subcategoryId)
            .collection("details")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching details: \(error)")
                    completion()  // Hata durumunda da completion'ı çağırıyoruz
                    return
                }

                // Eğer koleksiyon boşsa
                if snapshot?.documents.isEmpty ?? true {
                    print("No details available for this subcategory.")
                    self.details = [] // Boş liste döndürelim
                    completion()  // Veriyi çektikten sonra completion'ı çağırıyoruz
                    return
                }

                // Veriyi alalım
                self.details = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Detail.self)
                } ?? []

                print("Fetched details: \(self.details)")
                completion()  // Veri çekme tamamlandığında completion'ı çağırıyoruz
            }
    }
}


