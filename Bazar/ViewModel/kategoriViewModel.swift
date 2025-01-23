//
//  kategoriViewModel.swift
//  Bazar
//
//  Created by Emre Şahin on 20.01.2025.
//

import SwiftUI
import FirebaseFirestore

class kategoriViewModel: ObservableObject {
    @Published var categories: [kategori] = [] // Ana kategoriler
    @Published var subcategories: [Subcategory] = [] // Alt kategoriler

    private var db = Firestore.firestore()

    // Ana kategorileri çek
    func fetchCategories() {
        db.collection("categories").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching categories: \(error)")
                return
            }
            self.categories = snapshot?.documents.compactMap { doc in
                try? doc.data(as: kategori.self)
            } ?? []
        }
    }

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
}
