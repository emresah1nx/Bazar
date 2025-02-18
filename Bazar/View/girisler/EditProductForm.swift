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
                // 1) Kategori Seçimi Butonları
                VStack(alignment: .leading) {
                    Text("Kategori Seçin")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.leading)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                        ForEach(viewModel.categories, id: \.id) { category in
                            Button(action: {
                                selectedCategory = category
                                selectedSubcategory = nil
                                selectedDetail = nil
                                viewModel.fetchSubcategories(forCategoryId: category.id)
                            }) {
                                Text(category.name)
                                    .frame(width: 100, height: 40) // Sabit genişlik ve yükseklik
                                    .background(selectedCategory?.id == category.id ? Color.blue : Color.gray)
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal,5)
                }

                // 2) Alt Kategori Seçimi Butonları
                if let selectedCategory = selectedCategory {
                    VStack(alignment: .leading) {
                        Text("Alt Kategori Seçin")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.leading)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                            ForEach(viewModel.subcategories, id: \.id) { subcategory in
                                Button(action: {
                                    selectedSubcategory = subcategory
                                    selectedDetail = nil
                                    viewModel.fetchDetails(forCategoryId: selectedCategory.id, subcategoryId: subcategory.id)
                                }) {
                                    Text(subcategory.name)
                                        .frame(width: 100, height: 40) // Sabit genişlik ve yükseklik
                                        .background(selectedSubcategory?.id == subcategory.id ? Color.blue : Color.gray)
                                        .cornerRadius(8)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // 3) Detay Seçimi Butonları
                if let selectedSubcategory = selectedSubcategory {
                    VStack(alignment: .leading) {
                        Text("Detay Seçin")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.leading)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                            ForEach(viewModel.details, id: \.id) { detail in
                                Button(action: {
                                    selectedDetail = detail
                                }) {
                                    Text(detail.name)
                                        .frame(width: 100, height: 40) // Sabit genişlik ve yükseklik
                                        .background(selectedDetail?.id == detail.id ? Color.blue : Color.gray)
                                        .cornerRadius(8)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
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
