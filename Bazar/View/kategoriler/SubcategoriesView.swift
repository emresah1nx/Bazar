//
//  SubcategoriesView.swift
//  Bazar
//
//  Created by Emre Şahin on 20.01.2025.
//

import SwiftUI

struct SubcategoriesView: View {
    var category: kategori
    @StateObject private var viewModel = SubcategoryViewModel()

    var body: some View {
        VStack {
            NavigationView {
                List(viewModel.subcategories) { subcategory in
                    NavigationLink(destination: DetailsView(category: category, subcategory: subcategory)) {
                        Text(subcategory.name)
                    }
                }
                .onAppear {
                    // Alt kategorileri çek
                    if let categoryId = category.id {
                        viewModel.fetchSubcategories(for: categoryId)
                    }
                }
                .background(Color.anaRenk2) // Arka plan rengini belirler
                .scrollContentBackground(.hidden) // Liste içeriğinin arka planını gizler
            }
        }
        .navigationTitle(category.name)
    }
}
