import SwiftUI

struct KategorilerView: View {
    @StateObject private var viewModel = kategorilerViewModel()
    @State private var selectedCategory: String? = nil
    @State private var navigateToSearchView = false

    var body: some View {
        NavigationStack {
            List(viewModel.categories) { category in
                HStack {
                    // Kategori adına basıldığında alt kategorilere gider
                    NavigationLink(destination: SubcategoriesView(category: category)) {
                        Text(category.name)
                            .padding()
                    }
                    Spacer()

                    // "Tümünü Göster" Butonu (Sadece Butona Basınca Çalışacak)
                    Button(action: {
                        selectedCategory = category.name
                        navigateToSearchView = true
                    }) {
                        Text("Tümünü Göster")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle()) // Buton tasarımını korumak için
                }
            }
            .onAppear {
                viewModel.fetchCategories()
            }
            .scrollContentBackground(.hidden) // Liste içeriğinin arka planını gizler
            .background(Color.anaRenk2) // Arka plan rengini belirler
            .navigationTitle("Kategoriler")

            // Butona basınca yönlendirme yapacak NavigationLink
            .background(
                NavigationLink(
                    destination: KategoriSearchAnaView(categoryName: selectedCategory ?? ""),
                    isActive: $navigateToSearchView
                ) {
                    EmptyView()
                }
                .hidden()
            )
        }
    }
}
