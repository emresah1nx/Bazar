//
//  DetayView.swift
//  Bazar
//
//  Created by Emre Şahin on 10.01.2025.
//

import SwiftUI

struct DetayView: View {
    let ad: ilanlar // Tıklanan ilan bilgisi

    var body: some View {
        GeometryReader { geo in
          //  let ekranGenişlik = geo.size.width
            let ekranYükseklik = geo.size.height
            let ekranGenislik = geo.size.width
            ScrollView {
                VStack() {
                    // Resimler
                    TabView {
                        ForEach(ad.imageUrl, id: \.self) { photoURL in
                            if let url = URL(string: photoURL) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    default:
                                        ProgressView()
                                    }
                                }
                            }
                        }
                    }
                    .cornerRadius(20)
                    .padding([.leading,.trailing], 10)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(width: UIScreen.main.bounds.width , height: ekranYükseklik / 2 , alignment: .top)
                    
                    Spacer()
                // Başlık
                Text(ad.title)
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                    .background(
                            Rectangle()
                                .fill(Color.anaRenk1) // Düz renk doldurma
                                .cornerRadius(20) // Köşe yuvarlama
                        )
                    
                    Spacer()
                    
                    // Fiyat
                    Text("₺\(ad.price, specifier: "%.2f")")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .padding(.horizontal)
                        .background(
                                Rectangle()
                                    .fill(Color.anaRenk1) // Düz renk doldurma
                                    .cornerRadius(20) // Köşe yuvarlama
                            )
                    Spacer()
                    Text(ad.description)
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                        .background(
                                Rectangle()
                                    .fill(Color.anaRenk1) // Düz renk doldurma
                                    .cornerRadius(20) // Köşe yuvarlama
                            )
                }
                .padding(.vertical)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
