import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore
import FirebaseAuth

struct VitrinView: View {
    @StateObject private var viewModel = ilanItem()
    @State private var searchText: String = "" // Arama metni için state
    @State private var favoriteAds: Set<String> = [] // Favori ilanları tutan set

    var body: some View {
        GeometryReader { geo in
            let ekranGenişlik = geo.size.width
            let ekranYükseklik = geo.size.height
            let itemGenişlik = (ekranGenişlik - 50) / 2
            let itemYükseklik = (ekranYükseklik - 60) / 4
            
            NavigationView {
                VStack {
                    ScrollView {
                        Spacer()
                        HStack {
                            TextField("", text: $searchText, prompt : Text("Ara...").foregroundColor(Color.yazıRenk1))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.leading, 10)
                                .background(Color.anaRenk1)
                                
                            Button(action: {
                                viewModel.searchAds(query: searchText)
                            }) {
                                Text(Image(systemName: "magnifyingglass.circle"))
                                    .foregroundColor(.white)
                                    .padding(.vertical,5)
                                    .padding(.horizontal,10)
                                    .background(Color.yazıRenk1)
                                    .cornerRadius(10)
                            }
                            .foregroundColor(.yazıRenk3)
                            .padding(.trailing,10)
                        }
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                            ForEach(viewModel.ads) { ads in
                                NavigationLink(
                                    destination: DetayView(ad: ads)
                                ) {
                                    VStack {
                                        AdImageView(imageUrl: ads.imageUrl.first ?? "")
                                            .frame(width: itemGenişlik, height: itemYükseklik)
                                            .cornerRadius(10)
                                            .shadow(radius: 2)
                                            .clipped()

                                        Text(ads.title)
                                            .font(.headline)
                                            .lineLimit(1)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)

                                        Text("\(ads.price, specifier: "%.2f") €")
                                            .font(.subheadline)
                                            .foregroundColor(.yellow)
                                            .frame(maxWidth: .infinity)
                                    }
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                    .frame(width: itemGenişlik)
                                    
                                }
                                .disabled(ads.title.isEmpty) // Eğer ilan başlığı eksikse butonu kapat
                            }
                        }
                        .padding(.top,0)
                    }
                    .background(Color.anaRenk2)
                }
                .onAppear {
                    fetchAds()
                    loadFavorites()
                }
            }
        }
        .padding(0)
    }
    
    // Firestore Favori Güncelleme
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
    
    // Firestore'dan Kullanıcının Favorilerini Çekme
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
    
    // 🔹 Firestore'dan ilgili kategoriye ait ilanları çekme
    func fetchAds() {
        let db = Firestore.firestore()
        db.collection("products")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("🔥 Firestore Hata: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("🔥 Firestore Veri Yok!")
                    return
                }

                print("✅ Firestore'dan \(documents.count) ilan çekildi.")

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

}

