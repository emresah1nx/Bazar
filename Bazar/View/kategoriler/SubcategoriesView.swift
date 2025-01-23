//
//  SubcategoriesView.swift
//  Bazar
//
//  Created by Emre Şahin on 20.01.2025.
//

import SwiftUI

struct SubcategoriesView: View {
    var category: kategori
    @StateObject private var viewModel = kategoriViewModel()

    var body: some View {
        NavigationView {
        List(viewModel.subcategories) { subcategory in
            NavigationLink(destination: DetailsView(category: category, subcategory: subcategory)) {
                Text(subcategory.name)
            }
        }
        .onAppear {
            if let categoryId = category.id {
                viewModel.fetchSubcategories(for: categoryId)
            }
        }
        .scrollContentBackground(.hidden) // Liste içeriğinin arka planını gizler
        .background(Color.anaRenk2) // Arka plan rengini belirler
    }
    }
}


