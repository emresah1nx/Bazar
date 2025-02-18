import SwiftUI
import FirebaseFirestore

class ilanItem: ObservableObject {
    @Published var ads: [ilanlar] = []           // Tüm ilanlar
    @Published var filteredAds: [ilanlar] = []  // Filtrelenmiş ilanlar
    @Published var categories: [String: String] = [:] // Alt kategori isimleri

    var db = Firestore.firestore()

    // 🔹 **Tüm İlanları Firestore’dan Çekme**
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

            let fetchedAds = documents.compactMap { doc -> ilanlar? in
                let data = doc.data()
                guard let imageUrl = data["foto"] as? [String],
                      let userId = data["uid"] as? String,
                      let title = data["title"] as? String,
                      let price = data["price"] as? Double,
                      let createdAt = data["createdAt"] as? Timestamp,
                      let altcategory = data["altcategory"] as? String,
                      let tempCategory = data["tempCategory"] as? String,
                      let marka = data["marka"] as? String,
                      let model = data["model"] as? String,
                      let description = data["description"] as? String else { return nil }

                return ilanlar(id: doc.documentID, imageUrl: imageUrl, userId: userId, title: title, price: price, createdAt: createdAt, description: description, altcategory: altcategory,tempCategory: tempCategory,marka: marka,model: model)
            }

            DispatchQueue.main.async {
                self?.ads = fetchedAds.shuffled()  // Rastgele sırala
                self?.filteredAds = fetchedAds  // Varsayılan olarak tüm ilanları göster
                self?.fetchCategoryNames()       // Kategori isimlerini çek
                print("Veriler başarıyla yüklendi: \(self?.ads.count ?? 0) ilan.")
            }
        }
    }

    // 🔹 **Kategoriye Göre İlanları Firestore’dan Çekme**
    func fetchAdsByCategory(categoryId: String?, subCategoryId: String?, detailCategoryId: String?) {
        var query: Query = db.collection("products")
        
        if let categoryId = categoryId {
            query = query.whereField("tempCategory", isEqualTo: categoryId)
        }
        if let subCategoryId = subCategoryId {
            query = query.whereField("altcategory", isEqualTo: subCategoryId)
        }
        if let detailCategoryId = detailCategoryId {
            query = query.whereField("marka", isEqualTo: detailCategoryId)
        }
        
        query.getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("İlanları çekerken hata: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("Bu kategoriye ait ilan bulunamadı!")
                return
            }
            
            let fetchedAds = documents.compactMap { doc -> ilanlar? in
                let data = doc.data()
                guard let imageUrl = data["foto"] as? [String],
                      let userId = data["uid"] as? String,
                      let title = data["title"] as? String,
                      let price = data["price"] as? Double,
                      let createdAt = data["createdAt"] as? Timestamp,
                      let altcategory = data["altcategory"] as? String,
                      let tempCategory = data["tempCategory"] as? String,
                      let marka = data["marka"] as? String,
                      let model = data["model"] as? String,
                      let description = data["description"] as? String else { return nil }
                
                return ilanlar(id: doc.documentID, imageUrl: imageUrl, userId: userId, title: title, price: price, createdAt: createdAt, description: description, altcategory: altcategory,tempCategory: tempCategory,marka: marka,model: model)
            }
            
            DispatchQueue.main.async {
                self?.filteredAds = fetchedAds
                print("Kategoriye göre ilanlar çekildi: \(self?.filteredAds.count ?? 0) ilan bulundu.")
            }
        }
    }

    // 🔹 **Alt Kategori Adlarını Firestore’dan Çekme**
    func fetchCategoryNames() {
        var categoryIds: Set<String> = [] // Benzersiz kategori ID'leri

        // Tüm ilanlarda alt kategori ID'lerini topla
        for ad in ads {
            categoryIds.insert(ad.altcategory)
        }

        // Firestore’dan kategori adlarını çek
        for categoryId in categoryIds {
            if categories[categoryId] == nil {  // Eğer bu kategori adı zaten çekilmediyse
                db.collection("categories").document(categoryId).collection("subcategories").getDocuments { [weak self] snapshot, error in
                    if let error = error {
                        print("Hata: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    for document in documents {
                        if let name = document.data()["name"] as? String {
                            DispatchQueue.main.async {
                                self?.categories[categoryId] = name
                            }
                        }
                    }
                }
            }
        }
    }

    // 🔹 **İlan Arama Fonksiyonu**
    func searchAds(query: String) {
        if query.isEmpty {
            self.filteredAds = ads
        } else {
            self.filteredAds = ads.filter { $0.title.lowercased().contains(query.lowercased()) }
        }
    }
}
