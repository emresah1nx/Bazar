import SwiftUI

struct KategoriAltPickerView<T: Identifiable & Hashable>: View {
    let title: String
    let items: [T?]
    
    /// Her item’ın ekranda gösterilecek ismini sağlayan closure
    let itemName: (T) -> String
    
    @Binding var selection: T?
    var onChange: ((T?) -> Void)?

    /// Nil olmayan değerleri tek seferde toplayarak derleyiciyi yormaktan kaçınıyoruz
    private var validItems: [T] {
        items.compactMap { $0 }
    }

    var body: some View {
        if validItems.isEmpty {
            EmptyView()
        } else {
            contentView
        }
    }

    /// Ana içerik
    private var contentView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                itemPicker
                    .padding()
                    .background(Color.yazıRenk1)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .padding(.horizontal, 10)
        }
        .frame(width: UIScreen.main.bounds.width)
    }

    /// Picker
    private var itemPicker: some View {
        Picker(title, selection: $selection) {
            ForEach(validItems, id: \.self) { item in
                pickerRow(for: item)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .onChange(of: selection) { newValue in
            onChange?(newValue)
        }
    }

    /// Picker’daki her bir satır
    private func pickerRow(for item: T) -> some View {
        Text(itemName(item)) // Artık .name yerine closure ile alıyoruz
            .padding()
            .background(selection?.id == item.id ? Color.yazıRenk1 : Color.clear)
            .cornerRadius(10)
            .foregroundColor(selection?.id == item.id ? .white : .gray)
            .tag(item as T?)
    }
}
