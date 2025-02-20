import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore
import FirebaseAuth

struct KategoriSearchAnaView: View {
    var categoryID: String
    @StateObject private var viewModel = ilanItem()
    @State private var searchText: String = ""
    @State private var selectedAd: ilanlar?
    @State private var showDetail = false
    @State private var favoriteAds: Set<String> = [] // Kullanıcının favori ilanlarını tutan set

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let ekranGenişlik = geo.size.width
                let ekranYükseklik = geo.size.height
                let itemGenişlik = (ekranGenişlik - 70) / 2
                let itemYükseklik = (ekranYükseklik - 70) / 4
                
                VStack {
                    ScrollView {
                        // 🔎 Arama Çubuğu
                        Spacer()
                        HStack {
                            TextField("", text: $searchText, prompt: Text("Ara...").foregroundColor(Color.gray))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.leading, 10)
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()), GridItem(.flexible())
                        ], spacing: 5) {
                            ForEach(filteredAds()) { ad in
                                ZStack(alignment: .topTrailing) {
                                    Button(action: {
                                        selectedAd = ad
                                        showDetail = true
                                    }) {
                                        VStack {
                                            WebImage(url: URL(string: ad.imageUrl.first ?? ""))
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: itemGenişlik, height: itemYükseklik)
                                                .cornerRadius(10)
                                                .shadow(radius: 2)
                                                .clipped()
                                            
                                            Text(ad.title)
                                                .font(.headline)
                                                .lineLimit(1)
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                            
                                            Text("\(ad.price, specifier: "%.2f") €")
                                                .font(.subheadline)
                                                .foregroundColor(.yellow)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .padding(5)
                                        .background(Color.white.opacity(0.2))
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                        .frame(width: 150)
                                    }

                                    // 🖤 Favori Butonu
                                    Button(action: {
                                        toggleFavorite(adId: ad.id)
                                    }) {
                                        Image(systemName: favoriteAds.contains(ad.id) ? "heart.fill" : "heart")
                                            .foregroundColor(favoriteAds.contains(ad.id) ? .red : .white)
                                            .padding(8)
                                            .background(Color.black.opacity(0.5))
                                            .clipShape(Circle())
                                    }
                                    .padding(10)
                                    .padding(.top, -5)
                                }
                            }
                        }
                        .padding(.top, 0)
                    }
                    .background(LinearGradient(
                        gradient: Gradient(colors: [Color.anaRenk1.opacity(0.7), Color.anaRenk2.opacity(0.9)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                }
                .navigationTitle("İlanlar")
                .onAppear {
                    fetchAds()
                    loadFavorites() // Kullanıcının favorilerini Firestore’dan çek
                }
                .sheet(item: $selectedAd) { ad in
                    DetayView(ad: ad)
                }
            }
        }
    }

    // 🔹 Arama metnine göre filtreleme fonksiyonu
    func filteredAds() -> [ilanlar] {
        if searchText.isEmpty {
            return viewModel.ads
        } else {
            return viewModel.ads.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }

    // 🔹 Firestore'dan ilgili kategoriye ait ilanları çekme
    func fetchAds() {
        let db = Firestore.firestore()
        db.collection("products")
            .whereField("tempCategory", isEqualTo: categoryID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Hata: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("Veri yok!")
                    return
                }

                DispatchQueue.main.async {
                    self.viewModel.ads = documents.map { doc in
                        let data = doc.data()
                        
                        // **Eksik olan verileri varsayılan değerlerle tamamla**
                        let id = doc.documentID
                        let imageUrl = data["foto"] as? [String] ?? []
                        let userId = data["uid"] as? String ?? "Bilinmeyen Kullanıcı"
                        let title = data["title"] as? String ?? "Başlık Yok"
                        let price = data["price"] as? Double ?? 0.0
                        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                        let description = data["description"] as? String ?? "Açıklama Yok"
                        let altcategory = data["altcategory"] as? String ?? "Kategori Yok"
                        let tempCategory = data["tempCategory"] as? String ?? ""
                        let marka = data["marka"] as? String ?? "Marka Yok"
                        let model = data["model"] as? String ?? "Model Yok"

                        print("📌 İlan Yüklendi: \(title) - Kullanıcı: \(userId)")

                        return ilanlar(
                            id: id,
                            imageUrl: imageUrl,
                            userId: userId,
                            title: title,
                            price: price,
                            createdAt: createdAt,
                            description: description,
                            altcategory: altcategory,
                            tempCategory: tempCategory,
                            marka: marka,
                            model: model
                        )
                    }
                }
            }
    }

    // 🔹 Firestore Favori Güncelleme
    func toggleFavorite(adId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(userId)

        if favoriteAds.contains(adId) {
            // Favoriden Kaldır
            favoriteAds.remove(adId)
            userRef.updateData([
                "favorites": FieldValue.arrayRemove([adId])
            ])
        } else {
            // Favorilere Ekle
            favoriteAds.insert(adId)
            userRef.updateData([
                "favorites": FieldValue.arrayUnion([adId])
            ])
        }
    }

    // 🔹 Firestore'dan Kullanıcının Favorilerini Çekme
    func loadFavorites() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(userId)

        userRef.getDocument { document, error in
            if let document = document, document.exists {
                if let favorites = document.data()?["favorites"] as? [String] {
                    favoriteAds = Set(favorites)
                }
            }
        }
    }
}
