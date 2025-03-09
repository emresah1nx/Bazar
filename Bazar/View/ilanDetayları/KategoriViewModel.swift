//
//  KategoriViewModel.swift
//  Bazar
//
//  Created by Emre Şahin on 24.01.2025.
//


import SwiftUI
import FirebaseFirestore

class KategoriViewModel: ObservableObject {
    @Published var categories: [Kategori] = [] // Kategoriler listesi
    @Published var subcategories: [SubKategori] = [] // Alt kategoriler listesi
    @Published var details: [Detailss] = [] // Detail listesi
    @Published var moreDetails: [MoreDetailss] = []

    private var db = Firestore.firestore()

    func fetchCategories() {
        db.collection("categories").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Kategoriler alınırken hata: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("Kategoriler bulunamadı.")
                return
            }

            let fetchedCategories = documents.compactMap { doc -> Kategori? in
                let data = doc.data()
                guard let name = data["name"] as? String else { return nil }
                return Kategori(id: doc.documentID, name: name)
            }

            DispatchQueue.main.async {
                self?.categories = fetchedCategories
            }
        }
    }

    func fetchSubcategories(forCategoryId categoryId: String) {
        db.collection("categories").document(categoryId).collection("subcategories").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Alt kategoriler alınırken hata: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("Alt kategoriler bulunamadı.")
                return
            }

            let fetchedSubcategories = documents.compactMap { doc -> SubKategori? in
                let data = doc.data()
                guard let name = data["name"] as? String else { return nil }
                return SubKategori(id: doc.documentID, name: name)
            }

            DispatchQueue.main.async {
                self?.subcategories = fetchedSubcategories
            }
        }
    }

    func fetchDetails(forCategoryId categoryId: String, subcategoryId: String) {
        db.collection("categories")
            .document(categoryId)
            .collection("subcategories")
            .document(subcategoryId)
            .collection("details")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Details verisi alınırken hata: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("Details verisi bulunamadı.")
                    return
                }

                let fetchedDetails = documents.compactMap { doc -> Detailss? in
                    let data = doc.data()
                    guard let name = data["name"] as? String else { return nil }
                    return Detailss(id: doc.documentID, name: name)
                }

                DispatchQueue.main.async {
                    self?.details = fetchedDetails
                }
            }
    }
    
    func fetchMoreDetails(forCategoryId categoryId: String, subcategoryId: String, detailsId:String) {
        print("Fetching MoreDetails for Category: \(categoryId), Subcategory: \(subcategoryId), Detail: \(detailsId)")

        db.collection("categories")
            .document(categoryId)
            .collection("subcategories")
            .document(subcategoryId)
            .collection("details")
            .document(detailsId)
            .collection("moreDetail")
            .getDocuments { [weak self] snapshot, error in
                
                if let error = error {
                    print("MoreDetails verisi alınırken hata: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("MoreDetails verisi bulunamadı. (Snapshot boş)")
                    return
                }

                print("Found \(documents.count) MoreDetails documents.")
                
                let fetchedMoreDetails = documents.compactMap { doc -> MoreDetailss? in
                    let data = doc.data()
                    print("Document Data: \(data)")  // Firestore'dan gelen ham veriyi görmek için
                    
                    guard let name = data["name"] as? String else {
                        print("Document \(doc.documentID) 'name' alanı eksik!")
                        return nil
                    }
                    
                    return MoreDetailss(id: doc.documentID, name: name)
                }

                DispatchQueue.main.async {
                    print("Fetched MoreDetails: \(fetchedMoreDetails)")
                    self?.moreDetails = fetchedMoreDetails
                }
            }
    }
    
    
}
