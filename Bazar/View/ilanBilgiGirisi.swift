//
//  ilanBilgiGirisi.swift
//  Bazar
//
//  Created by Emre Şahin on 11.01.2025.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import PhotosUI
import FirebaseAuth
import FirebaseStorage

struct ilanBilgiGirisi: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var price: String = ""
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    @State private var isUploading = false
    @State private var alertMessage: String?
    @State private var showAlert = false
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case title, description, price
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Artı Butonu ile Resim Seçme
                HStack {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        Image(systemName: "photo.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                    }
                    
                    Text("Resim Seç")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .padding(.top)
                
                // Resim Seçim Ekranı
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(selectedImage: $selectedImages)
                }

                // Seçilen Resimlerin Önizlemesi
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(selectedImages.indices, id: \.self) { index in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: selectedImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding(4)
                                
                                Button(action: {
                                    // Resmi silme işlemi
                                    selectedImages.remove(at: index)
                                }) {
                                    Image(systemName: "x.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.red)
                                }
                                .padding(4)
                            }
                        }
                    }
                }

                // İlan Başlığı
                TextField("İlan Başlığı", text: $title)
                    .focused($focusedField, equals: .title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .submitLabel(.next)

                // Açıklama (TextEditor ile uzun açıklama girişi)
                Text("Açıklama")
                    .font(.headline)
                    .padding(.horizontal)

                TextEditor(text: $description)
                    .focused($focusedField, equals: .description)
                    .frame(height: 150) // Açıklama kısmı için yüksekliği ayarlıyoruz
                    .border(Color.gray, width: 1)
                    .padding(.horizontal)
                    .submitLabel(.next)
                
                // Fiyat
                TextField("Fiyat", text: $price)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .price)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .submitLabel(.done)
                
                // Kaydet Butonu
                Button(action: saveAd) {
                    if isUploading {
                        ProgressView()
                    } else {
                        Text("İlanı Kaydet")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .disabled(isUploading || title.isEmpty || description.isEmpty || price.isEmpty || selectedImages.isEmpty)
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Durum"), message: Text(alertMessage ?? ""), dismissButton: .default(Text("Tamam")))
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Klavyeyi Kapat") {
                        // Klavye kapanacak
                        focusedField = nil
                    }
                }
            }
        }
    }

    // Firestore'a İlan Kaydetme
    private func saveAd() {
        guard !selectedImages.isEmpty else {
            alertMessage = "Lütfen en az bir resim seçin."
            showAlert = true
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            alertMessage = "Lütfen giriş yapın."
            showAlert = true
            return
        }
        
        let db = Firestore.firestore()
        let storage = Storage.storage().reference()
        var imageURLs: [String] = []
        let dispatchGroup = DispatchGroup()
        
        isUploading = true
        
        // Seçilen her resmi yükleme
        for image in selectedImages {
            dispatchGroup.enter()
            
            guard let imageData = image.jpegData(compressionQuality: 0.7) else {
                dispatchGroup.leave()
                continue
            }
            
            let imageRef = storage.child("products/\(UUID().uuidString).jpg")
            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Resim yükleme hatası: \(error.localizedDescription)")
                    dispatchGroup.leave()
                    return
                }
                
                imageRef.downloadURL { url, error in
                    if let error = error {
                        print("URL alma hatası: \(error.localizedDescription)")
                    } else if let url = url {
                        imageURLs.append(url.absoluteString)
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        // Tüm yüklemeler tamamlandığında
        dispatchGroup.notify(queue: .main) {
            let adData: [String: Any] = [
                "title": self.title,
                "description": self.description,
                "price": Double(self.price) ?? 0.0,
                "foto": imageURLs,
                "uid": uid,
                "createdAt": Timestamp()
            ]
            
            db.collection("products").addDocument(data: adData) { error in
                isUploading = false
                
                if let error = error {
                    alertMessage = "İlan kaydetme hatası: \(error.localizedDescription)"
                } else {
                    alertMessage = "İlan başarıyla kaydedildi!"
                    clearForm()
                }
                showAlert = true
            }
        }
    }
    
    // Formu Temizleme
    private func clearForm() {
        title = ""
        description = ""
        price = ""
        selectedImages.removeAll()
    }
}
