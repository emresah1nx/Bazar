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
    var marka: String
    var model: String

    enum CodingKeys: String, CodingKey {
        case id, imageUrl, userId, title, price, createdAt, description, altcategory, tempCategory, marka, model
    }

    // Firestore'dan gelen veriyi düzgün parse etmek için init fonksiyonu
    init(id: String, imageUrl: [String], userId: String, title: String, price: Double, createdAt: Any?, description: String, altcategory: String, tempCategory: String, marka: String,model: String) {
        self.id = id
        self.imageUrl = imageUrl
        self.userId = userId
        self.title = title
        self.price = price

        // 🔹 **createdAt değerini Timestamp'tan Date'e dönüştürme**
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

    // 🔹 **Hashable Protokolü için Gerekli Metotlar**
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ilanlar, rhs: ilanlar) -> Bool {
        return lhs.id == rhs.id
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
