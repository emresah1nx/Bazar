//
//  MoreDetailsViewModel.swift
//  Bazar
//
//  Created by Emre Şahin on 11.02.2025.
//

import SwiftUI
import FirebaseFirestore

class MoreDetailsViewModel: ObservableObject {
    @Published var moreDetails: [MoreDetail] = []  // MoreDetails verilerini tutacak
    private var db = Firestore.firestore()

    // MoreDetails'ı çek
    func fetchMoreDetails(for categoryId: String, subcategoryId: String, detailId: String, completion: @escaping () -> Void) {
        db.collection("categories")
            .document(categoryId)
            .collection("subcategories")
            .document(subcategoryId)
            .collection("details")
            .document(detailId)
            .collection("moreDetail")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching moreDetails: \(error)")
                    completion()  // Hata durumunda da completion'ı çağırıyoruz
                    return
                }

                // Eğer koleksiyon boşsa
                if snapshot?.documents.isEmpty ?? true {
                    print("No moreDetails available for this detail.")
                    self.moreDetails = [] // Boş liste döndürelim
                    completion()  // Veriyi çektikten sonra completion'ı çağırıyoruz
                    return
                }

                // Veriyi alalım
                self.moreDetails = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: MoreDetail.self)
                } ?? []

                print("Fetched moreDetails: \(self.moreDetails)")
                completion()  // Veri çekme tamamlandığında completion'ı çağırıyoruz
            }
    }
}
