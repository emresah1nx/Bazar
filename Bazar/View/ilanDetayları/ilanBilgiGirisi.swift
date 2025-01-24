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
    @State private var text = ""
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    @State private var isUploading = false
    @State private var alertMessage: String?
    @State private var showAlert = false
    @State private var selectedCategory: kategori? // Kategori seçimi için eklenen state
    @FocusState private var focusedField: Field?

    @StateObject private var viewModel = kategoriViewModel() // Kategori ViewModel

    enum Field: Hashable {
        case title, description, price
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.anaRenk1.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // İlan Başlığı
                        TextField("", text: $title, prompt: Text("İlan Başlığı").foregroundColor(Color.white))
                            .focused($focusedField, equals: .title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .submitLabel(.next)
                            .font(.system(size: 26))

                        // Açıklama (TextEditor ile uzun açıklama girişi)
                        Text("Açıklama")
                            .font(.system(size: 24))
                            .padding(.horizontal)
                        
                        TextEditor(text: $description)
                            .focused($focusedField, equals: .description)
                            .frame(height: 300) // Açıklama kısmı için yüksekliği ayarlıyoruz
                            .border(Color.gray, width: 1)
                            .padding(.horizontal)
                            .submitLabel(.next)
                        
                        // Fiyat
                        TextField("", text: $price, prompt: Text("Fiyat").foregroundColor(Color.white))
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .price)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .submitLabel(.done)
                            .font(.system(size: 26))
                        
                        HStack {
                            Button(action: {
                                showImagePicker = true
                            }) {
                                Image(systemName: "photo.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 60, height: 60, alignment: .leading) // Button'ı sola yapıştır

                            Text("Resim Seç")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                                .onTapGesture {
                                    // Text'e tıklandığında butonun aksiyonunu tetikleyin
                                    showImagePicker = true
                                }
                        }
                        .padding() // HStack'in etrafında biraz boşluk bırakmak için
                        .background(Color.yazıRenk1) // Arka plan rengi
                        .cornerRadius(20) // Köşeleri yuvarla
                        .shadow(radius: 10) // Gölgelendirme ekleyebilirsiniz (isteğe bağlı)
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
                                            selectedImages.remove(at: index)
                                        }) {
                                            Image(systemName: "x.circle.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(.white)
                                                .background(Color.yazıRenk1)
                                        }
                                        .padding(4)
                                    }
                                }
                            }
                        }
                        
                        // Kaydet Butonu
                        Button(action: saveAd) {
                            if isUploading {
                                ProgressView()
                            } else {
                                Text("İlanı Kaydet")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.yazıRenk1)
                                    .cornerRadius(8)
                            }
                        }
                        .disabled(isUploading || title.isEmpty || description.isEmpty || price.isEmpty || selectedImages.isEmpty || selectedCategory == nil)
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding(.bottom, 100)
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
                    .background(Color.anaRenk2)
                }
                .onAppear {
                    viewModel.fetchCategories() // Kategorileri fetch et
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

        guard let categoryId = selectedCategory?.id else {
            alertMessage = "Lütfen bir kategori seçin."
            showAlert = true
            return
        }

        // Image upload task
        uploadImages { imageURLs in
            // Firestore data
            saveProductData(uid: uid, categoryId: categoryId, imageURLs: imageURLs)
        }
    }

    // Resimleri Firebase Storage'a Yükleme
    private func uploadImages(completion: @escaping ([String]) -> Void) {
        var imageURLs: [String] = []
        let dispatchGroup = DispatchGroup()

        isUploading = true
        for image in selectedImages {
            dispatchGroup.enter()
            guard let imageData = image.jpegData(compressionQuality: 0.7) else {
                dispatchGroup.leave()
                continue
            }

            let imageRef = Storage.storage().reference().child("products/\(UUID().uuidString).jpg")
            imageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("Resim yükleme hatası: \(error.localizedDescription)")
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

        dispatchGroup.notify(queue: .main) {
            completion(imageURLs)
        }
    }

    // Firestore'a İlan Kaydetme
    private func saveProductData(uid: String, categoryId: String, imageURLs: [String]) {
        let db = Firestore.firestore()
        let adData: [String: Any] = [
            "title": self.title,
            "description": self.description,
            "price": Double(self.price) ?? 0.0,
            "foto": imageURLs,
            "uid": uid,
            "tempCategory": categoryId, // Kategoriyi kaydet
            "createdAt": Timestamp()
        ]

        db.collection("products").addDocument(data: adData) { error in
            self.isUploading = false
            if let error = error {
                self.alertMessage = "İlan kaydetme hatası: \(error.localizedDescription)"
            } else {
                self.alertMessage = "İlan başarıyla kaydedildi!"
                clearForm()
            }
            self.showAlert = true
        }
    }

    // Formu Temizleme
    private func clearForm() {
        title = ""
        description = ""
        price = ""
        selectedImages.removeAll()
        selectedCategory = nil
    }
}

