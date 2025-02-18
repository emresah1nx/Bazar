//
//  SubcategoryViewModel.swift
//  Bazar
//
//  Created by Emre Şahin on 23.01.2025.
//

import SwiftUI
import FirebaseFirestore

class SubcategoryViewModel: ObservableObject {
    @Published var subcategories: [Subcategory] = []
    @Published var allListings: [ilanlar] = [] // Seçili kategoriye ait tüm ilanlar
    @Published var showAllListings: Bool = false // İlanları mı göstereceğiz?
    
    private var db = Firestore.firestore()
    
    // Alt kategorileri çek
    func fetchSubcategories(for categoryId: String) {
        db.collection("categories")
            .document(categoryId)
            .collection("subcategories")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching subcategories: \(error)")
                    return
                }
                self.subcategories = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Subcategory.self)
                } ?? []
            }
    }
    
    // Firebase'den ilgili kategoriye ait tüm ilanları çek
    func fetchAllListings(for categoryId: String) {
        db.collection("products")
            .whereField("altcategory", isEqualTo: categoryId) // Seçili kategoriye göre filtreleme
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching listings: \(error)")
                    return
                }
                self.allListings = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: ilanlar.self)
                } ?? []
                
                self.showAllListings = true // Listeleme moduna geç
            }
    }
}
