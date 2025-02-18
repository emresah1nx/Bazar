import SwiftUI

struct KategorilerView: View {
    @StateObject private var viewModel = kategorilerViewModel()
    @State private var selectedCategoryID: String? = nil
    @State private var navigateToSearchView = false

    var body: some View {
        NavigationStack {
            List(viewModel.categories) { category in
                HStack {
                    NavigationLink(destination: SubcategoriesView(category: category)) {
                        Text(category.name)
                            .padding()
                    }
                    Spacer()

                    // "Tümünü Göster" Butonu
                    Button(action: {
                        selectedCategoryID = category.id
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
                    .buttonStyle(PlainButtonStyle()) // Butonun tıklanabilir alanını düzenler
                }
            }
            .onAppear {
                viewModel.fetchCategories()
            }
            .scrollContentBackground(.hidden)
            .background(Color.anaRenk2)
            .navigationTitle("Kategoriler")

            // SwiftUI 16+ uyumlu Navigation
            .navigationDestination(isPresented: $navigateToSearchView) {
                if let categoryID = selectedCategoryID {
                    KategoriSearchAnaView(categoryID: categoryID)
                }
            }
        }
    }
}
