import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

struct EditProductView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // İlan Modeli
    @Binding var product: Product // ✅ ProfileView ile senkronize olacak

    // Form Alanları
    @State private var title: String
    @State private var description: String
    @State private var price: String
    @State private var existingImages: [String] = []  // Firestore'daki mevcut resimler
    @State private var selectedImages: [UIImage] = [] // Yeni seçilen resimler
    
    // Resim Seçme ve Yükleme Durumu
    @State private var showImagePicker = false
    @State private var isUploading = false
    
    // Alert
    @State private var alertMessage: String?
    @State private var showAlert = false
    
    // Klavye Odaklanma
    @FocusState private var focusedField: Field?
    enum Field: Hashable {
        case title, description, price
    }
    
    // MARK: Init
    init(product: Binding<Product>) {
        self._product = product
        _title = State(initialValue: product.wrappedValue.title)
        _description = State(initialValue: product.wrappedValue.description)
        _price = State(initialValue: "\(product.wrappedValue.price)")
    }
    
    var body: some View {
        ScrollView {
            ZStack {
                Color.anaRenk2.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // 📝 Başlık
                    TextField("İlan Başlığı", text: $title)
                        .focused($focusedField, equals: .title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title2)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    
                    // 📝 Açıklama
                    TextEditor(text: $description)
                        .focused($focusedField, equals: .description)
                        .frame(height: 150)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.3), lineWidth: 1))
                    
                    // 💰 Fiyat
                    TextField("Fiyat", text: $price)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .price)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    
                    // 📸 Mevcut Resimler
                    Text("Mevcut Resimler")
                        .font(.headline)
                        .foregroundColor(.white)

                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(existingImages, id: \.self) { imageUrl in
                                ZStack(alignment: .topTrailing) {
                                    AsyncImage(url: URL(string: imageUrl)) { image in
                                        image.resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    
                                    // ❌ Resim Sil Butonu
                                    Button(action: { deleteImage(imageUrl) }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.red)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                    }
                                    .offset(x: -5, y: 5)
                                }
                            }
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 5)
                    }
                    
                    // 📷 Yeni Eklenen Resimler (Direkt UI'ya Yansıt)
                    Text("Yeni Eklenen Resimler")
                        .font(.headline)
                        .foregroundColor(.white)

                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(selectedImages.indices, id: \.self) { index in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: selectedImages[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    
                                    // ❌ Yeni eklenen resimleri sil
                                    Button(action: { selectedImages.remove(at: index) }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.red)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                    }
                                    .offset(x: -5, y: 5)
                                }
                            }
                        }
                    }
                    
                    // 📤 Resim Ekle Butonu
                    Button {
                        showImagePicker = true
                    } label: {
                        Text("Resim Seç")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(selectedImage: $selectedImages)
                    }
                    
                    // 💾 Güncelle Butonu
                    Button(action: updateProduct) {
                        if isUploading {
                            ProgressView()
                        } else {
                            Text("Güncelle")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(isUploading || title.isEmpty || description.isEmpty || price.isEmpty)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .background(LinearGradient(
            gradient: Gradient(colors: [Color.anaRenk1.opacity(0.7), Color.anaRenk2.opacity(0.9)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
        .navigationTitle("İlanı Düzenle")
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Bilgi"), message: Text(alertMessage ?? ""), dismissButton: .default(Text("Tamam")))
        }
        .onAppear {
            fetchProductDetails()
        }
    }
    
    // 📥 Firestore'dan En Güncel Veriyi Çek
    private func fetchProductDetails() {
        let db = Firestore.firestore()
        db.collection("products").document(product.id).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                DispatchQueue.main.async {
                    self.product = Product(
                        id: product.id,
                        title: data["title"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        price: data["price"] as? Double ?? 0.0,
                        imageUrls: data["foto"] as? [String] ?? [],
                        uid: data["uid"] as? String ?? "",
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue(),
                        altcategory: data["altcategory"] as? String ?? "",
                        tempCategory: data["tempCategory"] as? String ?? "",
                        marka: data["marka"] as? String ?? "",
                        model: data["model"] as? String ?? ""
                    )
                    existingImages = self.product.imageUrls
                }
            }
        }
    }

    
    // MARK: 🔥 Firestore Güncelleme
    private func updateProduct() {
        let db = Firestore.firestore()
        let productRef = db.collection("products").document(product.id)
        
        let priceValue = Double(price) ?? product.price
        var updatedData: [String: Any] = [
            "title": title,
            "description": description,
            "price": priceValue
        ]
        
        uploadImages { newImageURLs in
            updatedData["foto"] = existingImages + newImageURLs
            productRef.updateData(updatedData) { error in
                if let error = error {
                    alertMessage = "Hata: \(error.localizedDescription)"
                } else {
                    alertMessage = "İlan başarıyla güncellendi!"
                }
                showAlert = true
            }
        }
    }
    
    // 🗑 Resim Silme (Firestore'dan güncelleme)
    private func deleteImage(_ url: String) {
        existingImages.removeAll { $0 == url }
        Firestore.firestore().collection("products").document(product.id).updateData([
            "foto": existingImages
        ])
    }
    
    // 📤 Yeni Resim Yükleme
    private func uploadImages(completion: @escaping ([String]) -> Void) {
        var imageURLs: [String] = []
        let dispatchGroup = DispatchGroup()
        
        for image in selectedImages {
            dispatchGroup.enter()
            let imageRef = Storage.storage().reference().child("products/\(UUID().uuidString).jpg")
            
            guard let imageData = image.jpegData(compressionQuality: 0.7) else { continue }
            
            imageRef.putData(imageData, metadata: nil) { _, _ in
                imageRef.downloadURL { url, _ in
                    if let url = url {
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
}
