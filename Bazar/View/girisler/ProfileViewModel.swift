import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class ProfileViewModel: ObservableObject {
    @Published var userProducts: [Product] = []
    @Published var favoriteProducts: [Product] = []

    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() {
        fetchUserProducts()
        fetchFavoriteProducts()
    }

    // 🔄 Kullanıcının ilanlarını getir
    func fetchUserProducts() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("products")
            .whereField("uid", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("İlanları çekerken hata oluştu: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                DispatchQueue.main.async {
                    self.objectWillChange.send() // 🔄 UI Güncelleme
                    self.userProducts = documents.compactMap { doc in
                        let data = doc.data()
                        return self.createProduct(from: data, id: doc.documentID)
                    }
                }
            }
    }

    // 🔄 Favori ilanları getir
    func fetchFavoriteProducts() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(userId).addSnapshotListener { document, error in
            if let error = error {
                print("Favori ilanları çekerken hata oluştu: \(error.localizedDescription)")
                return
            }

            guard let document = document, document.exists,
                  let favoriteIds = document.get("favorites") as? [String], !favoriteIds.isEmpty else {
                DispatchQueue.main.async {
                    self.favoriteProducts = []
                }
                return
            }

            self.db.collection("products")
                .whereField(FieldPath.documentID(), in: favoriteIds)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        print("Favori ilanları çekerken hata oluştu: \(error.localizedDescription)")
                        return
                    }

                    guard let documents = snapshot?.documents else { return }

                    DispatchQueue.main.async {
                        self.objectWillChange.send() // 🔄 UI Güncelleme
                        self.favoriteProducts = documents.compactMap { doc in
                            let data = doc.data()
                            return self.createProduct(from: data, id: doc.documentID)
                        }
                    }
                }
        }
    }

    // 📌 Firestore verisini `Product` modeline dönüştür
    private func createProduct(from data: [String: Any], id: String) -> Product {
        return Product(
            id: id,
            title: data["title"] as? String ?? "Bilinmeyen",
            description: data["description"] as? String ?? "",
            price: data["price"] as? Double ?? 0.0,
            imageUrls: data["foto"] as? [String] ?? [],
            uid: data["uid"] as? String ?? "",
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue(),
            altcategory: data["altcategory"] as? String ?? "",
            tempCategory: data["tempCategory"] as? String ?? "",
            marka: data["marka"] as? String ?? "",
            model: data["model"] as? String ?? ""
        )
    }

    // 🗑 Firestore Dinleyicisini Kapat
    deinit {
        listener?.remove()
    }
}
