//
//  DetailsView.swift
//  Bazar
//
//  Created by Emre Şahin on 23.01.2025.
//

import SwiftUI

struct DetailsView: View {
    var category: kategori
    var subcategory: Subcategory
    @StateObject private var viewModel = DetailViewModel()

    // Yükleniyor göstergesi
    @State private var isLoading = true

    var body: some View {
        VStack {
            // Detayları listele
            List(viewModel.details) { detail in
                NavigationLink(destination: KategoriSearchView(detailName: detail.name)) {
                    HStack {
                        Text(detail.name)  // `name` özelliğini listele
                            .padding()
                        Spacer()
                     //   Image(systemName: "chevron.right") // Sağda yönlendirme oku
                    }
                    .contentShape(Rectangle()) // Tıklanabilir alanı genişletir
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.anaRenk2) // Arka plan rengini belirler
        }
        .navigationTitle(subcategory.name)
        .onAppear {
            if let categoryId = category.id, let subcategoryId = subcategory.id {
                viewModel.fetchDetails(for: categoryId, subcategoryId: subcategoryId) {
                    // Veri çekme tamamlandığında `isLoading`'i false yapalım
                    isLoading = false
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
}
