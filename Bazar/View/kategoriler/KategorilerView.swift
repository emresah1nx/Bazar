//
//  KategorilerView.swift
//  Bazar
//
//  Created by Emre Şahin on 10.01.2025.
//

import SwiftUI

struct KategorilerView: View {
    @StateObject private var viewModel = kategoriViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.categories) { category in
                NavigationLink(destination: SubcategoriesView(category: category)) {
                    Text(category.name)
                }
            }
            .onAppear {
                viewModel.fetchCategories()
        }
            .scrollContentBackground(.hidden) // Liste içeriğinin arka planını gizler
            .background(Color.anaRenk2) // Arka plan rengini belirler
      }
   }
}

