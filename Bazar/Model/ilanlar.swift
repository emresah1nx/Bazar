import Foundation
import FirebaseFirestore

struct ilanlar: Identifiable, Codable, Hashable {
    var id: String
    var imageUrl: [String]
    var userId: String
    var title: String
    var price: Double
    var createdAt: Date?
    var description: String
    var altcategory: String
    var tempCategory: String
    var marka: String // Firestore ID
    var model: String // Firestore ID
    var markaName: String? // Firestore'dan çekilecek isim
    var modelName: String? // Firestore'dan çekilecek isim

    enum CodingKeys: String, CodingKey {
        case id, imageUrl, userId, title, price, createdAt, description, altcategory, tempCategory, marka, model
    }

    init(id: String, imageUrl: [String], userId: String, title: String, price: Double, createdAt: Any?, description: String, altcategory: String, tempCategory: String, marka: String, model: String) {
        self.id = id
        self.imageUrl = imageUrl
        self.userId = userId
        self.title = title
        self.price = price

        if let timestamp = createdAt as? Timestamp {
            self.createdAt = timestamp.dateValue()
        } else {
            self.createdAt = nil
        }

        self.description = description
        self.altcategory = altcategory
        self.tempCategory = tempCategory
        self.marka = marka
        self.model = model

    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ilanlar, rhs: ilanlar) -> Bool {
        return lhs.id == rhs.id
    }

    // Firestore'dan Marka İsmini Çekme
    func fetchMarkaName(completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        db.collection("categories")
            .document(tempCategory) // Kategori ID
            .collection("subcategories")
            .document(altcategory) // Marka ID
            .collection("details")
            .document(marka) // Marka ID
            .getDocument { snapshot, error in
                if let error = error {
                    print("Marka adı alınırken hata: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                if let data = snapshot?.data(), let name = data["name"] as? String {
                    completion(name)
                } else {
                    completion(nil)
                }
            }
    }

    // Firestore'dan Model İsmini Çekme
    func fetchModelName(completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        db.collection("categories")
            .document(tempCategory) // Kategori ID
            .collection("subcategories")
            .document(altcategory) // Marka ID
            .collection("details")
            .document(marka) // Marka ID
            .collection("moreDetail")
            .document(model) // Marka ID
            .getDocument { snapshot, error in
                if let error = error {
                    print("Model adı alınırken hata: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                if let data = snapshot?.data(), let name = data["name"] as? String {
                    completion(name)
                } else {
                    completion(nil)
                }
            }
    }
}

extension ilanlar {
    init(from product: Product) {
        self.id = product.id
        self.imageUrl = product.imageUrls
        self.userId = product.uid
        self.title = product.title
        self.price = product.price
        self.createdAt = product.createdAt
        self.description = product.description
        self.altcategory = product.altcategory
        self.tempCategory = product.tempCategory
        self.marka = product.marka
        self.model = product.model
    }
}
