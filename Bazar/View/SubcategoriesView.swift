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
        List(viewModel.subcategories) { subcategory in
            Text(subcategory.name)
        }
        .navigationTitle(category.name)
        .onAppear {
            if let categoryId = category.id {
                viewModel.fetchSubcategories(for: categoryId)
            }
        }
    }
}

