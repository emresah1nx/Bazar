import Foundation
import FirebaseFirestore

struct kategori: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var subcategories: [Subcategory]? = nil

    // Hashable için zorunlu: `id` opsiyonel olduğu için elle tanımlıyoruz
    static func == (lhs: kategori, rhs: kategori) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Subcategory: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String

    static func == (lhs: Subcategory, rhs: Subcategory) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Detail: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String

    static func == (lhs: Detail, rhs: Detail) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct MoreDetail: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    
    static func == (lhs: MoreDetail, rhs: MoreDetail) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
