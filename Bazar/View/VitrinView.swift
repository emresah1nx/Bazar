//
//  VitrinView.swift
//  Bazar
//
//  Created by Emre Şahin on 10.01.2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct VitrinView: View {
    @StateObject private var viewModel = ilanItem()
    @State private var searchText: String = "" // Arama metni için state

    var body: some View {
        GeometryReader { geo in
            let ekranGenişlik = geo.size.width
            let ekranYükseklik = geo.size.height
            let itemGenişlik = (ekranGenişlik - 70) / 2
            let itemYükseklik = (ekranYükseklik - 70) / 4
            
            NavigationView {
                VStack {
                    ScrollView {
                        // Arama Çubuğu
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
                            ForEach(viewModel.filteredAds) { ads in
                                NavigationLink(destination: DetayView(ad: ads)) {
                                    VStack {
                                        // Görseli burada yükleyelim
                                        AdImageView(imageUrl: ads.imageUrl.first ?? "")
                                            .frame(width: itemGenişlik, height: itemYükseklik)
                                            .cornerRadius(10)
                                            .shadow(radius: 5)
                                            .clipped()

                                        Text(ads.title)
                                            .font(.headline)
                                            .lineLimit(1)
                                            .foregroundColor(.anaRenk1)
                                            .padding([.leading, .trailing], 0)
                                            .frame(maxWidth: .infinity)

                                        Text("₺\(ads.price, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .foregroundColor(.anaRenk1)
                                            .padding([.leading, .trailing], 0)
                                            .frame(maxWidth: .infinity)
                                    }
                                    .padding(5)
                                    .background(Color.yazıRenk3)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                    .frame(width: 150)
                                }
                            }
                        }
                        .padding(.top,0)
                    }
                    .background(Color.anaRenk2)
                }
                .onAppear {
                    viewModel.fetchAds()
                }
            }
        }
        .padding(0)
    }
}
