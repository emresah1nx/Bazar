import SwiftUI

struct ProductRowView: View {
    @Binding var product: Product // ✅ Güncellenebilir hale getirildi
    var onDelete: () -> Void // 🗑️ Silme işlemi için closure

    var body: some View {
        HStack {
            // 🖼️ Ürün Resmi
            if let firstImageUrl = product.imageUrls.first, let url = URL(string: firstImageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } placeholder: {
                    ProgressView()
                        .frame(width: 80, height: 80)
                }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
            }

            // 📝 Ürün Bilgileri
            VStack(alignment: .leading) {
                Text(product.title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(product.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)

                Text("\(product.price, specifier: "%.2f") €")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.yellow)
            }
            .padding(.leading, 10)

            Spacer()

            // 🗑️ Çöp Kutusu Butonu
            Button(action: {
                onDelete() // Silme işlemi için closure tetikleniyor
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
