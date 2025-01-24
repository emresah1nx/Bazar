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
                        Text(detail.name)  // `name` özelliğini listele
                    }
            
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
        .scrollContentBackground(.hidden) // Liste içeriğinin arka planını gizler
        .background(Color.anaRenk2) // Arka plan rengini belirler
    }
}


