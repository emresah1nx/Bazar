import Foundation

struct Product: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let price: Double
    let imageUrls: [String]
    let uid: String
    let createdAt: Date?  // ✅ Firestore'dan gelen tarih alanı eklendi
    let altcategory: String // ✅ Alt kategori eklendi
    let tempCategory: String // ✅ Geçici kategori eklendi
    let marka: String // ✅ Marka bilgisi eklendi
    let model: String

    // Hashable için gerekli olan fonksiyon
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // İki Product nesnesini karşılaştırmak için
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Product {
    func toIlanlar() -> ilanlar {
        guard !self.id.isEmpty else {
            print("HATA: Product ID boş!")
            return ilanlar(
                id: UUID().uuidString,
                imageUrl: [],
                userId: "",
                title: "Bilinmeyen",
                price: 0.0,
                createdAt: nil,
                description: "",
                altcategory: "",
                tempCategory: "",
                marka: "",
                model: ""
            )
        }
        
        return ilanlar(
            id: self.id,
            imageUrl: self.imageUrls,
            userId: self.uid,
            title: self.title,
            price: self.price,
            createdAt: self.createdAt,
            description: self.description,
            altcategory: self.altcategory,
            tempCategory: self.tempCategory,
            marka: self.marka,
            model: self.model
        )
    }
}
