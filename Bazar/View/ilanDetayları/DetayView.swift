import SwiftUI
import FirebaseFirestore

struct DetayView: View {
    let ad: ilanlar // Tıklanan ilan bilgisi
    @StateObject private var firestoreManager = FirestoreManager() // Alt kategori adı için manager
    
    @State private var categoryName: String = "" // Kategori adı için state

    var body: some View {
        GeometryReader { geo in
            let ekranYükseklik = geo.size.height
            let ekranGenislik = geo.size.width

            ZStack {
                // Gradient Arkaplan (Sayfanın tamamına yayılır)
                LinearGradient(gradient: Gradient(colors: [
                    Color.orange.opacity(0.7),
                    Color.pink.opacity(0.8)
                ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.vertical) // **Alt ve üst safe area ignore edildi**
                
                ScrollView {
                    VStack(spacing: 20) {
                        // **En Üste Navigation Bar ile Çakışmayı Önlemek İçin Boşluk Ekledik**
                        Spacer().frame(height: 10)

                        // **İlan Resimleri Slider (TabView)**
                        TabView {
                            ForEach(ad.imageUrl, id: \.self) { photoURL in
                                if let url = URL(string: photoURL) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: ekranGenislik - 40, height: ekranYükseklik / 2.5)
                                                .clipped()
                                        default:
                                            ProgressView()
                                        }
                                    }
                                }
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                        .frame(width: ekranGenislik - 40, height: ekranYükseklik / 2.5)
                        .cornerRadius(20)
                        .shadow(radius: 10)

                        // **Kategori Adı Firestore'dan Çekiliyor**
                        bilgiKartıMetin(text: categoryName.isEmpty ? "Kategori yükleniyor..." : categoryName)
                        
                        // **Başlık**
                        bilgiKartıMetin(text: ad.title, fontSize: 26, fontWeight: .bold)
                        
                        // **Fiyat**
                        Text("₺\(ad.price, specifier: "%.2f")")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .padding()
                            .frame(width: ekranGenislik - 40)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                            .shadow(radius: 5)

                        // **Açıklama**
                        bilgiKartıMetin(text: ad.description, fontSize: 22, fontWeight: .regular)

                    }
                    .padding(.horizontal, 20)  // Taşmayı engellemek için yatay padding
                    .padding(.bottom, 30) // Ekstra alttan boşluk eklenmez
                    .onAppear {
                        // Firestore'dan Kategori İsmini Çek
                        firestoreManager.fetchCategoryName(for: ad.altcategory) { name in
                            categoryName = name
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // **GENEL BİLGİ KARTI METİN STİLİ (KÜÇÜK BİR COMPONENT)**
    private func bilgiKartıMetin(text: String, fontSize: CGFloat = 24, fontWeight: Font.Weight = .semibold) -> some View {
        Text(text)
            .font(.system(size: fontSize))
            .fontWeight(fontWeight)
            .multilineTextAlignment(.center)
            .padding()
            .frame(width: UIScreen.main.bounds.width - 40) // **Maksimum genişlik ayarlandı**
            .background(Color.white.opacity(0.2))
            .cornerRadius(15)
            .shadow(radius: 5)
    }
}

// **FirestoreManager (Kategori İsmini Getiriyor)**
class FirestoreManager: ObservableObject {
    private var db = Firestore.firestore()

    /// **Kategori ID yerine, ilgili kategorinin adını (name) getiriyoruz**
    func fetchCategoryName(for categoryId: String, completion: @escaping (String) -> Void) {
        db.collection("subcategories").document(categoryId).getDocument { document, error in
            if let error = error {
                print("Hata: \(error.localizedDescription)")
                completion("Kategori bulunamadı")
                return
            }
            if let document = document, document.exists {
                if let name = document.data()?["name"] as? String {
                    completion(name) // **Kategori adını al ve gönder**
                } else {
                    completion("Kategori adı eksik")
                }
            } else {
                completion("Kategori bulunamadı")
            }
        }
    }
}
