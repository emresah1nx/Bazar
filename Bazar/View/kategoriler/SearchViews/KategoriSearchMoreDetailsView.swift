//
//  KategoriSearchMoreDetailsView.swift
//  Bazar
//
//  Created by Emre Şahin on 11.02.2025.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore

struct KategoriSearchMoreDetailsView: View {
    let moreDetail: MoreDetail
    
    @State private var ads: [ilanlar] = [] // İlanları saklamak için
    @State private var searchText: String = ""
    @State private var selectedAd: ilanlar? // Seçili ilanı göstermek için

    var body: some View {
        GeometryReader { geo in
            let ekranGenişlik = geo.size.width
            let itemGenişlik = (ekranGenişlik - 70) / 2
            
            NavigationStack {
                VStack {
                ScrollView {
                    // 🔹 Arama Çubuğu
                    HStack {
                        TextField("", text: $searchText, prompt: Text("Ara...").foregroundColor(Color.gray))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(filteredIlanlar(searchText: searchText)) { ilan in
                            VStack(alignment: .leading) {
                                WebImage(url: URL(string: ilan.imageUrl.first ?? ""))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: itemGenişlik, height: itemGenişlik * 1.2)
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                                    .clipped()
                                
                                Text(ilan.title)
                                    .font(.headline)
                                    .lineLimit(1)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity)
                                
                                Text("\(ilan.price, specifier: "%.2f") €")
                                    .font(.subheadline)
                                    .foregroundColor(.yellow)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity)
                                
                                Spacer()
                            }
                            .padding(5)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .frame(width: 150)
                            .onTapGesture {
                                selectedAd = ilan
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
                .navigationTitle(moreDetail.name)
                .onAppear {
                    fetchAdsByCategory(moreDetail.id!) // ✅ Firestore'dan kategoriye göre ilanları çekiyor
                }
                .sheet(item: $selectedAd) { ilan in
                    DetayView(ad: ilan) // ✅ Seçili ilan detay ekranı açılıyor
                }
            }
        }
    }
    
    // 🔹 **Firestore'dan kategoriye göre ilanları çekme fonksiyonu**
    func fetchAdsByCategory(_ categoryID: String) {
        let db = Firestore.firestore()
        db.collection("products")
            .whereField("model", isEqualTo: categoryID) // Kategoriye göre filtreleme
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
                    self.ads = documents.map { doc in
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

    // 🔹 **Arama filtresi**
    func filteredIlanlar(searchText: String) -> [ilanlar] {
        if searchText.isEmpty {
            return ads
        } else {
            return ads.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
    }
}

