//
//  ilanKategori.swift
//  Bazar
//
//  Created by Emre Şahin on 24.01.2025.
//

import SwiftUI

struct ilanKategori: View {
    @ObservedObject var categoryViewModel: kategoriViewModel
    @ObservedObject var subCategoryViewModel: SubcategoryViewModel
    @State private var expandedCategoryIds: Set<String> = []
    
    var body: some View {
            List {
                ForEach(categoryViewModel.categories) { category in
                    Section {
                        // Ana kategori
                        HStack {
                            Text(category.name)
                            Spacer()
                            if expandedCategoryIds.contains(category.id) {
                                Image(systemName: "chevron.down")
                            } else {
                                Image(systemName: "chevron.right")
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleExpansion(for: category)
                        }

                        // Alt kategoriler
                        if expandedCategoryIds.contains(category.id) {
                            if let subcategories = subCategoryViewModel.subcategories[category.id] {
                                ForEach(subcategories) { subcategory in
                                    Text(subcategory.name)
                                        .padding(.leading, 16) // Alt kategoriler için kaydırma
                                }
                            } else {
                                Text("Alt kategoriler yükleniyor...")
                                    .italic()
                                    .padding(.leading, 16)
                            }
                        }
                    }
                }
            }
            .onAppear {
                categoryViewModel.fetchCategories()
            }
        }

        private func toggleExpansion(for category: Category) {
            if expandedCategoryIds.contains(category.id) {
                expandedCategoryIds.remove(category.id)
            } else {
                expandedCategoryIds.insert(category.id)
                subCategoryViewModel.fetchSubcategories(for: category.id)
            }
        }
    }

#Preview {
    ilanKategori()
}
