//
//  VitrinView.swift
//  Bazar
//
//  Created by Emre Şahin on 10.01.2025.
//

import SwiftUI

struct VitrinView: View {
    @StateObject private var viewModel = ilanItem()

    var body: some View {
        GeometryReader { geo in
            let ekranGenişlik = geo.size.width
            let ekranYükseklik = geo.size.height
            let itemGenişlik = (ekranGenişlik - 70)/2
            let itemYükseklik = (ekranYükseklik - 70)/4
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())]) {
                        ForEach(viewModel.ads) { ads in
                            NavigationLink(destination: DetayView(ad: ads)) {
                                VStack {
                                    if let firstPhoto = ads.imageUrl.first, let url = URL(string: firstPhoto) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image.resizable().scaledToFill().frame(width: itemGenişlik, height: itemYükseklik)
                                            default:
                                                ProgressView()
                                            }
                                        }
                                        .cornerRadius(10) // Köşe yuvarlama
                                        .shadow(radius: 5) // Gölge eklemek (isteğe bağlı)
                                        .clipped()
                                    }
                                    Text(ads.title)
                                        .font(.headline)
                                        .lineLimit(1)
                                        .foregroundColor(.yazıRenk3)
                                        .padding([.leading, .trailing], 0)  // Padding'i hizalamak için
                                        .frame(maxWidth: .infinity) // Genişliği sınırsız yaparak hizalamayı sağla
                                    
                                    Text("₺\(ads.price, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .foregroundColor(.yazıRenk3)
                                        .padding([.leading, .trailing], 0)  // Padding'i hizalamak için
                                        .frame(maxWidth: .infinity) // Genişliği sınırsız yaparak hizalamayı sağla
                                }
                                .padding(5)
                                .background(Color.yazıRenk1)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                                .frame(width: 150)  // Aynı boyutta görünmesini sağla
                            }
                        }
                    }
                    .padding()
                }
                .background(Color.anaRenk2)
            }
        }
        .padding(0)
        .onAppear {
            viewModel.fetchAds()
            print("Veriler: \(viewModel.ads)")
        }
    }
}


