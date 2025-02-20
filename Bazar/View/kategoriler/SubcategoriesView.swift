import SwiftUI

struct SubcategoriesView: View {
    var category: kategori
    @StateObject private var viewModel = SubcategoryViewModel()
    @State private var selectedSubcategory: String? = nil
    @State private var navigateToSearchView = false

    var body: some View {
        NavigationStack {
            List(viewModel.subcategories) { subcategory in
                HStack {
                    // Alt kategori adına tıklanınca DetailsView açılır
                    NavigationLink(destination: DetailsView(category: category, subcategory: subcategory)) {
                        Text(subcategory.name)
                            .padding()
                    }
                    Spacer()

                    // "Tümünü Göster" Butonu (Sadece Butona Basınca Çalışacak)
                    Button(action: {
                        selectedSubcategory = subcategory.id
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
                if let categoryId = category.id {
                    viewModel.fetchSubcategories(for: categoryId)
                }
            }
            .scrollContentBackground(.hidden) // Liste içeriğinin arka planını gizler
            .background(LinearGradient(
                gradient: Gradient(colors: [Color.anaRenk1.opacity(0.7), Color.anaRenk2.opacity(0.9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .navigationTitle(category.name)

            // Butona basınca yönlendirme yapacak SwiftUI 16+ uyumlu navigation
            .navigationDestination(isPresented: $navigateToSearchView) {
                if let subcategoryID = selectedSubcategory {
                    KategoriSearchSubView(subcategoryID: subcategoryID)
                }
            }
        }
    }
}
