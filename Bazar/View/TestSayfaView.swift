//
//  TestSayfaView.swift
//  Bazar
//
//  Created by Emre Şahin on 12.01.2025.
//

import SwiftUI

struct TestSayfaView: View {
    @StateObject private var viewModel = TestSayfaViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                    ForEach(viewModel.ads) { ad in
                        VStack {
                            if let firstPhoto = ad.foto.first, let url = URL(string: firstPhoto) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().scaledToFill()
                                    default:
                                        ProgressView()
                                    }
                                }
                                .frame(width: 150, height: 150)
                                .clipped()
                            }

                            Text(ad.title)
                                .font(.headline)
                                .lineLimit(1)

                            Text("₺\(ad.price, specifier: "%.2f")")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                }
                .padding()
            }
            .navigationTitle("Vitrin")
        }
        .onAppear {
            viewModel.fetchAds()
        }
    }
}

#Preview {
    TestSayfaView()
}
