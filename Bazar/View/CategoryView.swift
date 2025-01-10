import SwiftUI

struct CategoryView: View {
    // Ana kategoriler ve alt kategorileri tutacak veri modeli
    let categories = [
        Category(name: "Araçlar", subcategories: ["Otomobil", "Kamyon", "Motosiklet"]),
        Category(name: "Yedek Parçalar", subcategories: ["Motor", "Fren", "Elektrik"]),
        Category(name: "Aksesuarlar", subcategories: ["Direksiyon", "Pedallar", "Koltuklar"])
    ]
    
    // Kategorilerin açılıp kapanma durumlarını tutan bir dizi
    @State private var expandedCategories: Set<String> = []
    
    var body: some View {
        NavigationView {
            List(categories, id: \.name) { category in
                DisclosureGroup(isExpanded: .constant(expandedCategories.contains(category.name))) {
                    // Alt kategorileri listele
                    ForEach(category.subcategories, id: \.self) { subcategory in
                        Text(subcategory)
                            .padding(.leading, 20) // Alt kategoriyi girintili göster
                    }
                } label: {
                    // Kategori adını ve açılma işlemini kapsayan bir buton
                    HStack {
                        Text(category.name)
                            .font(.headline)
                        Spacer()
                        Image(systemName: expandedCategories.contains(category.name) ? "chevron.down" : "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                    .onTapGesture {
                        // Kategoriye tıklanınca açma/kapama işlemi
                        if expandedCategories.contains(category.name) {
                            expandedCategories.remove(category.name)
                        } else {
                            expandedCategories.insert(category.name)
                        }
                    }
                }
            }
            .navigationTitle("Araç Kategorileri")
        }
    }
}

struct Category {
    let name: String
    let subcategories: [String]
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView()
    }
}
