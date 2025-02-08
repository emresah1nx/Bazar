import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

struct EditProductView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: Product & States
    @State var product: Product
    
    // Form alanları (title, description, price)
    @State private var title: String
    @State private var description: String
    @State private var price: String
    
    // Seçilen resimler
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    @State private var isUploading = false
    
    // Kategori, alt kategori, detay
    @State private var selectedCategory: Kategori?
    @State private var selectedSubcategory: SubKategori?
    @State private var selectedDetail: Detailss?
    
    // ViewModel
    @StateObject private var viewModel = KategoriViewModel()
    
    // Alert
    @State private var alertMessage: String?
    @State private var showAlert = false
    
    // Focus (klavye)
    @FocusState private var focusedField: Field?
    enum Field: Hashable {
        case title, description, price
    }
    
    // MARK: Init
    init(product: Product) {
        self.product = product
        _title = State(initialValue: product.title)
        _description = State(initialValue: product.description)
        _price = State(initialValue: "\(product.price)")
    }
    
    // MARK: Body
    var body: some View {
        ZStack {
            // Gradient Arkaplan
            LinearGradient(
                gradient: Gradient(colors: [Color.orange.opacity(0.7), Color.pink.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            // ScrollView + Form Bileşenleri
            EditProductForm(
                title: $title,
                description: $description,
                price: $price,
                selectedImages: $selectedImages,
                showImagePicker: $showImagePicker,
                isUploading: $isUploading,
                selectedCategory: $selectedCategory,
                selectedSubcategory: $selectedSubcategory,
                selectedDetail: $selectedDetail,
                viewModel: viewModel,
                focusedField: _focusedField
            ) {
                // Kaydet butonuna basınca yapılacak işlem
                updateProduct()
            }
            .padding()
            .onAppear {
                // Kategorileri yükle
                viewModel.fetchCategories()
            }
            .toolbar {
                // Klavye kapatma butonu
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Klavyeyi Kapat") {
                        focusedField = nil
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Durum"),
                    message: Text(alertMessage ?? ""),
                    dismissButton: .default(Text("Tamam")) {
                        // Alert kapandığında geri dönmek istersen:
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
        .navigationTitle("İlanı Düzenle")
        .navigationBarItems(trailing: Button("Kapat") {
            presentationMode.wrappedValue.dismiss()
        })
    }
}

// MARK: - Firestore İşlemleri
extension EditProductView {
    private func updateProduct() {
        let db = Firestore.firestore()
        let productRef = db.collection("products").document(product.id)
        
        let priceValue = Double(price) ?? product.price
        
        // 1) Metin alanlarını güncelle
        productRef.updateData([
            "title": title,
            "description": description,
            "price": priceValue
        ]) { error in
            if let error = error {
                alertMessage = "Güncelleme hatası: \(error.localizedDescription)"
                showAlert = true
            } else {
                // 2) Yeni resimler varsa, Storage’a yükleyip Firestore’daki "foto" dizisini güncelle
                if !selectedImages.isEmpty {
                    uploadImages { newImageURLs in
                        productRef.updateData(["foto": newImageURLs]) { error2 in
                            if let error2 = error2 {
                                alertMessage = "Resimler kaydedilirken hata: \(error2.localizedDescription)"
                            } else {
                                alertMessage = "Güncelleme başarılı!"
                            }
                            showAlert = true
                        }
                    }
                } else {
                    // Resim seçilmemişse sadece metin güncellenir
                    alertMessage = "Güncelleme başarılı!"
                    showAlert = true
                }
            }
        }
    }
    
    // Yeni resimleri Firebase Storage’a yükle
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
                
                imageRef.downloadURL { url, _ in
                    if let url = url {
                        imageURLs.append(url.absoluteString)
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            isUploading = false
            completion(imageURLs)
        }
    }
}
