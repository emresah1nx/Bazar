import SwiftUI
import FirebaseFirestore

class kategorilerViewModel: ObservableObject {
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
}
