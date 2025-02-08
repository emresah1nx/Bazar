//
//  EditProductForm.swift
//  Bazar
//
//  Created by Emre Şahin on 30.01.2025.
//

import SwiftUI

struct EditProductForm: View {
    // Form Alanları
    @Binding var title: String
    @Binding var description: String
    @Binding var price: String
    
    // Resimler
    @Binding var selectedImages: [UIImage]
    @Binding var showImagePicker: Bool
    @Binding var isUploading: Bool
    
    // Kategori Seçimleri
    @Binding var selectedCategory: Kategori?
    @Binding var selectedSubcategory: SubKategori?
    @Binding var selectedDetail: Detailss?
    
    // ViewModel
    @ObservedObject var viewModel: KategoriViewModel
    
    // Focus
    @FocusState var focusedField: EditProductView.Field?
    
    // Kaydet Butonuna basıldığında yapılacak işlem
    let saveAction: () -> Void
    
    // MARK: Body
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 1) Kategori Picker
                KategoriAltPickerView(
                    title: "Kategori Seçin",
                    items: viewModel.categories.map { $0 as Kategori? },
                    itemName: { kategori in
                        kategori.name  // Kategori'nin hangi özelliğini gösterecekseniz
                    },
                    selection: $selectedCategory
                ) { category in
                    // onChange
                    if let category = category {
                        viewModel.fetchSubcategories(forCategoryId: category.id)
                    }
                }
                
                // 2) Alt Kategori Picker
                KategoriAltPickerView(
                    title: "Alt Kategori Seçin",
                    items: viewModel.subcategories.map { $0 as SubKategori? },
                    itemName: { subcat in
                        subcat.name
                    },
                    selection: $selectedSubcategory
                ) { subcategory in
                    if let subcategory = subcategory, let cat = selectedCategory {
                        viewModel.fetchDetails(forCategoryId: cat.id, subcategoryId: subcategory.id)
                    }
                }
                
                // 3) Detay Picker
                KategoriAltPickerView(
                    title: "Detay Seçin",
                    items: viewModel.details.map { $0 as Detailss? },
                    itemName: { detail in
                        detail.name
                    },
                    selection: $selectedDetail
                )
                
                // 4) İlan Başlığı
                TextField("", text: $title, prompt: Text("İlan Başlığı").foregroundColor(.white))
                    .focused($focusedField, equals: .title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .submitLabel(.next)
                    .font(.system(size: 26))
                
                // 5) İlan Açıklaması
                VStack(alignment: .leading) {
                    Text("Açıklama")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                    
                    TextEditor(text: $description)
                        .focused($focusedField, equals: .description)
                        .frame(height: 250)
                        .border(Color.gray, width: 1)
                }
                
                // 6) Fiyat
                TextField("", text: $price, prompt: Text("Fiyat").foregroundColor(.white))
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .price)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .submitLabel(.done)
                    .font(.system(size: 26))
                
                // 7) Resim Seç
                Button {
                    showImagePicker = true
                } label: {
                    Text("Resim Seç")
                        .font(.system(size: 20))
                        .padding()
                        .background(Color.yazıRenk1)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }
                .sheet(isPresented: $showImagePicker) {
                    // Kendi ImagePicker component’in
                    ImagePicker(selectedImage: $selectedImages)
                }
                
                // Seçilen Resimler
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(selectedImages.indices, id: \.self) { index in
                            Image(uiImage: selectedImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding(4)
                        }
                    }
                }
                
                // 8) Kaydet Butonu
                Button {
                    saveAction()
                } label: {
                    if isUploading {
                        ProgressView()
                    } else {
                        Text("Güncelle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.yazıRenk1)
                            .cornerRadius(8)
                    }
                }
                .disabled(isUploading || title.isEmpty || description.isEmpty || price.isEmpty)
            }
        }
    }
}
