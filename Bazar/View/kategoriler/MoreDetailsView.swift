//
//  MoreDetailsView.swift
//  Bazar
//
//  Created by Emre Şahin on 11.02.2025.
//

import SwiftUI

struct MoreDetailsView: View {
    @StateObject var viewModel = MoreDetailsViewModel()
    
    let categoryId: String
    let subcategoryId: String
    let detailId: String
    let categoryName: String // ✅ Seçili kategori adı eklendi

    var body: some View {
        VStack {
            // MoreDetails listesini göster
            List(viewModel.moreDetails) { moreDetail in
                NavigationLink(destination: KategoriSearchMoreDetailsView(moreDetail: moreDetail)) {
                    HStack {
                        Text(moreDetail.name)
                            .padding()
                        Spacer()
                    }
                    .contentShape(Rectangle()) // Tıklanabilir alanı genişletir
                }
            }
            .scrollContentBackground(.hidden)
            .background(LinearGradient(
                gradient: Gradient(colors: [Color.anaRenk1.opacity(0.7), Color.anaRenk2.opacity(0.9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
        }
        .navigationTitle(categoryName) // ✅ Kategori adı başlık olarak gösterilecek
        .onAppear {
            viewModel.fetchMoreDetails(for: categoryId, subcategoryId: subcategoryId, detailId: detailId) {
                // Veri çekme tamamlandı
            }
        }
    }
}
